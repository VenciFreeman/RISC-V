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
 * - 19/12/19: Edit the RISC-V instructions.
 *
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
