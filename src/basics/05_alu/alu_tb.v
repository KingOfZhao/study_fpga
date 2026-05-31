// alu 自校验 testbench —— 4 位宽，穷举 a/b 全组合 × 全部 8 种运算
`timescale 1ns/1ps

module alu_tb;
    localparam WIDTH = 4;
    localparam MASK  = (1 << WIDTH) - 1;

    reg  [WIDTH-1:0] a, b;
    reg  [2:0]       op;
    wire [WIDTH-1:0] y;
    wire             zero;
    wire             carry;

    integer ia, ib, iop;
    integer exp_y, exp_carry;
    integer errors = 0;

    alu #(.WIDTH(WIDTH)) dut (
        .a(a), .b(b), .op(op), .y(y), .zero(zero), .carry(carry)
    );

    // 参考模型：用整数算出期望结果
    task ref_model(input integer ra, input integer rb, input integer rop,
                   output integer ey, output integer ec);
        begin
            ec = 0;
            case (rop)
                0: begin ey = (ra + rb) & MASK; ec = ((ra + rb) >> WIDTH) & 1; end          // ADD
                1: begin ey = (ra - rb) & MASK; ec = (ra < rb) ? 1 : 0;        end          // SUB(借位)
                2: ey = (ra & rb) & MASK;                                                    // AND
                3: ey = (ra | rb) & MASK;                                                    // OR
                4: ey = (ra ^ rb) & MASK;                                                    // XOR
                5: ey = (ra < rb) ? 1 : 0;                                                   // SLT
                6: ey = (ra << rb) & MASK;                                                   // SHL
                7: ey = (ra >> rb) & MASK;                                                   // SHR
                default: ey = 0;
            endcase
        end
    endtask

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);

        for (iop = 0; iop < 8; iop = iop + 1)
        for (ia = 0; ia <= MASK; ia = ia + 1)
        for (ib = 0; ib <= MASK; ib = ib + 1) begin
            a  = ia[WIDTH-1:0];
            b  = ib[WIDTH-1:0];
            op = iop[2:0];
            #2;
            ref_model(ia, ib, iop, exp_y, exp_carry);

            if (y !== exp_y[WIDTH-1:0]) begin
                errors = errors + 1;
                $display("[FAIL] op=%0d a=%0d b=%0d -> y=%0d exp=%0d", iop, ia, ib, y, exp_y);
            end
            if (zero !== (exp_y[WIDTH-1:0] == {WIDTH{1'b0}})) begin
                errors = errors + 1;
                $display("[FAIL] op=%0d a=%0d b=%0d -> zero=%b", iop, ia, ib, zero);
            end
            if ((iop == 0 || iop == 1) && (carry !== exp_carry[0])) begin
                errors = errors + 1;
                $display("[FAIL] op=%0d a=%0d b=%0d -> carry=%b exp=%0d", iop, ia, ib, carry, exp_carry);
            end
        end

        if (errors == 0)
            $display("[PASS] alu: all op/operand combinations passed");
        else begin
            $display("[FAIL] alu: %0d error(s)", errors);
            $fatal(1);
        end
        $finish;
    end
endmodule
