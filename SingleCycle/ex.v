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
 *   corresponding operation;
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

        input   [31:0]  oprend1,
        input   [31:0]  oprend2,
        input   [3:0]   aluCtr,
        input   [4:0]   shamt,
        output          zero,
        output  [31:0]  result

    );
    
    reg rZero;
    reg [31:0] rRes;

	    assign zero = rZero;
    assign result = rRes;
    
always @ (oprend1 or oprend2 or aluCtr or shamt) begin
	case (aluCtr)
		4'b0000: rRes = oprend1 & oprend2;	// AND	
		4'b0001: rRes = oprend1 | oprend2;	// OR
		4'b0010: rRes = oprend1 + oprend2;	// ADD
		4'b0011: rRes = oprend1 - oprend2;	// SUB
		4'b1010: rRes = oprend1 < oprend2 ? 1 : 0;	// SLT
		4'b1000: rRes = oprend2 << shamt;	// SHL
		4'b1001: rRes = oprend2 >> shamt;	// SHR
		4'b1100: rRes = oprend1;	// PUSH
	endcase
end
    
always @ (*)
	rZero <= (rRes == 0) ? 1 : 0;
    

    
endmodule