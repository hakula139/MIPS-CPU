`timescale 1ns / 1ps

// Since our TA has hard-coded variable names into the grader, we have
// to name the variables like this, regardless of the coding style.

// 32-bit data memory
module dmem (
  input               clk,
  input               we,  // mem_write_en
  input        [31:0] a,   // mem_write_addr
  input        [31:0] wd,  // mem_write_data
  output logic [31:0] rd   // mem_read_data
);
  logic [31:0] RAM[127:0];
  always_ff @(posedge clk) begin
    if (we) RAM[a[31:2]] <= wd;
  end
  assign rd = RAM[a[31:2]];  // word aligned
endmodule : dmem
