/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.

 * Description:
 * This file controls signal PC, it need to send PC+4 and instruction to id.v
 * through inst_mem.v. For 5 stage stall, it need to keep PC.

 * Details:
 * - PC + 4 per cycle;]
 * - PC value send to inst_mem as the address of instruction, then send the
 *   instruction to decode module;
 * - If current instruction is beq, blt or jal, update PC immediately.

 * History:
 * - 19/12/05: Create this file, add PC module;
 * - 19/12/23: Add UpdatePC module.

 * Notes:
 * - Take care that the module name can't be "if". Maybe it's a keep word.
 * - Should I use 32-bit adders? Maybe it's good for Vivado synthesizing.
 */

module PC(

	input  		 clk,
	input 		 rst,		// High signal is reset.
	input		 Branch,
	input		 Zero,
	input [1:0]	 Jump,
	input [31:0] imm,
	input [31:0] currPC,
	output[31:0] nextPC		// a.k.a. addr in inst_mem.v, the instruction address.

);

	reg [31:0] next_PC;
	assign nextPC = next_PC;

/*
* This always part controls the signal next_PC.
*/
always @ (posedge clk) begin	// New PC equals ((old PC) + 4) per cycle.
	if (rst)
		next_PC <= 32'b0;
	else begin
		if (Branch && Zero)
			next_PC <= currPC + 4'h4 + imm;
		else if (Jump)
			next_PC <= currPC + 4'h4 + (imm << 2) | (next_PC & 32'hF0000000);
		else
			next_PC <= currPC + 4'h4;
	end
end

endmodule