/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.
 *
 * Description:
 * This file controls the CPU.
 *
 * Details:
 *
 * History:
 * - 19/12/19: Create this file.
 *
 * Notes:
 *
 */

`include "data_mem.v"
`include "ex.v"
`include "id.v"
`include "if.v"
`include "inst_mem.v"
`include "mem.v"
`include "register.v"

module riscv(

	input wire				 clk,
	input wire				 rst,        // high is reset
	
    // inst_mem
	input wire[31:0]         inst_i,
	output wire[31:0]        inst_addr_o,
	output wire              inst_ce_o,	

    // data_mem
	input wire[31:0]         data_i,      // load data from data_mem
	output wire              data_we_o,
    output wire              data_ce_o,
	output wire[31:0]        data_addr_o,
	output wire[31:0]        data_o       // store data to  data_mem

);

//  instance your module  below





endmodule