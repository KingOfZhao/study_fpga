// 综合项目(收官)：微指令数据通路 = alu + 寄存器堆 + 取指/执行时序机。
// 内置一段微程序，逐条 取指->读寄存器->ALU 运算->写回，演示一个最小处理核雏形。
// 指令格式(16 位): [15]=use_imm  [14:12]=op  [11:10]=rd  [9:8]=ra  [7:0]=imm 或 {6'b0,rb}
`timescale 1ns/1ps

module alu_datapath (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    output reg        done,
    input  wire [1:0] dbg_addr,
    output wire [7:0] dbg_data
);
    localparam integer NP = 6;        // 程序长度
    localparam [2:0]   LASTPC = NP[2:0] - 3'd1;

    // 4 个 8 位通用寄存器
    reg [7:0] regs [0:3];
    assign dbg_data = regs[dbg_addr];

    // 程序存储
    reg [15:0] prog [0:NP-1];
    initial begin
        // op: ADD0 SUB1 AND2 OR3 XOR4 SLT5 SHL6 SHR7
        prog[0] = {1'b1, 3'd0, 2'd0, 2'd0, 8'd5};   // r0 = r0(0) + 5  = 5
        prog[1] = {1'b1, 3'd0, 2'd1, 2'd1, 8'd3};   // r1 = r1(0) + 3  = 3
        prog[2] = {1'b0, 3'd0, 2'd2, 2'd0, 8'd1};   // r2 = r0 + r1    = 8   (rb=1)
        prog[3] = {1'b0, 3'd1, 2'd3, 2'd0, 8'd1};   // r3 = r0 - r1    = 2
        prog[4] = {1'b1, 3'd6, 2'd2, 2'd2, 8'd1};   // r2 = r2 << 1    = 16
        prog[5] = {1'b1, 3'd2, 2'd0, 2'd0, 8'h0F};  // r0 = r0 & 0x0F  = 5
    end

    reg  [2:0] pc;
    reg        running;

    wire [15:0] ir      = prog[pc[2:0]];
    wire        use_imm = ir[15];
    wire [2:0]  op      = ir[14:12];
    wire [1:0]  rd      = ir[11:10];
    wire [1:0]  ra      = ir[9:8];
    wire [7:0]  imm     = ir[7:0];

    wire [7:0]  opA = regs[ra];
    wire [7:0]  opB = use_imm ? imm : regs[imm[1:0]];
    wire [7:0]  alu_y;
    wire        alu_zero, alu_carry;

    alu #(.WIDTH(8)) u_alu (
        .a(opA), .b(opB), .op(op), .y(alu_y), .zero(alu_zero), .carry(alu_carry));

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc<=0; running<=0; done<=0;
            for (i=0;i<4;i=i+1) regs[i]<=8'd0;
        end else begin
            done <= 1'b0;
            if (!running) begin
                if (start) begin running<=1'b1; pc<=0; for (i=0;i<4;i=i+1) regs[i]<=8'd0; end
            end else begin
                regs[rd] <= alu_y;            // 写回
                if (pc == LASTPC) begin running<=1'b0; done<=1'b1; end
                else pc <= pc + 1'b1;
            end
        end
    end
endmodule
