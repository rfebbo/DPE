`timescale 1ns/10ps

module FA(input logic a, input logic b, input logic c_in, output logic s, output logic c_out);

	logic temp;


	// always_comb begin
    assign temp = a ^ b;
    assign s = temp ^ c_in;
    assign c_out = (a & b) | (temp & c_in);
	// end

endmodule