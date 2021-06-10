// 8 input CSA. generates cout and s for the first three numbers using the 3 assign satements, 
//then generates a cout and sum using the cout and sum from the previous stage and a single number from the input.
`timescale 1ns/10ps

`include "../DPE_params.sv"

module CSA_8(input logic [INPUT_VEC_LEN-1:0][WIDTH-1:0] in, output logic [OUT_WIDTH-1:0] s);

    logic temp_0, temp_1, temp_2, temp_3;
    logic s_0, s_1;
    logic c_0, c_1, c_2;

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
    RCA rca(s_internal[INPUT_VEC_LEN-3], {c_internal[INPUT_VEC_LEN-3][WIDTH-2:0], 1'b0}, 1'b0, s[WIDTH-1:0], c_out);

    // final FAs 7-bit 
    
    //FA 0
    assign temp_0 = c_internal[0][WIDTH-1] ^ c_internal[1][WIDTH-1];
    assign s_0 = temp_0 ^ c_internal[2][WIDTH-1];
    assign c_0 = (c_internal[0][WIDTH-1] & c_internal[1][WIDTH-1]) | temp_0 & c_internal[2][WIDTH-1];

    //FA 1
    assign temp_1 = c_internal[3][WIDTH-1] ^ c_internal[4][WIDTH-1];
    assign s_1 = temp_1 ^ c_internal[5][WIDTH-1];
    assign c_1 = (c_internal[3][WIDTH-1] & c_internal[4][WIDTH-1]) | temp_1 & c_internal[5][WIDTH-1];

    //FA 2
    assign temp_2 = s_0 ^ s_1;
    assign s[WIDTH] = temp_2 ^ c_out;
    assign c_2 = (s_0 & s_1) | temp_2 & c_out;

    //FA 3
    assign temp_3 = c_0 ^ c_1;
    assign s[WIDTH+1] = temp_3 ^ c_2;
    assign s[WIDTH+2] = (c_0 & c_1) | temp_3 & c_2;

    assign s[OUT_WIDTH-1:WIDTH+3] = 0;

endmodule
	