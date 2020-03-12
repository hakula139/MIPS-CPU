`timescale 1ns / 1ps

// Register file
module regfile
(
  input logic clk,
  input logic we3,
  input logic [4:0] wa3,
  input logic [31:0] wd3,
  input logic [4:0] ra1, ra2,
  output logic [31:0] rd1, rd2
);
  logic [31:0] rf[31:0];
  always_ff @(posedge clk) begin
    if (we3) rf[wa3] <= wd3;
  end
  // Register 0 hardwired to 0
  assign rd1 = ra1 ? rf[ra1] : '0;
  assign rd2 = ra2 ? rf[ra2] : '0;
endmodule: regfile
