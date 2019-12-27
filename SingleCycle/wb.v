/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.

 * Description:
 * This file controls write back.

 * Details:

 * History:
 * - 19/12/27: Create this file, add PC module;

 * Notes:

 */

module WB (

    input   wire        rst,

    input   wire[4:0]   mem_wd,
    input   wire        mem_wreg,
    input   wire[31:0]  mem_wdata,

    output  reg [4:0]   wb_wd,
    output  reg         wb_wreg,
    output  reg [31:0]  wb_wdata

);

always @ (*) begin
    if (rst)
        wb_wd <= 5'b0;
    else
        wb_wd <= mem_wd;
end

always @ (*) begin
    if (rst)
        wb_wreg <= 1'b0;
    else
        wb_wreg <= mem_wreg;
end

always @ (*) begin
    if (rst)
        wb_wdata <= 32'b0;
    else
        wb_wdata <= mem_wdata;
end

endmodule