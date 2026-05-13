用Claude制作的一个专注程度小工具，我总是不好判断自己的专注状态，所以试着做了一个小工具来帮我记录我的专注程度以便我决定什么时候该休息了
完全没有自己敲一个代码，所以 可能有很多不合理的地方
自己用了一天，感觉还不错，等考试完可能会更新一下它

"""
Mouse activity tracker for the study-state-tracker artifact.

Listens to mouse events at OS level (position, clicks, scrolls).
Aggregates per-window stats and appends each row to mouse_log.jsonl.

Also runs a tiny HTTP server on 127.0.0.1:9876:
  GET  /mouse_log.jsonl  -> serves the log file
  GET  /health           -> "ok"
  POST /analyze          -> body {"prompt": "..."} -> runs `claude -p`, returns text

Does NOT capture screen, keystrokes, app names, or anything else.
"""

import json
import math
import os
import shutil
import subprocess
import sys
import threading
import time
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler
from pynput import mouse

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
LOG_PATH = os.path.join(SCRIPT_DIR, "mouse_log.jsonl")
STOP_FILE = os.path.join(SCRIPT_DIR, "STOP_TRACKER")
WINDOW_SECONDS = 30
IDLE_THRESHOLD_SEC = 1.0
HTTP_PORT = 9876


class _LogHandler(BaseHTTPRequestHandler):
    def _cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "*")
        self.send_header("Cache-Control", "no-cache")

    def do_OPTIONS(self):
        self.send_response(204)
        self._cors()
        self.end_headers()

    def do_GET(self):
        if self.path == "/mouse_log.jsonl":
            try:
                with open(LOG_PATH, "rb") as f:
                    data = f.read()
            except OSError:
                data = b""
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self._cors()
            self.end_headers()
            self.wfile.write(data)
        elif self.path == "/health":
            self.send_response(200)
            self._cors()
            self.end_headers()
            self.wfile.write(b"ok")
        else:
            self.send_response(404)
            self._cors()
            self.end_headers()

    def do_POST(self):
        if self.path != "/analyze":
            self.send_response(404)
            self._cors()
            self.end_headers()
            return
        try:
            length = int(self.headers.get("Content-Length", "0"))
            body = self.rfile.read(length).decode("utf-8") if length else "{}"
            data = json.loads(body)
            prompt = data.get("prompt", "")
            if not prompt:
                self.send_response(400)
                self._cors()
                self.end_headers()
                self.wfile.write(b"missing prompt")
                return
            cli = shutil.which("claude") or shutil.which("claude.cmd") or shutil.which("claude.exe")
            if not cli:
                self.send_response(500)
                self._cors()
                self.end_headers()
                self.wfile.write(b"claude CLI not found on PATH")
                return
            # Suppress console window on Windows
            kw = {}
            if os.name == "nt":
                CREATE_NO_WINDOW = 0x08000000
                kw["creationflags"] = CREATE_NO_WINDOW
            # Pass prompt as command-line arg so CLI definitely treats it as non-interactive
            proc = subprocess.run(
                [cli, "-p", prompt],
                capture_output=True,
                text=True,
                timeout=120,
                encoding="utf-8",
                errors="replace",
                **kw,
            )
            if proc.returncode != 0:
                self.send_response(500)
                self.send_header("Content-Type", "text/plain; charset=utf-8")
                self._cors()
                self.end_headers()
                err = (proc.stderr or "")[:500] or f"exit {proc.returncode}"
                self.wfile.write(f"claude CLI failed: {err}".encode("utf-8"))
                return
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self._cors()
            self.end_headers()
            self.wfile.write((proc.stdout or "").encode("utf-8"))
        except subprocess.TimeoutExpired:
            self.send_response(504)
            self._cors()
            self.end_headers()
            self.wfile.write(b"claude CLI timeout (>120s)")
        except Exception as e:
            self.send_response(500)
            self._cors()
            self.end_headers()
            self.wfile.write(f"error: {e}".encode("utf-8"))

    def log_message(self, fmt, *args):
        pass


def start_http_server():
    try:
        srv = HTTPServer(("127.0.0.1", HTTP_PORT), _LogHandler)
        t = threading.Thread(target=srv.serve_forever, daemon=True)
        t.start()
        return srv
    except OSError as e:
        print(f"HTTP server failed to start on :{HTTP_PORT}: {e}")
        return None


