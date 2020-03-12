`timescale 1ns / 1ps

// 2-to-1 multiplexer
module mux2
#(WIDTH = 8
)(
  input logic [WIDTH-1:0] d0, d1,
  input logic s,
  output logic [WIDTH-1:0] y
);
  assign y = s ? d1 : d0;
endmodule: mux2
