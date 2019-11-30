/************************************************************************************
 * Description:                                                                     *
 * This file stores some constants so I can view and modify them easily.            *
 * Notes:                                                                           *
 * Note the sub-file comments, it's better to describe the role of each variable.   *
 *                                                                                  *
 * include this file as header like this:                                           *
 *   `include "define.v"                                                            *
 ************************************************************************************/

`define InstAddrBus 31:0
`define InstBus 31:0

`define DataAddrBus 31:0
`define DataBus 31:0

`define RegAddrBus 4:0
`define RegBus 31:0
`define RegWidth 32
`define DoubleRegWidth 64
`define DoubleRegBus 63:0
`define RegNum 32

/************************************* GLOBAL *************************************/
`define RstEnable 1'b1
`define RstDisable 1'b0
`define ZeroWord 32'h00000000
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0

`define AluOpBus 7:0
`define AluSelBus 2:0

`define InstValid 1'b0
`define InstInvalid 1'b1
`define Stop 1'b1
`define NoStop 1'b0
`define InDelaySlot 1'b1
`define NotInDelaySlot 1'b0

`define Branch 1'b1
`define NotBranch 1'b0

`define InterruptAssert 1'b1
`define InterruptNotAssert 1'b0
`define TrapAssert 1'b1
`define TrapNotAssert 1'b0
`define True_v 1'b1
`define False_v 1'b0
`define ChipEnable 1'b1
`define ChipDisable 1'b0

/************************************* Instructions *************************************/
`define EXE_AND  6'b100100
`define EXE_OR   6'b100101
`define EXE_XOR  6'b100110
`define EXE_NOR  6'b100111
`define EXE_ANDI 6'b001100
`define EXE_ORI  6'b001101
`define EXE_XORI 6'b001110
`define EXE_LUI  6'b001111

`define EXE_SLL  6'b000000
`define EXE_SLLV 6'b000100
`define EXE_SRL  6'b000010
`define EXE_SRLV 6'b000110
`define EXE_SRA  6'b000011
`define EXE_SRAV 6'b000111

`define EXE_MOVZ 6'b001010
`define EXE_MOVN 6'b001011
`define EXE_MFHI 6'b010000
`define EXE_MTHI 6'b010001
`define EXE_MFLO 6'b010010
`define EXE_MTLO 6'b010011

`define EXE_SLT   6'b101010
`define EXE_SLTU  6'b101011
`define EXE_SLTI  6'b001010
`define EXE_SLTIU 6'b001011   
`define EXE_ADD   6'b100000
`define EXE_ADDU  6'b100001
`define EXE_SUB   6'b100010
`define EXE_SUBU  6'b100011
`define EXE_ADDI  6'b001000
`define EXE_ADDIU 6'b001001
`define EXE_CLZ   6'b100000
`define EXE_CLO   6'b100001

`define EXE_MULT  6'b011000
`define EXE_MULTU 6'b011001
`define EXE_MUL   6'b000010
`define EXE_MADD  6'b000000
`define EXE_MADDU 6'b000001
`define EXE_MSUB  6'b000100
`define EXE_MSUBU 6'b000101

/************************************* RISC-V *************************************/
`define OpcodeBus 6:0
`define Funct3Bus 2:0
`define Funct7Bus 6:0
`define OP_F3_NOP 3'b000
`define OP_F7_NOP 7'b0000000

/************************************* opcode *************************************/
`define OP_NOP		7'b0000000
`define OP_LUI      7'b0110111
`define OP_AUIPC    7'b0010111
`define OP_JAL      7'b1101111
`define OP_JALR     7'b1100111
`define OP_BRANCH   7'b1100011
`define OP_LOAD     7'b0000011
`define OP_STORE    7'b0100011
`define OP_OP_IMM   7'b0010011
`define OP_OP       7'b0110011
`define OP_MISC_MEM 7'b0001111

/************************************* funct3 *************************************/
// JALR
`define FUNCT3_JALR 3'b000
// BRANCH
`define FUNCT3_BEQ  3'b000
`define FUNCT3_BNE  3'b001
`define FUNCT3_BLT  3'b100
`define FUNCT3_BGE  3'b101
`define FUNCT3_BLTU 3'b110
`define FUNCT3_BGEU 3'b111
// LOAD
`define FUNCT3_LB   3'b000
`define FUNCT3_LH   3'b001
`define FUNCT3_LW   3'b010
`define FUNCT3_LBU  3'b100
`define FUNCT3_LHU  3'b101
// STORE
`define FUNCT3_SB   3'b000
`define FUNCT3_SH   3'b001
`define FUNCT3_SW   3'b010
// OP-IMM
`define FUNCT3_ADDI      3'b000
`define FUNCT3_SLTI      3'b010
`define FUNCT3_SLTIU     3'b011
`define FUNCT3_XORI      3'b100
`define FUNCT3_ORI       3'b110
`define FUNCT3_ANDI      3'b111
`define FUNCT3_SLLI      3'b001
`define FUNCT3_SRLI_SRAI 3'b101
// OP
`define FUNCT3_ADD_SUB 3'b000
`define FUNCT3_SLL     3'b001
`define FUNCT3_SLT     3'b010
`define FUNCT3_SLTU    3'b011
`define FUNCT3_XOR     3'b100
`define FUNCT3_SRL_SRA 3'b101
`define FUNCT3_OR      3'b110
`define FUNCT3_AND     3'b111
// MISC-MEM
`define FUNCT3_FENCE  3'b000
`define FUNCT3_FENCEI 3'b001

/************************************* funct7 *************************************/
`define FUNCT7_SLLI 7'b0000000
// SRLI_SRAI
`define FUNCT7_SRLI 7'b0000000
`define FUNCT7_SRAI 7'b0100000
// ADD_SUB
`define FUNCT7_ADD  7'b0000000
`define FUNCT7_SUB  7'b0100000
`define FUNCT7_SLL  7'b0000000
`define FUNCT7_SLT  7'b0000000
`define FUNCT7_SLTU 7'b0000000
`define FUNCT7_XOR  7'b0000000
// SRL_SRA
`define FUNCT7_SRL  7'b0000000
`define FUNCT7_SRA  7'b0100000
`define FUNCT7_OR   7'b0000000
`define FUNCT7_AND  7'b0000000