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
	input [31:0] nextPC,
	output[31:0] PCval		// a.k.a. addr in inst_mem.v, the instruction address.

);

	reg [31:0] PCreg;

	assign PCval = PCreg;

/*
* This always part controls the signal PCreg.
*/
always @ (posedge clk) begin	// New PC equals ((old PC) + 4) per cycle.
	if (rst)
		PCreg <= 32'b0;
	else
		PCreg <= nextPC;
end

endmodule

module UpdatePC(

	input [31:0] PCval,
	input [31:0] pc_add_4,
	input [19:0] imm20,  // for jal
	input [11:0] imm12,  // for beq, blt
	input [31:0] regRead1,
	input 		 Branch,
	input		 Zero,
	input [1:0]  Jump,
	input [31:0] NextPC

);

	reg [31:0] nextPC;

	assign NextPC = nextPC;

/*
 * This always part controls the signal nextPC, a.k.a. nextPC.
 */
always @ (*) begin
	if (jump == 2'b00) begin
		if (Branch && Zero)
			nextPC <= pc_add_4 + (imm12 << 2);
		else
			nextPC <= pc_add_4;
	end
	else if (Jump == 2'b01)
		nextPC <= (imm20 << 2) | (PCval & 32'hF0000000);
	else
		nextPC <= regRead1;
end

endmodule