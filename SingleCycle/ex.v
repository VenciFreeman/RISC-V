/************************************************************************************
 * Description:                                                                     *
 * Analyze ALUop and do operation.                                                  *       
 * Notes:                                                                           * 
 * This is demo code.                                                               *                                                                               *
 ************************************************************************************/

module ex(
	
	input wire		  	rst,
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
	output reg [31:0]	wdata_o,
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

	parameter IDLE = 32'b00000000000000000000000000000000;	

	assign aluop_o = aluop_i;
	
	assign mem_addr_o = ((aluop_i == 8'b11101000) || 
  						 (aluop_i == 8'b11101001) ||
  						 (aluop_i == 8'b11101011)) ? reg1_i + {{21{inst_i[31]}}, inst_i[30:25],inst_i[11:7]} :
													reg1_i + {{21{inst_i[31]}}, inst_i[30:20]};
													
	assign reg2_o = reg2_i; 	
	

always @ (*) begin

	if(rst == 1'b1)
		logicout <= IDLE;

	else begin
		case (aluop_i)
			8'b00100100: logicout <= reg1_i & reg2_i;
			8'b00100101: logicout <= reg1_i | reg2_i;
			8'b00100110: logicout <= reg1_i ^ reg2_i;
			default:	 logicout <= IDLE;
		endcase
	end

end


always @ (*) begin

	if(rst == 1'b1)
		shiftres <= IDLE;

	else begin
		case (aluop_i)
			8'b01111100: shiftres <= reg1_i << reg2_i[4:0] ;
			8'b00000010: shiftres <= reg1_i >> reg2_i[4:0];
			8'b00000011: shiftres <= ({32{reg1_i[31]}} << (6'd32-{1'b0, reg2_i[4:0]})) | reg1_i >> reg2_i[4:0];
			default: 	 shiftres <= IDLE;
		endcase
	end

end
	
	
	assign reg2_i_mux = ((aluop_i == 8'b00100010) || (aluop_i == 8'b00101010)) ? (~reg2_i)+1 : reg2_i;

	assign result_sum = reg1_i + reg2_i_mux;										 
							
	assign reg1_lt_reg2 = (aluop_i == 8'b00101010)
						? ((reg1_i[31] && !reg2_i[31]) || (!reg1_i[31] && !reg2_i[31] && result_sum[31])|| (reg1_i[31] && reg2_i[31] && result_sum[31]))
			            : (reg1_i < reg2_i);

	assign reg1_i_not = ~reg1_i;


always @ (*) begin
	if(rst == 1'b1) arithmeticres <= 32'b00000000000000000000000000000000;

	else begin
		case (aluop_i)
			8'b0010101x: arithmeticres <= reg1_lt_reg2;
			8'b00100000: arithmeticres <= result_sum; 
			8'b00100010: arithmeticres <= result_sum; 	
			default: 	 arithmeticres <= IDLE;
		endcase
	end
	
end


always @ (*) begin

	wd_o <= wd_i;
	wreg_o <= wreg_i;

	case (alusel_i) 
		3'b001:  wdata_o <= logicout;
		3'b010:  wdata_o <= shiftres; 	
		3'b100:  wdata_o <= arithmeticres;
		3'b110:  wdata_o <= link_address_i;
		default: wdata_o <= IDLE;
	endcase

end	 	

endmodule