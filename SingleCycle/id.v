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
 * - 19/12/26: Edit the logic.

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

module Control(

    input   wire        rst,
    input   wire[31:0]  pc_i,
    input   wire[31:0]  inst_i,
    input   wire[31:0]  reg1_data_i,
    input   wire[31:0]  reg2_data_i,

    output  reg [1:0]   reg1_read_o,
    output  reg [1:0]   reg2_read_o,
    output  reg [4:0]   reg1_addr_o,
    output  reg [4:0]   reg2_addr_o,

    output  reg [4:0]   aluop_o,
    output  reg [4:0]   alusel_o,
    output  reg [31:0]  reg1_o,
    output  reg [31:0]  reg2_o,
    output  reg [4:0]   wd_o,
    output  reg         wreg_o,

    output  reg         branch_flag_o,
    output  reg [31:0]  branch_target_address_o,
    output  reg [31:0]  link_addr_o,
    output  wire[31:0]  inst_o


    output      RegWrite,
    output      MemRead,
    output      MemWrite,
    output      MemToReg,
    output      ALUsrc,
    output[6:0] ALUop,
    output      Branch,
    output[1:0] Jump,
    output      Link,
    output      ALUOp1,
    output      ALUOp0

);

    reg regDst, regWrite, memRead, memWrite, memToReg, needZEXT, aluSrc, branch, link;
    reg [3:0] aluOp;
    reg [1:0] jump, stackOp;

    assign RegWrite = regWrite;
    assign MemRead = memRead;
    assign MemWrite = memWrite;
    assign MemToReg = memToReg;
    assign NeedZEXT = needZEXT;
    assign ALUsrc = aluSrc;
    assign ALUop = aluOp;
    assign Branch = branch;
    assign Jump = jump;
    assign Link = link;
    assign StackOp = stackOp;

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