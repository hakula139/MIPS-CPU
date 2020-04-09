`timescale 1ns / 1ps

// Since our TA has hard-coded variable names into the grader, we have
// to name the variables like this, regardless of the coding style.

// Top module
module cpu (
  input clk,
  input reset
);

  logic        mem_write;
  logic [31:0] pc, instr, read_data, write_data, data_addr;
  
  mips mips (
    .clk,
    .reset,
    .instr,
    .readdata(read_data),
    .pc,
    .memwrite(mem_write),
    .aluout(data_addr),
    .writedata(write_data)
  );

  imem imem (
    .a(pc[7:2]),
    .rd(instr)
  );

  dmem dmem (
    .clk,
    .we(mem_write),
    .a(data_addr),
    .wd(write_data),
    .rd(read_data)
  );

endmodule : cpu
