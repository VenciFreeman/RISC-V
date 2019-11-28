# RISC-V_CPU
A simple CPU for RISC-V written by Verilog.

## Introduction

- Design a processor based on the RISC-V instruction set by Verilog;
- Implements some instructions in the RV32I instruction set;
- Run the test codes and get correct results.

## Content

- Design a single-cycle processor;
- Improve to a multi-cycle processor;
  - Single issue, 5 stages;
  - Data forwarding, pipeline blocking;
  - *Branch Prediction.
- Use Modelsim to view waveform;
- Use *Vivado to optimize timing;
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

| Singal | Bit width |                  Introduction                  |
| :----: | :-------: | :--------------------------------------------: |
|   ce   |     1     | Chip select signal, high level enable inst_mem |
|  addr  |    32     |              instruction address               |
|  inst  |    32     |                  instruction                   |

### id.v (single cycle)

### ex.v (single cycle)

### mem.v (single cycle)

### register.v

## Submission

- Format: Student ID_Name_lab.zip
- deadline: Dec 29, 2019 (Sunday)