`timescale 1ns / 1ps

module adder
(
  input logic [31:0] a, b,
  output logic [31:0] y
);
  assign y = a + b;
endmodule: adder
