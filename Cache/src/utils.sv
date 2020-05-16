`timescale 1ns / 1ps

// 32-bit adder
module adder (
  input        [31:0] a_i,
  input        [31:0] b_i,
  output logic [31:0] result_o
);
  assign result_o = a_i + b_i;
endmodule : adder

// 2-to-1 multiplexer
module mux2 #(
  parameter Width = 32
) (
  input        [Width-1:0] data0_i, data1_i,
  input                    select_i,
  output logic [Width-1:0] result_o
);
  assign result_o = select_i ? data1_i : data0_i;
endmodule : mux2

// 4-to-1 multiplexer
module mux4 #(
  parameter Width = 32
) (
  input        [Width-1:0] data0_i, data1_i, data2_i, data3_i,
  input        [1:0]       select_i,
  output logic [Width-1:0] result_o
);
  always_comb begin
    unique case (select_i)
      2'b00:   result_o <= data0_i;
      2'b01:   result_o <= data1_i;
      2'b10:   result_o <= data2_i;
      2'b11:   result_o <= data3_i;
      default: result_o <= '0;
    endcase
  end
endmodule : mux4

module extend #(
  parameter InWidth  = 16,
  parameter OutWidth = 32
) (
  input                       sign_i,
  input        [InWidth-1:0]  a_i,
  output logic [OutWidth-1:0] result_o
);
  assign result_o = {{(OutWidth - InWidth){sign_i ? a_i[InWidth - 1] : 1'b0}}, a_i};
endmodule : extend

// 32-bit equality comparator
module equal_cmp (
  input        [31:0] a_i,
  input        [31:0] b_i,
  output logic        equal_o
);
  assign equal_o = a_i == b_i ? '1 : '0;
endmodule : equal_cmp
