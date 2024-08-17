# RISC-V_CPU

> A simple RISC-V CPU written in Verilog.
> 
> 用Verilog编写的简单的RISC-V处理器。

## Overview

This is an undergraduate Digital Logic Design course assignment. The task is to design and implement a processor based on the RISC-V instruction set using Verilog, with a requirement to implement some instructions from the RV32I instruction set. The expected outcome is that executing test scripts will yield correct output results.

本科数字逻辑设计课程作业，内容是使用Verilog设计实现基于RISC-V指令集的处理器，要求实现RV32I指令集中的部分指令。预期目标是执行测试脚本可以得到正确的运算结果。

## Content

- Design and implement a **single-cycle** 32-bit RISC-V processor;
- 设计实现一款单周期的32位RISC-V处理器；
- Improve the processor from single-cycle to **multi-cycle**;
- 在单周期RISC-V处理器的基础上进行改进，实现多周期的RISC-V处理器；
  - **Single-issue**, **5-stages** pipelining;
  - 单发射、五级流水线；
  - **Data forwarding**, and **pipeline blocking**;
  - 实现数据转发、流水线阻塞；
  - Branch Prediction (optional).
  - 分支预测(选做)；
- Use **Modelsim** for simulation and verification, and observe the corresponding signal waveforms;
- 使用Modelsim进行仿真验证，查看相应信号波形；
- Use Vivado for synthesis, optimize timing as much as possible (optimize);
- 使用Vivado对代码进行综合，尽可能的优化时序(选做)；
- Executing test scripts to obtain correct output results.
- 运行测试指令，得到正确的输出结果。

<img src="https://github.com/VenciFreeman/RISC-V/blob/master/img/structure.jpg" style="zoom:50%;" />

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

