`timescale 1ns/1ps
module apb_regfile_tb;
    localparam AW = 4, DW = 32;
    reg pclk = 0, presetn, psel, penable, pwrite;
    reg  [AW-1:0] paddr;
    reg  [DW-1:0] pwdata;
    wire [DW-1:0] prdata;
    wire pready;
    integer errors = 0;
    integer i;
    reg [DW-1:0] model [0:15];

    apb_regfile #(.AW(AW), .DW(DW)) dut (
        .pclk(pclk), .presetn(presetn), .psel(psel), .penable(penable),
        .pwrite(pwrite), .paddr(paddr), .pwdata(pwdata), .prdata(prdata), .pready(pready));
    always #5 pclk = ~pclk;

    task apb_write(input [AW-1:0] addr, input [DW-1:0] data);
        begin
            @(negedge pclk); psel=1; penable=0; pwrite=1; paddr=addr; pwdata=data;  // setup
            @(negedge pclk); penable=1;                                             // access
            @(negedge pclk); psel=0; penable=0; pwrite=0;
        end
    endtask

    task apb_read(input [AW-1:0] addr, output [DW-1:0] data);
        begin
            @(negedge pclk); psel=1; penable=0; pwrite=0; paddr=addr;   // setup
            @(negedge pclk); penable=1;                                  // access
            @(negedge pclk); data=prdata; psel=0; penable=0;
        end
    endtask

    reg [DW-1:0] rd;
    initial begin
        $dumpfile("apb_regfile_tb.vcd");
        $dumpvars(0, apb_regfile_tb);
        presetn=0; psel=0; penable=0; pwrite=0; paddr=0; pwdata=0;
        repeat (2) @(negedge pclk); presetn=1;
        // 写 16 个寄存器
        for (i = 0; i < 16; i = i + 1) begin
            model[i] = (i*32'h1111_1111) ^ 32'hDEAD_0000;
            apb_write(i[AW-1:0], model[i]);
        end
        // 读回校验
        for (i = 0; i < 16; i = i + 1) begin
            apb_read(i[AW-1:0], rd);
            if (rd !== model[i]) begin
                errors=errors+1; $display("  reg[%0d]=%h 期望=%h", i, rd, model[i]);
            end
        end
        if (errors==0) $display("[PASS] apb_regfile: 16 个寄存器 APB 写后读回一致");
        else            $display("[FAIL] apb_regfile: %0d 处错误", errors);
        $finish;
    end

    initial begin #100000; $display("[FAIL] apb_regfile: 超时"); $finish; end
endmodule
