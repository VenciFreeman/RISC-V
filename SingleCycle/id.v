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
 * - 19/12/19: Edit the RISC-V instructions;
 * - 19/12/23: Add control module;
 * - 19/12/24: Change the structure;
 * - 19/12/27: Edit the logic.

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
    
    output  reg [1:0]   RegRead1,
    output  reg [1:0]   RegRead2,
    output  reg [4:0]   RegAddr1,
    output  reg [4:0]   RegAddr2,

    output  reg [4:0]   ALUop,
    output  reg [4:0]   ALUsel,
    output  reg [31:0]  Reg1,
    output  reg [31:0]  Reg2,
    output  reg [4:0]   WriteData,
    output  reg         WriteReg,

    output  reg         Branch,
    output  reg [31:0]  BranchAddr,
    output  reg [31:0]  LinkAddr,
    output  wire[31:0]  inst_o

);

    assign inst_o = inst_i;

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


always @ (*) begin
    if (rst)
        ALUop = 5'b0;
    else begin
        casex (inst_i)
            32'bxxxxxxxxxxxxxxxxxxxx    xxxxx 1101111: ALUop = 5'b10000;  // jal
            32'bxxxxxxx xxxxx xxxxx 000 xxxxx 1100011: ALUop = 5'b10001;  // beq
            32'bxxxxxxx xxxxx xxxxx 100 xxxxx 1100011: ALUop = 5'b10010;  // blt
            32'bxxxxxxxxxxxx  xxxxx 010 xxxxx 0000011: ALUop = 5'b10100;  // lw
            32'bxxxxxxx xxxxx xxxxx 010 xxxxx 0100011: ALUop = 5'b10101;  // sw
            32'bxxxxxxxxxxxx  xxxxx 000 xxxxx 0010011: ALUop = 5'b01100;  // addi
            32'b0000000 xxxxx xxxxx 000 xxxxx 0110011: ALUop = 5'b01101;  // add
            32'b0100000 xxxxx xxxxx 000 xxxxx 0110011: ALUop = 5'b01110;  // sub
            32'b0000000 xxxxx xxxxx 001 xxxxx 0110011: ALUop = 5'b01000;  // sll
            32'b0000000 xxxxx xxxxx 100 xxxxx 0110011: ALUop = 5'b00110;  // xor
            32'b0000000 xxxxx xxxxx 101 xxxxx 0110011: ALUop = 5'b01001;  // srl
            32'b0000000 xxxxx xxxxx 110 xxxxx 0110011: ALUop = 5'b00101;  // or
            32'b0000000 xxxxx xxxxx 111 xxxxx 0110011: ALUop = 5'b00100;  // and
            default: ALUop = 5'b0;
        endcase
    end
end

always @ (*) begin
    if (rst)
        ALUsel = 3'b000;
    else begin
        casex (inst_i)
            32'bxxxxxxxxxxxxxxxxxxxx    xxxxx 1101111: ALUsel = 3'b100;  // jal
            32'bxxxxxxx xxxxx xxxxx 000 xxxxx 1100011: ALUsel = 3'b100;  // beq
            32'bxxxxxxx xxxxx xxxxx 100 xxxxx 1100011: ALUsel = 3'b100;  // blt
            32'bxxxxxxxxxxxx  xxxxx 010 xxxxx 0000011: ALUsel = 3'b101;  // lw
            32'bxxxxxxx xxxxx xxxxx 010 xxxxx 0100011: ALUsel = 3'b101;  // sw
            32'bxxxxxxxxxxxx  xxxxx 000 xxxxx 0010011: ALUsel = 3'b011;  // addi
            32'b0000000 xxxxx xxxxx 000 xxxxx 0110011: ALUsel = 3'b011;  // add
            32'b0100000 xxxxx xxxxx 000 xxxxx 0110011: ALUsel = 3'b011;  // sub
            32'b0000000 xxxxx xxxxx 001 xxxxx 0110011: ALUsel = 3'b010;  // sll
            32'b0000000 xxxxx xxxxx 100 xxxxx 0110011: ALUsel = 3'b001;  // xor
            32'b0000000 xxxxx xxxxx 101 xxxxx 0110011: ALUsel = 3'b010;  // srl
            32'b0000000 xxxxx xxxxx 110 xxxxx 0110011: ALUsel = 3'b001;  // or
            32'b0000000 xxxxx xxxxx 111 xxxxx 0110011: ALUsel = 3'b001;  // and
            default: ALUsel = 3'b000;
        endcase
    end
