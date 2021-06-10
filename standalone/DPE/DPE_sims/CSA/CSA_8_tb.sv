`timescale 1ns/10ps
`include "../../DPE_srcs/DPE_params.sv"

module CSA_8_tb;
	
	logic [INPUT_VEC_LEN-1:0][WIDTH-1:0] in;
	logic [WIDTH-1:0] s;
	logic c_in, c_out0, c_out1;

	CSA_8 dut(in, s);

	logic [WIDTH-1:0] s_test;
	int i,j;

	initial begin
		s_test = 0;
		for (i = 0; i < 50; i = i+1) begin
			#2;
            for (j = 0; j < INPUT_VEC_LEN; j++) begin
				in[j] = $urandom;   
				s_test += in[j]; 
            end
			#5;
			if (s_test != s) begin
				$display("expected s to be %d not %d", s_test, s);
			end
 		end

	end

endmodule