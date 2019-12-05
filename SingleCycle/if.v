/************************************************************************************
 * Description:                                                                     *
 * This file controls signal PC. For 5 stage stall, keep PC.                        *       
 * Notes:                                                                           *
 * - PC+4 per cycle;                                                                *
 * - PC value send to inst_mem as the address of instruction, then send the         *
 *   instruction to decode module;                                                  *
 * - If current instruction is beq, blt or jal, update PC immediately.              *                                                                                  *
 ************************************************************************************/

module if_id(input  		   clk,
		  	 output wire[31:0] addr);

endmodule