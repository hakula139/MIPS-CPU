`timescale 1ns / 1ps

// Writeback stage pipeline register
module writeback_reg (
  input               clk_i,
  input               rst_i,
  input        [1:0]  control_m_i,
  input        [31:0] alu_out_m_i,
  input        [31:0] read_data_m_i,
  input        [4:0]  write_reg_m_i,
  output logic [1:0]  control_w_o,
  output logic [31:0] alu_out_w_o,
  output logic [31:0] read_data_w_o,
  output logic [4:0]  write_reg_w_o
);

  flip_flop #(2) control_reg (
    .clk_i,
    .rst_i,
    .en_ni('1),
    .clr_i('0),
    .d_i(control_m_i),
    .q_o(control_w_o)
  );
  flip_flop      alu_out_reg (
    .clk_i,
    .rst_i,
    .en_ni('1),
    .clr_i('0),
    .d_i(alu_out_m_i),
    .q_o(alu_out_w_o)
  );
  flip_flop      read_data_reg (
    .clk_i,
    .rst_i,
    .en_ni('1),
    .clr_i('0),
    .d_i(read_data_m_i),
    .q_o(read_data_w_o)
  );
  flip_flop #(5) write_reg_reg (
    .clk_i,
    .rst_i,
    .en_ni('1),
    .clr_i('0),
    .d_i(write_reg_m_i),
    .q_o(write_reg_w_o)
  );

endmodule : writeback_reg
