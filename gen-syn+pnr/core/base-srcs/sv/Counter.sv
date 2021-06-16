`timescale 1ns / 1ps

module Counter #(parameter n = 2) (
    input clk, rstn, en,
    output reg [n-1:0]cnt
  );

  always_ff @ (posedge clk or negedge rstn)
  if (!rstn)
    cnt = 0;
  else
    if (en)
      cnt = cnt + 1;

endmodule


