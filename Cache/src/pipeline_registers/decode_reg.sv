`timescale 1ns / 1ps

// Decode stage pipeline register
module decode_reg (
  input               clk_i,
  input               rst_i,
  input               stall_d_i,
  input               flush_d_i,
  input        [31:0] pc_plus_4_f_i,
  input        [31:0] instr_f_i,
  output logic [31:0] pc_plus_4_d_o,
  output logic [31:0] instr_d_o
);

  flip_flop pc_plus_4_reg (
    .clk_i,
    .rst_i,
    .en_ni(~stall_d_i),
    .clr_i('0),
    .d_i(pc_plus_4_f_i),
    .q_o(pc_plus_4_d_o)
  );
  flip_flop instr_reg (
    .clk_i,
    .rst_i,
    .en_ni(~stall_d_i),
    .clr_i(~stall_d_i & flush_d_i),
    .d_i(instr_f_i),
    .q_o(instr_d_o)
  );

endmodule : decode_reg
