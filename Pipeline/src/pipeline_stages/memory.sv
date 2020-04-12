`timescale 1ns / 1ps

module memory (
  input               clk_i,
  input               rst_i,
  input               reg_write_m_i,
  input               mem_to_reg_m_i,
  input        [31:0] alu_out_m_i,
  input        [4:0]  write_reg_m_i,
  input        [31:0] read_data_m_i,
  output logic        reg_write_w_o,
  output logic        mem_to_reg_w_o,
  output logic [31:0] alu_out_w_o,
  output logic [31:0] read_data_w_o,
  output logic [4:0]  write_reg_w_o
);

  logic [1:0] control_m, control_w;
  assign {reg_write_m_i, mem_to_reg_m_i} = control_m;

  // Writeback stage pipeline register logic
  writeback_reg u_writeback_reg (
    .clk_i,
    .rst_i,
    .control_m_i(control_m),
    .alu_out_m_i,
    .read_data_m_i,
    .write_reg_m_i,
    .control_w_o(control_w),
    .alu_out_w_o,
    .read_data_w_o,
    .write_reg_w_o
  );
  assign {reg_write_w_o, mem_to_reg_w_o} = control_w;

endmodule : memory
