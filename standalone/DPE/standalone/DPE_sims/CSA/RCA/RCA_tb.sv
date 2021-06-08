`timescale 1ns/10ps

module RCA_tb;
	
	logic [31:0] a, b, s;
    logic c_in, c_out;

	RCA dut(a, b, c_in, s, c_out);

	initial begin
		c_in = 0;
		a = 32'hffffffff;
		b = 1;
		#5;
		a = 4;
		b = 2;

	end

endmodule