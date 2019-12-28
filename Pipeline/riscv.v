/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.
 
 * Description:
 * This file controls the CPU.
 
 * Details:
 
 * History:
 * - 19/12/27: Create this pipeline file.
 
 * Notes:
 
 */

`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/Pipeline/ex.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/Pipeline/ex_mem.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/Pipeline/id.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/Pipeline/id_ex.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/Pipeline/if.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/Pipeline/mem.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/Pipeline/mem_wb.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/Pipeline/register.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/Pipeline/wb.v"
`include "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/Pipeline/stall.v"

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
/*
	wire [4:0] 	id_ex_ALUop;
	wire [31:0] id_ex_Reg1;
	wire [31:0] id_ex_Reg2;
	wire        id_ex_WriteReg;
	wire [4:0] 	id_ex_WriteData;
	wire [31:0] id_ex_LinkAddress;	
	wire [31:0] id_ex_Inst;

	wire 		id_reg_Read1;
	wire 	    id_reg_Read2;
	wire [31:0] id_reg_Data1;
	wire [31:0] id_reg_Data2;
	wire [4:0] 	id_reg_Addr1;
	wire [4:0] 	id_reg_Addr2;

	wire 		ex_mem_WriteReg;
	wire [4:0]  ex_mem_WriteNum;
	wire [31:0] ex_mem_WriteData;
	wire [4:0]  ex_mem_ALUop;
	wire [31:0] ex_mem_Addr;
	wire [31:0] ex_mem_Reg;

	wire 		mem_wb_WriteReg;
	wire [4:0]  mem_wb_WriteNum;
	wire [31:0] mem_wb_WriteData;

	wire [4:0]  wb_reg_WriteAddr;
	wire 		wb_reg_we;
	wire [31:0] wb_reg_WriteData;

	wire 		pc_id_branch;
	wire [31:0] pc_id_address;
*/
	wire[`InstAddrBus] 			    pc;
	wire[`InstAddrBus] 				id_pc_i;
	wire[`InstBus] 					id_inst_i;
	
	//连接译码阶段ID模块的输出与ID/EX模块的输入
	wire[`AluOpBus] 				id_aluop_o;
	wire[`AluSelBus] 				id_alusel_o;
	wire[`RegBus] 					id_reg1_o;
	wire[`RegBus] 					id_reg2_o;
	wire 							id_wreg_o;
	wire[`RegAddrBus] 				id_wd_o;
	wire[`RegBus] 					id_link_address_o;	
	wire[`RegBus] 					id_inst_o;
	
	//连接ID/EX模块的输出与执行阶段EX模块的输入
	wire[`AluOpBus] 				ex_aluop_i;
	wire[`AluSelBus] 				ex_alusel_i;
	wire[`RegBus] 					ex_reg1_i;
	wire[`RegBus] 					ex_reg2_i;
	wire 							ex_wreg_i;
	wire[`RegAddrBus] 				ex_wd_i;
	wire[`RegBus] 					ex_link_address_i;	
	wire[`RegBus] 					ex_inst_i;
	
	//连接执行阶段EX模块的输出与EX/MEM模块的输入
	wire 							ex_wreg_o;
	wire[`RegAddrBus] 				ex_wd_o;
	wire[`RegBus] 					ex_wdata_o;
	wire[`AluOpBus] 				ex_aluop_o;
	wire[`RegBus] 					ex_mem_addr_o;
	wire[`RegBus] 					ex_reg1_o;
	wire[`RegBus] 					ex_reg2_o;	

	//连接EX/MEM模块的输出与访存阶段MEM模块的输入
	wire 							mem_wreg_i;
	wire[`RegAddrBus] 				mem_wd_i;
	wire[`RegBus] 					mem_wdata_i;
	wire[`AluOpBus] 				mem_aluop_i;
	wire[`RegBus] 					mem_mem_addr_i;
	wire[`RegBus] 					mem_reg1_i;
	wire[`RegBus] 					mem_reg2_i;	
		
	//连接访存阶段MEM模块的输出与MEM/WB模块的输入
	wire 							mem_wreg_o;
	wire[`RegAddrBus] 				mem_wd_o;
	wire[`RegBus] 					mem_wdata_o;
	
	//连接MEM/WB模块的输出与回写阶段的输入	
	wire 							wb_wreg_i;
	wire[`RegAddrBus] 				wb_wd_i;
	wire[`RegBus] 					wb_wdata_i;
	
	//连接译码阶段ID模块与通用寄存器Regfile模块
	wire 							reg1_read;
	wire 							reg2_read;
	wire[`RegBus] 					reg1_data;
	wire[`RegBus] 					reg2_data;
	wire[`RegAddrBus] 				reg1_addr;
	wire[`RegAddrBus] 				reg2_addr;
	
	wire 							id_branch_flag_o;
	wire[`RegBus] 					branch_target_address;

	wire[5:0] 						stall;
	wire 							stallreq_from_id_load;	
	wire 							stallreq_from_id_branch;	

	//branch_prediction
	wire 		 					id_is_branch;
    wire 		 					id_take_or_not;
    wire 		 					id_pre_true;
    wire 		 					id_sel;
    wire [`InstAddrBus] 	 		id_pc;

    wire 		 					pre_branch_flag;
    wire [`InstAddrBus] 	 		pre_branch_target_address;
	
    wire 		 					pre_take_or_not;
    wire 		 					pre_sel;
   
    wire 		 					if_id_take_or_not;
    wire 						 	if_id_sel;
	
	PC pc(
		.clk(clk),
		.rst(rst),
		.stall(stall),
		.Branch(id_branch_flag_o),
		.Addr(branch_target_address),	
		.pre_branch_flag_i(pre_branch_flag),
		.pre_branch_target_address_i(pre_branch_target_address),
		
		.pc(pc),
		.ce(inst_ce_o)		
	);
	
  assign inst_addr_o = pc;

	//IF/ID模块例化
	if_id if_id0(
		.clk(clk),
        .rst(rst),

        .stall(stall),
      
        .if_pc(pc),
        .if_inst(inst_i),

        .pre_take_or_not_i(pre_take_or_not),
        .pre_sel_i(pre_sel),
       
        .id_pc(id_pc_i),
        .id_inst(id_inst_i),
 
        .pre_take_or_not_o(if_id_take_or_not),
        .pre_sel_o(if_id_sel)
	);
	
	//译码阶段ID模块
	id id0(
		.rst(rst),
		.pc_i(id_pc_i),
		.inst_i(id_inst_i),
		
		.pre_take_or_not(if_id_take_or_not),
		.pre_sel(if_id_sel),
		
		.ex_aluop_i(ex_aluop_o),

		.reg1_data_i(reg1_data),
		.reg2_data_i(reg2_data),

		//处于执行阶段的指令要写入的目的寄存器信息
		.ex_wreg_i(ex_wreg_o),
		.ex_wdata_i(ex_wdata_o),
		.ex_wd_i(ex_wd_o),

		//处于访存阶段的指令要写入的目的寄存器信息
		.mem_wreg_i(mem_wreg_o),
		.mem_wdata_i(mem_wdata_o),
		.mem_wd_i(mem_wd_o),

		//送到regfile的信息
		.reg1_read_o(reg1_read),
		.reg2_read_o(reg2_read), 	  

		.reg1_addr_o(reg1_addr),
		.reg2_addr_o(reg2_addr), 
	  
		//送到ID/EX模块的信息
		.aluop_o(id_aluop_o),
		.alusel_o(id_alusel_o),
		.reg1_o(id_reg1_o),
		.reg2_o(id_reg2_o),
		.wd_o(id_wd_o),
		.wreg_o(id_wreg_o),
		.inst_o(id_inst_o),
		
		.branch_flag_o(id_branch_flag_o),
		.branch_target_address_o(branch_target_address),     
		.link_addr_o(id_link_address_o),
		
		.is_branch_o(id_is_branch),
		.take_or_not_o(id_take_or_not),
		.pre_true_o(id_pre_true),
		.sel_o(id_sel),
		.pc_o(id_pc),
		
		.stallreq_branch(stallreq_from_id_branch),
		.stallreq_load(stallreq_from_id_load)
	);

  //通用寄存器Regfile例化
	regfile regfile1(
		.clk (clk),
		.rst (rst),
		.we	(wb_wreg_i),
		.waddr (wb_wd_i),
		.wdata (wb_wdata_i),
		.re1 (reg1_read),
		.raddr1 (reg1_addr),
		.rdata1 (reg1_data),
		.re2 (reg2_read),
		.raddr2 (reg2_addr),
		.rdata2 (reg2_data)
	);

	//ID/EX模块
	id_ex id_ex0(
		.clk(clk),
		.rst(rst),
		
		.stall(stall),
		
		//从译码阶段ID模块传递的信息
		.id_aluop(id_aluop_o),
		.id_alusel(id_alusel_o),
		.id_reg1(id_reg1_o),
		.id_reg2(id_reg2_o),
		.id_wd(id_wd_o),
		.id_wreg(id_wreg_o),
		.id_link_address(id_link_address_o),
		.id_inst(id_inst_o),		
	
		//传递到执行阶段EX模块的信息
		.ex_aluop(ex_aluop_i),
		.ex_alusel(ex_alusel_i),
		.ex_link_address(ex_link_address_i),
		.ex_reg1(ex_reg1_i),
		.ex_reg2(ex_reg2_i),
		.ex_wd(ex_wd_i),
		.ex_wreg(ex_wreg_i),
		.ex_inst(ex_inst_i)		
	);		
	
	//EX模块
	ex ex0(
		.rst(rst),
	
		//送到执行阶段EX模块的信息
		.aluop_i(ex_aluop_i),
		.alusel_i(ex_alusel_i),
		.reg1_i(ex_reg1_i),
		.reg2_i(ex_reg2_i),
		.wd_i(ex_wd_i),
		.wreg_i(ex_wreg_i),
		.inst_i(ex_inst_i),
			  
		//EX模块的输出到EX/MEM模块信息
		.wd_o(ex_wd_o),
		.wreg_o(ex_wreg_o),
		.wdata_o(ex_wdata_o),
		
		.link_address_i(ex_link_address_i),
		
		.aluop_o(ex_aluop_o),
		.mem_addr_o(ex_mem_addr_o),
		.reg2_o(ex_reg2_o)
		
	);

	//EX/MEM模块
	ex_mem ex_mem0(
		.clk(clk),
		.rst(rst),
	  
		.stall(stall),
	  
		//来自执行阶段EX模块的信息	
		.ex_wd(ex_wd_o),
		.ex_wreg(ex_wreg_o),
		.ex_wdata(ex_wdata_o),
		
		.ex_aluop(ex_aluop_o),
		.ex_mem_addr(ex_mem_addr_o),
		.ex_reg2(ex_reg2_o),	

		//送到访存阶段MEM模块的信息
		.mem_wd(mem_wd_i),
		.mem_wreg(mem_wreg_i),
		.mem_wdata(mem_wdata_i),
		
		.mem_aluop(mem_aluop_i),
		.mem_mem_addr(mem_mem_addr_i),
		.mem_reg2(mem_reg2_i)
						       	
	);
	
	//MEM模块例化
	mem mem0(
		.rst(rst),
	
		//来自EX/MEM模块的信息	
		.wd_i(mem_wd_i),
		.wreg_i(mem_wreg_i),
		.wdata_i(mem_wdata_i),

		.aluop_i(mem_aluop_i),
		.mem_addr_i(mem_mem_addr_i),
		.reg2_i(mem_reg2_i),
	
		//来自memory的信息
		.mem_data_i(data_i),
	  
		//送到MEM/WB模块的信息
		.wd_o(mem_wd_o),
		.wreg_o(mem_wreg_o),
		.wdata_o(mem_wdata_o),
		
		//送到memory的信息
		.mem_addr_o(data_addr_o),
		.mem_we_o(data_we_o),
		.mem_sel_o(ram_sel_o),
		.mem_data_o(ram_data_o),
		.mem_ce_o(data_ce_o)		
	);

	//MEM/WB模块
	mem_wb mem_wb0(
		.clk(clk),
		.rst(rst),

		.stall(stall),

		//来自访存阶段MEM模块的信息	
		.mem_wd(mem_wd_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),		
	
		//送到回写阶段的信息
		.wb_wd(wb_wd_i),
		.wb_wreg(wb_wreg_i),
		.wb_wdata(wb_wdata_i)	
									       	
	);

	
	ctrl ctrl0(
		.rst(rst),
	
		.stallreq_from_id_load(stallreq_from_id_load),
		
		.stallreq_from_id_branch(stallreq_from_id_branch),

		.stall(stall)       	
	);
	
	branch_pre branch_pre0(
		.rst(rst),

		.pc_i(pc),
		.inst_i(inst_i),
	
		.id_is_branch(id_is_branch),
		.id_take_or_not(id_take_or_not),
		.id_pre_true(id_pre_true),
		.id_sel(id_sel),
		.id_pc(id_pc),

		.pre_branch_flag_o(pre_branch_flag),
		.pre_branch_target_address_o(pre_branch_target_address),

		.pre_take_or_not(pre_take_or_not),
		.pre_sel(pre_sel)
    );

endmodule