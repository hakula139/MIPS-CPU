`timescale 1ns / 1ps

module regfile
(
  input logic [4:0] ra1, ra2,
  output logic [31:0] rd1, rd2
);
  logic [31:0] rf[31:0];
  assign rd1 = ra1 ? rf[ra1] : '0;
  assign rd2 = ra2 ? rf[ra2] : '0;
endmodule: regfile
