/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.
 *
 * Description:
 * This file controls the read and write about data_mem.
 *
 * Details:
 * - Read 32bit data from data_mem if instruction is lw;
 * - Write 32bit data into data_mem if instruction is sw;
 * - Do no operation if there is other instruction.
 *
 * History:
 * - 19/12/05: Create this file.
 *
 * Notes:
 *
 */

module mem(

	input wire			rst,
	// Info from executing.	
	input wire [4:0]    wd_i,
	input wire          wreg_i,
	input wire [31:0]	wdata_i,
	input wire [7:0]    aluop_i,
	input wire [31:0]   mem_addr_i,
	input wire [31:0]   reg2_i,
	// Info from memory.
	input wire [31:0]   mem_data_i,
	// Info send to write back.
	output reg [4:0]    wd_o,
	output reg          wreg_o,
	output reg [31:0]	wdata_o,
	// Infp send to memory.
	output reg [31:0]   mem_addr_o,
	output wire			mem_we_o,
	output reg [3:0]    mem_sel_o,
	output reg [31:0]   mem_data_o,
	output reg          mem_ce_o	

);

    parameter IDLE = 32'b0;

	wire [31:0] zero32;
	reg         mem_we;
			

            
endmodule