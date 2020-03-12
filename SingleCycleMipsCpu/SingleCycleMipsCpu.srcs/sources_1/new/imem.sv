`timescale 1ns / 1ps

// Instruction memory
module imem
(
  input logic [5:0] a,
  output logic [31:0] rd
);
  logic [31:0] ram[63:0];
  initial begin
    $readmemh("memfile.dat", ram);
  end
  assign rd = ram[a];
endmodule: imem
