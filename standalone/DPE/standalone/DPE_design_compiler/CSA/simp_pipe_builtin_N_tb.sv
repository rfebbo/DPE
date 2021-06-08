`timescale 1ns/10ps
`include "DPE_params.sv"

module simp_pipe_builtin_N_tb;
	
	logic [INPUT_VEC_LEN-1:0][WIDTH-1:0] in
	logic [WIDTH-1:0] s;
    logic clk, rst_n;

	integer i;

	simp_pipe_builtin_N dut(.*);

    always begin
        #1 clk = !clk;

    end

	initial begin
        clk <= 0;
        rst_n <= 0;
		#10;
        rst_n <= 1;
		#20;
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