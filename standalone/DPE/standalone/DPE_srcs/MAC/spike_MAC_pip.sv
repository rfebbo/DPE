`include "../DPE_params.sv"

//multiply spike vector of 8 bits with 8 bit 8 element vector and sum column
module spike_MAC_pip(   input logic [INPUT_VEC_LEN-1:0] spikes,
                        input logic [INPUT_VEC_LEN-1:0][WIDTH-1:0] matrix,
                        output logic [OUT_WIDTH-1:0] out);

    logic [INPUT_VEC_LEN-1:0][WIDTH-1:0] product;

    genvar ii, jj;
     // element wise multiplication between spikes and each column
    for (ii = 0; ii < INPUT_VEC_LEN; ii++) begin //row
        for (jj = 0; jj < WIDTH; jj++) begin //bit
            assign product[ii][jj] = spikes[ii] & matrix[ii][jj]; 
        end
    end

    //sum columns of product INPUT_VEC_LEN must be 8 because we are using CSA_8
    CSA_8 csa(product, out); 


endmodule
	