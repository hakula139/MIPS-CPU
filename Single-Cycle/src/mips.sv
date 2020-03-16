`timescale 1ns / 1ps

// Since our TA has hard-coded variable names into the grader, we have
// to name the variables like this, regardless of the coding style.

// Single-cycle 32-bit MIPS processor
module mips (
  input               clk,
  input               reset,
  input        [31:0] instr,
  input        [31:0] readdata,
  output logic [31:0] pc,
  output logic        memwrite,
  output logic [31:0] aluout,
  output logic [31:0] writedata
);

  logic mem_to_reg, branch, pc_src, zero, alu_src, reg_dst, reg_write, jump;
  logic [3:0] alu_control;

  control_unit u_control_unit (
    .op_i(instr[31:26]),
    .funct_i(instr[5:0]),
    .zero_i(zero),
    .mem_to_reg_o(mem_to_reg),
    .mem_write_o(memwrite),
    .pc_src_o(pc_src),
    .jump_o(jump),
    .alu_control_o(alu_control),
    .alu_src_o(alu_src),
    .reg_dst_o(reg_dst),
    .reg_write_o(reg_write)
  );

  datapath     u_datapath (
    .clk_i(clk),
    .rst_i(reset),
    .instr_i(instr[25:0]),
    .mem_to_reg_i(mem_to_reg),
    .pc_src_i(pc_src),
    .jump_i(jump),
    .alu_control_i(alu_control),
    .alu_src_i(alu_src),
    .reg_dst_i(reg_dst),
    .reg_write_i(reg_write),
    .read_data_i(readdata),
    .pc_o(pc),
    .alu_result_o(aluout),
    .zero_o(zero),
    .write_data_o(writedata)
  );

endmodule : mips
