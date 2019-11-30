# RISC-V_CPU
A simple CPU for **RISC-V** written by Verilog.

## Introduction

- Design a processor based on the RISC-V instruction set by Verilog;
- Implements some instructions in the **RV32I** instruction set;
- Run the test codes and get correct results.

## Content

- Design a **single-cycle** processor;
- Improve to a **multi-cycle** processor;
  - **Single issue**, **5 stages**;
  - **Data forwarding**, **pipeline blocking**;
  - Branch Prediction (not necessary).
- Use **Modelsim** to view waveform;
- Use Vivado to optimize timing (not necessary);
- Run the test codes.

## Set

| Instruction | Opcode  | Funct3 | Funct6/7 |
| :---------: | :-----: | :----: | :------: |
|    `add`    | 0110011 |  000   | 0000000  |
|   `addi`    | 0010011 |  000   |   N/A    |
|    `sub`    | 0110011 |  000   | 0100000  |
|    `and`    | 0110011 |  111   | 0000000  |
|    `or`     | 0110011 |  110   | 0000000  |
|    `xor`    | 0110011 |  100   | 0000000  |
|    `blt`    | 1100111 |  100   |   N/A    |
|    `beq`    | 1100111 |  000   |   N/A    |
|    `jal`    | 1101111 |  N/A   |   N/A    |
|    `sll`    | 0110011 |  001   | 0000000  |
|    `srl`    | 0110011 |  101   | 0000000  |
|    `lw`     | 0000011 |  010   |   N/A    |
|    `sw`     | 0100011 |  010   |   N/A    |

## Explain

> Only if.v and register.v is sequential circuit.

### if.v (single cycle)

- PC+4 per cycle;
- PC value send to inst_mem as the address of instruction, then send the instruction to decode module;
- If current instruction is beq, blt or jal, update PC immediately.

| Signal | Bit width |                    Function                    |
| :----: | :-------: | :--------------------------------------------: |
|   ce   |     1     | Chip select signal, high level enable inst_mem |
|  addr  |    32     |              instruction address               |
|  inst  |    32     |                  instruction                   |

### id.v (single cycle)

- Decode the instruction, get ALUop by opcode, funct3 and funct7.
- Determine if the register needs to be read or not and send the register numbers rs1, rs2 to the register file, and read the corresponding data as the source operand;
- Determine if the register needs to be written or not then output target register number rd and write register flag for register write back;
- Determine if the branch instruction is true or not and calculate the jump address (or ex.v);
- Sign extension (or unsigned extension) for instructions containing immediate values as one of the source operands.

| Instruction | opcode  | funct3 | funct7  | ALUop  |
| :---------: | :-----: | :----: | :-----: | :----: |
|     add     | 0110011 |  000   | 0000000 | 000001 |
|     sub     | 0110011 |  000   | 0100000 | 000010 |
|     sll     | 0110011 |  001   | 0000000 | 000011 |
|     jal     | 1101111 |  N/A   |   N/A   | 000100 |

### ex.v (single cycle)

- Use the ALUop and the two source operands decoded in id.v to perform the corresponding operation;
- If ALUop indicates that it's an addition operation, the two operands will be added; the sub operation can be implemented by complement...

| ALUop  | Operation |
| :----: | :-------: |
| 000001 |     +     |
| 000011 |    <<     |
| 000010 |     -     |

### mem.v (single cycle)

- Read 32bit data from data_mem if instruction is lw;
- Write 32bit data into data_mem if instruction is sw;
- Do no operation if there is other instruction.

| Signal | Bit width |                           Function                           |
| :----: | :-------: | :----------------------------------------------------------: |
|   ce   |     1     |        Chip select signal, high level enable inst_mem        |
|   we   |     1     | Write into data_mem at high level and read from data_mem at low level |
|  addr  |    32     |                        Address signal                        |
| data_i |    32     |          the data which need to write into data_mem          |
| data_o |    32     |               the data which is from data_mem                |

### register.v

- When we need to read rs1, rs2, read data from register file according to the address in rs1, rs2;
- When we need to write rd, write data into register file according to the address in rd;
- The operation of writing data to the register file uses sequential logic, and the operation of reading data from the register file using combinational logic;
- X0 is a constant zero register in RISC-V. When the target register rd is X0, the data won't actually be written to X0;
- If the read and write register signals are valid at the same time, and if the read address is the same as the write address, then the data which need to write can be directly output as read data to achieve data forwarding.

### stall.v (5 stages)

### if_id.v (5 stages)

### id_ex.v (5 stages)

### ex_mem.v (5 stages)

### mem_wb.v (5 stages)

## Submission

- Format: Student ID_Name_lab.zip
- deadline: Dec 29, 2019 (Sunday)