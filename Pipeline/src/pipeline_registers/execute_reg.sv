`timescale 1ns / 1ps

// Execute stage pipeline register
module execute_reg (
  input               clk_i,
  input               rst_i,
  input               flush_e_i,
  input        [8:0]  control_d_i,
  input        [31:0] src_a_d_i,
  input        [31:0] src_b_d_i,
  input        [4:0]  rs_d_i,
  input        [4:0]  rt_d_i,
  input        [4:0]  rd_d_i,
  input        [31:0] sign_imm_d_i,
  output logic [8:0]  control_e_o,
  output logic [31:0] src_a_e_o,
  output logic [31:0] src_b_e_o,
  output logic [4:0]  rs_e_o,
  output logic [4:0]  rt_e_o,
  output logic [4:0]  rd_e_o,
  output logic [31:0] sign_imm_e_o
);

  flip_flop #(9) control_reg (
    .clk_i,
    .rst_i,
    .en_ni('1),
    .clr_i(flush_e_i),
    .d_i(control_d_i),
    .q_o(control_e_o)
  );
  flip_flop      src_a_reg (
    .clk_i,
    .rst_i,
    .en_ni('1),
    .clr_i(flush_e_i),
    .d_i(src_a_d_i),
    .q_o(src_a_e_o)
  );
  flip_flop      src_b_reg (
    .clk_i,
    .rst_i,
    .en_ni('1),
    .clr_i(flush_e_i),
    .d_i(src_b_d_i),
    .q_o(src_b_e_o)
  );
  flip_flop #(5) rs_reg (
    .clk_i,
    .rst_i,
    .en_ni('1),
    .clr_i(flush_e_i),
    .d_i(rs_d_i),
    .q_o(rs_e_o)
  );
  flip_flop #(5) rt_reg (
    .clk_i,
    .rst_i,
    .en_ni('1),
    .clr_i(flush_e_i),
    .d_i(rt_d_i),
    .q_o(rt_e_o)
  );
  flip_flop #(5) rd_reg (
    .clk_i,
    .rst_i,
    .en_ni('1),
    .clr_i(flush_e_i),
    .d_i(rd_d_i),
    .q_o(rd_e_o)
  );
  flip_flop      sign_imm_reg (
    .clk_i,
    .rst_i,
    .en_ni('1),
    .clr_i(flush_e_i),
    .d_i(sign_imm_d_i),
    .q_o(sign_imm_e_o)
  );

endmodule : execute_reg
