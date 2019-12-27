/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.

 * Description:
 * This file determines the ALUop and determines what to do.

 * Details:
 * - Decode the instruction, get ALUop by opcode, funct3 and funct7;
 * - Determine if the register needs to be read or not and send the register
 *   numbers rs1, rs2 to the register file, and read the corresponding data as the
 *   source operand;
 * - Determine if the register needs to be written or not then output target
 *   register number rd and write register flag for register write back;
 * - Determine if the branch instruction is true or not and calculate the jump
 *   address (or in ex.v);
 * - Sign extension (or unsigned extension) for instructions containing immediate
 *   values as one of the source operands.

 * History:
 * - 19/12/27: Create this pipeline file.

 * Notes:
 *
 ***************************************************************************************
 * Inst * ALUSrc * MemToReg * RegWrite * MemRead * MemWrite * Branch * ALUOp1 * ALUOp0 *
 ***************************************************************************************
 *   R  *    0   *     0    *     1    *    0    *     0    *    0   *    1   *    0   *
 ***************************************************************************************
 *  lw  *    1   *     1    *     1    *    1    *     0    *    0   *    0   *    0   *
 ***************************************************************************************
 *  sw  *    1   *     x    *     0    *    0    *     1    *    0   *    0   *    0   *
 ***************************************************************************************
 * beq  *    0   *     x    *     0    *    0    *     0    *    1   *    0   *    1   *
 ***************************************************************************************
 *
 */

