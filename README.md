# RISC-V_CPU

A simple CPU for **RISC-V** written by Verilog.

用Verilog编写的简单的RISC-V处理器。

## Introduction

- Design a processor based on the RISC-V instruction set by Verilog;
- 使用Verilog设计实现基于RISC-V指令集的处理器；
- Implements some instructions in the **RV32I** instruction set;
- 实现RV32I指令集中的部分指令；
- Run the test codes and get correct results.
- 运行测试指令，得到正确的运行结果

## Content

- Design a **single-cycle** processor;
- 设计实现一款单周期的32位RISC-V处理器；
- Improve to a **multi-cycle** processor;
- 在单周期RISC-V处理器的基础上进行改进，实现多周期的RISC-V处理器；
  - **Single issue**, **5 stages**;
  - 单发射、五级流水线；
  - **Data forwarding**, **pipeline blocking**;
  - 实现数据转发、流水线阻塞；
  - Branch Prediction (not necessary).
  - 分支预测(选做)；
- Use **Modelsim** to view waveform;
- 使用Modelsim进行仿真验证，查看相应信号波形；
- Use Vivado to optimize timing (not necessary);
- 使用Vivado对代码进行综合，尽可能的优化时序(选做)；
- Run the test codes.
- 运行测试指令，得到正确的输出结果。

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
- 程序计数器PC 在正常情况下，每个周期加4；
- PC value send to inst_mem as the address of instruction, then send the instruction to decode module;
- PC值送入inst_mem作为指令的地址，将取得的指令直接送入译码模块；
- If current instruction is beq, blt or jal, update PC immediately.
- 如果当前的指令是条件分支指令(beq,blt)或直接跳转指令(jal)，当分支成立时，PC需要更新为跳转指令的目标地址。

| Signal | Bit width |                    Function                    |
| :----: | :-------: | :--------------------------------------------: |
|   ce   |     1     | Chip select signal, high level enable inst_mem |
|  addr  |    32     |              instruction address               |
|  inst  |    32     |                  instruction                   |

### id.v (single cycle)

- Decode the instruction, get ALUop by opcode, funct3 and funct7;
- 对取到的指令进行译码，根据opcode, funct3, funct7确定具体的ALUop；
- Determine if the register needs to be read or not and send the register numbers rs1, rs2 to the register file, and read the corresponding data as the source operand;
- 判断是否需要读寄存器，把要读取的寄存器号rs1,rs2 送入register file，读取相应的数据作为源操作数；
- Determine if the register needs to be written or not then output target register number rd and write register flag for register write back;
- 判断是否需要写寄存器，输出目标寄存器号rd、写寄存器标志，用于寄存器回写；
- Determine if the branch instruction is true or not and calculate the jump address (or in ex.v);
- 判断分支指令是否成立，并计算跳转地址(也可以在ex.v中实现)；
- Sign extension (or unsigned extension) for instructions containing immediate values as one of the source operands.
- 对含有立即数的指令进行符号扩展(或无符号扩展，具体参考spec文件)，作为其中的一个源操作数。

| Instruction | opcode  | funct3 | funct7  | ALUop  |
| :---------: | :-----: | :----: | :-----: | :----: |
|     add     | 0110011 |  000   | 0000000 | 000001 |
|     sub     | 0110011 |  000   | 0100000 | 000010 |
|     sll     | 0110011 |  001   | 0000000 | 000011 |
|     jal     | 1101111 |  N/A   |   N/A   | 000100 |

### ex.v (single cycle)

- Use the ALUop and the two source operands decoded in id.v to perform the corresponding operation;
- 根据id.v中译码所得的ALUop和两个源操作数，进行相应的操作；
- If ALUop indicates that it's an addition operation, the two operands will be added; the sub operation can be implemented by complement.
- 如果ALUop表明是加法操作，则将两个操作数相加；减法操作可以通过加补码实现。

