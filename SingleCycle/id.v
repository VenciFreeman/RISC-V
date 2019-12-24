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
 * - 19/12/24: Change the structure.

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

    input [6:0] Opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output      RegDst,
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

    reg regDst, regWrite, memRead, memWrite, memToReg, needZEXT, aluSrc, branch, link, ALUOp1, ALUOp0;
    reg [3:0] aluOp;
    reg [1:0] jump, stackOp;

    assign RegDst = regDst;
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
 * This always part controls the signal regDst.
 */
always @ (Opcode or Funct) begin
    case (Opcode)
        7'b0000011: regDst <= 0;  // I-type, lw.
        7'b0010011: regDst <= 0;  // I-type, addi.
        7'b0100011: regDst <= 0;  // S-type, sw.
        7'b0110011: regDst <= 1;  // R-type, including add, sub, sll, srl, and, or & xor.
        7'b1100011: regDst <= 0;  // B-type, including beq & blt.  
        7'b1101111: regDst <= 0;  // J-type, including jal.
    endcase
end

/*
 * This always part controls the signal regWrite.
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
        7'b1101111: lunk <= 1;  // J-type, including jal.
    endcase
end

endmodule