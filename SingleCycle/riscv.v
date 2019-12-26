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

	wire [5:0] ReadReg1;
    wire [5:0] ReadReg2;
    wire [5:0] WriteReg;
	wire [31:0] writedata;
	wire [31:0] RegData1;
    wire [31:0] RegData2;

	assign readReg1 = rs1;
    assign readReg2 = rs2;
    assign WriteReg = (regDst == 0)?rs2:rd;
	assign writedata = data_i[31:0];

	Registers registers(
		.readReg1(readReg1),
		.readReg2(readReg2),
		.writeReg(WriteReg),
		.writedata(writedata),
		.regwrite(RegWrite),
		.clk(clk),
		.rst(rst),
		.rd1_o(RegData1),
		.rd2_o(RegData2)
	);

// Execution, ALU

    wire [31:0] ALUinputA;
    wire [31:0] ALUinputB;
    wire [31:0] ALUresult;
    wire ZERO;

    assign ALUinputA = RegData1;
    assign ALUinputB = (ALUsrc == 0) ? RegData2 : (needZEXT == 1 ? Imm16ZEXT : Imm16SEXT);
	ALU alu(
		.oprend1(ALUinputA),
		.oprend2(ALUinputB),
		.ALUop(ALUop),
		.pc(),
		.zero(ZERO),
		.result(ALUresult)
	);

// stack_mem, perip_mem

// ADbus

	// assign WriteData = MemToReg == 1 ? MemReadData : ALUresult;  // Write back

// PC update, lr, pc and update pc.

	PC pc(
		.clk(clk),
		.rst(rst),
		.Branch(),
		.Zero(ZERO),
		.Jump(Jump),
		.imm(imm),
		.currPC(currPC)
		.nextPC(nextPC)
	);

endmodule