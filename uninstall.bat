<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<title>学习状态记录</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.5.0/dist/chart.umd.js" integrity="sha384-iU8HYtnGQ8Cy4zl7gbNMOhsDTTKX02BTXptVP/vqAWIaTfM7isw76iyZCsjL2eVi" crossorigin="anonymous"></script>
<style>
:root{color-scheme:light}*{box-sizing:border-box;margin:0;padding:0}
body{font-family:-apple-system,"PingFang SC","Microsoft YaHei",sans-serif;background:#f4f1e9;color:#2a2a2a;line-height:1.55;padding:16px}
.layout{max-width:980px;margin:0 auto;display:grid;grid-template-columns:1fr;gap:14px}
@media(min-width:760px){.layout{grid-template-columns:minmax(0,1fr) minmax(0,1fr)}.full-row{grid-column:1/-1}}
.card{background:#fff;border-radius:14px;padding:16px;box-shadow:0 1px 3px rgba(0,0,0,0.04);min-width:0}
.card-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:12px;gap:10px}
.card-header h2{font-size:15px;font-weight:600;color:#333;margin:0}
h1{font-size:22px;font-weight:600;color:#1f1f1f;margin-bottom:4px}
.page-subtitle{font-size:12px;color:#888}
button{font:inherit;padding:7px 14px;border:1px solid #d6d1c0;background:#fff;border-radius:8px;cursor:pointer;color:#333;transition:background .15s}
button:hover:not(:disabled){background:#faf6e8}
button:disabled{opacity:.4;cursor:not-allowed}
button.primary{background:#4a6b4a;border-color:#3d5b3d;color:#fff}
button.primary:hover:not(:disabled){background:#3d5b3d}
button.danger{border-color:#c08080;color:#a04040}
button.danger:hover:not(:disabled){background:#fbeaea}
button.small{padding:4px 10px;font-size:12px}
button.icon-btn{padding:2px 8px;color:#aaa;border:none;background:transparent;font-size:16px}
button.icon-btn:hover{color:#a04040;background:transparent}
.plane-wrap{position:relative;aspect-ratio:1/1;width:100%;max-width:320px;margin:0 auto}
.plane{position:absolute;inset:0;border:1px solid #ddd6c4;border-radius:8px;background:radial-gradient(circle at 75% 25%,rgba(95,160,95,.10),transparent 60%),radial-gradient(circle at 25% 75%,rgba(192,132,84,.10),transparent 60%),#fdfcf7;cursor:crosshair;overflow:hidden;user-select:none;outline:none}
.plane:focus{box-shadow:0 0 0 2px rgba(95,160,95,.3)}
.axis{position:absolute;background:#d5cfb8;pointer-events:none}
.axis-x{left:0;right:0;top:50%;height:1px}
.axis-y{top:0;bottom:0;left:50%;width:1px}
.plane-label{position:absolute;font-size:10px;color:#8a8a82;pointer-events:none;font-weight:500}
.plane-label.top{top:8px;left:50%;transform:translateX(-50%)}
.plane-label.bottom{bottom:8px;left:50%;transform:translateX(-50%)}
.plane-label.left{left:8px;top:50%;transform:translateY(-50%)}
.plane-label.right{right:8px;top:50%;transform:translateY(-50%)}
.dot{position:absolute;width:9px;height:9px;border-radius:50%;background:#c5b8a0;transform:translate(-50%,-50%);opacity:.5;pointer-events:none}
.dot.preview{background:#c08454;border:2px dashed #a06030;width:14px;height:14px;opacity:.8;box-sizing:content-box}
.dot.last{background:#5fa05f;opacity:.95;width:11px;height:11px}
.plane-hint{text-align:center;font-size:11px;color:#999;margin-top:8px}
.preview-strip{background:#faf6e8;border:1px dashed #d4c89a;border-radius:10px;padding:10px 12px;margin-top:12px;display:none}
.preview-strip.active{display:block}
.preview-row{display:flex;align-items:center;gap:6px;flex-wrap:wrap;margin-bottom:6px}
.chip{font-size:11.5px;padding:2px 9px;border-radius:11px;background:#ede5cc;color:#5a4d1e}
.chip.energy{background:#d8e3cf;color:#3d5a3d}
.chip.focus{background:#dadde8;color:#303060;font-weight:600}
.preview-note{width:100%;border:1px solid #d4cba5;border-radius:6px;padding:5px 8px;font:inherit;font-size:13px;background:#fff;resize:vertical;min-height:36px;margin-top:6px;outline:none}
.preview-note:focus{border-color:#b09a5e}
.preview-actions{display:flex;gap:6px;margin-top:8px}
.tracker-status{display:flex;align-items:center;gap:10px;padding:10px 12px;background:#faf6e8;border:1px solid #ede5cc;border-radius:8px;margin-bottom:10px}
.tracker-dot{width:10px;height:10px;border-radius:50%;background:#b0b0b0;flex-shrink:0}
.tracker-dot.running{background:#5fa05f;box-shadow:0 0 0 4px rgba(95,160,95,.20);animation:pulse 2s infinite}
@keyframes pulse{0%,100%{box-shadow:0 0 0 4px rgba(95,160,95,.20)}50%{box-shadow:0 0 0 6px rgba(95,160,95,.05)}}
.tracker-text{font-size:13px;color:#333;flex:1;min-width:0}
.tracker-text .sub{font-size:11px;color:#888;display:block;margin-top:2px}
.btn-row{display:flex;gap:6px;margin-bottom:12px;flex-wrap:wrap}
.setup-hint{background:#fbf3dd;border:1px dashed #d4b06a;border-radius:8px;padding:10px 12px;font-size:11.5px;color:#5a4d1e;margin-bottom:10px;line-height:1.65}
.setup-hint code{background:#fff;padding:1px 5px;border-radius:3px;border:1px solid #e0d3a3;font-size:11px;font-family:ui-monospace,Consolas,monospace}
.metrics-mini{display:grid;grid-template-columns:repeat(2,1fr);gap:6px;margin-bottom:10px}
.metric-mini{background:#faf7ef;border:1px solid #ede5cc;border-radius:6px;padding:6px 9px}
.metric-mini .lab{color:#8a7e5c;font-size:10px;text-transform:uppercase;letter-spacing:.4px}
.metric-mini .val{color:#4a3f1e;font-weight:600;font-size:14px;margin-top:1px}
.ai-result{background:#f6f1e6;border:1px solid #d4c89a;border-radius:8px;padding:10px 12px;font-size:12.5px;color:#4a3f1e;white-space:pre-wrap;line-height:1.65;margin-top:8px;display:none;max-height:280px;overflow-y:auto}
.ai-result.active{display:block}
.ai-result.loading{font-style:italic;color:#8a7a4a}
.day-nav{display:flex;align-items:center;gap:6px;font-size:13px;color:#555}
.day-nav button{padding:3px 10px;font-size:13px}
.day-nav .label{min-width:130px;text-align:center;font-weight:500}
.day-summary{display:flex;gap:18px;margin-bottom:8px;font-size:12px;color:#666;flex-wrap:wrap}
.day-summary .stat{display:flex;flex-direction:column}
.day-summary .stat .num{font-size:17px;font-weight:600;color:#2a2a2a}
.day-summary .stat .lab{font-size:10px;color:#999;text-transform:uppercase;letter-spacing:.4px}
.chart-section-title{font-size:10.5px;color:#888;text-transform:uppercase;letter-spacing:.6px;margin:18px 0 4px;font-weight:600}
.chart-area{position:relative;height:200px}
.chart-area.short{height:130px}
.chart-empty{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;color:#b0b0a0;font-size:12px;pointer-events:none}
.chart-empty.hidden{display:none}
.entries{border-top:1px solid #efeadb;padding-top:12px;margin-top:16px}
.entries h3{font-size:11px;color:#888;text-transform:uppercase;letter-spacing:.5px;margin-bottom:6px;font-weight:600}
.entry-row{display:grid;grid-template-columns:60px 1fr auto;gap:12px;padding:8px 0;border-bottom:1px solid #f5f1e2;align-items:start;font-size:13px}
.entry-row:last-child{border-bottom:none}
.entry-time{font-size:12px;color:#888;padding-top:2px}
.entry-body{min-width:0}
.entry-chips{display:flex;gap:5px;flex-wrap:wrap;margin-bottom:3px}
.entry-note{font-size:12px;color:#6b6b6b;word-break:break-word}
.empty{text-align:center;color:#b0a890;font-size:13px;padding:22px 0}
.label-section-title{font-size:10.5px;color:#888;text-transform:uppercase;letter-spacing:.5px;margin:10px 0 5px;font-weight:600}
.label-btn{padding:4px 11px;font-size:12px;border-radius:13px;border:1px solid #d6d1c0;background:#fff;cursor:pointer;color:#444;transition:background .15s}
.label-btn:hover{background:#faf6e8}
.label-btn.active{background:#4a6b4a;border-color:#3d5b3d;color:#fff}
.label-btn-group{display:flex;gap:5px;flex-wrap:wrap;align-items:center}
.label-custom-input{padding:4px 9px;font-size:12px;border:1px solid #d6d1c0;border-radius:13px;min-width:140px;font:inherit;outline:none}
.label-custom-input:focus{border-color:#b09a5e}
.label-note-input{width:100%;padding:6px 10px;font-size:12.5px;border:1px solid #d6d1c0;border-radius:6px;margin-top:8px;font:inherit;outline:none;box-sizing:border-box}
.label-note-input:focus{border-color:#b09a5e}
.label-actions{display:flex;gap:6px;margin-top:10px}
.label-history{margin-top:12px;border-top:1px solid #efeadb;padding-top:10px;max-height:240px;overflow-y:auto}
.label-history-row{display:grid;grid-template-columns:115px 1fr auto;gap:10px;padding:5px 0;font-size:12.5px;align-items:center;border-bottom:1px solid #f5f1e2}
.label-history-row:last-child{border-bottom:none}
.label-history-row .time{color:#888;font-size:11px}
.label-history-row .what{color:#3d5b3d;font-weight:500}
.label-history-row .note{color:#888;font-size:11px}
.label-intro{font-size:12px;color:#888;margin-bottom:10px;line-height:1.55}
.import-zone{border:2px dashed #d4c89a;border-radius:8px;padding:16px 14px;text-align:center;cursor:pointer;background:#faf6e8;margin-bottom:10px;transition:background .2s}
.import-zone:hover,.import-zone.dragover{background:#f4ecc8;border-color:#b09a5e}
.import-text{font-size:13px;color:#5a4d1e;font-weight:500}
.import-sub{font-size:11px;color:#888;margin-top:4px}
.import-zone code{background:#fff;padding:1px 6px;border-radius:3px;border:1px solid #e0d3a3;font-size:11px;font-family:ui-monospace,Consolas,monospace}
.import-status{font-size:12px;color:#666;margin-bottom:10px;padding:6px 10px;background:#f7f3e6;border-radius:6px;border:1px solid #efe6c8}
.import-status.ok{background:#e8f0e0;border-color:#b8d0a8;color:#3d5b3d}
</style>
</head>
<body>
<div class="layout">
<div class="full-row">
<h1>学习状态记录</h1>
<div class="page-subtitle">点击坐标记录此刻 · 方向键调节 · Enter 保存 · 鼠标活动后台自动采集</div>
</div>
<div class="card">
<div class="card-header"><h2>记录当下</h2></div>
<div class="plane-wrap"><div class="plane" id="plane" tabindex="0">
<div class="axis axis-x"></div><div class="axis axis-y"></div>
<div class="plane-label top">休息好了 ↑</div>
<div class="plane-label bottom">↓ 疲惫</div>
<div class="plane-label left">消沉 ←</div>
<div class="plane-label right">→ 斗志昂扬</div>
</div></div>
<div class="plane-hint">点击 / 方向键调节 · Shift+方向键大步 · Enter 保存 · Esc 取消</div>
<div class="preview-strip" id="preview">
<div class="preview-row" id="previewVals"></div>
<div class="preview-row" id="previewPredict"></div>
<div class="preview-row" style="font-size:12px;color:#5a4d1e;align-items:center;gap:4px;flex-wrap:wrap">
<span>实际坚持</span>
<input type="number" id="actualFocusInput" min="0" max="300" step="1" placeholder="—" style="width:50px;padding:3px 6px;font:inherit;font-size:12px;border:1px solid #d4cba5;border-radius:4px;background:#fff">
<span>分</span>
<span style="margin-left:10px">· 专注有效</span>
<input type="number" id="focusEffInput" min="0" max="100" step="5" placeholder="—" style="width:48px;padding:3px 6px;font:inherit;font-size:12px;border:1px solid #d4cba5;border-radius:4px;background:#fff">
<span>%</span>
<span style="margin-left:10px">· 休息有效</span>
<input type="number" id="restEffInput" min="0" max="100" step="5" placeholder="—" style="width:48px;padding:3px 6px;font:inherit;font-size:12px;border:1px solid #d4cba5;border-radius:4px;background:#fff">
<span>%</span>
</div>
<div class="preview-row" style="font-size:10.5px;color:#999;margin-top:-2px">
听歌学 ≈ 50-70%，焦虑下学 ≈ 5%，休息好+静音学 ≈ 95%；不学填休息有效（睡饱 90%、刷手机 20%）
</div>
<textarea class="preview-note" id="noteInput" placeholder="备注（可选）..."></textarea>
<div class="preview-actions">
<button class="primary small" id="saveBtn">保存</button>
<button class="small" id="cancelBtn">取消</button>
</div>
</div>
</div>
<div class="card">
<div class="card-header"><h2>鼠标数据 · AI 分析</h2></div>
<div class="import-zone" id="importZone">
<input type="file" id="fileInput" accept=".jsonl,.json,.txt,application/json" style="display:none">
<div class="import-text">点击或拖入 <code>mouse_log.jsonl</code></div>
<div class="import-sub">文件在 <code>Documents\StudyTracker\</code> 里 · 想看最新数据时再拖一次</div>
</div>
<div class="import-status" id="importStatus">尚未导入数据</div>
<div class="btn-row">
<button class="small" id="clearMouseBtn" disabled>清空</button>
<button class="primary small" id="analyzeBtn" disabled>🤖 快速分析（Haiku）</button>
<button class="small" id="askClaudeBtn">💬 让对话里的 Claude 详细分析</button>
</div>
<div class="metrics-mini" id="metricsMini"></div>
<div class="ai-result" id="aiResult"></div>
</div>
<div class="card full-row">
<div class="card-header"><h2>活动标注 — 教 AI 你的鼠标模式</h2></div>
<div class="label-intro">刚做完一段特征明显的事？给它打个标签 —— 比如"刚才 5 分钟我在背诵默写"。这些标注会作为"用户专属字典"喂给 AI，让它学会**你的**鼠标活动 ↔ 实际行为的对应关系。攒上 10-20 条之后，AI 推断会准确很多。</div>
<div class="label-section-title">这段时间范围</div>
<div class="label-btn-group" id="rangeButtons">
<button class="label-btn" data-range="5">刚才 5 分钟</button>
<button class="label-btn" data-range="15">15 分钟</button>
<button class="label-btn" data-range="30">30 分钟</button>
<button class="label-btn" data-range="60">1 小时</button>
</div>
<div class="label-section-title">这段在做什么</div>
<div class="label-btn-group" id="whatButtons">
<button class="label-btn" data-what="背诵默写">背诵默写</button>
<button class="label-btn" data-what="看笔记">看笔记</button>
<button class="label-btn" data-what="写作业做题">写作业做题</button>
<button class="label-btn" data-what="听课看视频">听课看视频</button>
<button class="label-btn" data-what="放松娱乐">放松娱乐</button>
<button class="label-btn" data-what="离开/玩手机">离开/玩手机</button>
<input class="label-custom-input" id="customWhat" placeholder="或自定义...">
</div>
<input class="label-note-input" id="labelNote" placeholder="可选备注（比如：高数第3章复习 / 写英语作文）">
<div class="label-actions">
<button class="primary small" id="saveLabelBtn" disabled>保存标注</button>
<button class="small" id="cancelLabelBtn">清空</button>
</div>
<div class="label-history" id="labelHistory"></div>
</div>

<div class="card full-row">
<div class="card-header"><h2>今日学习曲线</h2><div class="day-nav">
<button id="prevDay">‹</button><span class="label" id="dayLabel">—</span><button id="nextDay">›</button>
<button class="small" id="todayBtn">回到今日</button>
</div></div>
<div class="day-summary" id="daySummary"></div>
<div class="chart-section-title">预计专注分钟（动力 × 精力 的结果）</div>
<div class="chart-area"><canvas id="focusChart"></canvas><div class="chart-empty hidden" id="focusEmpty">尚无自评数据</div></div>
<div class="chart-section-title">动力（橙）· 精力（蓝）</div>
<div class="chart-area short"><canvas id="dualChart"></canvas></div>
<div class="chart-section-title">鼠标活跃度</div>
<div class="chart-area short"><canvas id="mouseChart"></canvas><div class="chart-empty hidden" id="mouseEmpty">这一天没有鼠标数据</div></div>
<div class="entries"><h3>这一天的自评</h3><div id="entriesList"></div></div>
</div>
</div>
<script>
(function(){
const KEY='study_state_log_v1';
const load=()=>{try{return JSON.parse(localStorage.getItem(KEY)||'[]')}catch(e){return[]}};
const save=e=>localStorage.setItem(KEY,JSON.stringify(e));
const pad2=n=>String(n).padStart(2,'0');
const fmtTime=ts=>{const d=new Date(ts);return pad2(d.getHours())+':'+pad2(d.getMinutes())};
const fmtDay=d=>`${d.getMonth()+1}月${d.getDate()}日 ${['周日','周一','周二','周三','周四','周五','周六'][d.getDay()]}`;
const clamp=(v,lo,hi)=>Math.max(lo,Math.min(hi,v));
const predict=(m,e)=>{const a=(m+100)/200,b=(e+100)/200,p=a*b;return{focusMin:Math.round(10+110*p),efficiency:Math.round(p*100)}};

// Infer (motivation, energy) from a single mouse window's stats.
// Heuristic, intended as a starting point — user's self-reports refine it.
function inferState(row){
  const dist=row.distance_px||0;
  const clicks=row.clicks||0;
  const scrolls=row.scrolls||0;
  const idle=row.idle_sec||0;
  const active=row.active_ratio||0;
  const jerk=row.jerkiness||0;
  // Fully absent → no inference
  if(active<0.05&&idle>25&&dist<100)return{motivation:null,energy:null};
  // Energy: rooted in active_ratio, penalize high jerkiness (fatigue/jitter)
  let energy=Math.round(active*130-30);
  if(jerk>1000)energy-=Math.round(Math.min(25,(jerk-1000)/80));
  energy=Math.max(-100,Math.min(100,energy));
  // Motivation: clicks vs scrolls ratio + overall activity
  let motivation;
  const opRatio=clicks/Math.max(1,clicks+scrolls); // 1=all clicks, 0=all scrolls
  if(scrolls+clicks<2) motivation=active>0.3?20:-20;
  else if(scrolls>8&&opRatio<0.3) motivation=-30-Math.min(30,scrolls);
  else if(clicks>4&&opRatio>0.5) motivation=30+Math.min(40,clicks*3);
  else motivation=Math.round((opRatio-0.3)*100+active*20);
  motivation=Math.max(-100,Math.min(100,motivation));
  return{motivation,energy};
}
const esc=s=>String(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
let currentDay=new Date();currentDay.setHours(0,0,0,0);
let pending=null,mouseRows=[],charts={focus:null,dual:null,mouse:null};
const $=id=>document.getElementById(id);
const plane=$('plane'),preview=$('preview'),previewVals=$('previewVals'),previewPredict=$('previewPredict'),noteInput=$('noteInput');
const saveBtn=$('saveBtn'),cancelBtn=$('cancelBtn');
const analyzeBtn=$('analyzeBtn');
const metricsMini=$('metricsMini'),aiResult=$('aiResult');
const prevDayBtn=$('prevDay'),nextDayBtn=$('nextDay'),todayBtn=$('todayBtn'),dayLabel=$('dayLabel'),daySummary=$('daySummary'),entriesList=$('entriesList');
const focusEmpty=$('focusEmpty'),mouseEmpty=$('mouseEmpty');

function setPending(m,e){
m=clamp(Math.round(m),-100,100);e=clamp(Math.round(e),-100,100);
pending={motivation:m,energy:e};
const p=predict(m,e);
previewVals.innerHTML='<span class="chip">动力 '+(m>0?'+':'')+m+'</span><span class="chip energy">精力 '+(e>0?'+':'')+e+'</span>';
previewPredict.innerHTML='<span class="chip focus">预计可专注 '+p.focusMin+' 分钟（效率 '+p.efficiency+'%）</span>';
preview.classList.add('active');renderPlaneDots();
}
function clearPending(){pending=null;noteInput.value='';['actualFocusInput','focusEffInput','restEffInput'].forEach(id=>{const el=document.getElementById(id);if(el)el.value=''});preview.classList.remove('active');renderPlaneDots()}
function renderPlaneDots(){
plane.querySelectorAll('.dot').forEach(d=>d.remove());
const today=load().filter(e=>new Date(e.ts).toDateString()===new Date().toDateString()).slice(-10);
today.forEach((e,i,arr)=>{const d=document.createElement('div');d.className='dot'+(i===arr.length-1?' last':'');d.style.left=((e.motivation+100)/2)+'%';d.style.top=(100-(e.energy+100)/2)+'%';if(i!==arr.length-1)d.style.opacity=(.15+.45*(i/Math.max(1,arr.length-1))).toFixed(2);plane.appendChild(d)});
if(pending){const d=document.createElement('div');d.className='dot preview';d.style.left=((pending.motivation+100)/2)+'%';d.style.top=(100-(pending.energy+100)/2)+'%';plane.appendChild(d)}
}
plane.addEventListener('click',ev=>{const r=plane.getBoundingClientRect();setPending(((ev.clientX-r.left)/r.width)*200-100,100-((ev.clientY-r.top)/r.height)*200);plane.focus()});
plane.addEventListener('keydown',ev=>{
const step=ev.shiftKey?20:5;
if(!pending&&['ArrowUp','ArrowDown','ArrowLeft','ArrowRight'].includes(ev.key)){ev.preventDefault();setPending(0,0);return}
let h=true;
switch(ev.key){
case'ArrowUp':setPending(pending.motivation,pending.energy+step);break;
case'ArrowDown':setPending(pending.motivation,pending.energy-step);break;
case'ArrowLeft':setPending(pending.motivation-step,pending.energy);break;
case'ArrowRight':setPending(pending.motivation+step,pending.energy);break;
case'Enter':doSave();break;
case'Escape':clearPending();break;
default:h=false;
}
if(h)ev.preventDefault();
});
noteInput.addEventListener('keydown',ev=>{
if(ev.key==='Escape'){ev.preventDefault();clearPending();plane.focus()}
if(ev.key==='Enter'&&(ev.ctrlKey||ev.metaKey)){ev.preventDefault();doSave()}
});
function parsePct(id){
  const v=document.getElementById(id).value;
  if(!v)return null;
  return Math.max(0,Math.min(100,parseInt(v)));
}
function doSave(){
if(!pending)return;
const entries=load();
const actualRaw=document.getElementById('actualFocusInput').value;
const actualMin=actualRaw?Math.max(0,Math.min(300,parseInt(actualRaw))):null;
entries.push({
  id:Date.now().toString(36)+Math.random().toString(36).slice(2,6),
  ts:Date.now(),
  motivation:pending.motivation,
  energy:pending.energy,
  note:noteInput.value.trim(),
  actualFocusMin:actualMin,
  focusEff:parsePct('focusEffInput'),
  restEff:parsePct('restEffInput'),
  source:'self'
});
save(entries);clearPending();renderTimeline();
}
saveBtn.addEventListener('click',doSave);
cancelBtn.addEventListener('click',clearPending);

function updateDayLabel(){
const t=new Date();t.setHours(0,0,0,0);
dayLabel.textContent=(currentDay.getTime()===t.getTime()?'今天 · ':'')+fmtDay(currentDay);
}
prevDayBtn.addEventListener('click',()=>{currentDay.setDate(currentDay.getDate()-1);updateDayLabel();renderTimeline()});
nextDayBtn.addEventListener('click',()=>{currentDay.setDate(currentDay.getDate()+1);updateDayLabel();renderTimeline()});
todayBtn.addEventListener('click',()=>{currentDay=new Date();currentDay.setHours(0,0,0,0);updateDayLabel();renderTimeline()});

function dayBounds(){const s=currentDay.getTime();return[s,s+86400000]}
function interp(s,t,k){
if(!s.length)return null;
if(t<s[0].ts)return null;
const last=s[s.length-1];
if(t>last.ts)return(t-last.ts<1800000)?last[k]:null;
for(let i=0;i<s.length-1;i++){if(t>=s[i].ts&&t<=s[i+1].ts){const sp=s[i+1].ts-s[i].ts;if(!sp)return s[i][k];const f=(t-s[i].ts)/sp;return s[i][k]+f*(s[i+1][k]-s[i][k])}}
return null;
}

function renderTimeline(){
const b=dayBounds(),start=b[0],end=b[1];
const all=load().filter(e=>e.ts>=start&&e.ts<end).sort((a,b)=>a.ts-b.ts);
const mds=mouseRows.filter(r=>r.ts>=start&&r.ts<end);
if(!all.length){daySummary.innerHTML='<span style="color:#999">这一天还没有自评记录</span>'}
else{
const aM=Math.round(all.reduce((s,e)=>s+e.motivation,0)/all.length);
const aE=Math.round(all.reduce((s,e)=>s+e.energy,0)/all.length);
const aF=Math.round(all.reduce((s,e)=>s+predict(e.motivation,e.energy).efficiency,0)/all.length);
const tF=all.reduce((s,e)=>s+predict(e.motivation,e.energy).focusMin,0);
daySummary.innerHTML='<div class="stat"><span class="num">'+all.length+'</span><span class="lab">自评次数</span></div>'+
'<div class="stat"><span class="num">'+(aM>0?'+':'')+aM+'</span><span class="lab">平均动力</span></div>'+
'<div class="stat"><span class="num">'+(aE>0?'+':'')+aE+'</span><span class="lab">平均精力</span></div>'+
'<div class="stat"><span class="num">'+aF+'%</span><span class="lab">平均效率</span></div>'+
'<div class="stat"><span class="num">'+(tF/60).toFixed(1)+'h</span><span class="lab">预计专注总量</span></div>';
}
drawCharts(all,mds,start,end);drawEntries(all);
}

function drawCharts(entries,mouseData,start,end){
const labels=[],stamps=[];
for(let t=start;t<=end;t+=600000){const d=new Date(t);labels.push(pad2(d.getHours())+':'+pad2(d.getMinutes()));stamps.push(t)}
const samples=entries.map(e=>({ts:e.ts,m:e.motivation,e:e.energy,focus:predict(e.motivation,e.energy).focusMin}));
const focusSeries=stamps.map(t=>interp(samples,t,'focus'));
const motSeries=stamps.map(t=>interp(samples,t,'m'));
const engSeries=stamps.map(t=>interp(samples,t,'e'));
const snap=ts=>Math.round((ts-start)/600000);
const scatter=new Array(labels.length).fill(null);
const actualScatter=new Array(labels.length).fill(null);
entries.forEach(e=>{
  const i=snap(e.ts);
  if(i>=0&&i<scatter.length)scatter[i]=predict(e.motivation,e.energy).focusMin;
  if(i>=0&&i<actualScatter.length&&e.actualFocusMin!=null)actualScatter[i]=e.actualFocusMin;
});
// Build inferred series from mouse data, aggregated to the same 10-min slots
const inferBucket={};
mouseData.forEach(r=>{
  const i=snap(r.ts);
  if(i<0||i>=labels.length)return;
  const s=inferState(r);
  if(s.motivation===null)return;
  if(!inferBucket[i])inferBucket[i]={m:0,e:0,n:0};
  inferBucket[i].m+=s.motivation;
  inferBucket[i].e+=s.energy;
  inferBucket[i].n++;
});
const inferMotSeries=labels.map((_,i)=>{const b=inferBucket[i];return b?Math.round(b.m/b.n):null});
const inferEngSeries=labels.map((_,i)=>{const b=inferBucket[i];return b?Math.round(b.e/b.n):null});
const inferFocusSeries=labels.map((_,i)=>{
  const m=inferMotSeries[i],e=inferEngSeries[i];
  if(m===null||e===null)return null;
  return predict(m,e).focusMin;
});

focusEmpty.classList.toggle('hidden',entries.length>0||mouseData.length>0);
mouseEmpty.classList.toggle('hidden',mouseData.length>0);
const hourTick={font:{size:10},autoSkip:false,callback:function(v){const l=this.getLabelForValue(v);return(l.endsWith(':00')&&parseInt(l.split(':')[0])%2===0)?l:''},maxRotation:0};
const baseOpts=function(o){return{responsive:true,maintainAspectRatio:false,interaction:{mode:'index',intersect:false},plugins:{legend:{labels:{boxWidth:10,font:{size:11}}}},scales:{y:{min:o.yMin,max:o.yMax,position:'right',ticks:{stepSize:o.step,font:{size:10}},grid:{color:'#f0ede0'}},x:{ticks:hourTick,grid:{display:false}}}}};
if(charts.focus)charts.focus.destroy();
charts.focus=new Chart($('focusChart'),{type:'line',data:{labels:labels,datasets:[{label:'推测专注（鼠标）',data:inferFocusSeries,borderColor:'#a8c8a8',backgroundColor:'rgba(168,200,168,.15)',fill:'origin',tension:.35,spanGaps:false,pointRadius:0,borderWidth:1.2,borderDash:[4,3]},{label:'预计专注分钟（自评）',data:focusSeries,borderColor:'#3d5b3d',backgroundColor:'rgba(95,160,95,.20)',fill:false,tension:.35,spanGaps:false,pointRadius:0,borderWidth:2},{label:'自评（预测）',data:scatter,showLine:false,pointRadius:5,pointBackgroundColor:'#3d5b3d',pointBorderColor:'#fff',pointBorderWidth:1.5},{label:'实际坚持',data:actualScatter,showLine:false,pointRadius:6,pointStyle:'triangle',pointBackgroundColor:'#a06030',pointBorderColor:'#fff',pointBorderWidth:1.5}]},options:baseOpts({yMin:0,yMax:120,step:30})});
if(charts.dual)charts.dual.destroy();
charts.dual=new Chart($('dualChart'),{type:'line',data:{labels:labels,datasets:[{label:'推测动力（鼠标）',data:inferMotSeries,borderColor:'#e0bda0',fill:false,tension:.35,spanGaps:false,pointRadius:0,borderWidth:1.2,borderDash:[3,3]},{label:'推测精力（鼠标）',data:inferEngSeries,borderColor:'#a0b8d0',fill:false,tension:.35,spanGaps:false,pointRadius:0,borderWidth:1.2,borderDash:[3,3]},{label:'动力（自评）',data:motSeries,borderColor:'#c08454',fill:false,tension:.35,spanGaps:false,pointRadius:0,borderWidth:2},{label:'精力（自评）',data:engSeries,borderColor:'#5878a0',fill:false,tension:.35,spanGaps:false,pointRadius:0,borderWidth:2,borderDash:[4,3]}]},options:baseOpts({yMin:-100,yMax:100,step:50})});
if(charts.mouse)charts.mouse.destroy();
if(mouseData.length){
const dist=new Array(labels.length).fill(null),clicks=new Array(labels.length).fill(null);
mouseData.forEach(r=>{const i=snap(r.ts);if(i>=0&&i<dist.length){dist[i]=(dist[i]||0)+(r.distance_px||0);clicks[i]=(clicks[i]||0)+(r.clicks||0)}});
charts.mouse=new Chart($('mouseChart'),{type:'line',data:{labels:labels,datasets:[{label:'移动 (px)',data:dist,borderColor:'#7a8d6d',backgroundColor:'rgba(122,141,109,.18)',fill:'origin',tension:.3,spanGaps:true,pointRadius:0,borderWidth:1.5,yAxisID:'y'},{label:'点击',data:clicks,borderColor:'#c08454',tension:.3,spanGaps:true,pointRadius:0,borderWidth:1,borderDash:[3,3],yAxisID:'y1'}]},options:{responsive:true,maintainAspectRatio:false,interaction:{mode:'index',intersect:false},plugins:{legend:{labels:{boxWidth:8,font:{size:10}}}},scales:{y:{position:'right',ticks:{font:{size:10}},grid:{color:'#f0ede0'},beginAtZero:true},y1:{position:'left',ticks:{font:{size:10}},grid:{display:false},beginAtZero:true},x:{ticks:hourTick,grid:{display:false}}}}});
}
}

function drawEntries(entries){
if(!entries.length){entriesList.innerHTML='<div class="empty">这一天还没有自评</div>';return}
entriesList.innerHTML='';
entries.slice().reverse().forEach(e=>{
const p=predict(e.motivation,e.energy);
const r=document.createElement('div');r.className='entry-row';
const actualChip=(e.actualFocusMin!=null)?'<span class="chip" style="background:#f5d8b0;color:#704020">实际 '+e.actualFocusMin+' min</span>':'';
const focusEffChip=(e.focusEff!=null)?'<span class="chip" style="background:#dfead0;color:#3d5b3d">专注 '+e.focusEff+'%</span>':'';
const restEffChip=(e.restEff!=null)?'<span class="chip" style="background:#d8e0f0;color:#303060">休息 '+e.restEff+'%</span>':'';
r.innerHTML='<div class="entry-time">'+fmtTime(e.ts)+'</div>'+
'<div class="entry-body"><div class="entry-chips">'+
'<span class="chip">动力 '+(e.motivation>0?'+':'')+e.motivation+'</span>'+
'<span class="chip energy">精力 '+(e.energy>0?'+':'')+e.energy+'</span>'+
'<span class="chip focus">预测 '+p.focusMin+' min</span>'+
actualChip+focusEffChip+restEffChip+
'</div>'+(e.note?'<div class="entry-note">'+esc(e.note)+'</div>':'')+'</div>'+
'<button class="icon-btn" data-id="'+e.id+'" title="删除">×</button>';
entriesList.appendChild(r);
});
}
entriesList.addEventListener('click',ev=>{const b=ev.target.closest('button[data-id]');if(!b)return;if(!confirm('删除这条记录？'))return;save(load().filter(e=>e.id!==b.dataset.id));renderTimeline();renderPlaneDots()});

// ============ Activity labels ============
const LABELS_KEY='study_state_labels_v1';
const loadLabels=()=>{try{return JSON.parse(localStorage.getItem(LABELS_KEY)||'[]')}catch(e){return[]}};
const saveLabels=arr=>localStorage.setItem(LABELS_KEY,JSON.stringify(arr));
let labelPick={rangeMin:null,what:null};

function bindBtnGroup(containerId, key){
  document.querySelectorAll('#'+containerId+' .label-btn').forEach(btn=>{
    btn.addEventListener('click',()=>{
      document.querySelectorAll('#'+containerId+' .label-btn').forEach(b=>b.classList.remove('active'));
      btn.classList.add('active');
      labelPick[key] = key==='rangeMin' ? parseInt(btn.dataset.range) : btn.dataset.what;
      if(key==='what') document.getElementById('customWhat').value='';
      updateSaveLabelBtn();
    });
  });
}
bindBtnGroup('rangeButtons','rangeMin');
bindBtnGroup('whatButtons','what');

document.getElementById('customWhat').addEventListener('input',e=>{
  const v=e.target.value.trim();
  if(v){
    document.querySelectorAll('#whatButtons .label-btn').forEach(b=>b.classList.remove('active'));
    labelPick.what=v;
  } else {
    labelPick.what=null;
  }
  updateSaveLabelBtn();
});

function updateSaveLabelBtn(){
  document.getElementById('saveLabelBtn').disabled = !(labelPick.rangeMin && labelPick.what);
}

function clearLabelPick(){
  document.querySelectorAll('.label-btn.active').forEach(b=>b.classList.remove('active'));
  document.getElementById('customWhat').value='';
  document.getElementById('labelNote').value='';
  labelPick={rangeMin:null,what:null};
  updateSaveLabelBtn();
}

document.getElementById('saveLabelBtn').addEventListener('click',()=>{
  if(!labelPick.rangeMin||!labelPick.what)return;
  const end=Date.now();
  const start=end-labelPick.rangeMin*60000;
  const labels=loadLabels();
  labels.push({
    id:Date.now().toString(36)+Math.random().toString(36).slice(2,6),
    start,end,
    what:labelPick.what,
    note:document.getElementById('labelNote').value.trim(),
    created:Date.now()
  });
  saveLabels(labels);
  clearLabelPick();
  renderLabelHistory();
});

document.getElementById('cancelLabelBtn').addEventListener('click',clearLabelPick);

function renderLabelHistory(){
  const box=document.getElementById('labelHistory');
  const labels=loadLabels().slice(-15).reverse();
  if(!labels.length){
    box.innerHTML='<div style="color:#aaa;font-size:12px;text-align:center;padding:10px 0">还没标注。点上面的按钮试试。</div>';
    return;
  }
  let html='<div class="label-section-title">最近 '+labels.length+' 条标注（喂给 AI）</div>';
  labels.forEach(l=>{
    const s=new Date(l.start),e=new Date(l.end);
    const range=pad2(s.getHours())+':'+pad2(s.getMinutes())+'–'+pad2(e.getHours())+':'+pad2(e.getMinutes());
    html+='<div class="label-history-row"><span class="time">'+range+'</span><span><span class="what">'+esc(l.what)+'</span>'+(l.note?' <span class="note">· '+esc(l.note)+'</span>':'')+'</span><button class="icon-btn" data-label-id="'+l.id+'">×</button></div>';
  });
  box.innerHTML=html;
}

document.getElementById('labelHistory').addEventListener('click',ev=>{
  const b=ev.target.closest('button[data-label-id]');
  if(!b)return;
  if(!confirm('删除这条标注？'))return;
  saveLabels(loadLabels().filter(l=>l.id!==b.dataset.labelId));
  renderLabelHistory();
});

function labelMouseSummary(label){
  const inRange=mouseRows.filter(r=>r.ts>=label.start&&r.ts<=label.end);
  if(!inRange.length) return null;
  const sum=(k)=>inRange.reduce((s,r)=>s+(r[k]||0),0);
  const avg=(k)=>inRange.reduce((s,r)=>s+(r[k]||0),0)/inRange.length;
  return {
    what:label.what,
    note:label.note,
    duration_min:Math.round((label.end-label.start)/60000),
    samples:inRange.length,
    avg_dist_per_window:Math.round(avg('distance_px')),
    total_clicks:sum('clicks'),
    total_scrolls:sum('scrolls'),
    total_idle_sec:Math.round(sum('idle_sec')),
    avg_active_ratio:Math.round(avg('active_ratio')*100)/100,
    avg_jerkiness:Math.round(avg('jerkiness'))
  };
}

renderLabelHistory();

// === Mouse data: imported via file upload (artifact's bash MCP is disabled) ===
const MOUSE_KEY='study_mouse_data_v1';
const loadMouseLocal=()=>{try{return JSON.parse(localStorage.getItem(MOUSE_KEY)||'[]')}catch(e){return[]}};
const saveMouseLocal=rows=>localStorage.setItem(MOUSE_KEY,JSON.stringify(rows));
const importZone=$('importZone');
const fileInput=$('fileInput');
const importStatus=$('importStatus');
const clearMouseBtn=$('clearMouseBtn');

async function ingestFile(file){
  if(!file)return;
  try{
    const text=await file.text();
    const lines=text.split('\n').map(s=>s.trim()).filter(Boolean);
    const rows=[];
    for(const ln of lines){try{rows.push(JSON.parse(ln))}catch(e){}}
    if(!rows.length){
      importStatus.classList.remove('ok');
      importStatus.textContent='文件读到了但没解析出有效行（共 '+lines.length+' 行）';
      return;
    }
    mouseRows=rows;
    saveMouseLocal(rows);
    updateMouseStatus();
    renderMouseMetrics();
    renderTimeline();
  }catch(e){
    importStatus.classList.remove('ok');
    importStatus.textContent='读取失败：'+(e.message||e);
  }
}

function updateMouseStatus(){
  if(!mouseRows.length){
    importStatus.classList.remove('ok');
    importStatus.textContent='尚未导入数据';
    analyzeBtn.disabled=true;clearMouseBtn.disabled=true;
    return;
  }
  const last=mouseRows[mouseRows.length-1];
  const first=mouseRows[0];
  const lastT=new Date(last.ts).toLocaleTimeString('zh-CN',{hour:'2-digit',minute:'2-digit'});
  const firstT=new Date(first.ts).toLocaleTimeString('zh-CN',{hour:'2-digit',minute:'2-digit'});
  const ageMin=Math.round((Date.now()-last.ts)/60000);
  importStatus.classList.add('ok');
  // Color the age based on staleness
  const ageColor=ageMin<5?'#3d5b3d':(ageMin<15?'#a08030':'#a04040');
  const ageText=(ageMin<1?'刚才':ageMin+' 分钟前');
  let auto='';
  if(httpSyncOK)auto=' · 🌐 HTTP 自动同步';
  importStatus.innerHTML='✓ 已导入 <strong>'+mouseRows.length+'</strong> 条 · 范围 '+firstT+'–'+lastT+' · 最新 <span style="color:'+ageColor+';font-weight:600">'+ageText+'</span>'+auto;
  if(ageMin>=10&&!httpSyncOK){
    importStatus.innerHTML+='<br><span style="font-size:11px;color:#a08030">⚠ 数据较旧，把 mouse_log.jsonl 再拖进来一次以刷新（拖完会自动跑一次分析）</span>';
  }
  analyzeBtn.disabled=false;clearMouseBtn.disabled=false;
}

let fileHandle=null;
let autoSyncTimer=null;

async function pickFileSmartly(){
  if(window.showOpenFilePicker){
    try{
      const [h]=await window.showOpenFilePicker({
        types:[{description:'mouse_log.jsonl',accept:{'application/json':['.jsonl','.json','.txt']}}],
        multiple:false
      });
      fileHandle=h;
      const file=await h.getFile();
      await ingestFile(file);
      startAutoSync();
      return;
    }catch(e){
      if(e.name==='AbortError')return;
      console.warn('File System Access failed:',e);
    }
  }
  fileInput.click();
}

function startAutoSync(){
  if(autoSyncTimer)clearInterval(autoSyncTimer);
  if(!fileHandle)return;
  autoSyncTimer=setInterval(async()=>{
    try{
      const file=await fileHandle.getFile();
      await ingestFile(file);
    }catch(e){
      console.warn('auto-sync failed:',e);
      stopAutoSync();
      updateMouseStatus();
    }
  },30000);
  updateMouseStatus();
}

function stopAutoSync(){
  if(autoSyncTimer){clearInterval(autoSyncTimer);autoSyncTimer=null}
}

importZone.addEventListener('click',pickFileSmartly);
fileInput.addEventListener('change',e=>{if(e.target.files[0])ingestFile(e.target.files[0])});
['dragover','dragenter'].forEach(ev=>importZone.addEventListener(ev,e=>{e.preventDefault();importZone.classList.add('dragover')}));
['dragleave','drop'].forEach(ev=>importZone.addEventListener(ev,e=>{e.preventDefault();importZone.classList.remove('dragover')}));
importZone.addEventListener('drop',e=>{if(e.dataTransfer.files[0])ingestFile(e.dataTransfer.files[0])});
clearMouseBtn.addEventListener('click',()=>{
  if(!confirm('清空导入的鼠标数据并停止自动同步？'))return;
  stopAutoSync();fileHandle=null;httpSyncOK=false;
  if(httpSyncTimer){clearInterval(httpSyncTimer);httpSyncTimer=null}
  mouseRows=[];saveMouseLocal([]);
  updateMouseStatus();renderMouseMetrics();renderTimeline();
});

// === HTTP-based auto-sync from local Python HTTP server ===
const HTTP_URL='http://127.0.0.1:9876/mouse_log.jsonl';
let httpSyncTimer=null;
let httpSyncOK=false;
window._httpDiag='not tried yet';

async function tryHttpFetch(){
  try{
    const r=await fetch(HTTP_URL,{cache:'no-store',mode:'cors'});
    if(!r.ok){window._httpDiag='HTTP '+r.status;return false}
    const text=await r.text();
    const lines=text.split('\n').map(s=>s.trim()).filter(Boolean);
    const rows=[];
    for(const ln of lines){try{rows.push(JSON.parse(ln))}catch(e){}}
    if(!rows.length){window._httpDiag='fetched but parsed 0 rows from '+lines.length+' lines';return false}
    mouseRows=rows;
    saveMouseLocal(rows);
    window._httpDiag='OK';
    updateMouseStatus();renderMouseMetrics();renderTimeline();
    // Auto-analysis disabled by user — they'll click 快速分析 when they want it
    return true;
  }catch(e){
    window._httpDiag=(e.name||'Error')+': '+(e.message||String(e));
    return false;
  }
}

let httpFailCount=0;
async function tryStartHttpSync(){
  const ok=await tryHttpFetch();
  if(ok){
    httpSyncOK=true;httpFailCount=0;
    if(httpSyncTimer)clearInterval(httpSyncTimer);
    httpSyncTimer=setInterval(tryHttpFetch,300000); // 5 min
    updateMouseStatus();
  }else{
    httpSyncOK=false;
    httpFailCount++;
    updateMouseStatus();
    // Give up after 3 attempts — Cowork iframe permanently blocks fetch
    if(httpFailCount<3)setTimeout(tryStartHttpSync,30000);
  }
}

function renderMouseMetrics(){
if(!mouseRows.length){metricsMini.innerHTML='';return}
const tail=mouseRows.slice(-20);
const dist=tail.reduce((s,r)=>s+(r.distance_px||0),0);
const clicks=tail.reduce((s,r)=>s+(r.clicks||0),0);
const scrolls=tail.reduce((s,r)=>s+(r.scrolls||0),0);
const active=tail.reduce((s,r)=>s+(r.active_ratio||0),0)/tail.length;
metricsMini.innerHTML='<div class="metric-mini"><div class="lab">近10分钟移动</div><div class="val">'+Math.round(dist).toLocaleString()+' px</div></div>'+
'<div class="metric-mini"><div class="lab">点击</div><div class="val">'+clicks+'</div></div>'+
'<div class="metric-mini"><div class="lab">滚动</div><div class="val">'+scrolls+'</div></div>'+
'<div class="metric-mini"><div class="lab">活跃比例</div><div class="val">'+Math.round(active*100)+'%</div></div>';
}

// "Ask Claude in chat" button — uses sendPrompt to bounce the request to the conversation
const askClaudeBtn=$('askClaudeBtn');
askClaudeBtn.addEventListener('click',()=>{
  if(typeof window.sendPrompt!=='function'){
    alert('sendPrompt 不可用。请直接在对话里告诉 Claude "帮我分析最近的鼠标数据"');
    return;
  }
  const labels=loadLabels().slice(-15);
  const reports=load().slice(-5).map(e=>({time:new Date(e.ts).toLocaleString('zh-CN'),motivation:e.motivation,energy:e.energy,note:e.note||''}));
  let msg='请帮我分析最近的鼠标活动状态。\n\n';
  msg+='**步骤：**\n';
  msg+='1. 用 bash 读取 `/sessions/*/mnt/Documents/StudyTracker/mouse_log.jsonl` 拿最新数据\n';
  msg+='2. 看最近 20-30 分钟的窗口（每 30 秒一条）\n';
  msg+='3. 结合下面的活动标注字典推断我当下在做什么\n';
  msg+='4. 给出 A 活动类型 / B 动力 -100~+100 / C 精力 -100~+100 / D 建议\n\n';
  if(labels.length){
    msg+='**我的活动标注字典（重点参考）：**\n```json\n'+JSON.stringify(labels,null,1)+'\n```\n\n';
  }else{
    msg+='（我还没做活动标注，请按通用规则推断）\n\n';
  }
  if(reports.length){
    msg+='**最近自评：**\n```json\n'+JSON.stringify(reports,null,1)+'\n```\n\n';
  }
  msg+='当前时间：'+new Date().toLocaleString('zh-CN');
  window.sendPrompt(msg);
});

let lastAnalyzedTs=0;
let analysisInFlight=false;

async function runAnalysis(triggerLabel){
  if(!mouseRows.length||analysisInFlight)return;
  // Skip if we've already analyzed this exact dataset
  const newestTs=mouseRows[mouseRows.length-1].ts;
  if(newestTs===lastAnalyzedTs&&triggerLabel!=='manual')return;
  analysisInFlight=true;
  aiResult.classList.add('active','loading');
  aiResult.textContent=(triggerLabel==='auto'?'⏱ 5 分钟自动分析中…':'AI 分析中…');
  analyzeBtn.disabled=true;
  try{
    const recent=mouseRows.slice(-20);
    const reports=load().slice(-5).map(e=>({time:new Date(e.ts).toLocaleString('zh-CN'),motivation:e.motivation,energy:e.energy,note:e.note||'',actualFocusMin:e.actualFocusMin}));
    const dict=loadLabels().map(labelMouseSummary).filter(Boolean);
    const prompt='你是学习状态分析助手。下面有三块信息：(1) 用户当下约 10 分钟的鼠标数据；(2) 用户**亲自标注过**的历史活动 — 这是他的"鼠标模式 → 实际做什么"个人字典，**重点参考**；(3) 最近的状态自评。\n\n请按顺序输出（中文、简短、不用 markdown 标题）：\nA. 当下在做什么活动（先和用户字典里的模式做匹配；匹配不到再用通用思路）\nB. 推断动力：-100 到 +100 + 一句话理由\nC. 推断精力：-100 到 +100 + 一句话理由\nD. 建议：1-2 句\n\n通用 fallback：\n- dist 低 + idle 高 → 离开/走神\n- 操作密集 + jerkiness 高 → 可能浏览娱乐\n- 移动平稳 + 点击适中 → 专注阅读/编辑\n\n==== 当下鼠标 ====\n'+JSON.stringify(recent)+'\n\n==== 用户字典 ====\n'+JSON.stringify(dict)+'\n\n==== 最近自评 ====\n'+JSON.stringify(reports);
    let t;
    if(isStandalone){
      // Try Claude Code via local Python first (free, uses Max subscription)
      try{
        t=await callClaudeCodeLocal(prompt);
      }catch(localErr){
        // Fall back to direct Anthropic API if user has key set
        if(localStorage.getItem(ANTHROPIC_KEY_STORAGE)){
          t=await callAnthropicDirect(prompt);
        }else{
          throw new Error('Claude Code 调用失败: '+localErr.message+'\n（设置 API Key 可作为备用方案）');
        }
      }
    }else{
      const r=await window.cowork.askClaude(prompt,[]);
      t=typeof r==='string'?r:(r&&(r.text||r.content||r.output))||JSON.stringify(r);
    }
    aiResult.classList.remove('loading');
    const stamp=new Date().toLocaleTimeString('zh-CN',{hour:'2-digit',minute:'2-digit'});
    aiResult.textContent='【'+stamp+(triggerLabel==='auto'?' · 自动':'')+'】\n\n'+t;
    lastAnalyzedTs=newestTs;
  }catch(e){
    aiResult.classList.remove('loading');
    aiResult.textContent='分析失败：'+(e.message||e)+'\n\n如果是 askClaude 在 artifact 里不可用，请在对话里让 Claude 直接帮你分析。';
  }finally{
    analysisInFlight=false;
    analyzeBtn.disabled=false;
  }
}

analyzeBtn.addEventListener('click',()=>runAnalysis('manual'));

// Detect runtime: Cowork artifact (sandboxed iframe) vs standalone browser tab
const isStandalone = typeof window.cowork === 'undefined';
const ANTHROPIC_KEY_STORAGE='anthropic_api_key';

// Standalone mode: call local Python /analyze endpoint (uses Claude Code CLI -> Max subscription, free)
async function callClaudeCodeLocal(prompt){
  const r=await fetch('http://127.0.0.1:9876/analyze',{
    method:'POST',
    headers:{'Content-Type':'application/json'},
    body:JSON.stringify({prompt:prompt})
  });
  if(!r.ok){
    const t=await r.text();
    throw new Error('Local /analyze HTTP '+r.status+': '+t.slice(0,200));
  }
  return await r.text();
}

// Direct Anthropic API call from browser (standalone mode, fallback)
async function callAnthropicDirect(prompt){
  const key=localStorage.getItem(ANTHROPIC_KEY_STORAGE);
  if(!key)throw new Error('未设置 API Key — 点页面顶部"设置 API Key"');
  const r=await fetch('https://api.anthropic.com/v1/messages',{
    method:'POST',
    headers:{
      'Content-Type':'application/json',
      'x-api-key':key,
      'anthropic-version':'2023-06-01',
      'anthropic-dangerous-direct-browser-access':'true'
    },
    body:JSON.stringify({
      model:'claude-haiku-4-5-20251001',
      max_tokens:1024,
      messages:[{role:'user',content:prompt}]
    })
  });
  if(!r.ok){
    const t=await r.text();
    throw new Error('API '+r.status+': '+t.slice(0,200));
  }
  const data=await r.json();
  return data.content[0].text;
}

if(isStandalone){
  document.title='学习状态记录（独立模式 · 自动同步）';
  const banner=document.createElement('div');
  banner.style.cssText='background:#dfead0;border:1px solid #aac28a;border-radius:8px;padding:8px 12px;margin-bottom:14px;font-size:12.5px;color:#3d5b3d;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px';
  const keySet=!!localStorage.getItem(ANTHROPIC_KEY_STORAGE);
  banner.innerHTML='<span>✓ <strong>独立模式</strong> · 自动同步已启用 · API Key <strong id="keyStatus">'+(keySet?'已设置':'未设置')+'</strong></span><button id="setKeyBtn" class="small">设置 / 修改 API Key</button>';
  document.querySelector('.layout').prepend(banner);
  document.getElementById('setKeyBtn').addEventListener('click',()=>{
    const current=localStorage.getItem(ANTHROPIC_KEY_STORAGE)||'';
    const masked=current?current.slice(0,10)+'...'+current.slice(-4):'(空)';
    const newKey=prompt('粘贴 Anthropic API Key（sk-ant-...）。\n当前：'+masked+'\n留空清除已存的 key。','');
    if(newKey===null)return;
    if(newKey.trim()===''){
      localStorage.removeItem(ANTHROPIC_KEY_STORAGE);
      document.getElementById('keyStatus').textContent='未设置';
    }else{
      localStorage.setItem(ANTHROPIC_KEY_STORAGE,newKey.trim());
      document.getElementById('keyStatus').textContent='已设置';
    }
  });
}

mouseRows=loadMouseLocal();
updateMouseStatus();
updateDayLabel();renderPlaneDots();renderMouseMetrics();renderTimeline();
tryStartHttpSync();
})();
</script>
</body>
</html>