module ID(

    input   wire        rst,
    input   wire[31:0]  pc_i,
    input   wire[31:0]  inst_i,
    input   wire[31:0]  RegData1,
    input   wire[31:0]  RegData2,

    input   wire[4:0]	ex_aluop_i,
	input   wire		ex_wreg_i,
	input   wire[31:0]	ex_wdata_i,
	input   wire[4:0]   ex_wd_i,
	input   wire		mem_wreg_i,
	input   wire[31:0]	mem_wdata_i,
	input   wire[4:0]   mem_wd_i,
    input   wire 		pre_take_or_not,
    input   wire		pre_sel,
    
    output  reg [1:0]   RegRead1,
    output  reg [1:0]   RegRead2,
    output  reg [4:0]   RegAddr1,
    output  reg [4:0]   RegAddr2,

    output  reg [4:0]   ALUop,
    output  reg [2:0]   ALUsel,
    output  reg [31:0]  Reg1,
    output  reg [31:0]  Reg2,
    output  reg [4:0]   WriteData,
    output  reg         WriteReg,

    output  reg         Branch,
    output  reg [31:0]  BranchAddr,
    output  reg [31:0]  LinkAddr,
    output  wire[31:0]  inst_o,

    output  reg			is_branch_o,
	output  reg			take_or_not_o,
	output  reg			pre_true_o,
	output  wire		sel_o,
	output  wire[31:0] 	pc_o,
    output  reg         stallreq_branch,	
	output  wire        stallreq_load

);

    assign inst_o = inst_i;
    assign sel_o = pre_sel;
	assign pc_o = pc_i;

    wire[4:0] rs1_addr = inst_i[19:15];
    wire[4:0] rs2_addr = inst_i[24:20];
    wire[4:0] rd_addr = inst_i[11:7];
    wire[31:0] pc_add_4;
    wire[31:0] pc_add_imm_B;
    wire[31:0] pc_add_imm_J;

    wire[31:0] imm_I = {{21{inst_i[31:31]}}, inst_i[30:25], inst_i[24:21], inst_i[20:20]};
    wire[31:0] imm_S = {{21{inst_i[31:31]}}, inst_i[30:25], inst_i[11: 8], inst_i[7:7]};
    wire[31:0] imm_B = {{20{inst_i[31:31]}}, inst_i[ 7: 7], inst_i[30:25], inst_i[11:8], 1'b0};
    wire[31:0] imm_U =     {inst_i[31:31],   inst_i[30:20], inst_i[19:12], {12{1'b0}}};
    wire[31:0] imm_J = {{12{inst_i[31:31]}}, inst_i[19:12], inst_i[20:20], inst_i[30:25], inst_i[24:21], 1'b0};

    reg [31:0] imm;
    reg inst_valid;

    assign pc_add_4 = pc_i + 4;
    assign pc_add_imm_B = pc_i + imm_B;
    assign pc_add_imm_J = pc_i + imm_J;

    reg stallreq_for_reg1_loadrelate;
	reg stallreq_for_reg2_loadrelate;
	wire pre_inst_is_load;

    assign pc_plus_4 = pc_i + 4;
	assign stallreq_load = stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;
	assign pre_inst_is_load = ( (ex_aluop_i == `EXE_LB_OP) || 
  								(ex_aluop_i == `EXE_LBU_OP)||
  								(ex_aluop_i == `EXE_LH_OP) ||
  								(ex_aluop_i == `EXE_LHU_OP)||
  								(ex_aluop_i == `EXE_LW_OP) ) ? 1'b1 : 1'b0;


always @ (*) begin
    if (rst)
        ALUop = 5'b0;
    else begin
        casex (inst_i)
            32'bxxxxxxxxxxxxxxxxxxxxxxxxx1101111: ALUop = 5'b10000;  // jal
            32'bxxxxxxxxxxxxxxxxx000xxxxx1100011: ALUop = 5'b10001;  // beq
            32'bxxxxxxxxxxxxxxxxx100xxxxx1100011: ALUop = 5'b10010;  // blt
            32'bxxxxxxxxxxxxxxxxx010xxxxx0000011: ALUop = 5'b10100;  // lw
            32'bxxxxxxxxxxxxxxxxx010xxxxx0100011: ALUop = 5'b10101;  // sw
            32'bxxxxxxxxxxxxxxxxx000xxxxx0010011: ALUop = 5'b01100;  // addi
            32'b0000000xxxxxxxxxx000xxxxx0110011: ALUop = 5'b01101;  // add
            32'b0100000xxxxxxxxxx000xxxxx0110011: ALUop = 5'b01110;  // sub
            32'b0000000xxxxxxxxxx001xxxxx0110011: ALUop = 5'b01000;  // sll
            32'b0000000xxxxxxxxxx100xxxxx0110011: ALUop = 5'b00110;  // xor
            32'b0000000xxxxxxxxxx101xxxxx0110011: ALUop = 5'b01001;  // srl
            32'b0000000xxxxxxxxxx110xxxxx0110011: ALUop = 5'b00101;  // or
            32'b0000000xxxxxxxxxx111xxxxx0110011: ALUop = 5'b00100;  // and
            default: ALUop = 5'b0;
        endcase
    end
end

always @ (*) begin
    if (rst)
        ALUsel = 3'b000;
    else begin
        casex (inst_i)
            32'bxxxxxxxxxxxxxxxxxxxxxxxxx1101111: ALUsel = 3'b100;  // jal
            32'bxxxxxxxxxxxxxxxxx000xxxxx1100011: ALUsel = 3'b100;  // beq
            32'bxxxxxxxxxxxxxxxxx100xxxxx1100011: ALUsel = 3'b100;  // blt
            32'bxxxxxxxxxxxxxxxxx010xxxxx0000011: ALUsel = 3'b101;  // lw
            32'bxxxxxxxxxxxxxxxxx010xxxxx0100011: ALUsel = 3'b101;  // sw
            32'bxxxxxxxxxxxxxxxxx000xxxxx0010011: ALUsel = 3'b011;  // addi
            32'b0000000xxxxxxxxxx000xxxxx0110011: ALUsel = 3'b011;  // add
            32'b0100000xxxxxxxxxx000xxxxx0110011: ALUsel = 3'b011;  // sub
            32'b0000000xxxxxxxxxx001xxxxx0110011: ALUsel = 3'b010;  // sll
            32'b0000000xxxxxxxxxx100xxxxx0110011: ALUsel = 3'b001;  // xor
            32'b0000000xxxxxxxxxx101xxxxx0110011: ALUsel = 3'b010;  // srl
            32'b0000000xxxxxxxxxx110xxxxx0110011: ALUsel = 3'b001;  // or
            32'b0000000xxxxxxxxxx111xxxxx0110011: ALUsel = 3'b001;  // and
            default: ALUsel = 3'b000;
        endcase
    end
end

always @ (*) begin
    if (rst)
        WriteReg = 1'b0;
    else begin
        casex (inst_i)
            32'bxxxxxxxxxxxxxxxxxxxxxxxxx1101111: WriteReg = 1'b1;  // jal
            32'bxxxxxxxxxxxxxxxxx000xxxxx1100011: WriteReg = 1'b0;  // beq
            32'bxxxxxxxxxxxxxxxxx100xxxxx1100011: WriteReg = 1'b0;  // blt
            32'bxxxxxxxxxxxxxxxxx010xxxxx0000011: WriteReg = 1'b1;  // lw
            32'bxxxxxxxxxxxxxxxxx010xxxxx0100011: WriteReg = 1'b0;  // sw
            32'bxxxxxxxxxxxxxxxxx000xxxxx0010011: WriteReg = 1'b1;  // addi
            32'b0000000xxxxxxxxxx000xxxxx0110011: WriteReg = 1'b1;  // add
            32'b0100000xxxxxxxxxx000xxxxx0110011: WriteReg = 1'b1;  // sub
            32'b0000000xxxxxxxxxx001xxxxx0110011: WriteReg = 1'b1;  // sll
            32'b0000000xxxxxxxxxx100xxxxx0110011: WriteReg = 1'b1;  // xor
            32'b0000000xxxxxxxxxx101xxxxx0110011: WriteReg = 1'b1;  // srl
            32'b0000000xxxxxxxxxx110xxxxx0110011: WriteReg = 1'b1;  // or
            32'b0000000xxxxxxxxxx111xxxxx0110011: WriteReg = 1'b1;  // and
            default: WriteReg = 1'b0;
        endcase
    end
end

always @ (*) begin
    if (rst)
        inst_valid = 1'b0;
    else begin
        casex (inst_i)
            32'bxxxxxxxxxxxxxxxxxxxxxxxxx1101111: inst_valid = 1'b0;  // jal
            32'bxxxxxxxxxxxxxxxxx000xxxxx1100011: inst_valid = 1'b0;  // beq
            32'bxxxxxxxxxxxxxxxxx100xxxxx1100011: inst_valid = 1'b0;  // blt
            32'bxxxxxxxxxxxxxxxxx010xxxxx0000011: inst_valid = 1'b0;  // lw
            32'bxxxxxxxxxxxxxxxxx010xxxxx0100011: inst_valid = 1'b0;  // sw
            32'bxxxxxxxxxxxxxxxxx000xxxxx0010011: inst_valid = 1'b0;  // addi
            32'b0000000xxxxxxxxxx000xxxxx0110011: inst_valid = 1'b0;  // add
            32'b0100000xxxxxxxxxx000xxxxx0110011: inst_valid = 1'b0;  // sub
            32'b0000000xxxxxxxxxx001xxxxx0110011: inst_valid = 1'b0;  // sll
            32'b0000000xxxxxxxxxx100xxxxx0110011: inst_valid = 1'b0;  // xor
            32'b0000000xxxxxxxxxx101xxxxx0110011: inst_valid = 1'b0;  // srl
            32'b0000000xxxxxxxxxx110xxxxx0110011: inst_valid = 1'b0;  // or
            32'b0000000xxxxxxxxxx111xxxxx0110011: inst_valid = 1'b0;  // and
            default: inst_valid = 1'b1;
        endcase
    end
end

always @ (*) begin
    if (rst)
        RegRead1 = 1'b0;
    else begin
        casex (inst_i)
            32'bxxxxxxxxxxxxxxxxxxxxxxxxx1101111: RegRead1 = 1'b0;  // jal
            32'bxxxxxxxxxxxxxxxxx000xxxxx1100011: RegRead1 = 1'b1;  // beq
            32'bxxxxxxxxxxxxxxxxx100xxxxx1100011: RegRead1 = 1'b1;  // blt
            32'bxxxxxxxxxxxxxxxxx010xxxxx0000011: RegRead1 = 1'b1;  // lw
            32'bxxxxxxxxxxxxxxxxx010xxxxx0100011: RegRead1 = 1'b1;  // sw
            32'bxxxxxxxxxxxxxxxxx000xxxxx0010011: RegRead1 = 1'b1;  // addi
            32'b0000000xxxxxxxxxx000xxxxx0110011: RegRead1 = 1'b1;  // add
            32'b0100000xxxxxxxxxx000xxxxx0110011: RegRead1 = 1'b1;  // sub
            32'b0000000xxxxxxxxxx001xxxxx0110011: RegRead1 = 1'b1;  // sll
            32'b0000000xxxxxxxxxx100xxxxx0110011: RegRead1 = 1'b1;  // xor
            32'b0000000xxxxxxxxxx101xxxxx0110011: RegRead1 = 1'b1;  // srl
            32'b0000000xxxxxxxxxx110xxxxx0110011: RegRead1 = 1'b1;  // or
            32'b0000000xxxxxxxxxx111xxxxx0110011: RegRead1 = 1'b1;  // and
            default: RegRead1 = 1'b0;
        endcase
    end
end

always @ (*) begin
    if (rst)
        RegRead2 = 1'b0;
    else begin
        casex (inst_i)
            32'bxxxxxxxxxxxxxxxxxxxxxxxxx1101111: RegRead2 = 1'b0;  // jal
            32'bxxxxxxxxxxxxxxxxx000xxxxx1100011: RegRead2 = 1'b1;  // beq
            32'bxxxxxxxxxxxxxxxxx100xxxxx1100011: RegRead2 = 1'b1;  // blt
            32'bxxxxxxxxxxxxxxxxx010xxxxx0000011: RegRead2 = 1'b0;  // lw
            32'bxxxxxxxxxxxxxxxxx010xxxxx0100011: RegRead2 = 1'b1;  // sw
            32'bxxxxxxxxxxxxxxxxx000xxxxx0010011: RegRead2 = 1'b0;  // addi
            32'b0000000xxxxxxxxxx000xxxxx0110011: RegRead2 = 1'b1;  // add
            32'b0100000xxxxxxxxxx000xxxxx0110011: RegRead2 = 1'b1;  // sub
            32'b0000000xxxxxxxxxx001xxxxx0110011: RegRead2 = 1'b1;  // sll
            32'b0000000xxxxxxxxxx100xxxxx0110011: RegRead2 = 1'b1;  // xor
            32'b0000000xxxxxxxxxx101xxxxx0110011: RegRead2 = 1'b1;  // srl
            32'b0000000xxxxxxxxxx110xxxxx0110011: RegRead2 = 1'b1;  // or
            32'b0000000xxxxxxxxxx111xxxxx0110011: RegRead2 = 1'b1;  // and
            default: RegRead2 = 1'b0;
        endcase
    end
end

always @ (*) begin
    if (rst)
        imm = 32'b0;
    else if (inst_i[14:12] == 3'b000 && inst_i[6:0] == 7'b0010011)  // addi
        imm = imm_I;
    else
        imm = 32'b0;
end

always @ (*) begin
    if (rst)
        LinkAddr = 32'b0;
    else if (inst_i[6:0] == 7'b1101111)  // jal
        LinkAddr = pc_add_4;
    else
        LinkAddr = 32'b0;
end

always @ (*) begin
    if (rst)
        BranchAddr = 32'b0;
    else if (inst_i[6:0] == 7'b1101111)  // jal
            BranchAddr = pc_add_imm_J;
    else if ((inst_i[6:0] == 7'b1100011 && inst_i[14:12] == 3'b000))  // beq
        if (Reg1 != Reg2)
            BranchAddr = pc_add_imm_B;
    else if ((inst_i[6:0] == 7'b1100011 && inst_i[14:12] == 3'b100))  // blt
        if ($signed(Reg1) >= $signed(Reg2))
            BranchAddr = pc_add_imm_B;
    else
        BranchAddr = 32'b0;
end

always @ (*) begin
    if (rst)
        Branch = 1'b0;

    else if (inst_i[6:0] == 7'b1101111)  // jal
        Branch = 1'b1;
    else if ((inst_i[6:0] == 7'b1100011 && inst_i[14:12] == 3'b000))  // beq
        if (Reg1 != Reg2)
            Branch = 1'b1;
    else if ((inst_i[6:0] == 7'b1100011 && inst_i[14:12] == 3'b100))  // blt
        if ($signed(Reg1) >= $signed(Reg2))
            Branch = 1'b1;
    else
        Branch = 1'b0;
end

always @ (*) begin
    if (rst)
        is_branch_o = 1'b0;
    else if (inst_i[6:0] == 7'b1101111 || (inst_i[6:0] == 7'b1100011 && inst_i[13:12] == 2'b00))  // jal, beq, blt
        is_branch_o = 1'b1;
    else
        is_branch_o = 1'b0;
end

always @ (*) begin
    if (rst)
        take_or_not_o = 1'b0;
    else if ((inst_i[6:0] == 7'b1100011 && inst_i[14:12] == 2'b000))  // beq
        if (Reg1 == Reg2)
            take_or_not_o = 1'b1;
    else if ((inst_i[6:0] == 7'b1100011 && inst_i[14:12] == 3'b100))  // blt
        if ($signed(Reg1) < $signed(Reg2))
            take_or_not_o = 1'b1;
    else
        take_or_not_o = 1'b0;
end

always @ (*) begin
    if (rst)
        pre_true_o = 1'b0;
    else if (inst_i[6:0] == 7'b1101111)  // jal
        pre_true_o = 1'b1;
    else if ((inst_i[6:0] == 7'b1100011 && inst_i[13:12] == 2'b00))  // beq, blt
        pre_true_o = pre_take_or_not ? 1'b1 : 1'b0;
    else
        pre_true_o = 1'b0;
end

always @ (*) begin
    if (rst)
        stallreq_branch = 1'b0;
    else if (inst_i[6:0] == 7'b1101111)  // jal
         stallreq_branch = 1'b1;
    else if ((inst_i[6:0] == 7'b1100011 && inst_i[14:12] == 3'b000))  // beq
        if (Reg1 != Reg2)
        stallreq_branch = 1'b1;
    else if ((inst_i[6:0] == 7'b1100011 && inst_i[14:12] == 3'b100))  // blt
        if ($signed(Reg1) >= $signed(Reg2))
        stallreq_branch = 1'b1;
    else
        stallreq_branch = 1'b0;
end

always @ (*) begin
    if (rst)
        WriteData = 5'b0;
    else
        WriteData = rd_addr;
end

always @ (*) begin
    if (rst)
        RegAddr1 = 5'b0;
    else
        RegAddr1 = rs1_addr;
end

always @ (*) begin
    if (rst)
        RegAddr2 = 5'b0;
    else
        RegAddr2 = rs2_addr;
end

always @ (*) begin
    if (rst)
        Reg1 = 32'b0;
    else if (RegRead1 && ex_wreg_i && (ex_wd_i == RegAddr1))
        Reg1 = ex_wdata_i;
    else if (RegRead1 && mem_wreg_i && (mem_wd_i == RegAddr1))    
        Reg1 = mem_wdata_i;
    else if  (RegRead1)
        Reg1 = RegData1;
    else if (!RegRead1)
        Reg1 = imm;
    else
        Reg1 = 32'b0;
end

always @ (*) begin
    if (rst)
        Reg2 = 32'b0;
    else if (RegRead1 && ex_wreg_i && (ex_wd_i == RegAddr2))
        Reg2 = ex_wdata_i;
    else if (RegRead1 && mem_wreg_i && (mem_wd_i == RegAddr2))    
        Reg2 = mem_wdata_i;
    else if  (RegRead2)
        Reg2 = RegData1;
    else if (!RegRead2)
        Reg2 = imm;
    else
        Reg2 = 32'b0;
end

always @ (*) begin
    if(pre_inst_is_load && RegRead1 && ex_wd_i == RegAddr1)
	    stallreq_for_reg1_loadrelate <= 1'b1;
    else
        stallreq_for_reg1_loadrelate <= 1'b0;
end

always @ (*) begin
    if(pre_inst_is_load && RegRead2 && ex_wd_i == RegAddr2)
	    stallreq_for_reg2_loadrelate <= 1'b1;
    else
        stallreq_for_reg2_loadrelate <= 1'b0;
end	


endmodule