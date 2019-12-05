/************************************************************************************
 * Description:                                                                     *
 * This file determines the ALUop and determines what to do.                        *
 * Notes:                                                                           *
 * - Decode the instruction, get ALUop by opcode, funct3 and funct7;                *
 * - Determine if the register needs to be read or not and send the register        *
 *   numbers rs1, rs2 to the register file, and read the corresponding data as the  *
 *   source operand;                                                                *
 * - Determine if the register needs to be written or not then output target        *
 *   register number rd and write register flag for register write back;            *
 * - Determine if the branch instruction is true or not and calculate the jump      *
 *   address (or in ex.v);                                                          *
 * - Sign extension (or unsigned extension) for instructions containing immediate   *
 *   values as one of the source operands.                                          *
 ************************************************************************************/