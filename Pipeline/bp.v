/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.

 * Description:
 * This file determines whether a conditional branch (jump) in the instruction
 * flow of a program is likely to be taken or not.

 * Details:
 * No details.

 * History:
 * - 19/12/27: Create this file;
 * - 19/12/28: Fix some errors;
 * - 19/12/29: Finished!

 * Notes:
 */

module BRANCH_PRE(

	input   wire        rst,
	input   wire[31:0]  pc_i,
	input   wire[31:0]	inst_i,
	input   wire		Branch,
	input   wire		Accept,
	input   wire		Predict,
	input   wire		idSel,
	input   wire[31:0] 	idPC,											
	output  reg         PreBranch,
	output  reg [31:0]  PreAddr,
	output  reg			PreAccept,
	output  reg			PreSel
		
);

wire is_branch = (inst_i[6:0] == 7'b1100011);

/*
 * Keep predictor deterministic and side-effect free:
 * static not-taken prediction for conditional branches.
 */
always @ (*) begin
    if (rst) begin
        PreBranch <= 1'b0;
        PreAddr   <= 32'b0;
        PreAccept <= 1'b0;
        PreSel    <= 1'b0;
    end else if (is_branch) begin
        PreBranch <= 1'b1;
        PreAddr   <= pc_i + 32'd4;
        PreAccept <= 1'b0;
        PreSel    <= 1'b0;
    end else begin
        PreBranch <= 1'b0;
        PreAddr   <= 32'b0;
        PreAccept <= 1'b0;
        PreSel    <= 1'b0;
    end
end


endmodule