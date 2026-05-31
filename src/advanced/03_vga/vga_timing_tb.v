// vga_timing 自校验 testbench
//  - 小参数实例（快速跑 2 整帧）：用性质检查验证可见像素总数、hsync 脉冲宽度/个数、
//    vsync 脉冲宽度/个数、px/py 范围。
//  - 默认参数(640×480)实例：检查首个 hsync 低脉冲宽度恰为 96。
`timescale 1ns/1ps

module vga_timing_tb;
    // ---------- 小参数实例（验证通用时序逻辑）----------
    localparam HV=8, HF=2, HS=3, HB=2;     // H_TOTAL = 15
    localparam VV=4, VF=1, VS=2, VB=1;     // V_TOTAL = 8
    localparam H_TOTAL = HV+HF+HS+HB;
    localparam V_TOTAL = VV+VF+VS+VB;

    reg        clk = 1'b0, rst_n;
    wire       hsync, vsync, active;
    wire [9:0] px, py;

    vga_timing #(.H_VISIBLE(HV),.H_FRONT(HF),.H_SYNC(HS),.H_BACK(HB),
                 .V_VISIBLE(VV),.V_FRONT(VF),.V_SYNC(VS),.V_BACK(VB))
        dut (.clk(clk),.rst_n(rst_n),.hsync(hsync),.vsync(vsync),
             .active(active),.px(px),.py(py));

    // ---------- 默认参数实例（验证真实 640×480 的 H_SYNC=96）----------
    wire       r_hsync, r_vsync, r_active;
    wire [9:0] r_px, r_py;
    vga_timing dflt (.clk(clk),.rst_n(rst_n),.hsync(r_hsync),.vsync(r_vsync),
                     .active(r_active),.px(r_px),.py(r_py));

    always #5 clk = ~clk;

    integer errors = 0;
    // 小实例统计
    integer active_cnt = 0, h_pulses = 0, v_pulses = 0;
    integer h_run = 0, v_run = 0;
    reg     ph = 1'b1, pv = 1'b1;
    // 默认实例：首个 hsync 低脉冲宽度
    integer r_run = 0, r_first_w = -1;
    reg     r_ph = 1'b1;
    reg     counting = 1'b0;
    integer ccyc = 0;

    always @(posedge clk) if (counting) begin
        ccyc = ccyc + 1;
      if (ccyc <= 2*H_TOTAL*V_TOTAL) begin
        // —— 小实例性质统计 ——
        if (active) begin
            active_cnt = active_cnt + 1;
            if (px >= HV || py >= VV) begin
                errors = errors + 1;
                $display("[FAIL] active 时坐标越界 px=%0d py=%0d", px, py);
            end
        end
        // hsync 低脉冲宽度（按周期数）
        if (!hsync) h_run = h_run + 1;
        if (ph && !hsync) h_run = 1;                 // 下降沿，重新计数
        if (!ph && hsync) begin                      // 上升沿，结束一个脉冲
            if (h_run !== HS) begin
                errors = errors + 1;
                $display("[FAIL] hsync 宽度=%0d 期望=%0d", h_run, HS);
            end
            h_pulses = h_pulses + 1;
        end
        ph <= hsync;
        // vsync 低脉冲宽度（按周期数 = VS 行 × H_TOTAL）
        if (!vsync) v_run = v_run + 1;
        if (pv && !vsync) v_run = 1;
        if (!pv && vsync) begin
            if (v_run !== VS*H_TOTAL) begin
                errors = errors + 1;
                $display("[FAIL] vsync 宽度=%0d 期望=%0d", v_run, VS*H_TOTAL);
            end
            v_pulses = v_pulses + 1;
        end
        pv <= vsync;
      end

        // —— 默认实例：捕获首个 hsync 低脉冲宽度 ——
        if (!r_hsync) r_run = r_run + 1;
        if (r_ph && !r_hsync) r_run = 1;
        if (!r_ph && r_hsync && r_first_w < 0) r_first_w = r_run;
        r_ph <= r_hsync;
    end

    initial begin
        $dumpfile("vga_timing_tb.vcd");
        $dumpvars(0, vga_timing_tb);
        rst_n = 1'b0;
        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
        counting = 1'b1;                  // 从干净起点开始统计

        // 跑足够周期：小实例统计前 2 帧；默认 640x480 实例需 ~752 周期出首个 hsync
        repeat (1200) @(posedge clk);
        counting = 1'b0;

        // 性质断言（小实例恰好统计了 2 个完整周期，与相位无关）
        if (active_cnt !== 2*HV*VV) begin
            errors = errors + 1;
            $display("[FAIL] 可见像素数=%0d 期望=%0d", active_cnt, 2*HV*VV);
        end else $display("[ OK ] 可见像素数=%0d（2 帧）", active_cnt);

        if (h_pulses < V_TOTAL) begin
            errors = errors + 1;
            $display("[FAIL] hsync 脉冲数=%0d 偏少", h_pulses);
        end else $display("[ OK ] hsync 脉冲数=%0d，宽度均为 %0d", h_pulses, HS);

        if (v_pulses < 1) begin
            errors = errors + 1;
            $display("[FAIL] vsync 脉冲数=%0d", v_pulses);
        end else $display("[ OK ] vsync 脉冲数=%0d，宽度均为 %0d 周期", v_pulses, VS*H_TOTAL);

        if (r_first_w !== 96) begin
            errors = errors + 1;
            $display("[FAIL] 640x480 hsync 宽度=%0d 期望=96", r_first_w);
        end else $display("[ OK ] 默认 640x480：hsync 宽度=96 周期");

        if (errors == 0)
            $display("[PASS] vga_timing: 时序与同步脉冲全部正确");
        else begin
            $display("[FAIL] vga_timing: %0d error(s)", errors);
            $fatal(1);
        end
        $finish;
    end
endmodule
