`timescale 1ns / 1ps

// Register file
module regfile
(
  input logic clk,
  input logic regWriteEn,
  input logic [4:0] regWriteAddr,
  input logic [31:0] regWriteData,
  input logic [4:0] rsAddr, rtAddr,
  output logic [31:0] rsData, rtData
);
  logic [31:0] rf[31:0];
  always_ff @(posedge clk) begin
    if (regWriteEn) rf[regWriteAddr] <= regWriteData;
  end
  // Register 0 hardwired to 0
  assign rsData = rsAddr ? rf[rsAddr] : '0;
  assign rtData = rtAddr ? rf[rtAddr] : '0;
endmodule: regfile
