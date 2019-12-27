/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.

 * Description:
 * Branch Predict.

 * Details:

 * History:
 * - 19/12/27: Create this file.

 * Notes:

 */

module branch_pre(

	input   wire        rst,
	//from if
	input   wire[31:0]  pc_i,
	input   wire[31:0]	inst_i,
	//from id
	input   wire		id_is_branch,
	input   wire		id_take_or_not,
	input   wire		id_pre_true,
	input   wire		id_sel,
	input   wire[31:0] 	id_pc,											
	//to pc_reg
	output  reg         pre_branch_flag_o,
	output  reg [31:0]  pre_branch_target_address_o,
	//to id
	output  reg			pre_take_or_not,
	output  reg			pre_sel
		
);

	reg [0:9]   overall_addr_rec[0:4095];
	reg [1:0]	overall_pre[0:1023];
	
	reg [11:0] 	global_rec;
	reg [1:0] 	global_pre[0:4095];
	
	reg [0:9] 	local_addr_rec[0:1023];
	reg [1:0]	local_pre[0:1023];
	
	integer i;

always @ (*) begin
    if (rst)
        for(i = 0; i < 4096; i = i + 1)
				overall_addr_rec[i] = 10'b0;
end

always @ (*) begin
    if (rst)
        for(i = 0; i < 1024; i = i + 1)
			local_addr_rec[i] <= 10'b0;
end

always @ (*) begin
    if (rst)
        for(i = 0; i < 4096; i = i + 1)
			global_pre[i] = 2'b0;
    else if (id_is_branch && id_pre_true && id_sel && global_pre[global_rec] < 3)
        global_pre[global_rec] = global_pre[global_rec] + 1;
    else if (id_is_branch && !id_pre_true && id_sel && global_pre[global_rec] > 0)
        global_pre[global_rec] = global_pre[global_rec] - 1;
    global_rec <= (global_rec << 1 | id_take_or_not);
end

always @ (*) begin
    if (rst)
        for(i = 0; i < 1024; i = i + 1)
			local_pre[i] <= 2'b0;
    else if (id_is_branch && id_pre_true && !id_sel && local_pre[local_addr_rec[id_pc[11:2]]] < 3)
        local_pre[local_addr_rec[id_pc[11:2]]] <= local_pre[local_addr_rec[id_pc[11:2]]] + 1;
    else if (id_is_branch && !id_pre_true && !id_sel && local_pre[local_addr_rec[id_pc[11:2]]] > 0)
        local_pre[local_addr_rec[id_pc[11:2]]] <= local_pre[local_addr_rec[id_pc[11:2]]] - 1;
end

always @ (*) begin
    if (rst)
        global_pre = 12'b0;
end

always @ (*) begin
    if (rst)
        pre_branch_flag_o <= 1'b0;
    else if (inst_i[6:0] == 7'b1100011)
        pre_branch_flag_o <= 1'b1;
end

always @ (*) begin
    if (rst)
        pre_branch_target_address_o <= 32'b0;
    else if (inst_i[6:0] == 7'b1100011)
        if (!overall_pre[overall_addr_rec[pc_i[13:2]]][1]) begin
            if (!local_pre[local_addr_rec[pc_i[11:2]]][1])
                pre_branch_target_address_o <= pc_i + 4;
            else
                pre_branch_target_address_o <= pc_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
        end
        else begin
            if (global_pre[global_rec][1] == 0)
                pre_branch_target_address_o <= pc_i + 4;
            else
                pre_branch_target_address_o <= pc_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
        end
end

always @ (*) begin
    if (rst)
        pre_take_or_not <= 1'b0;
    else if (inst_i[6:0] == 7'b1100011)
        if (!overall_pre[overall_addr_rec[pc_i[13:2]]][1]) begin
            if (!local_pre[local_addr_rec[pc_i[11:2]]][1])
                pre_take_or_not <= 1'b0;
            else
                pre_take_or_not <= 1'b1;
        end
        else begin
            if (global_pre[global_rec][1] == 0)
                pre_take_or_not <= 1'b0;
            else
                pre_take_or_not <= 1'b1;
        end
end


always @ (*) begin
	if (rst) 
		pre_sel <= 1'b0;
	else if (inst_i[6:0] == 7'b1100011) 
		if (overall_pre[overall_addr_rec[pc_i[13:2]]][1] == 0)
			pre_sel <= 1'b0;
        else
			pre_sel <= 1'b1;
    	else pre_branch_flag_o <= 1'b0;
end


endmodule