end

always @ (*) begin
    if (rst)
        WriteReg = 1'b0;
    else begin
        casex (inst_i)
            32'bxxxxxxxxxxxxxxxxxxxx    xxxxx 1101111: WriteReg = 1'b1;  // jal
            32'bxxxxxxx xxxxx xxxxx 000 xxxxx 1100011: WriteReg = 1'b0;  // beq
            32'bxxxxxxx xxxxx xxxxx 100 xxxxx 1100011: WriteReg = 1'b0;  // blt
            32'bxxxxxxxxxxxx  xxxxx 010 xxxxx 0000011: WriteReg = 1'b1;  // lw
            32'bxxxxxxx xxxxx xxxxx 010 xxxxx 0100011: WriteReg = 1'b0;  // sw
            32'bxxxxxxxxxxxx  xxxxx 000 xxxxx 0010011: WriteReg = 1'b1;  // addi
            32'b0000000 xxxxx xxxxx 000 xxxxx 0110011: WriteReg = 1'b1; // add
            32'b0100000 xxxxx xxxxx 000 xxxxx 0110011: WriteReg = 1'b1; // sub
            32'b0000000 xxxxx xxxxx 001 xxxxx 0110011: WriteReg = 1'b1;  // sll
            32'b0000000 xxxxx xxxxx 100 xxxxx 0110011: WriteReg = 1'b1;  // xor
            32'b0000000 xxxxx xxxxx 101 xxxxx 0110011: WriteReg = 1'b1;  // srl
            32'b0000000 xxxxx xxxxx 110 xxxxx 0110011: WriteReg = 1'b1;  // or
            32'b0000000 xxxxx xxxxx 111 xxxxx 0110011: WriteReg = 1'b1;  // and
            default: WriteReg = 1'b0;
        endcase
    end
end

always @ (*) begin
    if (rst)
        inst_valid = 1'b0;
    else begin
        casex (inst_i)
            32'bxxxxxxxxxxxxxxxxxxxx    xxxxx 1101111: inst_valid = 1'b0;  // jal
            32'bxxxxxxx xxxxx xxxxx 000 xxxxx 1100011: inst_valid = 1'b0;  // beq
            32'bxxxxxxx xxxxx xxxxx 100 xxxxx 1100011: inst_valid = 1'b0;  // blt
            32'bxxxxxxxxxxxx  xxxxx 010 xxxxx 0000011: inst_valid = 1'b0;  // lw
            32'bxxxxxxx xxxxx xxxxx 010 xxxxx 0100011: inst_valid = 1'b0;  // sw
            32'bxxxxxxxxxxxx  xxxxx 000 xxxxx 0010011: inst_valid = 1'b0;  // addi
            32'b0000000 xxxxx xxxxx 000 xxxxx 0110011: inst_valid = 1'b0; // add
            32'b0100000 xxxxx xxxxx 000 xxxxx 0110011: inst_valid = 1'b0; // sub
            32'b0000000 xxxxx xxxxx 001 xxxxx 0110011: inst_valid = 1'b0;  // sll
            32'b0000000 xxxxx xxxxx 100 xxxxx 0110011: inst_valid = 1'b0;  // xor
            32'b0000000 xxxxx xxxxx 101 xxxxx 0110011: inst_valid = 1'b0;  // srl
            32'b0000000 xxxxx xxxxx 110 xxxxx 0110011: inst_valid = 1'b0;  // or
            32'b0000000 xxxxx xxxxx 111 xxxxx 0110011: inst_valid = 1'b0;  // and
            default: inst_valid = 1'b1;
        endcase
    end
end

