// seven_seg 自校验 testbench
//  1) 穷举验证 bin2bcd（0..255 → 百/十/个位）
//  2) 验证 seg7 对 0..9 的段码与规格表一致
//  3) 验证扫描显示：位选 an 轮流"一冷"，三位都被点亮过
`timescale 1ns/1ps

module seven_seg_tb;
    localparam SCAN_DIV = 4;

    // ---- 被测：bin2bcd ----
    reg  [7:0] bin;
    wire [3:0] huns, tens, ones;
    bin2bcd u_bcd (.bin(bin), .huns(huns), .tens(tens), .ones(ones));

    // ---- 被测：seg7 ----
    reg  [3:0] digit;
    wire [7:0] seg_d;
    seg7 u_seg (.digit(digit), .seg(seg_d));

    // ---- 被测：扫描显示顶层 ----
    reg        clk = 1'b0;
    reg        rst_n;
    reg  [7:0] value;
    wire [2:0] an;
    wire [7:0] seg_top;
    seven_seg #(.SCAN_DIV(SCAN_DIV)) u_top (
        .clk(clk), .rst_n(rst_n), .value(value), .an(an), .seg(seg_top)
    );

    always #5 clk = ~clk;

    integer i, errors = 0;
    integer eh, et, eo;
    reg [7:0] seg_table [0:9];
    reg seen0, seen1, seen2;   // 三个位选是否都出现过

    initial begin
        seg_table[0]=8'hC0; seg_table[1]=8'hF9; seg_table[2]=8'hA4;
        seg_table[3]=8'hB0; seg_table[4]=8'h99; seg_table[5]=8'h92;
        seg_table[6]=8'h82; seg_table[7]=8'hF8; seg_table[8]=8'h80;
        seg_table[9]=8'h90;
    end

    // 监测扫描：记录出现过哪些位选
    always @(posedge clk) if (rst_n) begin
        case (an)
            3'b110: seen0 = 1'b1;
            3'b101: seen1 = 1'b1;
            3'b011: seen2 = 1'b1;
            default: ;
        endcase
    end

    initial begin
        $dumpfile("seven_seg_tb.vcd");
        $dumpvars(0, seven_seg_tb);

        // 1) bin2bcd 穷举
        for (i = 0; i < 256; i = i + 1) begin
            bin = i[7:0];
            #2;
            eh = (i / 100);
            et = (i / 10) % 10;
            eo = i % 10;
            if (huns !== eh[3:0] || tens !== et[3:0] || ones !== eo[3:0]) begin
                errors = errors + 1;
                $display("[FAIL] bin=%0d -> %0d%0d%0d 期望 %0d%0d%0d",
                         i, huns, tens, ones, eh, et, eo);
            end
        end
        $display("[ OK ] bin2bcd 0..255 检查完成");

        // 2) seg7 段码表
        for (i = 0; i < 10; i = i + 1) begin
            digit = i[3:0];
            #2;
            if (seg_d !== seg_table[i]) begin
                errors = errors + 1;
                $display("[FAIL] seg7 digit=%0d -> %h 期望 %h", i, seg_d, seg_table[i]);
            end
        end
        $display("[ OK ] seg7 段码表检查完成");

        // 3) 扫描显示
        seen0 = 1'b0; seen1 = 1'b0; seen2 = 1'b0;
        value = 8'd123;
        rst_n = 1'b0;
        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        repeat (SCAN_DIV * 4 + 6) @(posedge clk);
        if (!(seen0 && seen1 && seen2)) begin
            errors = errors + 1;
            $display("[FAIL] 位选未轮全：an=110/101/011 -> %b%b%b", seen0, seen1, seen2);
        end else
            $display("[ OK ] 扫描位选轮全三位");

        if (errors == 0)
            $display("[PASS] seven_seg: bin2bcd + seg7 + scan 全部通过");
        else begin
            $display("[FAIL] seven_seg: %0d error(s)", errors);
            $fatal(1);
        end
        $finish;
    end
endmodule
