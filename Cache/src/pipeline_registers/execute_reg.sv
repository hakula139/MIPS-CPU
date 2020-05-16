`timescale 1ns / 1ps

// Execute stage pipeline register
module execute_reg (
  input               clk_i,
  input               rst_i,
  input               stall_e_i,
  input               flush_e_i,
  input        [12:0] control_d_i,
  input        [31:0] pc_plus_4_d_i,
  input        [31:0] reg_data_1_d_i,
  input        [31:0] reg_data_2_d_i,
  input        [4:0]  rs_d_i,
  input        [4:0]  rt_d_i,
  input        [4:0]  rd_d_i,
  input        [4:0]  shamt_d_i,
  input        [31:0] ext_imm_d_i,
  output logic [12:0] control_e_o,
  output logic [31:0] pc_plus_4_e_o,
  output logic [31:0] reg_data_1_e_o,
  output logic [31:0] reg_data_2_e_o,
  output logic [4:0]  rs_e_o,
  output logic [4:0]  rt_e_o,
  output logic [4:0]  rd_e_o,
  output logic [4:0]  shamt_e_o,
  output logic [31:0] ext_imm_e_o
);

  flip_flop #(13) control_reg (
    .clk_i,
    .rst_i,
    .en_ni(~stall_e_i),
    .clr_i(~stall_e_i & flush_e_i),
    .d_i(control_d_i),
    .q_o(control_e_o)
  );
  flip_flop       pc_plus_4_reg (
    .clk_i,
    .rst_i,
    .en_ni(~stall_e_i),
    .clr_i(~stall_e_i & flush_e_i),
    .d_i(pc_plus_4_d_i),
    .q_o(pc_plus_4_e_o)
  );
  flip_flop       reg_data_1_reg (
    .clk_i,
    .rst_i,
    .en_ni(~stall_e_i),
    .clr_i(~stall_e_i & flush_e_i),
    .d_i(reg_data_1_d_i),
    .q_o(reg_data_1_e_o)
  );
  flip_flop       reg_data_2_reg (
    .clk_i,
    .rst_i,
    .en_ni(~stall_e_i),
    .clr_i(~stall_e_i & flush_e_i),
    .d_i(reg_data_2_d_i),
    .q_o(reg_data_2_e_o)
  );
  flip_flop #(5)  rs_reg (
    .clk_i,
    .rst_i,
    .en_ni(~stall_e_i),
    .clr_i(~stall_e_i & flush_e_i),
    .d_i(rs_d_i),
    .q_o(rs_e_o)
  );
  flip_flop #(5)  rt_reg (
    .clk_i,
    .rst_i,
    .en_ni(~stall_e_i),
    .clr_i(~stall_e_i & flush_e_i),
    .d_i(rt_d_i),
    .q_o(rt_e_o)
  );
  flip_flop #(5)  rd_reg (
    .clk_i,
    .rst_i,
    .en_ni(~stall_e_i),
    .clr_i(~stall_e_i & flush_e_i),
    .d_i(rd_d_i),
    .q_o(rd_e_o)
  );
  flip_flop #(5)  shamt_reg (
    .clk_i,
    .rst_i,
    .en_ni(~stall_e_i),
    .clr_i(~stall_e_i & flush_e_i),
    .d_i(shamt_d_i),
    .q_o(shamt_e_o)
  );
  flip_flop       ext_imm_reg (
    .clk_i,
    .rst_i,
    .en_ni(~stall_e_i),
    .clr_i(~stall_e_i & flush_e_i),
    .d_i(ext_imm_d_i),
    .q_o(ext_imm_e_o)
  );

endmodule : execute_reg