always @ (*) begin
    if (rst)
        RegRead1 = 1'b0;
    else begin
        casex (inst_i)
            32'bxxxxxxxxxxxxxxxxxxxx    xxxxx 1101111: RegRead1 = 1'b0;  // jal
            32'bxxxxxxx xxxxx xxxxx 000 xxxxx 1100011: RegRead1 = 1'b1;  // beq
            32'bxxxxxxx xxxxx xxxxx 100 xxxxx 1100011: RegRead1 = 1'b1;  // blt
            32'bxxxxxxxxxxxx  xxxxx 010 xxxxx 0000011: RegRead1 = 1'b1;  // lw
            32'bxxxxxxx xxxxx xxxxx 010 xxxxx 0100011: RegRead1 = 1'b1;  // sw
            32'bxxxxxxxxxxxx  xxxxx 000 xxxxx 0010011: RegRead1 = 1'b1;  // addi
            32'b0000000 xxxxx xxxxx 000 xxxxx 0110011: RegRead1 = 1'b1; // add
            32'b0100000 xxxxx xxxxx 000 xxxxx 0110011: RegRead1 = 1'b1; // sub
            32'b0000000 xxxxx xxxxx 001 xxxxx 0110011: RegRead1 = 1'b1;  // sll
            32'b0000000 xxxxx xxxxx 100 xxxxx 0110011: RegRead1 = 1'b1;  // xor
            32'b0000000 xxxxx xxxxx 101 xxxxx 0110011: RegRead1 = 1'b1;  // srl
            32'b0000000 xxxxx xxxxx 110 xxxxx 0110011: RegRead1 = 1'b1;  // or
            32'b0000000 xxxxx xxxxx 111 xxxxx 0110011: RegRead1 = 1'b1;  // and
            default: RegRead1 = 1'b0;
        endcase
    end
end

always @ (*) begin
    if (rst)
        RegRead2 = 1'b0;
    else begin
        casex (inst_i)
            32'bxxxxxxxxxxxxxxxxxxxx    xxxxx 1101111: RegRead2 = 1'b0;  // jal
            32'bxxxxxxx xxxxx xxxxx 000 xxxxx 1100011: RegRead2 = 1'b1;  // beq
            32'bxxxxxxx xxxxx xxxxx 100 xxxxx 1100011: RegRead2 = 1'b1;  // blt
            32'bxxxxxxxxxxxx  xxxxx 010 xxxxx 0000011: RegRead2 = 1'b0;  // lw
            32'bxxxxxxx xxxxx xxxxx 010 xxxxx 0100011: RegRead2 = 1'b1;  // sw
            32'bxxxxxxxxxxxx  xxxxx 000 xxxxx 0010011: RegRead2 = 1'b0;  // addi
            32'b0000000 xxxxx xxxxx 000 xxxxx 0110011: RegRead2 = 1'b1; // add
            32'b0100000 xxxxx xxxxx 000 xxxxx 0110011: RegRead2 = 1'b1; // sub
            32'b0000000 xxxxx xxxxx 001 xxxxx 0110011: RegRead2 = 1'b1;  // sll
            32'b0000000 xxxxx xxxxx 100 xxxxx 0110011: RegRead2 = 1'b1;  // xor
            32'b0000000 xxxxx xxxxx 101 xxxxx 0110011: RegRead2 = 1'b1;  // srl
            32'b0000000 xxxxx xxxxx 110 xxxxx 0110011: RegRead2 = 1'b1;  // or
            32'b0000000 xxxxx xxxxx 111 xxxxx 0110011: RegRead2 = 1'b1;  // and
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
end

