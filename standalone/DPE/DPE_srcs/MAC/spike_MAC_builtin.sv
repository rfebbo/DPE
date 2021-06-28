`timescale 1ns/10ps
`include "../DPE_params.sv"


//multiply spike vector of 8 bits with 8x8 matrix and sum column
module spike_MAC_builtin(input logic [7:0] spikes, input logic [7:0][7:0][7:0] matrix, output logic [7:0][OUT_WIDTH-1:0] out);

    logic [7:0][7:0][7:0] product;
    logic [OUTPUT_VEC_LEN-1:0][INPUT_VEC_LEN-2:0][OUT_WIDTH-1:0] summation_steps;

    genvar ii, jj, kk, ll;

    // element wise multiplication between spikes and each column
    for (ii = 0; ii < INPUT_VEC_LEN; ii++) begin //row
        for (jj = 0; jj < OUTPUT_VEC_LEN; jj++) begin //column
            for (kk = 0; kk < WIDTH; kk++) begin //bit
                assign product[ii][jj][kk] = spikes[ii] & matrix[ii][jj][kk];
            end
        end
    end

    //sum columns of product
    for (jj = 0; jj < OUTPUT_VEC_LEN; jj++) begin //column
        //https://stackoverflow.com/a/29209422
        assign summation_steps[jj][0] = product[0][jj] + product[1][jj];
        for (ii = 0; ii < INPUT_VEC_LEN-2; ii++) begin //row
            assign summation_steps[jj][ii+1] = summation_steps[jj][ii] + product[ii+2][jj];
        end

        assign out[jj] = summation_steps[jj][INPUT_VEC_LEN-2];
    end


endmodule
	