| ALUop  | Operation |
| :----: | :-------: |
| 000001 |     +     |
| 000011 |    <<     |
| 000010 |     -     |

### mem.v (single cycle)

- Read 32bit data from data_mem if instruction is lw;
- 指令是lw指令，则从data_mem中读取32bit的数据；
- Write 32bit data into data_mem if instruction is sw;
- 指令是sw指令，则向data_ mem中写入32bit的数据；
- Do no operation if there is other instruction.
- 如果是其他指令，则不做操作。

| Signal | Bit width |                           Function                           |
| :----: | :-------: | :----------------------------------------------------------: |
|   ce   |     1     |        Chip select signal, high level enable inst_mem        |
|   we   |     1     | Write into data_mem at high level and read from data_mem at low level |
|  addr  |    32     |                        Address signal                        |
| data_i |    32     |          the data which need to write into data_mem          |
| data_o |    32     |               the data which is from data_mem                |

### register.v

- When we need to read rs1, rs2, read data from register file according to the address in rs1, rs2;
- 当需要读取rs1,rs2时，根据rs1,rs2的地址从register file中读取数据；
- When we need to write rd, write data into register file according to the address in rd;
- 当需要写入rd时，根据rd的地址往register file中写入数据
- The operation of writing data to the register file uses sequential logic, and the operation of reading data from the register file using combinational logic;
- 往register file中写数据的操作采用时序逻辑，即在下一个时钟上升沿写入数据，从register file中读取数据采用组合逻辑；
- X0 is a constant zero register in RISC-V. When the target register rd is X0, the data won't actually be written to X0;
- RISC-V中X0为恒零寄存器，当目标寄存器rd为X0时，数据实际不会被写入X0；
- If the read and write register signals are valid at the same time, and if the read address is the same as the write address, then the data which need to write can be directly output as read data to achieve data forwarding.
- 如果读寄存器信号与写寄存器信号同时有效，并且读地址与写地址相同，此时则可以将要写入的数据直接输出为读数据,实现数据转发。

### stall.v (5 stages)

- Pause the pipeline When data adventures cannot be resolved through data forwarding;
- 当数据冒险无法通过数据转发解决，使流水暂停；
- Collect stall request signals from levels. If some level sends a stall request, all sequential circuits in front of the level should be paused.
- 从各级之间收集stall请求信号，如果某级发出stall请求，则将该级前面所有的时序电路暂停。

### if_id.v (5 stages)

- Sequential logic: pass PC value and inst. When the pipeline is blocked, keep pc and inst; when the branch is established, clear pc and inst.
- 时序逻辑: 传递PC值和inst。流水线阻塞时，pc和inst保持不变；分支成立时，pc和inst清零。

### id_ex.v (5 stages)

- Sequential logic: pass the decoded ALUop, source operand, destination register address, write register flag and other signals in id.v.
- 时序逻辑: 传递id.v中译码得到的ALUop，源操作数，目标寄存器地址，写寄存器标志等信号。
- When the pipeline is blocked, the above signals remain unchanged or Bubble.
- 流水线阻塞时，以上信号保持不变或清零(Bubble)。

### ex_mem.v (5 stages)

- Sequential logic: Pass the calculated result data in ex.v, target register address, write register flag and other signals.
- 时序逻辑: 传递ex.v中计算得到的结果数据，目标寄存器地址，写寄存器标志等信号。
- When the pipeline is blocked, the above signals remain unchanged or Bubble.
- 流水线阻塞时，以上信号保持不变或清零(Bubble)

### mem_wb.v (5 stages)

- Sequential logic: Pass the result data to be written to the register, the destination register address, the write register flag and other signals.
- 时序逻辑: 传递要写入寄存器的结果数据，目标寄存器地址，写寄存器标志等信号。

## Submission

- Format: Student ID_Name_lab.zip
- deadline: Dec 29, 2019 (Sunday)