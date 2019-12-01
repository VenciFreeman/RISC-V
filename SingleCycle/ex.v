/************************************************************************************
 * Description:                                                                     *
 * Analyze ALUop and do operation.                                                  *       
 * Notes:                                                                           * 
 * This is demo code.                                                               *                                                                               *
 ************************************************************************************/
`include "define.v"

module ex(
	input wire					  rst,
	input wire[`AluOpBus]         aluop_i,
	input wire[`AluSelBus]        alusel_i,
	input wire[`RegBus]           reg1_i,
	input wire[`RegBus]           reg2_i,
	input wire[`RegAddrBus]       wd_i,
	input wire                    wreg_i,
	input wire[`RegBus]           inst_i,
	
	input wire[`RegBus]           link_address_i,
	
	output reg[`RegAddrBus]       wd_o,
	output reg                    wreg_o,
	output reg[`RegBus]			  wdata_o,

	output wire[`AluOpBus]        aluop_o,
	output wire[`RegBus]          mem_addr_o,
	output wire[`RegBus]          reg2_o  			
);

	reg[`RegBus] logicout;
	reg[`RegBus] shiftres;
	reg[`RegBus] arithmeticres;
	
	wire[`RegBus] reg2_i_mux;
	wire[`RegBus] reg1_i_not;	
	wire[`RegBus] result_sum;
	wire 		  reg1_eq_reg2;
	wire 		  reg1_lt_reg2;
	
	reg stallreq_for_madd_msub;		

	assign aluop_o = aluop_i;
	
	assign mem_addr_o = ((aluop_i == `EXE_SB_OP) || 
  						 (aluop_i == `EXE_SH_OP) ||
  						 (aluop_i == `EXE_SW_OP)) ? reg1_i + {{21{inst_i[31]}}, inst_i[30:25],inst_i[11:7]} :
													reg1_i + {{21{inst_i[31]}}, inst_i[30:20]};
													
	assign reg2_o = reg2_i; 	
	
	always @ (*) begin
		if(rst == `RstEnable) begin
			logicout <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_OR_OP:			begin
					logicout <= reg1_i | reg2_i;
				end
				`EXE_AND_OP:		begin
					logicout <= reg1_i & reg2_i;
				end
				`EXE_XOR_OP:		begin
					logicout <= reg1_i ^ reg2_i;
				end
				default:			begin
					logicout <= `ZeroWord;
				end
			endcase
		end  //if
	end      //always
	//shiftres
	always @ (*) begin
		if(rst == `RstEnable) begin
			shiftres <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_SLL_OP:		begin
					shiftres <= reg1_i << reg2_i[4:0] ;
				end
				`EXE_SRL_OP:		begin
					shiftres <= reg1_i >> reg2_i[4:0];
				end
				`EXE_SRA_OP:		begin
					shiftres <= ({32{reg1_i[31]}} << (6'd32-{1'b0, reg2_i[4:0]})) | reg1_i >> reg2_i[4:0];
				end
				default:			begin
					shiftres <= `ZeroWord;
				end
			endcase
			
		end    //if
	end      //always
	
	assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SLT_OP)) ? (~reg2_i)+1 : reg2_i;

	assign result_sum = reg1_i + reg2_i_mux;										 
							
	assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP)) ?
						  ((reg1_i[31] && !reg2_i[31]) || (!reg1_i[31] && !reg2_i[31] && result_sum[31])|| (reg1_i[31] && reg2_i[31] && result_sum[31]))
			              :	(reg1_i < reg2_i);

	assign reg1_i_not = ~reg1_i;
							
	always @ (*) begin
		if(rst == `RstEnable) begin
			arithmeticres <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_SLT_OP, `EXE_SLTU_OP:		begin
					arithmeticres <= reg1_lt_reg2 ;
				end
				`EXE_ADD_OP:		begin
					arithmeticres <= result_sum; 
				end
				`EXE_SUB_OP:		begin
					arithmeticres <= result_sum; 
				end		
				default:				begin
					arithmeticres <= `ZeroWord;
				end
			endcase
		end
	end

    always @ (*) begin
		wd_o <= wd_i;
		wreg_o <= wreg_i;			
		case ( alusel_i ) 
			`EXE_RES_LOGIC:		begin
				wdata_o <= logicout;
			end
			`EXE_RES_SHIFT:		begin
				wdata_o <= shiftres;
			end	 	
			`EXE_RES_ARITHMETIC:begin
				wdata_o <= arithmeticres;
			end	
			`EXE_RES_JUMP_BRANCH:	begin
				wdata_o <= link_address_i;
			end	 	
			default:			begin
				wdata_o <= `ZeroWord;
			end
		endcase
	end	 	

endmodule