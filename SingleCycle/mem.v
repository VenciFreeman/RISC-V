/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.

 * Description:
 * This file controls the read and write about data_mem.

 * Details:
 * - Read 32bit data from data_mem if instruction is lw;
 * - Write 32bit data into data_mem if instruction is sw;
 * - Do no operation if there is other instruction.

 * History:
 * - 19/12/05: Create this file;
 * - 19/12/23: Add PeriphMem and StackMem module.

 * Notes:
 *
 */

module PeriphMem(

    input   	 clk,
    input [31:0] address,
    input [31:0] writeData,
    input        memRead,
    input        memWrite,
    output[31:0] readData

    );

    reg [31:0] mem [1023:0];
    reg [31:0] ReadData;
    assign readData = ReadData;

/*
 * This always part controls the signal ReadData.
 */    
always @ (address or memRead or clk) begin
	if (address >= 32'h00002000 && address < 32'h00003000 && memRead)
			ReadData <= mem[((address & 32'h0000FFFF) - 32'h00002000) >> 2];
end

/*
 * This always part controls the reg mem.
 */ 
always @ (negedge clk) begin
	if (address >= 32'h00002000 && address < 32'h00003000 && memWrite)
			mem[((address & 32'h0000FFFF) - 32'h00002000) >> 2] <= writeData;
end

endmodule

module StackMem (

    input [31:0] Address,
    input [31:0] StackWRdata,
    input [31:0] NewSP,
    input        UpdateSP,
    input        WE,
    input [1:0]  StackOp,
    input        clk,
    input        rst,
    output[31:0] StackRDdata,
    output[31:0] SP

);

    reg [31:0] sp;
	reg [31:0] readData;
	reg [31:0] mem [1023:0];
    wire[31:0] sp_minus_4;

    assign sp_minus_4 = sp - 4;
    assign SP = sp;
    assign StackRDdata = readData;

always @ (*) begin
	if (Address >= 32'h00003000 && Address < 32'h00004000)
		readData <= mem[(sp & 32'h00000FFF) >> 2];
	else if (StackOp == 2'b11) // pop 
		readData <= mem[(sp & 32'h00000FFF) >> 2];
end

always @ (negedge clk) begin
	if (rst)
		sp <= 32'h00004000;
	else begin
		if(UpdateSP)
			sp <= NewSP;
		if(WE)
			if (Address >= 32'h00003000 && Address < 32'h00004000)
				mem[((Address) & 32'h00000FFF) >> 2] <= StackWRdata;
		else if (StackOp == 2'b10) begin  // push
			mem[((sp_minus_4 & 32'h00000FFF)) >> 2] <= StackWRdata;
			sp <= sp_minus_4;
		end
		else if (StackOp == 2'b11) // pop 
			sp <= sp + 4;
	end
end

endmodule
