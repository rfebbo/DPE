`timescale 1ns/10ps

module RCA_nocout
    #(parameter WIDTH=32)
    (input logic [WIDTH-1:0] a, input logic [WIDTH-1:0] b, output logic [WIDTH-1:0] s);

	logic [WIDTH-1:0] cin_internal;
    assign cin_internal[0] = 1'b0;

	genvar ii;
    generate
        for (ii=0; ii<WIDTH-1; ii=ii+1) begin
                FA fa(a[ii], b[ii], cin_internal[ii], s[ii], cin_internal[ii+1]);
        end
        FA_nocout fa_final(a[WIDTH-1], b[WIDTH-1], cin_internal[WIDTH-1], s[WIDTH-1]);
    endgenerate

endmodule