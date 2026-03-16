/*
 * Ask me anything: via repo/issue, or e-mail: vencifreeman16@sjtu.edu.cn.
 * Author: @VenciFreeman (GitHub), copyright 2019.
 * School: Shanghai Jiao Tong University.

 ****************** Original test module. Do not Modify! ******************

 */

module data_mem(

	input	wire		clk,
	input	wire		ce,		// Chip select signal, when it's high, enable data_mem.
	input	wire		we,		// When it's high, write data_mem. Otherwise read data_mem.
	input	wire[31:0]	addr,
	input	wire[31:0]	data_i,	// Data waiting for writing into data_mem
	output	reg [31:0]	data_o,	// Data reading from data_mem
	output 	wire[31:0]	verify	// test example.
	
);

	localparam DATA_MEM_DEPTH = 1024;
	reg[7:0] data[0:DATA_MEM_DEPTH - 1];
	reg[7:0] data_byte;
	integer fd;
	integer code;
	integer idx;

	/*
	 * Load data memory line by line to avoid readmemh range warnings.
	 * Expected format: one byte (hex) per line.
	 */
	initial begin
		for (idx = 0; idx < DATA_MEM_DEPTH; idx = idx + 1)
			data[idx] = 8'b0;

		fd = $fopen("data_mem.txt", "r");
		if (fd == 0)
			fd = $fopen("./Pipeline/data_mem.txt", "r");
		if (fd != 0) begin
			idx = 0;
			while (!$feof(fd) && idx < DATA_MEM_DEPTH) begin
				code = $fscanf(fd, "%h\n", data_byte);
				if (code == 1) begin
					data[idx] = data_byte;
					idx = idx + 1;
				end else
					code = $fgetc(fd);
			end
			$fclose(fd);
		end else
			$display("ERROR: cannot open data_mem.txt or ./Pipeline/data_mem.txt");
	end

	assign verify = {data[15], data[14], data[13], data[12]};

always @ (posedge clk) begin
	if (ce && we) begin
		data[addr]     <= data_i[7:0];
		data[addr + 1] <= data_i[15:8];
		data[addr + 2] <= data_i[23:16];
		data[addr + 3] <= data_i[31:24];
	end
end

always @ (*) begin
	if (!ce)
		data_o <= 32'b0;
	else if(we == 1'b0) begin
		data_o <= { 
					data[addr + 3],
					data[addr + 2],
					data[addr + 1],
					data[addr]   };
	end else
		data_o <= 32'b0;
end		

endmodule