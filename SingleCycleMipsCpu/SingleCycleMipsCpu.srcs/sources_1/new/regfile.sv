`timescale 1ns / 1ps

// Register file
module regfile
(
  input logic clk, reset,
  input logic regWriteEn,             // we3
  input logic [4:0] regWriteAddr,     // a3
  input logic [31:0] regWriteData,    // wd3
  input logic [4:0] rsAddr, rtAddr,   // a1, a2
  output logic [31:0] rsData, rtData  // rd1, rd2
);
  logic [31:0] rf[31:0];
  integer i;
  always_ff @(posedge clk) begin
    if (reset)
      for (i = 0; i < 32; i = i + 1)
        rf[i] <= '0;
    else if (regWriteEn)
      rf[regWriteAddr] <= regWriteData;
  end
  // Register 0 hardwired to 0
  assign rsData = rsAddr ? rf[rsAddr] : '0;
  assign rtData = rtAddr ? rf[rtAddr] : '0;
endmodule: regfile
