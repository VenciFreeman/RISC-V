/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.
 *
 * Description:
 * Do some operations according to ALUop and the 2 source oprands.
 *
 * Details:
 * - Use the ALUop and the two source operands decoded in id.v to perform the
 *   cordponding operation;
 * - If ALUop indicates that it's an addition operation, the two operands will be
 *	 added;
 * - The sub operation can be implemented by complement, etc.
 *
 * History:
 * - 19/12/05: Create this file;
 * - 19/12/19：Edit the ALU module and the RISC-V instructions;
 * - 19/12/23: Modify the format and logic.
 *
 * Notes:
 *
 */

module ALU(

        input   [31:0]  oprend1,
        input   [31:0]  oprend2,
        input   [5:0]   ALUop,
		input 			pc,  // If I need pc or not?
        output          zero,  // zero flag
        output  [31:0]  result

    );
    
    reg rZero;
    reg [31:0] rd;

	assign zero = rZero;
    assign result = rd;

/*
* This always part controls the signal rd, a.k.a. result.
*/    
always @ (*) begin
	case (ALUop)
		6'b000001: rd = oprend1 + oprend2;									// add.
		6'b000010: rd = oprend1 - oprend2;									// sub.
		6'b000011: rd = oprend1 << oprend2;									// sll.
		6'b001011: rd = oprend1 >> oprend2;									// srl.
		6'b000110: rd = oprend1 & oprend2;									// and.
		6'b000111: rd = oprend1 | oprend2;									// or.
		6'b001000: rd = oprend1 ^ oprend2;									// xor.
		6'b000100: begin rd = pc + 4; pc = pc + sext(offset); end			// jal
		6'b001001: if (oprend1 > oprend2) pc = pc + sext(offset);			// blt
		6'b001010: if (oprend1 == oprend2) pc = pc + sext(offset);			// beq
		6'b000101: rd = rd + sext(imm);										// addi		
		6'b001100: rd = sext(M[oprend1 + sext(offset)]);					// lw
		6'b001101: M[oprend1] + sext(offset) = oprend2;						// sw
		default: break;
	endcase
end

/*
* This always part controls the signal rZero.
*/    
always @ (*)
	rZero <= (rd == 0) ? 1 : 0;
    
endmodule