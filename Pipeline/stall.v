/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.

 * Description:

 * Details:
 * - When data adventures cannot be resolved through data forwarding, the
 *   pipeline is suspended;
 * - Collect stall request signals from each level. If a level sends a stall
 *   request, all sequential circuits in front of the level are suspended.

 * History:
 * - 19/12/27: Create this file.

 * Notes:
 */

 module stall(

	input   wire        rst,
	input   wire        stallreq_from_id_load,
	input   wire        stallreq_from_id_branch,
	output  reg [5:0]   stall       
	
);

always @ (*) begin
    if (rst)
        stall <= 6'b000000;
    else if (stallreq_from_id_branch)
        stall <= 6'b000010;
    else if (stallreq_from_id_load)
        stall <= 6'b000111;			
    else begin
        stall <= 6'b000000;
end		

endmodule