![](https://github.com/VenciFreeman/RISC-V/blob/master/img/SingleCycle.jpg)

### if.v (single cycle)

- PC (Program Counter) normally increments by 4 each cycle;
- 程序计数器PC在正常情况下，每个周期加4；
- PC value is sent to `inst_mem` as the address for fetching instructions, and the fetched instructions are directly passed to the decode module;
- PC值送入inst_mem作为指令的地址，将取得的指令直接送入译码模块；
- If the current instruction is a conditional branch instruction (e.g., `beq`, `blt`) or an unconditional jump instruction (`jal`), the PC needs to be updated to the target address of the jump instruction if the branch condition is met.
- 如果当前的指令是条件分支指令(beq,blt)或直接跳转指令(jal)，当分支成立时，PC需要更新为跳转指令的目标地址。

<img src="https://github.com/VenciFreeman/RISC-V/blob/master/img/inst_mem.jpg" alt=" " style="zoom:50%;" />

| Signal | Bit width |                    Function                    |
| :----: | :-------: | :--------------------------------------------: |
|   ce   |     1     | Chip select signal, high level enable inst_mem |
|  addr  |    32     |              instruction address               |
|  inst  |    32     |                  instruction                   |

### id.v (single cycle)

- Decode the fetched instruction to determine the specific `ALUop` based on `opcode`, `funct3`, and `funct7`.
- 对取到的指令进行译码，根据opcode, funct3, funct7确定具体的ALUop；
- Determine if there is a need to read from registers. If so, send the register numbers `rs1` and `rs2` to the register file to read the corresponding data as source operands.
- 判断是否需要读寄存器，把要读取的寄存器号rs1,rs2 送入register file，读取相应的数据作为源操作数；
- Determine if there is a need to write to a register. Output the destination register number `rd` and the write-enable flag for register write-back.
- 判断是否需要写寄存器，输出目标寄存器号rd、写寄存器标志，用于寄存器回写；
- Check if a branch instruction is taken, and compute the jump address (this can also be implemented in ex.v).
- 判断分支指令是否成立，并计算跳转地址(也可以在ex.v中实现)；
- For instructions with immediate values, perform sign extension (or no-sign extension, as specified in the spec file) to use as one of the source operands.
- 对含有立即数的指令进行符号扩展(或无符号扩展，具体参考spec文件)，作为其中的一个源操作数。

| Instruction | opcode  | funct3 | funct7  | ALUop  |
| :---------: | :-----: | :----: | :-----: | :----: |
|     add     | 0110011 |  000   | 0000000 | 000001 |
|     sub     | 0110011 |  000   | 0100000 | 000010 |
|     sll     | 0110011 |  001   | 0000000 | 000011 |
|     jal     | 1101111 |  N/A   |   N/A   | 000100 |

### ex.v (single cycle)

- Use the `ALUop` and the two source operands decoded in id.v to perform the corresponding operation;
- 根据id.v中译码所得的ALUop和两个源操作数，进行相应的操作；
- If `ALUop` indicates that it's an addition operation, the two operands will be added; the sub operation can be implemented by complement.
- 如果ALUop表明是加法操作，则将两个操作数相加；减法操作可以通过加补码实现。

<img src="https://github.com/VenciFreeman/RISC-V/blob/master/img/ALUop.jpg" style="zoom:50%;" />

| ALUop  | Operation |
| :----: | :-------: |
| 000001 |     +     |
| 000011 |    <<     |
| 000010 |     -     |

### mem.v (single cycle)

- If the instruction is `lw`, read 32-bit data from `data_mem`;
- 指令是lw指令，则从data_mem中读取32bit的数据；
- If the instruction is `sw`, write 32-bit data to `data_mem`;
- 指令是sw指令，则向data_ mem中写入32bit的数据；
- For other instructions, no operation is performed.
- 如果是其他指令，则不做操作。

| Signal | Bit width |                           Function                           |
| :----: | :-------: | :----------------------------------------------------------: |
|   ce   |     1     |        Chip select signal, high level enable inst_mem        |
|   we   |     1     | Write into data_mem at high level and read from data_mem at low level |
|  addr  |    32     |                        Address signal                        |
| data_i |    32     |          the data which need to write into data_mem          |
| data_o |    32     |               the data which is from data_mem                |

### register.v

- When reading `rs1` or `rs2`, fetch data from the register file using the addresses of `rs1` and `rs2`;
- 当需要读取rs1,rs2时，根据rs1,rs2的地址从register file中读取数据；
- When writing to `rd`, write data to the register file at the address of `rd`;
- 当需要写入rd时，根据rd的地址往register file中写入数据
- Writing data to the register file uses sequential logic, meaning data is written on the next clock rising edge, while reading data from the register file uses combinational logic;
- 往register file中写数据的操作采用时序逻辑，即在下一个时钟上升沿写入数据，从register file中读取数据采用组合逻辑；
- In RISC-V, `X0` is a zero register. When the destination register `rd` is `X0`, the data is not actually written to `X0`;
- RISC-V中X0为恒零寄存器，当目标寄存器rd为X0时，数据实际不会被写入X0；
- If the read register signal and write register signal are both active simultaneously, and the read address and write address are the same, the data to be written can be directly output as read data, implementing data forwarding.
- 如果读寄存器信号与写寄存器信号同时有效，并且读地址与写地址相同，此时则可以将要写入的数据直接输出为读数据,实现数据转发。

![](https://github.com/VenciFreeman/RISC-V/blob/master/img/FiveStages.jpg)

### stall.v (5 stages)

- When data hazards cannot be resolved through data forwarding, pipeline stalls are introduced;
- 当数据冒险无法通过数据转发解决，使流水暂停；
- Collect stall request signals between stages; if a stall request is issued by a stage, all sequential logic circuits before that stage are stalled.
- 从各级之间收集stall请求信号，如果某级发出stall请求，则将该级前面所有的时序电路暂停。

### if_id.v (5 stages)

- Sequential logic: Pass the `PC` value and `inst`. During pipeline stalls, `pc` and `inst` remain unchanged; when a branch is taken, `pc` and `inst` are cleared.
- 时序逻辑: 传递PC值和inst。流水线阻塞时，pc和inst保持不变；分支成立时，pc和inst清零。

### id_ex.v (5 stages)

- Sequential logic: Pass the ·ALUop·, source operands, destination register address, and write register flag obtained from decoding in id.v;
- 时序逻辑: 传递id.v中译码得到的ALUop，源操作数，目标寄存器地址，写寄存器标志等信号。
- During pipeline stalls, these signals remain unchanged or are Bubbled.
- 流水线阻塞时，以上信号保持不变或清零。

### ex_mem.v (5 stages)

- Sequential logic: Pass the result data computed in ex.v, destination register address, and write register flag;
- 时序逻辑: 传递ex.v中计算得到的结果数据，目标寄存器地址，写寄存器标志等信号。
- During pipeline stalls, these signals remain unchanged or are Bubbled.
- 流水线阻塞时，以上信号保持不变或清零。

### mem_wb.v (5 stages)

- Sequential logic: Pass the result data to be written to the register, destination register address, and write register flag.
- 时序逻辑: 传递要写入寄存器的结果数据，目标寄存器地址，写寄存器标志等信号。

![](https://github.com/VenciFreeman/RISC-V/blob/master/img/AddModule.jpg)

## Submission

- Deadline: Dec 29, 2019 (Sunday)
