`timescale 1ns/10ps
`include "DPE_params.sv"

module KSA_tb;
	
	logic [WIDTH-1:0] a, b, s;
    logic c_in, c_out;
	integer i;

	logic [WIDTH:0] s_test;

	KSA_2 dut(a, b, c_in, s, c_out);

	initial begin
		c_in = 0;
		a = 8'b10101010;
		b = 36;
		#5;
		a = 4;
		b = 2;

		for (i = 0; i < 50; i = i+1) begin
			#2;
			c_in = $urandom;
			a = $urandom;
			b = $urandom;
			s_test = a + b + c_in;
			#2;
			if (s_test != {c_out, s}) begin
				$display($time, " expected s to be %d not %d", s_test, {c_out, s});
			end
		end

	end

endmodule