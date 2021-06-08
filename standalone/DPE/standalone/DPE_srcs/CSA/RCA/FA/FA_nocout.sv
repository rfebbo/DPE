`timescale 1ns/10ps

module FA_nocout(input logic a, input logic b, input logic c_in, output logic s);

	logic temp;


	// always_comb begin
    assign temp = a ^ b;
    assign s = temp ^ c_in;
	// en

endmodule