module data_mem(

	input wire			clk,
	input wire			ce,
	input wire			we,
	input wire [31:0]	addr,
	input wire [31:0]	data_i,
	output reg [31:0]	data_o,
	output wire[31:0]	verify
	
);

	reg[7:0]  data[0:32'h400];
	initial $readmemh ( "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/SingleCycle/data_mem.txt", data );

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