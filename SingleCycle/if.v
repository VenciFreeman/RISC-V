/************************************************************************************
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.          *
 * Author: @VenciFreeman (GitHub), copyright 2019.									*
 * School: Shanghai Jiao Tong University.											*
 * Description:                                                                     *
 * This file controls signal PC, it need to send PC+4 and instruction to id.v 		*
 * through inst_mem.v. For 5 stage stall, it need to keep PC. 						*
 * Details:                                                                         *
 * - PC + 4 per cycle;                                                              *
 * - PC value send to inst_mem as the address of instruction, then send the         *
 *   instruction to decode module;                                                  *
 * - If current instruction is beq, blt or jal, update PC immediately.              *
 * History:																			*
 * - 19/12/05: Create this file.													*
 * Notes:																			*
 * - Take care that the module name can't be "if". Maybe it's a keep word.			*
 ************************************************************************************/

module IF(

	input wire clk,
	input wire rst,		// High signal is reset.
	input [31,0] pc_i,
	output[31:0] pc_o		// a.k.a. addr in inst_mem.v, the instruction address.

);

	parameter IDLE = 32'b0;		// Zero word.

/************************************************************************************
 * This always part controls the signal pc_o.										*
 ************************************************************************************/
always @ (posedge clk) begin	// New PC equals ((old PC) + 4) per cycle.
	if (rst)
		pc_o <= IDLE;
	else
		pc_o <= pc_i + 32'b100;
end

endmodule