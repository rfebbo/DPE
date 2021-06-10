`timescale 1ns/10ps
`include "../../DPE_srcs/DPE_params.sv"

//multiply spike vector of 8 bits with 8x8 matrix and sum column
module spike_MAC_tb;

    logic [7:0][7:0][7:0] matrix;
    logic [7:0] spikes;
    logic [7:0][OUT_WIDTH-1:0] out, out_test;

    int i,j,k;

    logic [7:0][7:0] s_test;

    spike_MAC dut(spikes,matrix,out);
    spike_MAC_builtin dut_tester(spikes,matrix,out_test);

	initial begin
        for (i = 0; i < 50; i = i+1) begin
			#2;
			spikes = $urandom;
            for (j = 0; j < 8; j++) begin
                for (k = 0; k < 8; k++) begin
			        matrix[j][k] = $urandom;
                end
            end
            #5;
            for (j = 0; j < 8; j++) begin
                for (k = 0; k < OUT_WIDTH; k++) begin
                    if (out_test[j][k] != out[j][k]) begin
                        $display($time, " bit %d in number %d should have been %d", k, j, out_test[j][k]);
                    end
                end
            end
            
		end
    end


endmodule
	