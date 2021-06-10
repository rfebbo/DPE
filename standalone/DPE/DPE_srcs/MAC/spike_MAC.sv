`include "../DPE_params.sv"

//multiply spike vector of 8 bits with 8x8 matrix and sum column
module spike_MAC(   input logic [INPUT_VEC_LEN-1:0] spikes,
                    input logic [INPUT_VEC_LEN-1:0][OUTPUT_VEC_LEN-1:0][WIDTH-1:0] matrix,
                    output logic [OUTPUT_VEC_LEN-1:0][OUT_WIDTH-1:0] out);

    logic [OUTPUT_VEC_LEN-1:0][INPUT_VEC_LEN-1:0][WIDTH-1:0] product;

    genvar ii, jj, kk;
     // element wise multiplication between spikes and each column
    for (ii = 0; ii < INPUT_VEC_LEN; ii++) begin //row
        for (jj = 0; jj < OUTPUT_VEC_LEN; jj++) begin //column
            for (kk = 0; kk < WIDTH; kk++) begin //bit
                assign product[jj][ii][kk] = spikes[ii] & matrix[ii][jj][kk]; //NOTE product is column row major while matrix is row column major
            end
        end
    end

    //sum columns of product INPUT_VEC_LEN must be 8 because we are using CSA_8
    for (jj = 0; jj < OUTPUT_VEC_LEN; jj++) begin //column
        CSA_8 csa(product[jj], out[jj]); // This is why product is column row major, because of syntax we cant have product[:][jj]
    end


endmodule
	