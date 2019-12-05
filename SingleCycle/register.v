/************************************************************************************
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.          *
 * Author: @VenciFreeman (GitHub), copyright 2019.									*
 * School: Shanghai Jiao Tong University.											*
 * Description:                                                                     *
 *                                                              					*
 * Details:                                                                         *
 * - When we need to read rs1, rs2, read data from register file according to the   *
 *   address in rs1, rs2;                                                           *
 * - When we need to write rd, write data into register file according to the       *
 *   address in rd;                                                                 *
 * - The operation of writing data to the register file uses sequential logic, and  *
 *   the operation of reading data from register file using combinational logic;    *
 * - X0 is a constant zero register in RISC-V. When the target register rd is X0,   *
 *   the data won't actually be written to X0;                                      *
 * - If the read and write register signals are valid at the same time, and if the  *
 *   read address is the same as the write address, then the data which need to     *
 *   write can be directly output as read data to achieve data forwarding.          *
 * History:																			*
 * Notes:																			*
 ************************************************************************************/