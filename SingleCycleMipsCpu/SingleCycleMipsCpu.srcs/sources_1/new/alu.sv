`timescale 1ns / 1ps

// Arithmetic logic unit
module alu
(
  input logic [2:0] alucont,
  input logic [31:0] a, b,
  output logic [31:0] result
);
  always_comb begin
    unique case(alucont) inside
      0: result <= a & b;
      1: result <= a | b;
      2: result <= a + b;
      3: result <= b << a;
      4: result <= a & ~b;
      5: result <= a | ~b;
      6: result <= a - b;
      7: result <= a < b ? 32'b1 : '0;
      8: result <= b >> a;   // logical shift
      9: result <= b >>> a;  // arithmetic shift
      default: result <= '0;
    endcase
  end
endmodule: alu
