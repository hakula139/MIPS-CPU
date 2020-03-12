`timescale 1ns / 1ps

// Left shift by 2
module sl2
(
  input logic [31:0] a,
  output logic [31:0] y
);
  assign y = {a[29:0], 2'b00};
endmodule: sl2
