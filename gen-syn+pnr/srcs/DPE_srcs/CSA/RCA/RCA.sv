`timescale 1ns/10ps
`include "../../DPE_params.sv"

module RCA
    (input logic [WIDTH-1:0] a, input logic [WIDTH-1:0] b, input logic c_in, output logic [WIDTH-1:0] s, output logic c_out);

	logic [WIDTH:0] cin_internal;
    assign cin_internal[0] = c_in;
    assign c_out = cin_internal[WIDTH-1];

	genvar ii;
    generate
        for (ii=0; ii<WIDTH; ii=ii+1) begin
                FA fa(a[ii], b[ii], cin_internal[ii], s[ii], cin_internal[ii+1]);
        end
    endgenerate

endmodule