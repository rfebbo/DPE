`timescale 1ns/10ps
`include "DPE_params.sv"

module simp_pipe_spike_MAC_builtin(
	input logic clk,
	input logic rst_n,
	input logic [INPUT_VEC_LEN-1:0] spikes,
	input logic [OUTPUT_VEC_LEN-1:0][INPUT_VEC_LEN-1:0][WIDTH-1:0] matrix,
	output logic [OUTPUT_VEC_LEN-1:0][WIDTH-1:0] out);

	logic [OUTPUT_VEC_LEN-1:0][INPUT_VEC_LEN-1:0][WIDTH-1:0] Matrixr;
	logic [INPUT_VEC_LEN-1:0] Spikesr;
	logic [OUTPUT_VEC_LEN-1:0][WIDTH-1:0] Outr;
	logic C_INr, C_OUT0m, C_OUT1m;
	
	always_ff @(posedge(clk)) begin
		if (~rst_n) begin
			Matrixr <= 0;
			Spikesr <= 0;

			out <= 0;
		end
		else begin
			Matrixr <= matrix;
			Spikesr <= spikes;

			out <= Outr;
		end
	end
	
	spike_MAC_builtin mac(Spikesr, Matrixr, Outr);

endmodule
	

