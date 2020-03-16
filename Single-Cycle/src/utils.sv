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
  input        [Width-1:0] data0_i,
  input        [Width-1:0] data1_i,
  input                    select_i,
  output logic [Width-1:0] result_o
);
  assign result_o = select_i ? data1_i : data0_i;
endmodule : mux2

// Sign extend
module sign_ext #(
  parameter InWidth  = 16,
  parameter OutWidth = 32
) (
  input        [InWidth-1:0]  a_i,
  output logic [OutWidth-1:0] result_o
);
  assign result_o = {{(OutWidth - InWidth){a_i[InWidth - 1]}}, a_i};
endmodule : sign_ext
