`timescale 1ns/10ps
`include "DPE_params.sv"

module simp_pipe_builtin_MAC_tb;
	
	
    logic clk, rst_n;

    logic [INPUT_VEC_LEN-1:0][OUTPUT_VEC_LEN-1:0][WIDTH-1:0] matrix;
    logic [INPUT_VEC_LEN-1:0] spikes;
    logic [OUTPUT_VEC_LEN-1:0][WIDTH-1:0] out, out_test;

    int i,j,k;

    logic [OUTPUT_VEC_LEN-1:0][WIDTH-1:0] s_test;

    simp_pipe_spike_MAC dut(spikes,matrix,out);
    simp_pipe_spike_MAC_builtin dut_tester(spikes,matrix,out_test);

    always begin
        #1 clk = !clk;

    end

	initial begin



	end

endmodule