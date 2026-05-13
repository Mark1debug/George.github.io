# Study State Tracker

A minimal local-first tool to track and analyze your learning state — combining mouse activity, self-evaluations, and AI-driven inference.

The premise: your focus and energy are real things you can measure, but they're hard to evaluate without data. This tool aggregates passive signals (mouse activity) and active signals (you tapping a 2D plane that means "current state of motivation × energy") and lets Claude make sense of both.

## What it does

- **`mouse_tracker.py`** runs in the Windows background, listening to OS-level mouse events (position, clicks, scrolls) and aggregating per-30-second windows into `mouse_log.jsonl`. Also serves the log over `http://127.0.0.1:9876` and exposes a `/analyze` endpoint that pipes prompts through `claude -p` for AI inference.
- **`study-state-tracker.html`** is a single-file SPA that visualizes the data, lets you log self-evaluations on a 2D motivation × energy plane, label specific activities ("背诵默写", "看笔记", …) to build a personal dictionary for the AI, and trigger Claude-powered state analysis.

It supports two AI paths:

1. **Local Claude Code CLI** (uses your Claude Max subscription, no API cost) — preferred
2. **Direct Anthropic API** (browser → api.anthropic.com with your API key) — fallback

When you open the HTML inside Anthropic Cowork (artifact mode), it uses Cowork's `askClaude` inline.

## Privacy

- ❌ No screen capture
- ❌ No keystroke logging
- ❌ No app/window tracking
- ❌ No outbound network traffic except optional AI calls
- ✅ All data stays in `mouse_log.jsonl` next to the script
- ✅ Self-evaluations and activity labels live in browser `localStorage`

Inspect the source — it's two small files plus shell wrappers. Nothing fancy.

## Quick Start (Windows)

1. Clone or download into `C:\Users\<you>\Documents\StudyTracker\` (recommended) or any folder.
2. Install Python 3.10+ from https://python.org (tick "Add Python to PATH").
3. Double-click `install.bat` → press Y → wait for "Done!".

   The installer will:
   - install `pynput` via pip (the only Python dependency)
   - create a Windows Startup VBS that launches the tracker silently on every login
   - launch the tracker immediately so you don't have to reboot

4. Open `study-state-tracker.html` in your browser (right-click → Open with → Edge/Chrome).
   - You'll see a green banner: "独立模式 · 自动同步已启用"
   - Data refreshes every 5 minutes from the local HTTP server

5. (Optional) For AI analysis:
   - **If you have Claude Code installed (`claude --version` works)**: nothing else to do. Click "AI 分析" and the local Python proxies the request through `claude -p` using your Max subscription.
   - **Otherwise**: click "设置 API Key" in the green banner, paste an `sk-ant-…` key from https://console.anthropic.com. Costs ~$0.005 per analysis.

## Daily use

- Tracker runs invisibly in the background (`pythonw.exe`)
- Open the HTML tab whenever you want to see your day; data is fresh ≤5 min old
- Click the 2D plane to log a self-evaluation; optionally fill "实际坚持 X 分钟 / 专注有效 X% / 休息有效 X%" for personal calibration
- Label time ranges (5 min / 15 min / 30 min / 1 hr) with activity types to teach the AI your personal mouse-pattern → activity mapping
- Click "AI 分析" any time you want a synthesized read of your current state

## Stopping / uninstalling

- Temporary stop: `stop_tracker.bat`
- Remove autostart and stop: `uninstall.bat`
- Delete the folder: yourself

## Architecture

```
mouse_tracker.py
    pynput Listener                 -> per-30s flush -> mouse_log.jsonl
    HTTP server on 127.0.0.1:9876
        GET  /mouse_log.jsonl       -> the log
        GET  /health                -> "ok"
        POST /analyze {prompt:...}  -> subprocess: claude -p

study-state-tracker.html
    auto fetch /mouse_log.jsonl every 5 min  -> redraw charts
    2D plane click                            -> motivation/energy in localStorage
    activity labels                           -> in localStorage (AI dictionary)
    "AI 分析" button                          -> POST /analyze  OR
                                                fetch api.anthropic.com  OR
                                                window.cowork.askClaude (Cowork only)
```

## File map

| File | Purpose |
|---|---|
| `mouse_tracker.py` | Core: mouse listener + HTTP server |
| `study-state-tracker.html` | Single-file web UI |
| `install.bat` | One-time installer (calls install.py) |
| `install.py` | Python installer: deps + autostart + start |
| `start_tracker.bat` | Visible console launch (debugging) |
| `start_background.bat` | Silent pythonw launch |
| `stop_tracker.bat` | Write STOP_TRACKER signal file |
| `uninstall.bat` | Remove autostart entry + stop tracker |
| `create_shortcut.bat` | Create a desktop shortcut to the web UI |

## Caveats

- Windows-only for now (uses .bat wrappers and pythonw.exe). Core Python script is OS-agnostic; porting the launchers to macOS/Linux is straightforward.
- The "expected focus minutes" formula is a generic baseline; if your real focus capacity is very different (e.g. short-burst ADHD-style attention), use the "实际坚持" field to log ground truth — over time the gap is informative.
- AI analysis quality depends on how many activity labels you've taught it. Start with 10-20 clear labels of distinct activities.

## License

MIT. Use, fork, modify freely.

## Notes

Originally built one evening with Claude in Anthropic Cowork. Not affiliated with Anthropic.