class Tracker:
    def __init__(self):
        self.reset()
        self.last_pos = None
        self.last_event_time = None

    def reset(self):
        self.window_start = time.time()
        self.distance_px = 0.0
        self.move_samples = 0
        self.speeds = []
        self.click_count = 0
        self.scroll_count = 0
        self.direction_changes = 0
        self.idle_seconds = 0.0
        self.last_dx = 0.0
        self.last_dy = 0.0

    def _account_gap(self, now):
        if self.last_event_time is None:
            return
        gap = now - self.last_event_time
        if gap > IDLE_THRESHOLD_SEC:
            self.idle_seconds += gap - IDLE_THRESHOLD_SEC

    def on_move(self, x, y):
        now = time.time()
        self._account_gap(now)
        if self.last_pos is not None:
            dx = x - self.last_pos[0]
            dy = y - self.last_pos[1]
            dist = math.hypot(dx, dy)
            if dist > 0:
                self.distance_px += dist
                self.move_samples += 1
                if self.last_event_time is not None:
                    dt = now - self.last_event_time
                    if 0.001 < dt < IDLE_THRESHOLD_SEC:
                        self.speeds.append(dist / dt)
                if dist > 5 and (dx * self.last_dx + dy * self.last_dy) < 0:
                    self.direction_changes += 1
                self.last_dx, self.last_dy = dx, dy
        self.last_pos = (x, y)
        self.last_event_time = now

    def on_click(self, x, y, button, pressed):
        now = time.time()
        self._account_gap(now)
        if pressed:
            self.click_count += 1
        self.last_event_time = now

    def on_scroll(self, x, y, dx, dy):
        now = time.time()
        self._account_gap(now)
        self.scroll_count += 1
        self.last_event_time = now

    def flush(self):
        now = time.time()
        if self.last_event_time is not None:
            tail = now - self.last_event_time
            if tail > IDLE_THRESHOLD_SEC:
                self.idle_seconds += tail - IDLE_THRESHOLD_SEC
        window_sec = max(1.0, now - self.window_start)
        avg_speed = sum(self.speeds) / len(self.speeds) if self.speeds else 0.0
        if len(self.speeds) > 1:
            mean = avg_speed
            var = sum((s - mean) ** 2 for s in self.speeds) / len(self.speeds)
            jerkiness = math.sqrt(var)
        else:
            jerkiness = 0.0
        row = {
            "ts": int(now * 1000),
            "iso_local": datetime.now().isoformat(timespec="seconds"),
            "window_sec": round(window_sec, 1),
            "distance_px": round(self.distance_px, 1),
            "avg_speed": round(avg_speed, 1),
            "jerkiness": round(jerkiness, 1),
            "clicks": self.click_count,
            "scrolls": self.scroll_count,
            "direction_changes": self.direction_changes,
            "idle_sec": round(self.idle_seconds, 1),
            "active_ratio": round(max(0.0, 1.0 - self.idle_seconds / window_sec), 3),
            "move_samples": self.move_samples,
        }
        try:
            with open(LOG_PATH, "a", encoding="utf-8") as f:
                f.write(json.dumps(row, ensure_ascii=False) + "\n")
        except OSError as e:
            print(f"write failed: {e}")
        ts = datetime.now().strftime("%H:%M:%S")
        print(
            f"[{ts}] dist={row['distance_px']:.0f}px clicks={row['clicks']} "
            f"scrolls={row['scrolls']} idle={row['idle_sec']:.0f}s "
            f"active={row['active_ratio']:.0%}"
        )
        self.reset()


def main():
    try:
        if os.path.exists(STOP_FILE):
            os.remove(STOP_FILE)
    except OSError:
        pass

    print("=" * 60)
    print(" Mouse activity tracker")
    print("=" * 60)
    print(f" Log file : {LOG_PATH}")
    print(f" Window   : {WINDOW_SECONDS}s")
    print(" Privacy  : mouse only, no screen/keys/app names")
    print(" Stop     : Ctrl+C, close window, or stop_tracker.bat")
    print("=" * 60)

    srv = start_http_server()
    if srv:
        print(f" HTTP API : http://127.0.0.1:{HTTP_PORT}/mouse_log.jsonl")
        print(f" Analyze  : POST http://127.0.0.1:{HTTP_PORT}/analyze (uses `claude` CLI)")
    print()

    tracker = Tracker()
    listener = mouse.Listener(
        on_move=tracker.on_move,
        on_click=tracker.on_click,
        on_scroll=tracker.on_scroll,
    )
    listener.start()

    def shutdown(reason):
        print(f"\n{reason}, flushing final window...")
        try:
            tracker.flush()
        except Exception as e:
            print(f"flush failed: {e}")
        try:
            listener.stop()
        except Exception:
            pass
        try:
            if os.path.exists(STOP_FILE):
                os.remove(STOP_FILE)
        except OSError:
            pass
        print("Done.")

    try:
        while True:
            for _ in range(WINDOW_SECONDS):
                time.sleep(1)
                if os.path.exists(STOP_FILE):
                    shutdown("Stop signal received")
                    return
            tracker.flush()
    except KeyboardInterrupt:
        shutdown("Interrupted")


if __name__ == "__main__":
    try:
        main()
    except ImportError as e:
        print(f"ERROR: missing dependency: {e}")
        print("Run:  pip install pynput")
        sys.exit(1)
