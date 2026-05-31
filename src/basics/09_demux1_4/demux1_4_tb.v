`timescale 1ns/1ps
module demux1_4_tb;
    localparam W = 8;
    reg  [W-1:0] d;
    reg  [1:0]   sel;
    wire [W-1:0] y0, y1, y2, y3;
    integer errors = 0;
    integer i;
    reg [W-1:0] exp [0:3];
    wire [W-1:0] got [0:3];

    demux1_4 #(.W(W)) dut (.d(d), .sel(sel), .y0(y0), .y1(y1), .y2(y2), .y3(y3));
    assign got[0] = y0;
    assign got[1] = y1;
    assign got[2] = y2;
    assign got[3] = y3;

    integer k;
    initial begin
        $dumpfile("demux1_4_tb.vcd");
        $dumpvars(0, demux1_4_tb);
        d = 8'h5A;
        for (i = 0; i < 4; i = i + 1) begin
            sel = i[1:0];
            #1;
            for (k = 0; k < 4; k = k + 1) exp[k] = (k == i) ? d : 8'h00;
            for (k = 0; k < 4; k = k + 1)
                if (got[k] !== exp[k]) begin
                    errors = errors + 1;
                    $display("  MISMATCH sel=%0d y%0d=%h exp=%h", sel, k, got[k], exp[k]);
                end
            #1;
        end
        if (errors == 0) $display("[PASS] demux1_4: 4 路解复用全部正确");
        else             $display("[FAIL] demux1_4: %0d 处错误", errors);
        $finish;
    end
endmodule
