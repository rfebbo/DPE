`timescale 1ns/10ps
`include "DPE_params.sv"

module simp_pipe_csa_N
	(input logic clk,
	input logic rst_n,
	input logic c_in,
	input logic [INPUT_VEC_LEN-1:0][WIDTH-1:0] in,
	output logic [WIDTH-1:0] s);


	logic [INPUT_VEC_LEN-1:0][WIDTH-1:0] Inr;
	logic [WIDTH-1:0] Sr;
	
	always_ff @(posedge(clk)) begin
		if (~rst_n) begin
			for (int i = 0; i < INPUT_VEC_LEN; i++) begin
				Inr[i] <= 0;
			end

			s <= 0;
		end
		else begin
			Inr <= in;

			s <= Sr;
		end
	end
	
	CSA_N csa(Inr, Sr);

endmodule
	

