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
 * - 19/12/26: Update modules;
 * - 10/12/27: Update modules.
 
 * Notes:
 
 */

`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/SingleCycle/ex.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/SingleCycle/id.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/SingleCycle/if.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/SingleCycle/mem.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/SingleCycle/register.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/SingleCycle/wb.v"

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

	wire [4:0] 	id_aluop;
	wire [2:0] 	id_alusel;
	wire [31:0] id_reg1;
	wire [31:0] id_reg2;
	wire        id_wreg;
	wire [4:0] 	id_wd;
	wire [31:0] link_address;	
	wire [31:0] id_inst;

	wire [1:0]	reg1_read;
	wire [1:0] reg2_read;
	wire [31:0] reg1_data;
	wire [31:0] reg2_data;
	wire [4:0] 	reg1_addr;
	wire [4:0] 	reg2_addr;

	wire 		ex_wreg;
	wire [4:0]  ex_wd;
	wire [31:0] ex_wdata;
	wire [4:0]  ex_aluop_o;
	wire [31:0] ex_addr_o;
	wire [31:0] ex_reg2_o;

	wire 		mem_wreg_o;
	wire [4:0]  mem_wd_o;
	wire [31:0] mem_wdata_o;

	wire [4:0]  wb_wd;
	wire 		wb_wreg;
	wire [31:0] wb_wdata;

	wire 		id_branch_flag_o;
	wire [31:0] branch_target_address;

	PC pc(
		.clk(clk),
		.rst(rst),
		.Branch(id_branch_flag_o),
		.Addr(branch_target_address),
		.ce(inst_ce_o),
		.PC(inst_addr_o)
	);

	ID id(
		.rst(rst),
		.pc_i(inst_addr_o),
		.inst_i(inst_i),
		.RegData1(reg1_data),
		.RegData2(reg2_data),
		.RegRead1(reg1_read),
		.RegRead2(reg2_read),
		.RegAddr1(reg1_addr),
		.RegAddr2(reg2_addr),
		.ALUop(id_aluop),
		.ALUsel(id_alusel),
		.Reg1(id_reg1),
		.Reg2(id_reg2),
		.WriteData(id_wd),
		.WriteReg(id_wreg),
		.Branch(id_branch_flag_o),
		.BranchAddr(branch_target_address),
		.LinkAddr(link_address),
		.inst_o(id_inst)
	);

	Registers registers(
		.clk(clk),
		.rst(rst),
		.we(wb_wreg),
		.WriteAddr(wb_wd),
		.WriteData(wb_wdata),
		.ReadReg1(reg1_read),
		.ReadReg2(reg2_read),
		.ReadAddr1(reg1_addr),
		.ReadAddr2(reg2_addr),
		.ReadData1(reg1_data),
		.ReadData2(reg2_data)
	);

	EX ex(
		.rst(rst),
		.ALUop_i(id_aluop),
		.ALUsel_i(id_alusel),
		.Oprend1(id_reg1),
		.Oprend2(id_reg2),
		.WriteDataNum_i(id_wd),
		.WriteReg_i(id_wreg),
		.LinkAddr(link_address),
		.inst_i(id_inst),
		.WriteReg_o(ex_wreg),
		.ALUop_o(ex_aluop_o),
		.WriteDataNum_o(ex_wd),
		.WriteData_o(ex_wdata),
		.MemAddr_o(ex_addr_o),
		.Result(ex_reg2_o)
	);

	MEM mem(
		.rst(rst),
		.WriteReg_i(ex_wreg),
		.WriteDataAddr_i(ex_wd),
		.ALUop_i(ex_aluop_o),
		.WriteData_i(ex_wdata),
		.MemAddr_i(ex_addr_o),
		.Reg_i(ex_reg2_o),
		.MemData_i(data_o),
		.MemWE_o(data_we_o),
		.WriteReg_o(mem_wreg_o),
		.MemCE_o(data_ce_o),
		.WriteDataAddr_o(mem_wd_o),
		.WriteData_o(mem_wdata_o),
		.MemAddr_o(data_addr_o),
		.MemData_o(data_i)
	);

	WB wb(
		.rst(rst),
		.mem_wd(mem_wd_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),
		.wb_wd(wb_wd),
		.wb_wreg(wb_wreg),
		.wb_wdata(wb_wdata)
);

endmodule