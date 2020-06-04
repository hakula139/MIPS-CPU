`timescale 1ns / 1ps

// 32-bit arithmetic logic unit
module alu (
  input        [31:0] a_i,
  input        [31:0] b_i,
  input        [3:0]  alu_control_i,
  output logic [31:0] result_o,
  output logic        zero_o
);

  always_comb begin
    unique case (alu_control_i)
      4'd0:    result_o = a_i & b_i;
      4'd1:    result_o = a_i | b_i;
      4'd2:    result_o = a_i + b_i;
      4'd3:    result_o = b_i << a_i;
      4'd4:    result_o = a_i & ~b_i;
      4'd5:    result_o = a_i | ~b_i;
      4'd6:    result_o = a_i - b_i;
      4'd7:    result_o = a_i < b_i ? 32'b1 : '0;
      4'd8:    result_o = b_i >> a_i;   // logical shift
      4'd9:    result_o = b_i >>> a_i;  // arithmetic shift
      default: result_o = '0;
    endcase
  end

  assign zero_o = !result_o;

endmodule : alu
