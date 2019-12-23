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
 * - 19/12/23: Add control module.

 * Notes:
 *
 */

module ID(

        input   [6:0] opcode,
        input   [2:0] funct3,
        input   [6:0] funct7,
        output  [5:0] ALUop_o

    );
    
    reg [3:0] ALUop;

    assign ALUop_o = ALUop;

/*
* This always part controls the signal ALUop.
*/   
always @ (*) begin
    casex ({opcode, funct3, funct7})
        17'b01100110000000000: ALUop <= 6'b000001;  // add
        17'b01100110000100000: ALUop <= 6'b000010;  // sub
        17'b01100110010000000: ALUop <= 6'b000011;  // sll
        17'b1101111xxxxxxxxxx: ALUop <= 6'b000100;  // jal
        17'b0010011000xxxxxxx: ALUop <= 6'b000101;  // addi
        17'b01100111110000000: ALUop <= 6'b000110;  // and
        17'b01100111100000000: ALUop <= 6'b000111;  // or
        17'b01100111000000000: ALUop <= 6'b001000;  // xor
        17'b1100111100xxxxxxx: ALUop <= 6'b001001;  // blt
        17'b1100111000xxxxxxx: ALUop <= 6'b001010;  // beq
        17'b01100111010000000: ALUop <= 6'b001011;  // srl
        17'b0000011010xxxxxxx: ALUop <= 6'b001100;  // lw
        17'b0100011010xxxxxxx: ALUop <= 6'b001101;  // sw
        default:               ALUop <= 6'bzzzzzz;
    endcase
end

endmodule

module Control(

    input [5:0] Opcode,
    input [5:0] Funct,
    output      RegDst,
    output      RegWrite,
    output      MemRead,
    output      MemWrite,
    output      MemToReg,
    output      NeedZEXT,
    output      ALUsrc,
    output[3:0] ALUop,
    output      Branch,
    output[1:0] Jump,
    output      Link,
    output[1:0] StackOp

);

    reg regDst, regWrite, memRead, memWrite, memToReg, needZEXT, aluSrc, branch, link;
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

always @ (Opcode or Funct) begin
    case (Opcode)
        6'b000000: regDst <= 1;  // R-type, use Rd
        6'b001000: regDst <= 0;  // addi, use Rt   
        6'b001100: regDst <= 0;  // andi, use Rt
        6'b000100: regDst <= 0;  // beq  
        6'b000011: regDst <= 0;  // jal
        6'b100011: regDst <= 0;  // lw
        6'b101011: regDst <= 0;  // sw
    endcase
end

always @ (Opcode or Funct) begin
    case (Opcode)
        6'b000000: regWrite <= 1;  // R-type, use Rd
        6'b001000: regWrite <= 1;  // addi, use Rt   
        6'b000100: regWrite <= 0;  // beq  
        6'b000011: regWrite <= 0;  // jal
        6'b100011: regWrite <= 1;  // lw
        6'b101011: regWrite <= 0;  // sw
    endcase
end

always @ (Opcode or Funct) begin
    case (Opcode)
        6'b000000: memRead <= 0;  // R-type, use Rd
        6'b001000: memRead <= 0;  // addi, use Rt   
        6'b000100: memRead <= 0;  // beq  
        6'b000011: memRead <= 0;  // jal
        6'b100011: memRead <= 1;  // lw
        6'b101011: memRead <= 0;  // sw
    endcase
end

always @ (Opcode or Funct) begin
    case (Opcode)
        6'b000000: memWrite <= 0;  // R-type, use Rd
        6'b001000: memWrite <= 0;  // addi, use Rt   
        6'b000100: memWrite <= 0;  // beq  
        6'b000011: memWrite <= 0;  // jal
        6'b100011: memWrite <= 0;  // lw
        6'b101011: memWrite <= 1;  // sw
    endcase
end

always @ (Opcode or Funct) begin
    case (Opcode)
        6'b000000: memToReg <= 0;  // R-type, use Rd
        6'b001000: memToReg <= 0;  // addi, use Rt   
        6'b000100: memToReg <= 0;  // beq  
        6'b000011: memToReg <= 0;  // jal
        6'b100011: memToReg <= 1;  // lw
        6'b101011: memToReg <= 0;  // sw
    endcase
end

always @ (Opcode or Funct) begin
    case (Opcode)
        6'b000000: needZEXT <= 0;  // R-type, use Rd
        6'b001000: needZEXT <= 0;  // addi, use Rt   
        6'b000100: needZEXT <= 0;  // beq  
        6'b000011: needZEXT <= 0;  // jal
        6'b100011: needZEXT <= 0;  // lw
        6'b101011: needZEXT <= 0;  // sw
    endcase
end

always @ (Opcode or Funct) begin
    case (Opcode)
        6'b000000: aluSrc <= 0;  // R-type, use Rd
        6'b001000: aluSrc <= 1;  // addi, use Rt   
        6'b000100: aluSrc <= 0;  // beq  
        6'b000011: aluSrc <= 1;  // jal
        6'b100011: aluSrc <= 1;  // lw
        6'b101011: aluSrc <= 1;  // sw
    endcase
end

always @ (Opcode or Funct) begin
    case (Opcode)
        6'b000000: aluOp <= Funct[3:0];  // R-type, use Rd
        6'b001000: aluOp <= 4'b0010;  // addi, use Rt   
        6'b000100: aluOp <= 4'b0011;  // beq  
        6'b000011: aluOp <= 4'b0000;  // jal
        6'b100011: aluOp <= 4'b0010;  // lw
        6'b101011: aluOp <= 4'b0010;  // sw
    endcase
end

always @ (Opcode or Funct) begin
    case (Opcode)
        6'b000000: branch <= 0;  // R-type, use Rd
        6'b001000: branch <= 0;  // addi, use Rt   
        6'b000100: branch <= 1;  // beq  
        6'b000011: branch <= 0;  // jal
        6'b100011: branch <= 0;  // lw
        6'b101011: branch <= 0;  // sw
    endcase
end

always @ (Opcode or Funct) begin
    case (Opcode)
        6'b000000: jump <= 2'b00;  // R-type, use Rd
        6'b001000: jump <= 2'b00;  // addi, use Rt   
        6'b000100: jump <= 2'b00;  // beq  
        6'b000011: jump <= 2'b01;  // jal
        6'b100011: jump <= 2'b00;  // lw
        6'b101011: jump <= 2'b00;  // sw
    endcase
end

always @ (Opcode or Funct) begin
    case (Opcode)
        6'b000000: link <= 0;  // R-type, use Rd
        6'b001000: link <= 0;  // addi, use Rt   
        6'b000100: link <= 0;  // beq  
        6'b000011: link <= 1;  // jal
        6'b100011: link <= 0;  // lw
        6'b101011: link <= 0;  // sw
    endcase
end

always @ (Opcode or Funct) begin
    case (Opcode)
        6'b000000: stackOp <= 2'b00;  // R-type, use Rd
        6'b001000: stackOp <= 2'b00;  // addi, use Rt   
        6'b000100: stackOp <= 2'b00;  // beq  
        6'b000011: stackOp <= 2'b00;  // jal
        6'b100011: stackOp <= 2'b00;  // lw
        6'b101011: stackOp <= 2'b00;  // sw
    endcase
end

endmodule