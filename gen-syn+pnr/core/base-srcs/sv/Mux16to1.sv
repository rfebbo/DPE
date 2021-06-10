`timescale 1ns / 1ps

module Mux16to1 (
    input [15:0]i,
    input [3:0]s,
    output o
  );
    
  assign o = i[s];

endmodule
