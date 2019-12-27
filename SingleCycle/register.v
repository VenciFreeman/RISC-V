/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.
 *
 * Description:
 *
 * Details:
 * - When we need to read readReg1, readReg2, read data from register file according to the
 *   address in readReg1, readReg2;
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
 * - 19/12/14: Create this file;
 * - 19/12/23: Modify the format;
 * - 19/12/26: Edit module. (I think it's finished.)
 *
 * Notes:
 *
 */

 module Registers(

    input   wire        clk,
    input   wire        rst,
    input   wire        we,
    input   wire[4:0]   WriteAddr,
    input   wire[31:0]  WriteData,
    input   wire[1:0]   ReadReg1,
    input   wire[1:0]   ReadReg2,
    input   wire[4:0]   ReadAddr1,
    input   wire[4:0]   ReadAddr2,
    output  reg [31:0]  ReadData1,
    output  reg [31:0]  ReadData2

    );

    reg [5:0]  n;
    reg [31:0] regFile [31:0];
    
/*
* This always part controls the signal reg_file, control write.
*/    
always @ (*) begin
    if(rst)
        for(n = 0; n < 32; n = n + 1)
            regFile[n] <= 0;
    else if(we && WriteAddr != 5'b0) begin
        regFile[WriteAddr] <= WriteData;
        $display("register: regs[%d] <= %h", WriteAddr, WriteData);
    end
end

/*
* This always part controls the signal ReadData1, control read1.
*/ 
always @ (*) begin
    if(rst || ReadAddr1 == 5'b0)
        ReadData1 <= 32'b0;
    else if (we && ReadReg1 && ReadAddr1 == WriteAddr)
        ReadData1 <= WriteData;
    else if (ReadReg1) begin
        ReadData1 <= regFile[ReadReg1];
        $display("register: regs[%d] <= %h", ReadAddr1, ReadData1);
    end else
        ReadData1 <= 32'b0;
end

/*
* This always part controls the signal ReadData2, control read2.
*/ 
always @ (*) begin
    if(rst || ReadAddr2 == 5'b0)
        ReadData2 <= 32'b0;
    else if (we && ReadReg2 && ReadAddr2 == WriteAddr)
        ReadData2 <= WriteData;
    else if (ReadReg2) begin
        ReadData2 <= regFile[ReadReg2];
        $display("register: regs[%d] <= %h", ReadAddr2, ReadData2);
    end else
        ReadData2 <= 32'b0;
end
    
endmodule