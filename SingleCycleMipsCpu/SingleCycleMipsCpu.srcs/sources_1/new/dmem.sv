`timescale 1ns / 1ps

// Data memory
module dmem
(
  input logic clk, we,
  input logic [31:0] a, wd,
  output logic [31:0] rd
);
  logic [31:0] ram[63:0];
  assign rd = ram[a[31:2]];
  always_ff @(posedge clk) begin
    if (we) ram[a[31:2]] <= wd;
  end
endmodule: dmem
