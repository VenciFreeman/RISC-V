module inst_mem(

	input wire					ce,
	input wire[31:0]			addr,
	output reg[31:0]			inst
	
);

	reg[31:0]  inst_memory[0:1000];

	initial $readmemb ( "C:/Users/Venci/Documents/GitHub/RISC-V_CPU/TestCode/machinecode.txt", inst_memory );

always @ (*) begin
	if (ce == 1'b0)
		inst <= 32'b0;
	else
		inst <= inst_memory [addr[31:2]];
end

endmodule