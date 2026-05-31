`timescale 1ns/1ps
module priority_encoder_tb;
    reg  [7:0] req;
    wire [2:0] code;
    wire       valid;
    integer errors = 0;
    integer i, j;
    reg [2:0] exp_code;
    reg       exp_valid;

    priority_encoder dut (.req(req), .code(code), .valid(valid));

    initial begin
        $dumpfile("priority_encoder_tb.vcd");
        $dumpvars(0, priority_encoder_tb);
        for (i = 0; i < 256; i = i + 1) begin
            req = i[7:0];
            #1;
            exp_code  = 3'd0;
            exp_valid = 1'b0;
            for (j = 0; j < 8; j = j + 1)
                if (req[j]) begin exp_code = j[2:0]; exp_valid = 1'b1; end
            if (code !== exp_code || valid !== exp_valid) begin
                errors = errors + 1;
                $display("  MISMATCH req=%b code=%0d valid=%b exp=%0d/%b", req, code, valid, exp_code, exp_valid);
            end
        end
        if (errors == 0) $display("[PASS] priority_encoder: 256 种输入全部正确");
        else             $display("[FAIL] priority_encoder: %0d 处错误", errors);
        $finish;
    end
endmodule
