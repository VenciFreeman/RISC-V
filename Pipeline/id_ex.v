/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.

 * Description:

 * Details:
 * - Sequential logic;
 * - Pass the decoded ALUop, source operand, destination register address,
 *   write register flag and other signals in id.v.
 * - When the pipeline is blocked, the above signals remain unchanged or
 *   cleared (Bubble).

 * History:
 * - 19/12/27: Create this file.

 * Notes:
 */

module id_ex(

	input   wire        clk,
	input   wire        rst,
	input   wire[5:0]   stall,
	input   wire[4:0]   idALUop,
	input   wire[2:0]   idALUsel,
	input   wire[31:0]  idReg1,
	input   wire[31:0]  idReg2,
	input   wire[4:0]   idWriteNum,
	input   wire        idWriteReg,	
	input   wire[31:0]  idLinkAddr,
	input   wire[31:0]  idInst,	
	output  reg [4:0]   exALUop,
	output  reg [2:0]   exALUsel,
	output  reg [31:0]  exLinkAddr,
	output  reg [31:0]  exInst,
	output  reg [31:0]  exReg1,
	output  reg [31:0]  exReg2,
	output  reg [4:0]   exWriteNum,
	output  reg         exWriteReg
	
);

always @ (posedge clk) begin
    if (rst)
        exALUsel <= 3'b0;
    else if (stall[3:2] == 2'b01)
        exALUsel <= 3'b0;
    else if (!stall[2])
        exALUsel <= idALUop;
end

always @ (posedge clk) begin
    if (rst)
        exALUop <= 5'b0;
    else if (stall[3:2] == 2'b01)
        exALUop <= 5'b0;
    else if (!stall[2])
        exALUop <= idALUsel;
end

always @ (posedge clk) begin
    if (rst)
        exReg1 <= 32'b0;
    else if (stall[3:2] == 2'b01)
        exReg1 <= 32'b0;
    else if (!stall[2])
        exReg1 <= idReg1;
end

always @ (posedge clk) begin
    if (rst)
        exReg2 <= 32'b0;
    else if (stall[3:2] == 2'b01)
        exReg2 <= 32'b0;
    else if (!stall[2])
        exReg2 <= idReg2;
end

always @ (posedge clk) begin
    if (rst)
        exWriteNum <= 5'b0;
    else if (stall[3:2] == 2'b01)
        exWriteNum <= 5'b0;
    else if (!stall[2])
        exWriteNum <= idWriteNum;
end

always @ (posedge clk) begin
    if (rst)
        exWriteReg <= 1'b0;
    else if (stall[3:2] == 2'b01)
        exWriteReg <= 1'b0;
    else if (!stall[2])
        exWriteReg <= idWriteReg;
end

always @ (posedge clk) begin
    if (rst)
        exLinkAddr <= 32'b0;
    else if (stall[3:2] == 2'b01)
        exLinkAddr <= 32'b0;
    else if (!stall[2])
        exLinkAddr <= idLinkAddr;
end

always @ (posedge clk) begin
    if (rst)
        exInst <= 32'b0;
    else if (stall[3:2] == 2'b01)
        exInst <= 32'b0;
    else if (!stall[2])
        exInst <= idInst;
end

endmodule