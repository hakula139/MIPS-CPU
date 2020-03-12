`timescale 1ns / 1ps

// Arithmetic logic unit
module alu
(
  input logic [3:0] aluControl,
  input logic [31:0] a, b,
  output logic [31:0] aluResult
);
  always_comb begin
    unique case(aluControl) inside
      0: aluResult <= a & b;
      1: aluResult <= a | b;
      2: aluResult <= a + b;
      3: aluResult <= b << a;
      4: aluResult <= a & ~b;
      5: aluResult <= a | ~b;
      6: aluResult <= a - b;
      7: aluResult <= a < b ? 32'b1 : '0;
      8: aluResult <= b >> a;   // logical shift
      9: aluResult <= b >>> a;  // arithmetic shift
      default: aluResult <= '0;
    endcase
  end
endmodule: alu
