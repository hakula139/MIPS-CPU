`timescale 1ns / 1ps

// Flip-flop with synchronous reset
module flopr
#(WIDTH = 8
)(
  input logic clk, reset,
  input logic [WIDTH-1:0] d,
  output logic [WIDTH-1:0] q
);
  always_ff @(posedge clk, posedge reset) begin
    if (reset)
      q <= '0;
    else
      q <= d;
  end
endmodule: flopr
