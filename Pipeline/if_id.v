/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.

 * Description:

 * Details:
 * - Sequential logic;
 * - Pass PC value, inst;
 * - When the pipeline is blocked, pc and inst remain unchanged;
 * - When the branch is established, pc and inst are cleared.

 * History:
 * - 19/12/27: Create this file.

 * Notes:
 */

 module PC_ID(

	input   wire        clk,
	input   wire        rst,
	input   wire[5:0]   stall,	
	input   wire[31:0]	if_pc,
	input   wire[31:0]  if_inst,
	input   wire 		pre_take_or_not_i,
    input   wire		pre_sel_i,
	output  reg 		pre_take_or_not_o,
    output  reg		    pre_sel_o,
	output  reg[31:0]   id_pc,
	output  reg[31:0]   id_inst

    );

always @ (*) begin
    if (rst)
        id_pc <= 32'b0; 
    else if (!stall[1])
        id_pc <= if_pc;
    else if (stall[2:1] ==2'b01)
        id_pc <= 32'b0;
end

always @ (*) begin
    if (rst)
        id_inst <= 32'b0; 
    else if (!stall[1])
        id_inst <= if_inst;
    else if (stall[2:1] ==2'b01)
        id_inst <= 32'b0;
end

always @ (*) begin
    if (rst)
        pre_take_or_not_o <= 1'b0; 
    else if (!stall[1])
        pre_take_or_not_o <= pre_take_or_not_i;
    else if (stall[2:1] ==2'b01)
        pre_take_or_not_o <= 1'b0;
end

always @ (*) begin
    if (rst)
        pre_sel_o <= 1'b0; 
    else if (!stall[1])
        pre_sel_o <= pre_sel_i;
    else if (stall[2:1] ==2'b01)
        pre_sel_o <= 1'b0;
end
	
 endmodule