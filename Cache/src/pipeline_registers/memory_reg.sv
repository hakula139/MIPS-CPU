`timescale 1ns / 1ps

// Memory stage pipeline register
module memory_reg (
  input               clk_i,
  input               rst_i,
  input        [2:0]  control_e_i,
  input        [31:0] alu_out_e_i,
  input        [31:0] write_data_e_i,
  input        [4:0]  write_reg_e_i,
  output logic [2:0]  control_m_o,
  output logic [31:0] alu_out_m_o,
  output logic [31:0] write_data_m_o,
  output logic [4:0]  write_reg_m_o
);

  flip_flop #(3) control_reg (
    .clk_i,
    .rst_i,
    .en_ni('1),
    .clr_i('0),
    .d_i(control_e_i),
    .q_o(control_m_o)
  );
  flip_flop      alu_out_reg (
    .clk_i,
    .rst_i,
    .en_ni('1),
    .clr_i('0),
    .d_i(alu_out_e_i),
    .q_o(alu_out_m_o)
  );
  flip_flop      write_data_reg (
    .clk_i,
    .rst_i,
    .en_ni('1),
    .clr_i('0),
    .d_i(write_data_e_i),
    .q_o(write_data_m_o)
  );
  flip_flop #(5) write_reg_reg (
    .clk_i,
    .rst_i,
    .en_ni('1),
    .clr_i('0),
    .d_i(write_reg_e_i),
    .q_o(write_reg_m_o)
  );

endmodule : memory_reg
