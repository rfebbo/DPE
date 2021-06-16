`timescale 1ns / 1ps

module RegPLoad #(parameter N=8) (  
    input clk,             // Declare input for clock to all flops in the shift register
    input [N-1:0] pd,      // Declare input for parallel input data
    input ld,              // Declare input to load pd vector
    input rstn,            // Declare input to reset the register to a default value
    output reg [N-1:0] out // Declare output to read out the current value of all flops in this register
  );


  // This always block will "always" be triggered on the rising edge of clock
  // Once it enters the block, it will first check to see if reset is 0 and if yes then reset register
  // If no, then check to see if the shift register is enabled
  // If no => maintain previous output. If yes, then shift based on the requested direction
  always_ff @ (posedge clk or negedge rstn)
  begin
    if (!rstn)
      out <= 0;
    else 
    begin
      if (ld)
        out <= pd;
    end
  end
endmodule

