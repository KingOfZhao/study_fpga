/* app.js —— FPGA 学习平台前端主逻辑。 */
(function () {
  const $ = (s) => document.querySelector(s);
  const state = {
    examples: [],
    current: null,     // 当前案例对象
    files: [],         // [{name, content}]
    docs: {},          // name -> CodeMirror.Doc
    activeFile: null,
    editor: null,
    wave: null,
  };

  // ---------------- 编辑器 ----------------
  function initEditor() {
    state.editor = CodeMirror($("#editor-host"), {
      mode: "verilog",
      theme: "material-darker",
      lineNumbers: true,
      indentUnit: 4,
      tabSize: 4,
      lineWrapping: false,
    });
    state.wave = new WaveformView($("#wave-host"));
  }

  function setStatus(text, kind) {
    const el = $("#status");
    el.textContent = text;
    el.className = "status " + (kind || "");
  }

  // ---------------- 案例库 ----------------
  async function loadExamples() {
    try {
      const res = await fetch("/api/examples");
      const data = await res.json();
      state.examples = data.examples || [];
      renderSidebar();
      if (state.examples.length) loadExample(state.examples[0]);
    } catch (e) {
      $("#example-list").textContent = "加载案例失败：" + e;
    }
    loadEnv();
  }

  async function loadEnv() {
    try {
      const h = await (await fetch("/api/health")).json();
      const mark = (b) => b ? '<span class="yes">✓ 已安装</span>' : '<span class="no">✗ 缺失</span>';
      $("#env-info").innerHTML =
        `iverilog: ${mark(h.iverilog)}<br>vvp: ${mark(h.vvp)}<br>yosys: ${mark(h.yosys)}`;
    } catch (e) {
      $("#env-info").textContent = "环境检测失败";
    }
  }

  function renderSidebar() {
    const host = $("#example-list");
    host.innerHTML = "";
    const cats = {};
    state.examples.forEach((ex) => {
      (cats[ex.category] = cats[ex.category] || []).push(ex);
    });
    const order = ["basics", "intermediate", "advanced"];
    const catName = { basics: "基础", intermediate: "进阶", advanced: "高级" };
    Object.keys(cats).sort((a, b) => order.indexOf(a) - order.indexOf(b)).forEach((cat) => {
      const t = document.createElement("div");
      t.className = "cat";
      t.textContent = catName[cat] || cat;
      host.appendChild(t);
      cats[cat].forEach((ex) => {
        const it = document.createElement("div");
        it.className = "item";
        it.textContent = ex.name;
        it.dataset.id = ex.id;
        it.onclick = () => loadExample(ex);
        host.appendChild(it);
      });
    });
  }

  function loadExample(ex) {
    state.current = ex;
    state.files = ex.files.map((f) => ({ name: f.name, content: f.content }));
    state.docs = {};
    state.files.forEach((f) => {
      state.docs[f.name] = CodeMirror.Doc(f.content, "verilog");
    });
    // 默认打开设计文件（非 *_tb.v）
    const design = state.files.find((f) => !/_tb\.v$/.test(f.name)) || state.files[0];
    renderTabs();
    openFile(design.name);
    $("#readme").textContent = ex.readme ? ex.readme.slice(0, 1200) : "";
    document.querySelectorAll("#example-list .item").forEach((el) => {
      el.classList.toggle("active", el.dataset.id === ex.id);
    });
    setStatus("已载入 " + ex.id, "");
  }

  function renderTabs() {
    const host = $("#file-tabs");
    host.innerHTML = "";
    state.files.forEach((f) => {
      const tab = document.createElement("div");
      tab.className = "tab";
      tab.textContent = f.name;
      tab.dataset.name = f.name;
      tab.onclick = () => openFile(f.name);
      host.appendChild(tab);
    });
  }

  function syncActiveDoc() {
    if (state.activeFile && state.docs[state.activeFile]) {
      // CodeMirror Doc 与 editor 关联时内容已同步，无需手动复制
    }
  }

  function openFile(name) {
    syncActiveDoc();
    state.activeFile = name;
    state.editor.swapDoc(state.docs[name]);
    document.querySelectorAll("#file-tabs .tab").forEach((el) => {
      el.classList.toggle("active", el.dataset.name === name);
    });
  }

  function currentFiles() {
    return state.files.map((f) => ({
      name: f.name,
      content: state.docs[f.name].getValue(),
    }));
  }

  // ---------------- 运行仿真（A） ----------------
  async function runSimulate() {
    if (!state.current) return;
    setStatus("仿真中…", "run");
    switchTab("log");
    $("#log-output").textContent = "编译并运行中…";
    try {
      const res = await fetch("/api/simulate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ files: currentFiles() }),
      });
      const r = await res.json();
      renderLog(r);
      if (!r.ok) {
        setStatus(r.stage === "compile" ? "编译错误" : "失败", "err");
        switchTab("log");
        return;
      }
      if (r.failed) setStatus("仿真完成：有断言 FAIL", "err");
      else if (r.passed) setStatus("仿真通过 [PASS]", "ok");
      else setStatus("仿真完成", "ok");

      if (r.waveform) {
        state.wave.setData(r.waveform);
        switchTab("wave");
      } else {
        switchTab("log");
      }
    } catch (e) {
      setStatus("请求失败", "err");
      $("#log-output").textContent = "请求后端失败：" + e;
    }
  }

  function renderLog(r) {
    const out = $("#log-output");
    let head = "";
    if (r.ok) {
      head = `阶段: ${r.stage}` + (r.passed ? "  结果: [PASS]" : r.failed ? "  结果: [FAIL]" : "");
    } else {
      head = `失败阶段: ${r.stage}`;
    }
    out.textContent = head + "\n" + "─".repeat(40) + "\n" + (r.log || "");
  }

  // ---------------- 结果标签切换 ----------------
  function switchTab(tab) {
    document.querySelectorAll(".rtab").forEach((b) => b.classList.toggle("active", b.dataset.tab === tab));
    $("#pane-wave").classList.toggle("hidden", tab !== "wave");
    $("#pane-log").classList.toggle("hidden", tab !== "log");
    $("#pane-interactive").classList.toggle("hidden", tab !== "interactive");
    if (tab === "wave" && state.wave.data) state.wave.render();
  }

  // ---------------- 交互式芯片仿真（B） ----------------
  // 解析当前设计文件第一个模块的端口
  function parsePorts(src) {
    // 去注释
    const clean = src.replace(/\/\/[^\n]*/g, "").replace(/\/\*[\s\S]*?\*\//g, "");
    const m = clean.match(/module\s+(\w+)\s*(#\s*\([\s\S]*?\))?\s*\(([\s\S]*?)\)\s*;/);
    if (!m) return null;
    const modName = m[1];
    const params = {};
    if (m[2]) {
      const re = /parameter\s+(\w+)\s*=\s*([0-9]+)/g;
      let pm;
      while ((pm = re.exec(m[2]))) params[pm[1]] = parseInt(pm[2], 10);
    }
    const body = m[3];
    const ports = [];
    body.split(",").forEach((seg) => {
      const pm = seg.trim().match(/(input|output|inout)\s+(?:wire|reg|logic)?\s*(\[[^\]]*\])?\s*(\w+)/);
      if (!pm) return;
      const dir = pm[1];
      let width = 1;
      if (pm[2]) width = evalWidth(pm[2], params);
      ports.push({ dir, name: pm[3], width });
    });
    return { modName, ports, params };
  }

  function evalWidth(bracket, params) {
    // bracket like "[WIDTH-1:0]" or "[7:0]" or "[1:0]"
    const inner = bracket.replace(/[\[\]\s]/g, "");
    const [hi, lo] = inner.split(":");
    const val = (expr) => {
      let e = expr;
      Object.keys(params).forEach((k) => { e = e.replace(new RegExp("\\b" + k + "\\b", "g"), params[k]); });
      if (/^[0-9+\-*/() ]+$/.test(e)) { try { return Function('"use strict";return(' + e + ')')(); } catch (_) { return 0; } }
      return 0;
    };
    return Math.abs(val(hi) - val(lo)) + 1;
  }

  function buildInteractive() {
    switchTab("interactive");
    const host = $("#interactive-host");
    if (!state.current) { host.textContent = "请先选择一个案例"; return; }
    const designFile = state.files.find((f) => !/_tb\.v$/.test(f.name));
    if (!designFile) { host.textContent = "未找到设计文件"; return; }
    const parsed = parsePorts(state.docs[designFile.name].getValue());
    if (!parsed) { host.textContent = "无法解析模块端口"; return; }

    const hasClock = parsed.ports.some((p) => /clk|clock/i.test(p.name));
    if (hasClock) {
      host.innerHTML = `<p>模块 <code>${parsed.modName}</code> 含时钟（时序逻辑），请用左上「▶ 运行仿真」查看<strong>波形</strong>。</p>
        <p>交互式开关仿真适用于<strong>组合逻辑</strong>（如 02_combinational、03_mux_decoder）。</p>`;
      return;
    }

    state.interactive = { parsed, designFile, inputs: {} };
    parsed.ports.filter((p) => p.dir === "input").forEach((p) => { state.interactive.inputs[p.name] = 0; });
    renderInteractive();
    probe();
  }

  function renderInteractive() {
    const { parsed } = state.interactive;
    const host = $("#interactive-host");
    const inputs = parsed.ports.filter((p) => p.dir === "input");
    const outputs = parsed.ports.filter((p) => p.dir === "output");

    let html = `<div class="io-group"><div class="io-title">芯片：<code>${parsed.modName}</code> —— 点开关设置输入，输出实时计算</div></div>`;
    html += `<div class="io-group"><div class="io-title">输入</div><div class="switch-row" id="sw-row"></div></div>`;
    html += `<div class="io-group"><div class="io-title">输出</div><div class="led-row" id="led-row"></div></div>`;
    host.innerHTML = html;

    const swRow = $("#sw-row");
    inputs.forEach((p) => {
      const wrap = document.createElement("div");
      wrap.className = "io-port";
      const pname = document.createElement("div"); pname.className = "pname"; pname.textContent = `${p.name}${p.width > 1 ? "[" + (p.width - 1) + ":0]" : ""}`;
      if (p.width === 1) {
        const sw = document.createElement("div");
        sw.className = "bit-switch" + (state.interactive.inputs[p.name] ? " on" : "");
        sw.innerHTML = `<div class="knob"></div><div class="lbl">${state.interactive.inputs[p.name]}</div>`;
        sw.onclick = () => {
          state.interactive.inputs[p.name] = state.interactive.inputs[p.name] ? 0 : 1;
          renderInteractive(); probe();
        };
        wrap.appendChild(sw); wrap.appendChild(pname);
      } else {
        const maxv = (1 << p.width) - 1;
        const input = document.createElement("input");
        input.type = "number"; input.min = 0; input.max = maxv; input.value = state.interactive.inputs[p.name];
        input.style.width = "70px";
        input.onchange = () => {
          let v = parseInt(input.value || "0", 10); v = Math.max(0, Math.min(maxv, v));
          state.interactive.inputs[p.name] = v; probe();
        };
        wrap.appendChild(input); wrap.appendChild(pname);
      }
      swRow.appendChild(wrap);
    });

    const ledRow = $("#led-row");
    outputs.forEach((p) => {
      const wrap = document.createElement("div");
      wrap.className = "io-port";
      const val = state.interactive.outputs ? state.interactive.outputs[p.name] : undefined;
      if (p.width === 1) {
        const led = document.createElement("div");
        led.className = "led" + (val === 1 ? " on" : "");
        led.id = "led-" + p.name;
        led.textContent = val === undefined ? "?" : val;
        wrap.appendChild(led);
      } else {
        const bus = document.createElement("div");
        bus.className = "bus-val"; bus.id = "led-" + p.name;
        bus.textContent = val === undefined ? "?" : val;
        wrap.appendChild(bus);
      }
      const pname = document.createElement("div"); pname.className = "pname"; pname.textContent = `${p.name}${p.width > 1 ? "[" + (p.width - 1) + ":0]" : ""}`;
      wrap.appendChild(pname);
      ledRow.appendChild(wrap);
    });
  }

  // 生成探针 testbench，驱动当前输入值，打印输出，再用 /api/simulate 求值
  async function probe() {
    const { parsed, designFile } = state.interactive;
    const inputs = parsed.ports.filter((p) => p.dir === "input");
    const outputs = parsed.ports.filter((p) => p.dir === "output");
    let tb = "`timescale 1ns/1ps\nmodule __probe;\n";
    inputs.forEach((p) => { tb += `  reg ${p.width > 1 ? `[${p.width - 1}:0] ` : ""}${p.name};\n`; });
    outputs.forEach((p) => { tb += `  wire ${p.width > 1 ? `[${p.width - 1}:0] ` : ""}${p.name};\n`; });
    const conn = parsed.ports.map((p) => `.${p.name}(${p.name})`).join(", ");
    tb += `  ${parsed.modName} dut(${conn});\n  initial begin\n`;
    inputs.forEach((p) => { tb += `    ${p.name} = ${p.width}'d${state.interactive.inputs[p.name]};\n`; });
    tb += "    #1;\n";
    outputs.forEach((p) => { tb += `    $display("OUT ${p.name} %0d", ${p.name});\n`; });
    tb += "    $finish;\n  end\nendmodule\n";

    try {
      const res = await fetch("/api/simulate", {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ files: [
          { name: designFile.name, content: state.docs[designFile.name].getValue() },
          { name: "__probe_tb.v", content: tb },
        ] }),
      });
      const r = await res.json();
      if (!r.ok) { setStatus("交互仿真失败（见日志）", "err"); $("#log-output").textContent = r.log; return; }
      const outs = {};
      (r.log || "").split("\n").forEach((line) => {
        const m = line.match(/OUT\s+(\w+)\s+(\d+)/);
        if (m) outs[m[1]] = parseInt(m[2], 10);
      });
      state.interactive.outputs = outs;
      // 更新输出显示
      outputs.forEach((p) => {
        const el = $("#led-" + p.name);
        if (!el) return;
        if (p.width === 1) { el.textContent = outs[p.name]; el.classList.toggle("on", outs[p.name] === 1); }
        else el.textContent = outs[p.name];
      });
      setStatus("交互仿真完成", "ok");
    } catch (e) {
      setStatus("交互仿真请求失败", "err");
    }
  }

  // ---------------- 事件绑定 ----------------
  function bind() {
    $("#btn-run").onclick = runSimulate;
    $("#btn-interactive").onclick = buildInteractive;
    document.querySelectorAll(".rtab").forEach((b) => { b.onclick = () => switchTab(b.dataset.tab); });
    $("#zoom-in").onclick = () => state.wave.zoomIn();
    $("#zoom-out").onclick = () => state.wave.zoomOut();
    $("#zoom-fit").onclick = () => state.wave.zoomFit();
  }

  window.addEventListener("DOMContentLoaded", () => {
    initEditor();
    bind();
    loadExamples();
  });
})();
