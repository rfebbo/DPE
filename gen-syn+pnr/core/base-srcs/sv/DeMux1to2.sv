`timescale 1ns / 1ps

module DeMux1to2 (
    input din,
    input s,
    output logic [1:0] dout
  );
  
  always_comb
  begin
    dout = 2'b0;
    case (s)
      1'b0: dout[0]=din;
      1'b1: dout[1]=din;
      default: dout[0]=din;
    endcase
  end
endmodule

