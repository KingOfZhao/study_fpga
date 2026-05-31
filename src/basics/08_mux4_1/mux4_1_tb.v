`timescale 1ns/1ps
module mux4_1_tb;
    localparam W = 8;
    reg  [W-1:0] d0, d1, d2, d3;
    reg  [1:0]   sel;
    wire [W-1:0] y;
    integer errors = 0;
    integer i;
    reg [W-1:0] exp;

    mux4_1 #(.W(W)) dut (.d0(d0), .d1(d1), .d2(d2), .d3(d3), .sel(sel), .y(y));

    initial begin
        $dumpfile("mux4_1_tb.vcd");
        $dumpvars(0, mux4_1_tb);
        d0 = 8'hA0; d1 = 8'hB1; d2 = 8'hC2; d3 = 8'hD3;
        for (i = 0; i < 4; i = i + 1) begin
            sel = i[1:0];
            #1;
            case (sel)
                2'd0: exp = d0;
                2'd1: exp = d1;
                2'd2: exp = d2;
                default: exp = d3;
            endcase
            if (y !== exp) begin
                errors = errors + 1;
                $display("  MISMATCH sel=%0d y=%h exp=%h", sel, y, exp);
            end
            #1;
        end
        if (errors == 0) $display("[PASS] mux4_1: 4 路选择全部正确");
        else             $display("[FAIL] mux4_1: %0d 处错误", errors);
        $finish;
    end
endmodule
