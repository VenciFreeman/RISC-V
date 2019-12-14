/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.
 *
 * Description:
 * This file determines the ALUop and determines what to do.
 *
 * Details:
 * - Decode the instruction, get ALUop by opcode, funct3 and funct7;
 * - Determine if the register needs to be read or not and send the register
 *   numbers rs1, rs2 to the register file, and read the corresponding data as the
 *   source operand;
 * - Determine if the register needs to be written or not then output target
 *   register number rd and write register flag for register write back;
 * - Determine if the branch instruction is true or not and calculate the jump
 *   address (or in ex.v);
 * - Sign extension (or unsigned extension) for instructions containing immediate
 *   values as one of the source operands.
 *
 * History:
 *
 * Notes:
 *
 */

 module ID(

	input wire 		 	clk,
	input wire		 	rst,		// High signal is reset.
    input 	   [31:0]	inst,     // The instruction from if.v.
	output reg [31:0]	pc		// a.k.a. addr in inst_mem.v, the instruction address.

 );

	parameter IDLE = 32'b0;		// Zero word.

	/*
	* This always part controls the signal.
	*/
	always @ (posedge clk) begin
		
	end


endmodule