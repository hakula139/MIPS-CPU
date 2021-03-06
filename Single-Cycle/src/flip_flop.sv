`timescale 1ns / 1ps

// Flip-flop with active-high asynchronous reset
module flip_flop #(
  parameter Width = 32
) (
  input                    clk_i,
  input                    rst_i,
  input        [Width-1:0] d_i,
  output logic [Width-1:0] q_o
);
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) q_o <= '0;
    else q_o <= d_i;
  end
endmodule : flip_flop
