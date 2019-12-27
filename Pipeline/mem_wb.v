/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.

 * Description:

 * Details:
 * - Sequential logic;
 * - Pass the result data to be written to the register, the destination
 *   register address, the write register flag and other signals.

 * History:
 * - 19/12/27: Create this file.

 * Notes:
 */
 
module mem_wb(

	input   wire        clk,
	input   wire        rst,
	input   wire[5:0]   stall,	
	input   wire[4:0]   mem_wd,
	input   wire        mem_wreg,
	input   wire[31:0]	mem_wdata,
	output  reg [4:0]   wb_wd,
	output  reg         wb_wreg,
	output  reg [31:0]	wb_wdata	       
	
);

always @ (posedge clk) begin
    if (rst)
        wb_wd <= 5'b0;
    else if (stall[5:4] == 2'b01)
        wb_wd <= 5'b0;
    else if (!stall[4])
        wb_wd <= mem_wd;
end

always @ (posedge clk) begin
    if (rst)
        wb_wreg <= 1'b0;
    else if (stall[5:4] == 2'b01)
        wb_wreg <= 1'b0;
    else if (!stall[4])
        wb_wreg <= mem_wreg;
end

always @ (posedge clk) begin
    if (rst)
        wb_wdata <= 32'b0;
    else if (stall[5:4] == 2'b01)
        wb_wdata <= 32'b0;
    else if (!stall[4])
        wb_wdata <= mem_wdata;
end			

endmodule