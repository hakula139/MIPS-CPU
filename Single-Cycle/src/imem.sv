`timescale 1ns / 1ps

// 32-bit instruction memory
module imem (
  input        [5:0]  a,  // pc_addr
  output logic [31:0] rd  // instr_data
);
  logic [31:0] data[63:0];
  initial begin
    $readmemh("memfile.dat", data);
  end
  assign rd = data[a];
endmodule : imem