always @ (*) begin
    if (rst)
        LinkAddr = 32'b0;
    else if (inst_i[6:0] == 7'b1101111)  // jal
        LinkAddr = pc_add_4;
    else
        LinkAddr = 32'b0;
    end
end

always @ (*) begin
    if (rst)
        BranchAddr = 32'b0;
    else if (inst_i[6:0] == 7'b1101111 || )  // jal
        BranchAddr = pc_add_imm_J;
        else if (inst_i[6:0] == 7'b1100011 && inst_i[13:12] == 2'b00)  // beq, blt
        BranchAddr = pc_add_imm_B;
    else
        BranchAddr = 32'b0;
    end
end

always @ (*) begin
    if (rst)
        Branch = 1'b0;
    else if (inst_i[6:0] == 7'b1101111 || (inst_i[6:0] == 7'b1100011 && inst_i[13:12] == 2'b00))  // jal, beq, blt
        Branch = 1'b1;
    else
        Branch = 1'b0;
    end
end

always @ (*) begin
    if (rst)
        WriteData = 5'b0;
    else
        WriteData = rd_addr;
    end
end

always @ (*) begin
    if (rst)
        RegAddr1 = 5'b0;
    else
        RegAddr1 = rs1_addr;
    end
end

always @ (*) begin
    if (rst)
        RegAddr2 = 5'b0;
    else
        RegAddr2 = rs2_addr;
    end
end

always @ (*) begin
    if (rst)
        Reg1 = 32'b0;
    else if (RegRead1)
        Reg1 = RegData1;
    else if (!RegRead1)
        Reg1 = imm;
    end else
        Reg1 = 32'b0;
end

always @ (*) begin
    if (rst)
        Reg2 =  32'b0;
    else if (RegRead2)
        Reg2 = RegData2;
    else if (!RegRead2)
        Reg2 = imm;
    else
        Reg2 = 32'b0;
end

endmodule





































/*
 * This always part controls the signal regWrite.

 * - When regWrite asserted, it means The register on the Write register input is
 *   written with the value on the Write data input;
 * - When regWrite deasserted, it means none.
 */
always @ (Opcode or Funct) begin
    case (Opcode)
        7'b0000011: regWrite <= 1;  // I-type, lw.
        7'b0010011: regWrite <= 1;  // I-type, addi.
        7'b0100011: regWrite <= 0;  // S-type, sw.
        7'b0110011: regWrite <= 1;  // R-type, including add, sub, sll, srl, and, or & xor.
        7'b1100011: regWrite <= 0;  // B-type, including beq & blt.  
        7'b1101111: regWrite <= 0;  // J-type, including jal.
    endcase
end

/*
 * This always part controls the signal memRead.

 * - When memRead asserted, it means data memory contents designated by the
 *   address input are put on the Read data output;
 * - When memRead deasserted, it means none.
 */
always @ (Opcode or Funct) begin
    case (Opcode)
        7'b0000011: memRead <= 1;  // I-type, lw.
        7'b0010011: memRead <= 0;  // I-type, addi.
        7'b0100011: memRead <= 0;  // S-type, sw.
        7'b0110011: memRead <= 0;  // R-type, including add, sub, sll, srl, and, or & xor.
        7'b1100011: memRead <= 0;  // B-type, including beq & blt.  
        7'b1101111: memRead <= 0;  // J-type, including jal.
    endcase
end

/*
 * This always part controls the signal memWrite.

 * - When memWrite asserted, it means data memory contents designated by the
 *   address input are replaced by the value on the Write data input;
 * - When memWrite deasserted, it means none.
 */
always @ (Opcode or Funct) begin
    case (Opcode)
        7'b0000011: memWrite <= 0;  // I-type, lw.
        7'b0010011: memWrite <= 0;  // I-type, addi.
        7'b0100011: memWrite <= 1;  // S-type, sw.
        7'b0110011: memWrite <= 0;  // R-type, including add, sub, sll, srl, and, or & xor.
        7'b1100011: memWrite <= 0;  // B-type, including beq & blt.  
        7'b1101111: memWrite <= 0;  // J-type, including jal.
    endcase
end

/*
 * This always part controls the signal memToReg.

 * - When memToRed asserted, it means The value fed to the register Write data
 *   input comes from the data memory;
 * - When memToReg deasserted, it means the value fed to the register Write
 *   data input comes from the ALU.
 */
always @ (Opcode or Funct) begin
    case (Opcode)
        7'b0000011: memToReg <= 1;  // I-type, lw.
        7'b0010011: memToReg <= 0;  // I-type, addi.
        7'b0100011: memToReg <= 0;  // S-type, sw.
        7'b0110011: memToReg <= 0;  // R-type, including add, sub, sll, srl, and, or & xor.
        7'b1100011: memToReg <= 0;  // B-type, including beq & blt.  
        7'b1101111: memToReg <= 0;  // J-type, including jal.
    endcase
end

/*
 * This always part controls the signal aluSrc.

 * - When aluSrc asserted, the second ALU operand is the sign-extended, 12 bits of
 *   the instruction;
 * - When aluSrc deasserted, it means The second ALU operand comes from the second
 *   register file output (Read data 2).
 */
always @ (Opcode or Funct) begin
    case (Opcode)
        7'b0000011: aluSrc <= 1;  // I-type, lw.
        7'b0010011: aluSrc <= 1;  // I-type, addi.
        7'b0100011: aluSrc <= 1;  // S-type, sw.
        7'b0110011: aluSrc <= 0;  // R-type, including add, sub, sll, srl, and, or & xor.
        7'b1100011: aluSrc <= 0;  // B-type, including beq & blt.  
        7'b1101111: aluSrc <= 1;  // J-type, including jal.
    endcase
end

/*
 * This always part controls the signal aluOp.
 */
always @ (Opcode or Funct) begin
    case (Opcode)
        7'b0000011: aluOp <= 6'b;  // I-type, lw.
        7'b0010011: aluOp <= 6'b;  // I-type, addi.
        7'b0100011: aluOp <= 6'b;  // S-type, sw.
        7'b0110011: aluOp <= 6'b;  // R-type, including add, sub, sll, srl, and, or & xor.
        7'b1100011: aluOp <= 6'b;  // B-type, including beq & blt.  
        7'b1101111: aluOp <= 6'b000100;  // J-type, including jal.

        // I don't know how to decide ALUOp... for R-type, maybe I can use Funct3/7?
    endcase
end

/*
 * This always part controls the signal branch.
 */
always @ (Opcode or Funct) begin
    case (Opcode)
        7'b0000011: branch <= 0;  // I-type, lw.
        7'b0010011: branch <= 0;  // I-type, addi.
        7'b0100011: branch <= 0;  // S-type, sw.
        7'b0110011: branch <= 0;  // R-type, including add, sub, sll, srl, and, or & xor.
        7'b1100011: branch <= 1;  // B-type, including beq & blt.  
        7'b1101111: branch <= 0;  // J-type, including jal.
    endcase
end

/*
 * This always part controls the signal jump.
 */
always @ (Opcode or Funct) begin
    case (Opcode)
        7'b0000011: jump <= 2'b00;  // I-type, lw.
        7'b0010011: jump <= 2'b00;  // I-type, addi.
        7'b0100011: jump <= 2'b00;  // S-type, sw.
        7'b0110011: jump <= 2'b00;  // R-type, including add, sub, sll, srl, and, or & xor.
        7'b1100011: jump <= 2'b00;  // B-type, including beq & blt.  
        7'b1101111: jump <= 2'b01;  // J-type, including jal.
    endcase
end

/*
 * This always part controls the signal link.
 */
always @ (Opcode or Funct) begin
    case (Opcode)
        7'b0000011: link <= 0;  // I-type, lw.
        7'b0010011: link <= 0;  // I-type, addi.
        7'b0100011: link <= 0;  // S-type, sw.
        7'b0110011: link <= 0;  // R-type, including add, sub, sll, srl, and, or & xor.
        7'b1100011: link <= 0;  // B-type, including beq & blt.  
        7'b1101111: link <= 1;  // J-type, including jal.
    endcase
end

/*
 * This always part controls the signal pcSrc.

 * - When pcSrc asserted, it mians the PC is replaced by the output of the adder
 *   that computes the branch target;
 * - When pcSrc deasserted, it means The PC is replaced by the output of the
 *   adder that computes the value of PC + 4.
 */
 */
always @ (Opcode or Funct) begin
    case (Opcode)
        7'b0000011: pcSrc <= 0;  // I-type, lw.
        7'b0010011: pcSrc <= 0;  // I-type, addi.
        7'b0100011: pcSrc <= 0;  // S-type, sw.
        7'b0110011: pcSrc <= 0;  // R-type, including add, sub, sll, srl, and, or & xor.
        7'b1100011: pcSrc <= 0;  // B-type, including beq & blt.  
        7'b1101111: pcSrc <= 0;  // J-type, including jal.
    endcase
end

endmodule