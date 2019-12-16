/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.
 *
 * Description:
 *
 * Details:
 * - When we need to read rs1, rs2, read data from register file according to the
 *   address in rs1, rs2;
 * - When we need to write rd, write data into register file according to the
 *   address in rd;
 * - The operation of writing data to the register file uses sequential logic, and
 *   the operation of reading data from register file using combinational logic;
 * - X0 is a constant zero register in RISC-V. When the target register rd is X0,
 *   the data won't actually be written to X0;
 * - If the read and write register signals are valid at the same time, and if the
 *   read address is the same as the write address, then the data which need to
 *   write can be directly output as read data to achieve data forwarding.
 *
 * History:
 *
 * Notes:
 *
 */

 module Registers(

    input   [25:21] readReg1,
    input   [20:16] readReg2,
    input   [15:11] writeReg,
    input   [31:0]  writeData,
    input           regWrite,
    input           clk,
    output  [31:0]  readData1,
    output  [31:0]  readData2,
    input           reset

    );
    
    reg [31:0]  regFile [31:0];
    reg [31:0]  ReadData1;
    reg [31:0]  ReadData2;
    reg [5:0]   n;
    
    assign readData1 = ReadData1;
    assign readData2 = ReadData2;
    
    always @ (readReg1 or readReg2 or clk or reset)
    begin
        if(reset) begin
            for(n = 0; n < 32; n = n + 1)
                regFile[n] <= 0;
        end
        else begin
            ReadData1 <= regFile[readReg1];
            ReadData2 <= regFile[readReg2];
        end
    end
    
    always @ (negedge clk)
    begin   
        if(reset) begin
            for(n = 0; n < 32; n = n + 1)
                regFile[n] <= 0;
        end
        else if(regWrite)
            regFile[writeReg] <= writeData;
    end
    
endmodule