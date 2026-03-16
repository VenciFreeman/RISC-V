/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.

 ****************** Original test module. Do not Modify! ******************
 
 */

module inst_mem(

	input	wire		ce,    // chip select signal
	input	wire[31:0]	addr,  // instruction address
	output 	reg [31:0]	inst   // instruction
	
);

	localparam INST_MEM_DEPTH = 1024;
	reg[31:0] inst_memory[0:INST_MEM_DEPTH - 1];
	reg[31:0] inst_word;
	integer fd;
	integer code;
	integer idx;

	/*
	 * Load instruction memory line by line to avoid readmemb range warnings.
	 * Expected format: one 32-bit binary instruction per line.
	 */
	initial begin
		for (idx = 0; idx < INST_MEM_DEPTH; idx = idx + 1)
			inst_memory[idx] = 32'b0;

		fd = $fopen("./TestCode/machinecode.txt", "r");
		if (fd != 0) begin
			idx = 0;
			while (!$feof(fd) && idx < INST_MEM_DEPTH) begin
				code = $fscanf(fd, "%b\n", inst_word);
				if (code == 1) begin
					inst_memory[idx] = inst_word;
					idx = idx + 1;
				end else
					code = $fgetc(fd);
			end
			$fclose(fd);
		end else
			$display("ERROR: cannot open ./TestCode/machinecode.txt");
	end

always @ (*) begin
	if (!ce)
		inst <= 32'b0;
	else
		inst <= inst_memory[addr[31:2]];
end

endmodule