/************************************************************************************
 * Description:                                                                     *
 * Analyze ALUop and do operation.                                                  *       
 * Notes:                                                                           * 
 * This is demo code.                                                               *                                                                               *
 ************************************************************************************/

module ex(input wire		  rst,
		  input wire [7:0]    aluop_i,
		  input wire [2:0]    alusel_i,
		  input wire [31:0]   reg1_i,
		  input wire [31:0]   reg2_i,
		  input wire [4:0]    wd_i,
		  input wire          wreg_i,
		  input wire [31:0]   inst_i,
		  input wire [31:0]   link_address_i,
		  
		  output reg [4:0]    wd_o,
		  output reg          wreg_o,
		  output reg [31:0]	  wdata_o,
		  output wire[7:0]    aluop_o,
		  output wire[31:0]   mem_addr_o,
		  output wire[31:0]   reg2_o  			
);

	reg [31:0] logicout;
	reg [31:0] shiftres;
	reg [31:0] arithmeticres;
	
	wire[31:0] reg2_i_mux;
	wire[31:0] reg1_i_not;	
	wire[31:0] result_sum;
	wire 	   reg1_eq_reg2;
	wire 	   reg1_lt_reg2;

	reg 	   stallreq_for_madd_msub;		

endmodule