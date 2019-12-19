/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.
 *
 * Description:
 * This file determines the ALUop and determines what to do.
 *
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
 *
 * History:
 *
 * Notes:
 *
 */

module ID(

    input [5:0]     Opcode,
    input [5:0]     Funct,
    output          RegDst,
    output          RegWrite,
    output          MemRead,
    output          MemWrite,
    output          MemToReg,
    output          NeedZEXT,
    output          ALUsrc,
    output [3:0]    ALUop,
    output          Branch,
    output [1:0]    Jump,
    output          Link,
    output [1:0]    StackOp

);

    reg regDst, regWrite, memRead, memWrite, memToReg, needZEXT, aluSrc, branch, link;
    reg [3:0] aluOp;
    reg [1:0] jump, [1:0] stackOp;

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
    6'b000000:          // R type
    begin
        regDst      <= 1;    // use Rd
        regWrite    <= 1;
        memRead     <= 0;
        memWrite    <= 0;
        memToReg    <= 0;
        needZEXT    <= 0;
        aluSrc      <= 0;    // Use rt 
        aluOp       <= Funct[3:0];
        branch      <= 0;
        jump        <= 2'b00;
        link        <= 0;
        stackOp     <= 2'b00;
    end

    6'b001000:          // addi
    begin
        regDst      <= 0;    // use Rt
        regWrite    <= 1;
        memRead     <= 0;
        memWrite    <= 0;
        memToReg    <= 0;
        needZEXT    <= 0;
        aluSrc      <= 1;    // Use imm16 
        aluOp       <= 4'b0010; // add
        branch      <= 0;
        jump        <= 2'b00;
        link        <= 0;
        stackOp     <= 2'b00;
    end
    
    6'b001100:          // andi
    begin
        regDst      <= 0;    // use Rt
        regWrite    <= 1;
        memRead     <= 0;
        memWrite    <= 0;
        memToReg    <= 0;
        needZEXT    <= 1;    // Use ZEXT 
        aluSrc      <= 1;    // Use imm16 
        aluOp       <= 4'b0000; // and
        branch      <= 0;
        jump        <= 2'b00;
        link        <= 0;
        stackOp     <= 2'b00;
    end

    6'b001101:          // ori
    begin
        regDst      <= 0;    // use Rt
        regWrite    <= 1;
        memRead     <= 0;
        memWrite    <= 0;
        memToReg    <= 0;
        needZEXT    <= 1;    // Use ZEXT 
        aluSrc      <= 1;    // Use imm16 
        aluOp       <= 4'b0001; // or
        branch      <= 0;
        jump        <= 2'b00;
        link        <= 0;
        stackOp     <= 2'b00;
    end

    6'b000100:          // beq
    begin
        regDst      <= 0;    
        regWrite    <= 0;
        memRead     <= 0;
        memWrite    <= 0;
        memToReg    <= 0;
        needZEXT    <= 0;    // Use SEXT 
        aluSrc      <= 0;    // Use Rt 
        aluOp       <= 4'b0011; // sub
        branch      <= 1;    // branch
        jump        <= 2'b00;
        link        <= 0;
        stackOp     <= 2'b00;
    end
    
    6'b000010:          // jmp
    begin
        regDst      <= 0;    
        regWrite    <= 0;
        memRead     <= 0;
        memWrite    <= 0;
        memToReg    <= 0;
        needZEXT    <= 0;    // Use SEXT 
        aluSrc      <= 1;    // Use imm16 
        aluOp       <= 4'b0000; 
        branch      <= 0;    
        jump        <= 2'b01;// jump imm26
        link        <= 0;
        stackOp     <= 2'b00;
    end
    
    6'b000011:          // jal
    begin
        regDst      <= 0;    
        regWrite    <= 0;
        memRead     <= 0;
        memWrite    <= 0;
        memToReg    <= 0;
        needZEXT    <= 0;    // Use SEXT 
        aluSrc      <= 1;    // Use imm16 
        aluOp       <= 4'b0000; 
        branch      <= 0;    
        jump        <= 2'b01;// jump imm26
        link        <= 1;    // link 
        stackOp     <= 2'b00;
    end
    
    6'b000101:          // jr
    begin
        regDst      <= 0;    
        regWrite    <= 0;
        memRead     <= 0;
        memWrite    <= 0;
        memToReg    <= 0;
        needZEXT    <= 0;    // Use SEXT 
        aluSrc      <= 1;    // Use imm16 
        aluOp       <= 4'b0000; 
        branch      <= 0;    
        jump        <= 2'b10;// jump rs 
        link        <= 0;    //  
        stackOp     <= 2'b00;
    end
    
    6'b100011:          // lw
    begin
        regDst      <= 0;    // Use Rt 
        regWrite    <= 1;
        memRead     <= 1;
        memWrite    <= 0;
        memToReg    <= 1;
        needZEXT    <= 0;    // Use SEXT 
        aluSrc      <= 1;    // Use imm16 
        aluOp       <= 4'b0010; // add 
        branch      <= 0;    
        jump        <= 2'b00; 
        link        <= 0;    //  
        stackOp     <= 2'b00;
    end

    6'b101011:          // sw
    begin
        regDst      <= 0;    // Use Rt 
        regWrite    <= 0;
        memRead     <= 0;
        memWrite    <= 1;
        memToReg    <= 0;
        needZEXT    <= 0;    // Use SEXT 
        aluSrc      <= 1;    // Use imm16 
        aluOp       <= 4'b0010; // add 
        branch      <= 0;    
        jump        <= 2'b00;
        link        <= 0;    //  
        stackOp     <= 2'b00;
    end
    
    6'b110000:          // push
    begin
        regDst      <= 0;    // Use Rt 
        regWrite    <= 0;
        memRead     <= 0;
        memWrite    <= 0;
        memToReg    <= 0;
        needZEXT    <= 0;    // Use SEXT 
        aluSrc      <= 1;    // Use imm16 
        aluOp       <= 4'b1100; 
        branch      <= 0;    
        jump        <= 2'b00;
        link        <= 0;    //  
        stackOp     <= 2'b10;   // push
    end

    6'b110001:          // pop
    begin
        regDst      <= 1;    // Use Rd
        regWrite    <= 1;
        memRead     <= 0;
        memWrite    <= 0;
        memToReg    <= 1;
        needZEXT    <= 0;    // Use SEXT 
        aluSrc      <= 1;    // Use imm16 
        aluOp       <= 4'b0000; 
        branch      <= 0;    
        jump        <= 2'b00;
        link        <= 0;    //  
        stackOp     <= 2'b11;   // pop
    end
    endcase
end

endmodule
