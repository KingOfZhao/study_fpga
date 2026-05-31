`timescale 1ns/1ps
module barrel_shifter_tb;
    localparam W = 8;
    reg  [W-1:0] din;
    reg  [2:0]   amt;
    reg  [1:0]   mode;
    wire [W-1:0] dout;
    integer errors = 0;
    integer m, s, t;
    reg [W-1:0] exp;
    reg [W-1:0] testvec [0:3];

    barrel_shifter #(.W(W)) dut (.din(din), .amt(amt), .mode(mode), .dout(dout));

    initial begin
        $dumpfile("barrel_shifter_tb.vcd");
        $dumpvars(0, barrel_shifter_tb);
        testvec[0] = 8'h81; testvec[1] = 8'hF0; testvec[2] = 8'h3C; testvec[3] = 8'hA5;
        for (t = 0; t < 4; t = t + 1)
          for (m = 0; m < 4; m = m + 1)
            for (s = 0; s < W; s = s + 1) begin
                din = testvec[t]; mode = m[1:0]; amt = s[2:0];
                #1;
                case (mode)
                    2'd0: exp = din << amt;
                    2'd1: exp = din >> amt;
                    2'd2: exp = (s == 0) ? din : ((din << amt) | (din >> (W - amt)));
                    default: exp = $signed(din) >>> amt;
                endcase
                if (dout !== exp) begin
                    errors = errors + 1;
                    $display("  MISMATCH din=%h mode=%0d amt=%0d dout=%h exp=%h", din, mode, amt, dout, exp);
                end
            end
        if (errors == 0) $display("[PASS] barrel_shifter: 4 模式 x 全移位量全部正确");
        else             $display("[FAIL] barrel_shifter: %0d 处错误", errors);
        $finish;
    end
endmodule
