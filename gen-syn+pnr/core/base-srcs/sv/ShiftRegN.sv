`timescale 1ns / 1ps

module ShiftRegN #(parameter N=8) (  
    input d,               // Declare input for data to the first flop in the shift register
    input clk,             // Declare input for clock to all flops in the shift register
    input en,              // Declare input for enable to switch the shift register on/off
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
    else if (en)
      out <= {d, out[N-1:1]};
  end
endmodule
