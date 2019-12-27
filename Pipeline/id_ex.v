/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.

 * Description:

 * Details:
 * - Sequential logic;
 * - Pass the decoded ALUop, source operand, destination register address,
 *   write register flag and other signals in id.v.
 * - When the pipeline is blocked, the above signals remain unchanged or
 *   cleared (Bubble).

 * History:
 * - 19/12/27: Create this file.

 * Notes:
 */

module id_ex(

	input   wire        clk,
	input   wire        rst,
	input   wire[5:0]   stall,
	input   wire[4:0]   id_aluop,
	input   wire[2:0]   id_alusel,
	input   wire[31:0]  id_reg1,
	input   wire[31:0]  id_reg2,
	input   wire[4:0]   id_wd,
	input   wire        id_wreg,	
	input   wire[31:0]  id_link_address,
	input   wire[31:0]  id_inst,	
	output  reg[4:0]    ex_aluop,
	output  reg[2:0]    ex_alusel,
	output  reg[31:0]   ex_link_address,
	output  reg[31:0]   ex_inst,
	output  reg[31:0]   ex_reg1,
	output  reg[31:0]   ex_reg2,
	output  reg[4:0]    ex_wd,
	output  reg         ex_wreg
	
);

always @ (posedge clk) begin
    if (rst)
        ex_alusel <= 3'b0;
    else if (stall[3:2] == 2'b01)
        ex_alusel <= 3'b0;
    else if (!stall[2])
        ex_alusel <= id_aluop;
end

always @ (posedge clk) begin
    if (rst)
        ex_aluop <= 5'b0;
    else if (stall[3:2] == 2'b01)
        ex_aluop <= 5'b0;
    else if (!stall[2])
        ex_aluop <= id_alusel;
end

always @ (posedge clk) begin
    if (rst)
        ex_reg1 <= 32'b0;
    else if (stall[3:2] == 2'b01)
        ex_reg1 <= 32'b0;
    else if (!stall[2])
        ex_reg1 <= id_reg1;
end

always @ (posedge clk) begin
    if (rst)
        ex_reg2 <= 32'b0;
    else if (stall[3:2] == 2'b01)
        ex_reg2 <= 32'b0;
    else if (!stall[2])
        ex_reg2 <= id_reg2;
end

always @ (posedge clk) begin
    if (rst)
        ex_wd <= 5'b0;
    else if (stall[3:2] == 2'b01)
        ex_wd <= 5'b0;
    else if (!stall[2])
        ex_wd <= id_wd;
end

always @ (posedge clk) begin
    if (rst)
        ex_wreg <= 1'b0;
    else if (stall[3:2] == 2'b01)
        ex_wreg <= 1'b0;
    else if (!stall[2])
        ex_wreg <= id_wreg;
end

always @ (posedge clk) begin
    if (rst)
        ex_link_address <= 32'b0;
    else if (stall[3:2] == 2'b01)
        ex_link_address <= 32'b0;
    else if (!stall[2])
        ex_link_address <= id_link_address;
end

always @ (posedge clk) begin
    if (rst)
        ex_inst <= 32'b0;
    else if (stall[3:2] == 2'b01)
        ex_inst <= 32'b0;
    else if (!stall[2])
        ex_inst <= id_inst;
end

endmodule