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
 * - 19/12/27: Create this pipeline file.

 * Notes:
 *
 */

module EX(

	input	wire	    rst,
	input	wire[4:0]   ALUop_i,
    input   wire[31:0]  Oprend1,
    input   wire[31:0]  Oprend2,
    input   wire[4:0]   WriteDataNum_i,
	input 	wire		WriteReg_i,
	input	wire[31:0]  LinkAddr,
	input   wire[31:0]  inst_i,
	output	reg 		WriteReg_o,
	output	wire[4:0]	ALUop_o,
	output	reg [4:0]	WriteDataNum_o,
	output	reg [31:0]	WriteData_o,
    output  wire[31:0]  MemAddr_o,
    output  wire[31:0]  Result,

	output 	wire        branch_flag_o,
    output 	reg [31:0]  NewPC,
    output 	wire        StallReq
    );
    
    wire  jump;
    wire  branch;
    reg   cmp_flag;
	
    assign ALUop_o   = ALUop_i;
    assign Result    = Oprend2;
	assign MemAddr_o = Oprend1 + ((inst_i[6:0] == 7'b0000011)
					 ? {{20{inst_i[31:31]}}, inst_i[31:20]}
					 : {{20{inst_i[31:31]}}, inst_i[31:25], inst_i[11:7]});

	assign branch = ((ALUop_i == 5'b10001) || (ALUop_i == 5'b10010)) ? 1'b1 : 1'b0;
 	assign jump = (((branch == 1'b1) && (cmp_flag == 1'b1)) || ALUop_i == 5'b10000) ? 1'b1 : 1'b0;
	assign branch_flag_o = ((jump == 1'b1) && (NewPC != pc_i + 4)) ? 1'b1 : 1'b0;
	assign StallReq = 1'b0;
	
/*
 * This always part controls the WriteDatamNum_o.
 */    
always @ (*) begin
    WriteDataNum_o <= WriteDataNum_i;
end

/*
 * This always part controls the WriteReg_i.
 */    
always @ (*) begin
    WriteReg_o <= WriteReg_i;
end

always @ (*) begin
	if (rst)
		cmp_flag <= 1'b0;
	else begin
		case (ALUop_i)
        	5'b10001: cmp_flag <= (Oprend1 == Oprend2) ? 1'b1 : 1'b0; // beq
        	5'b10010: cmp_flag <= (Oprend1 < Oprend2)  ? 1'b1 : 1'b0; // blt
			default:  cmp_flag <= 32'b0;
		endcase
	end
end

always @ (*) begin
	if (rst)
		NewPC <= 32'b0;
	else begin
		case (ALUop_i)
		    5'b10000: NewPC <= LinkAddr; // jal
        	5'b10001: NewPC <= LinkAddr; // beq
        	5'b10010: NewPC <= LinkAddr; // blt
			default:  NewPC <= 32'b0;
		endcase
	end
end

/*
 * This always part controls the WriteData_o.
 */    
always @ (*) begin
	if (rst)
		WriteData_o <= 32'b0;
	else begin
		case (ALUop_i)
		    5'b10000: WriteData_o <= LinkAddr; 					// jal
        	5'b10001: WriteData_o <= LinkAddr; 					// beq
        	5'b10010: WriteData_o <= LinkAddr; 					// blt
        	5'b10100: WriteData_o <= 32'b0; 					// lw
            5'b10101: WriteData_o <= 32'b0; 					// sw
            5'b01100: WriteData_o <= Oprend1 +  Oprend2;  		// addi
            5'b01101: WriteData_o <= Oprend1 +  Oprend2;  		// add
            5'b01110: WriteData_o <= Oprend1 -  Oprend2;  		// sub
            5'b01000: WriteData_o <= Oprend1 << Oprend2[4:0];	// sll
            5'b00110: WriteData_o <= Oprend1 ^  Oprend2; 		// xor
            5'b01001: WriteData_o <= Oprend1 >> Oprend2[4:0];  	// srl
            5'b00101: WriteData_o <= Oprend1 |  Oprend2;  		// or
            5'b00100: WriteData_o <= Oprend1 &  Oprend2;  		// and
			default:  WriteData_o <= 32'b0;
		endcase
	end
end
 
endmodule