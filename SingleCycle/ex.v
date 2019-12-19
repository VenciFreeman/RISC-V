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
 * - 19/12/19：Edit the ALU module.
 *
 * Notes:
 *
 */

module ALU(

        input   [31:0]  rs1,
        input   [31:0]  rs2,
        input   [5:0]   ALUop,
        output          zero,
        output  [31:0]  result

    );
    
    reg rZero;
    reg [31:0] rd;

	assign zero = rZero;
    assign result = rd;
    
always @ (rs1 or rs2 or ALUop or shamt) begin
	case (ALUop)
		6'b000001: rd = rs1 + rs2;								// add
		6'b000010: rd = rs1 - rs2;								// sub
		6'b000011; rd = rs1 << rs2;								// sll
		6'b000100; begin rd = pc + 4; pc += sext(offset); end	// jal
		6'b000101; rd = rd + sext(imm);							// addi
		6'b000110; rd = rs1 & rs2;								// and
		6'b000111; rd = rs1 | rs2;								// or
		6'b001000; rd = rs1 ^ rs2;								// xor
		6'b001001; if (rs1 > rs2) pc += sext(offset);			// blt
		6'b001010; if (rs1 + 8 == 0) pc += sext(offset);		// beq
		6'b001011; rd = rs1 >> rs2;								// srl
		6'b001100; rd]= sext(M[rs1 + sext(offset)]);			// lw
		6'b001101; M[rs1] + sext(offset) = rs2;					// sw
		default: break;
	endcase
end
    
always @ (*)
	rZero <= (rd == 0) ? 1 : 0;
    
module SEXT(

        input   [15:0]  inst,
        output  [31:0]  data

    );
    
    reg [31:0] Data;
    
always @ (inst)
	Data <= ((inst & 16'h8000) == 16'h8000 ? 32'hffff0000 : 32'h00000000) | inst;
    
    assign data = Data;
    
endmodule