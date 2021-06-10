// Parameterized CSA. generates cout and s for the first three numbers using the 3 assign satements, 
//then generates a cout and sum using the cout and sum from the previous stage and a single number from the input.
//this csa can easily overflow because there are no extra output bits
`timescale 1ns/10ps

`include "DPE_params.sv"

module CSA_N(input logic [INPUT_VEC_LEN-1:0][WIDTH-1:0] in, output logic [WIDTH-1:0] s);

    //since the first 3 inputs are taken care of in the first stage, we only need INPUT_VEC_LEN-2 signals
    logic [INPUT_VEC_LEN-3:0][WIDTH-1:0] temp, c_internal, s_internal;
    logic c_out;

    // generate cout and s from adding in[0], in[1], and in[2]
    assign temp[0] = in[0] ^ in[1];
    assign s_internal[0] = temp[0] ^ in[2];
    assign c_internal[0] = (in[0] & in[1]) | (temp[0] & in[2]);

    genvar ii;
    for(ii = 1; ii < INPUT_VEC_LEN-2; ii++) begin //we've already done the first stage now do the rest
        // generate cout and s from adding cout and s from the prev stage to in[ii+2]
        assign temp[ii] = s_internal[ii-1] ^ {c_internal[ii-1][WIDTH-2:0],1'b0};
        assign s_internal[ii] = temp[ii] ^ in[ii+2];
        assign c_internal[ii] = (s_internal[ii-1] & {c_internal[ii-1][WIDTH-2:0],1'b0}) | (temp[ii] & in[ii+2]);
    end

    // Post Final stage: adds the last sum and cout signals. c_internal is shifted to the left.
    // The last bits in c_internal can be used for cout
    RCA_nocout rca(s_internal[INPUT_VEC_LEN-3], {c_internal[INPUT_VEC_LEN-3][WIDTH-2:0], 1'b0}, s);


endmodule
	