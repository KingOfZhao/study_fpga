// 综合项目：VGA 上的移动方块 = vga_timing + 方块渲染。
// 每帧(vsync)方块横向移动一格；可见区内落在方块范围的像素输出白色。
`timescale 1ns/1ps

module vga_box #(
    parameter integer H_VISIBLE = 8, H_FRONT = 1, H_SYNC = 1, H_BACK = 1,
    parameter integer V_VISIBLE = 4, V_FRONT = 1, V_SYNC = 1, V_BACK = 1,
    parameter integer BS = 2          // 方块边长
) (
    input  wire       clk,
    input  wire       rst_n,
    output wire       hsync,
    output wire       vsync,
    output wire       active,
    output wire [9:0] px,
    output wire [9:0] py,
    output reg  [9:0] bx,
    output wire       rgb              // 1=白(方块)，0=背景
);
    localparam [9:0] BS10  = BS[9:0];
    localparam [9:0] XLIM  = H_VISIBLE[9:0] - BS10;   // 最大左上角 x
    localparam [9:0] BY    = 1;                        // 固定纵向位置

    vga_timing #(.H_VISIBLE(H_VISIBLE), .H_FRONT(H_FRONT), .H_SYNC(H_SYNC), .H_BACK(H_BACK),
                 .V_VISIBLE(V_VISIBLE), .V_FRONT(V_FRONT), .V_SYNC(V_SYNC), .V_BACK(V_BACK)) u_vga (
        .clk(clk), .rst_n(rst_n), .hsync(hsync), .vsync(vsync),
        .active(active), .px(px), .py(py));

    reg vsync_d;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin bx <= 0; vsync_d <= 1'b1; end
        else begin
            vsync_d <= vsync;
            if (vsync_d && !vsync) begin              // vsync 下降沿 = 新帧
                if (bx >= XLIM) bx <= 0;
                else bx <= bx + 1'b1;
            end
        end
    end

    assign rgb = active && (px >= bx) && (px < bx + BS10)
                        && (py >= BY) && (py < BY + BS10);
endmodule
