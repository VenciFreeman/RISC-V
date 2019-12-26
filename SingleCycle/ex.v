/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.

 * Description:
 * Do some operations according to ALUop and the 2 source oprands.

 * Details:
 * - Use the ALUop and the two source operands decoded in id.v to perform the
 *   cordponding operation;
 * - If ALUop indicates that it's an addition operation, the two operands will be
 *	 added;
 * - The sub operation can be implemented by complement, etc.

 * History:
 * - 19/12/05: Create this file;
 * - 19/12/19：Edit the ALU module and the RISC-V instructions;
 * - 19/12/23: Modify the format and logic;
 * - 19/12/26: Edit the module.(I think it's finished.)

 * Notes:
 *
 */

module EX(

	input	wire	    rst,
	input	wire[4:0]   ALUop_i,
	input	wire[2:0]	ALUsel_i,
    input   wire[31:0]  Oprend1,
    input   wire[31:0]  Oprend2,
    input   wire[4:0]   WriteDataNum_i,
	input 	wire		WriteReg_i,
	input	wire[31:0]  LinkAddr,
	input   wire[31:0]  inst_i,
	output	reg 		WriteReg_o,
	output	reg	[4:0]	ALUop_o,
	output	reg [4:0]	WriteDataNum_o,
	output	reg	[31:0]	WriteData_o,
    output  reg [31:0]  MemAddr_o,
    output  reg [31:0]  Result

    );
    
    assign ALUop_o = ALUop_i;
	assign MemAddr_o = Oprend1 + ( (inst_i[6:0] == 7'b0000011) ? {{20{inst_i[31:31]}}, inst_i[31:20]} : {{20{inst_i[31:31]}}, inst_i[31:25], inst_i[11:7]});
    assign Result = Oprend2;
	assign WriteData_o = WriteDataNum_i;
	assign WriteReg_o = WriteReg_i;

    reg[31:0] Logic;
    reg[31:0] Shift;
    reg[31:0] Arithme;

    wire[31:0] Oprend2_mux;
    wire[31:0] Result_sum;

    assign Oprend2_mux = (ALUop_i == 5'b01110) ? (~(Oprend2) + 1) : Oprend2;
    assign Result_sum = Oprend1 + Oprend2_mux;

/*
 * This always part controls the signal Logic.
 */    
always @ (*) begin
	if (rst)
		Logic <= 32'b0;
	else begin
		case (ALUop_i)
			5'b00100: Logic = Oprend1 & Oprend2;  // AND
			5'b00101: Logic = Oprend1 | Oprend2;  // OR
			5'b00110: Logic = Oprend1 ^ Oprend2;  // XOR
			default:  Logic = 32'b0;
		endcase
	end
end

/*
 * This always part controls the signal Shift.
 */    
always @ (*) begin
	if (rst)
		Shift <= 32'b0;
	else begin
		case (ALUop_i)
			5'b01000: Shift = Oprend1 << Oprend2[4:0];  // sll
			5'b01001: Shift = Oprend1 >> Oprend2[4:0];  // srl
		endcase
	end
end

/*
 * This always part controls the signal Arithme.
 */    
always @ (*) begin
	if (rst)
		Arithme = 32'b0;
	else begin
		casex (ALUop_i)
			5'b0x100: Arithme = Result_sum;
			5'b01110: Arithme = Result_sum;
			default:  Arithme = 32'b0;
		endcase
	end
end

/*
 * This always part controls the signal WriteData_o.
 */    
always @ (*) begin
	case (ALUsel_i)
		3'b001: WriteData_o = Logic;
		3'b010: WriteData_o = Shift;
		3'b011: WriteData_o = Arithme;
		3'b100: WriteData_o = LinkAddr;
		default:WriteData_o = 32'b0;
	endcase
end
 
endmodule