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
 * - 19/12/19: Create this file;
 * - 19/12/23: Add own module.
 *
 * Notes:
 *
 */

`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/SingleCycle/data_mem.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/SingleCycle/ex.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/SingleCycle/id.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/SingleCycle/if.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/SingleCycle/inst_mem.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/SingleCycle/mem.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/SingleCycle/register.v"

module riscv(

	input wire				 clk,
	input wire				 rst,         // high is reset
	
    // inst_mem
	input wire[31:0]         inst_i,	  // instruction
	output wire[31:0]        inst_addr_o, // instruction address
	output wire              inst_ce_o,	  // chip select signal

    // data_mem
	input wire[31:0]         data_i,      // load data from data_mem
	output wire              data_we_o,
    output wire              data_ce_o,
	output wire[31:0]        data_addr_o,
	output wire[31:0]        data_o       // store data to  data_mem

);

// mainControl

	Registers registers(
		.rs1(),
		.rs2(),
		.writeReg(WriteReg),
		.writedata(WriteData),
		.regwrite(RegWrite),
		.clk(clk),
		.rst(rsy),
		.rd1_o(),
		.rd2_o()
	);

// Execution, ALU

	ALU alu(
		.rs1(),
		.rs2(),
		ALUop(),
		.pc(),
		.zero(),
		.result()
	);

// stack_mem, perip_mem

// ADbus

	assign WriteData = MemToReg == 1 ? MemReadData : ALUresult;  // Write back

// PC update, lr, pc and update pc.

	IF if(
		.clk(clk),
		.rst(rst),
		.pc_i(),
		.pc_o()
	);




endmodule