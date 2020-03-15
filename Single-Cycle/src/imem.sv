`timescale 1ns / 1ps

// Since our TA has hard-coded variable names into the grader, we have
// to name the variables like this, regardless of the coding style.

// 32-bit instruction memory
module imem (
  input        [5:0]  a,  // pc_addr
  output logic [31:0] rd  // instr_data
);
  logic [31:0] RAM[63:0];
  initial begin
    $readmemh("memfile.dat", RAM);
  end
  assign rd = RAM[a];
endmodule : imem
