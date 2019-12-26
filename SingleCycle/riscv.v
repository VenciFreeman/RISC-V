/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.
 
 * Description:
 * This file controls the CPU.
 
 * Details:
 
 * History:
 * - 19/12/19: Create this file;
 * - 19/12/23: Add own modules;
 * - 19/12/24: Add own modules;
 * - 19/12/26: Update modules.
 
 * Notes:
 
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

	wire [6:0] Opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire       RegDst;
    wire       RegWrite;
    wire       MemRead;
    wire       MemWrite;
    wire       MemToReg;
    wire       ALUsrc;
    wire [6:0] ALUop;
    wire       Branch;
    wire [1:0] Jump;
    wire       Link;
    wire       ALUOp1;
    wire       ALUOp0;

	wire [5:0] rs1;
	wire [5:0] rs2;
	wire [5:0] rd;
	wire [11:0] imm12;
	wire [19:0] imm20;

	assign Opcode = inst_i[6:0];
	assign funct3 = inst_i[14:12];
	assign funct7 = inst_i[31:25];
	assign RegDst = inst_i[];
	assign RegWrite = inst_i[];
	assign RegRead = inst_i[];

	assign rs1 = inst_i[19:15];
	assign rs2 = inst_i[24:20];
	assign rd  = inst_i[11:7];

	Control control(
		.Opcode(Opcode),
		.funct3(funct3),
		.funct7(funct7),
		.RegDst(RegDst),
		.RegWrite(RegWrite),
		.MemRead(MemRead),
		.MemWrite(MemWrite),
		.MemToReg(MemToReg),
		.ALUsrc(ALUsrc),
		.ALUop(ALUop),
		.Branch(Branch),
		.Jump(Jump),
		.Link(Link),
    	.ALUOp1(ALUOp1),
    	.ALUOp0(ALUOp0)
	);

	Registers registers(
		.readReg1(),
		.readReg2(),
		.writeReg(WriteReg),
		.writedata(WriteData),
		.regwrite(RegWrite),
		.clk(clk),
		.rst(rst),
		.rd1_o(),
		.rd2_o()
	);

// Execution, ALU

	ALU alu(
		.oprend1(),
		.oprend2(),
		.ALUop(),
		.pc(),
		.zero(),
		.result()
	);

// stack_mem, perip_mem

// ADbus

	// assign WriteData = MemToReg == 1 ? MemReadData : ALUresult;  // Write back

// PC update, lr, pc and update pc.

	PC pc(
		.clk(clk),
		.rst(rst),
		.Branch(),
		.Zero(),
		.Jump(),
		.imm(),
		.currPC()
		.nextPC()
	);

endmodule