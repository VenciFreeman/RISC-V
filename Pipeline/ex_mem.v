/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.

 * Description:

 * Details:
 * - Sequential logic: Pass the calculated result data in ex.v, target register
 *   address, write register flag and other signals.
 * - When the pipeline is blocked, the above signals remain unchanged or cleared
 *   (Bubble).

 * History:
 * - 19/12/27: Create this file.

 * Notes:
 */

 module ex_mem(

	input   wire        clk,
	input   wire        rst,
	input   wire[5:0]	stall,	
	input   wire[4:0]   ex_wd,
	input   wire        ex_wreg,
	input   wire[31:0]	ex_wdata, 
	input   wire[4:0]   ex_aluop,
	input   wire[31:0]  ex_mem_addr,
	input   wire[31:0]  ex_reg2,
	output  reg [4:0]   mem_aluop,
	output  reg [31:0]  mem_mem_addr,
	output  reg [31:0]  mem_reg2,
	output  reg [4:0]   mem_wd,
	output  reg         mem_wreg,
	output  reg [31:0]	mem_wdata

);

always @ (posedge clk) begin
    if (rst)
        mem_wd <= 5'b0;
    else if (stall[4:3] == 2'b01)
        mem_wd <= 5'b0;
    else if (!stall[3])
        mem_wd <= ex_wd;
end

always @ (posedge clk) begin
    if (rst)
        mem_wreg <= 1'b0;
    else if (stall[4:3] == 2'b01)
        mem_wreg <= 1'b0;
    else if (!stall[3])
        mem_wreg <= ex_wreg;
end

always @ (posedge clk) begin
    if (rst)
        mem_wdata <= 32'b0;
    else if (stall[4:3] == 2'b01)
        mem_wdata <= 32'b0;
    else if (!stall[3])
        mem_wdata <= ex_wdata;
end

always @ (posedge clk) begin
    if (rst)
        mem_aluop <= 5'b0;
    else if (stall[4:3] == 2'b01)
        mem_aluop <= 5'b0;
    else if (!stall[3])
        mem_aluop <= ex_aluop;
end

always @ (posedge clk) begin
    if (rst)
        mem_mem_addr <= 32'b0;
    else if (stall[4:3] == 2'b01)
        mem_mem_addr <= 32'b0;
    else if (!stall[3])
        mem_mem_addr <= ex_mem_addr;
end

always @ (posedge clk) begin
    if (rst)
        mem_reg2 <= 32'b0;
    else if (stall[4:3] == 2'b01)
        mem_reg2 <= 32'b0;
    else if (!stall[3])
        mem_reg2 <= ex_reg2;
end

endmodule