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
 * - 19/12/14: Create this file.
 *
 * Notes:
 *
 */

 module Registers(

    input   [25:21] rs1,
    input   [20:16] rs2,
    input   [15:11] writeReg,
    input   [31:0]  writeData,
    input           regWrite,
    input           clk,
    input           rst,
    output  [31:0]  rd1_o,
    output  [31:0]  rd2_o

    );
    
    reg [31:0]  regFile [31:0];
    reg [31:0]  rd1;
    reg [31:0]  rd2;
    reg [5:0]   n;
    
    assign rd1_o = rd1;
    assign rd2_o = rd2;
    
always @ (rs1 or rs2 or clk or rst) begin
    if(rst) begin
        for(n = 0; n < 32; n = n + 1)
            regFile[n] <= 0;
    end
    else begin
        rd1 <= regFile[rs1];
        rd2 <= regFile[rs2];
    end
end
    
always @ (negedge clk) begin   
    if(rst) begin
        for(n = 0; n < 32; n = n + 1)
            regFile[n] <= 0;
    end
    else if(regWrite)
        regFile[writeReg] <= writeData;
end
    
endmodule