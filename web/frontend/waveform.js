/* waveform.js —— 用 Canvas 渲染 VCD 波形。
 * 用法：
 *   const view = new WaveformView(hostElement);
 *   view.setData(waveformJson);   // 来自后端 /api/simulate
 *   view.zoomIn() / view.zoomOut() / view.zoomFit();
 *
 * waveformJson 结构见 backend/vcd_parser.py。
 */
(function () {
  const NAME_W = 160;     // 左侧信号名列宽
  const ROW_H = 30;       // 每行高度
  const TOP_PAD = 24;     // 顶部时间轴高度

  function binToHex(bin) {
    if (!/^[01]+$/.test(bin)) return bin; // 含 x/z 原样返回
    // 按 4 位一组转 hex
    let s = bin;
    const pad = (4 - (s.length % 4)) % 4;
    s = "0".repeat(pad) + s;
    let hex = "";
    for (let i = 0; i < s.length; i += 4) {
      hex += parseInt(s.slice(i, i + 4), 2).toString(16);
    }
    return hex.replace(/^0+(?=.)/, "");
  }

  class WaveformView {
    constructor(host) {
      this.host = host;
      this.data = null;
      this.pxPerTime = 0.02;     // 像素/时间单位（会被 zoomFit 重设）
      this.canvas = document.createElement("canvas");
      this.canvas.style.display = "block";
      this.host.innerHTML = "";
      this.host.appendChild(this.canvas);
      this.ctx = this.canvas.getContext("2d");
      this.host.addEventListener("scroll", () => this._drawNamesOverlay());
      window.addEventListener("resize", () => this.render());
    }

    setData(data) {
      this.data = data;
      this.zoomFit();
    }

    clear() {
      this.data = null;
      const c = this.canvas, ctx = this.ctx;
      c.width = c.width; // reset
    }

    _visibleSignals() {
      // 过滤掉宽度过大的字符串信号（如 name[255:0]）与重复层级，保留有意义的波形
      return this.data.signals.filter((s) => s.width <= 64);
    }

    zoomFit() {
      if (!this.data) return;
      const w = Math.max(this.host.clientWidth - NAME_W - 20, 200);
      const end = this.data.end_time || 1;
      this.pxPerTime = w / end;
      this.render();
    }
    zoomIn() { this.pxPerTime *= 1.6; this.render(); }
    zoomOut() { this.pxPerTime /= 1.6; this.render(); }

    render() {
      if (!this.data) return;
      const ctx = this.ctx;
      const sigs = this._visibleSignals();
      const end = this.data.end_time || 1;
      const waveW = Math.max(end * this.pxPerTime, 100);
      const totalW = NAME_W + waveW + 20;
      const totalH = TOP_PAD + sigs.length * ROW_H + 10;

      const dpr = window.devicePixelRatio || 1;
      this.canvas.width = totalW * dpr;
      this.canvas.height = totalH * dpr;
      this.canvas.style.width = totalW + "px";
      this.canvas.style.height = totalH + "px";
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);

      ctx.clearRect(0, 0, totalW, totalH);

      // 时间网格 + 刻度
      this._drawTimeGrid(ctx, end, waveW, totalH);

      // 每个信号
      sigs.forEach((sig, idx) => {
        const y = TOP_PAD + idx * ROW_H;
        const changes = this.data.changes[sig.id] || [];
        if (sig.width === 1) this._drawScalar(ctx, sig, changes, y, end, waveW);
        else this._drawBus(ctx, sig, changes, y, end, waveW);
      });

      this._drawNamesOverlay();
      this._meta(sigs.length, end);
    }

    _meta(n, end) {
      const el = document.getElementById("wave-meta");
      if (el) el.textContent = `${n} 个信号 · 时长 ${end} ${this.data.timescale} · 缩放 ${(this.pxPerTime).toExponential(1)} px/单位`;
    }

    _drawTimeGrid(ctx, end, waveW, totalH) {
      ctx.save();
      ctx.strokeStyle = "#1d2330";
      ctx.fillStyle = "#8a91a3";
      ctx.font = "10px monospace";
      // 选择合适的刻度间隔（目标 ~每 90px 一格）
      const targetPx = 90;
      let step = Math.pow(10, Math.floor(Math.log10(targetPx / this.pxPerTime)));
      while (step * this.pxPerTime < targetPx) step *= 2;
      for (let t = 0; t <= end; t += step) {
        const x = NAME_W + t * this.pxPerTime;
        ctx.beginPath();
        ctx.moveTo(x, TOP_PAD - 6);
        ctx.lineTo(x, totalH);
        ctx.stroke();
        ctx.fillText(String(t), x + 2, 12);
      }
      ctx.restore();
    }

    _xAt(t, end, waveW) { return NAME_W + t * this.pxPerTime; }

    _drawScalar(ctx, sig, changes, y, end, waveW) {
      const hi = y + 6, lo = y + ROW_H - 8;
      ctx.save();
      ctx.lineWidth = 2;
      ctx.strokeStyle = "#35c46a";
      ctx.beginPath();
      let prevX = NAME_W;
      let prevVal = changes.length ? changes[0][1] : "0";
      const levelY = (v) => (v === "1" ? hi : lo);
      // 起始
      let started = false;
      const pts = changes.length ? changes : [[0, "0"]];
      for (let i = 0; i < pts.length; i++) {
        const [t, v] = pts[i];
        const x = this._xAt(t, end, waveW);
        if (!started) { ctx.moveTo(x, levelY(v)); started = true; prevVal = v; prevX = x; continue; }
        // 水平到 x（保持 prevVal），再竖直跳变
        ctx.lineTo(x, levelY(prevVal));
        if (v !== prevVal) {
          if (v === "x" || v === "z") { ctx.strokeStyle = "#ff5d6c"; }
          ctx.lineTo(x, levelY(v));
          ctx.strokeStyle = "#35c46a";
        }
        prevVal = v; prevX = x;
      }
      // 延伸到结尾
      ctx.lineTo(this._xAt(end, end, waveW), levelY(prevVal));
      ctx.stroke();
      ctx.restore();
    }

    _drawBus(ctx, sig, changes, y, end, waveW) {
      const top = y + 6, bot = y + ROW_H - 8, mid = (top + bot) / 2;
      ctx.save();
      ctx.lineWidth = 1.5;
      ctx.strokeStyle = "#4f9dff";
      ctx.fillStyle = "#dce6ff";
      ctx.font = "11px monospace";
      ctx.textBaseline = "middle";
      const pts = changes.length ? changes : [[0, "0".repeat(sig.width)]];
      for (let i = 0; i < pts.length; i++) {
        const [t, v] = pts[i];
        const x0 = this._xAt(t, end, waveW);
        const x1 = i + 1 < pts.length ? this._xAt(pts[i + 1][0], end, waveW) : this._xAt(end, end, waveW);
        if (x1 - x0 < 0.5) continue;
        // 六边形段
        ctx.beginPath();
        ctx.moveTo(x0 + 3, mid);
        ctx.lineTo(x0 + 6, top);
        ctx.lineTo(x1 - 3, top);
        ctx.lineTo(x1, mid);
        ctx.lineTo(x1 - 3, bot);
        ctx.lineTo(x0 + 6, bot);
        ctx.closePath();
        ctx.stroke();
        // 值（hex）
        const label = binToHex(v);
        const tw = ctx.measureText(label).width;
        if (x1 - x0 > tw + 8) {
          ctx.fillText(label, x0 + 8, mid);
        }
      }
      ctx.restore();
    }

    _drawNamesOverlay() {
      if (!this.data) return;
      const ctx = this.ctx;
      const sigs = this._visibleSignals();
      const scrollLeft = this.host.scrollLeft;
      ctx.save();
      ctx.setTransform((window.devicePixelRatio || 1), 0, 0, (window.devicePixelRatio || 1), 0, 0);
      // 名字列背景（跟随横向滚动固定在左侧）
      ctx.fillStyle = "#141822";
      ctx.fillRect(scrollLeft, 0, NAME_W, this.canvas.height);
      ctx.strokeStyle = "#2a2f3d";
      ctx.beginPath(); ctx.moveTo(scrollLeft + NAME_W, 0); ctx.lineTo(scrollLeft + NAME_W, this.canvas.height); ctx.stroke();
      ctx.fillStyle = "#d7dbe6";
      ctx.font = "12px monospace";
      ctx.textBaseline = "middle";
      sigs.forEach((sig, idx) => {
        const y = TOP_PAD + idx * ROW_H + ROW_H / 2 - 2;
        // 只显示最后一段层级名，避免太长
        const short = sig.name.split(".").slice(-1)[0];
        const label = sig.width > 1 ? `${short}[${sig.width - 1}:0]` : short;
        ctx.fillText(label, scrollLeft + 8, y);
      });
      ctx.restore();
    }
  }

  window.WaveformView = WaveformView;
})();
