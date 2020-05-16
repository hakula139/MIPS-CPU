`timescale 1ns / 1ps

// Fetch stage pipeline register
module fetch_reg (
  input               clk_i,
  input               rst_i,
  input               stall_f_i,
  input        [31:0] pc_next_f_i,
  output logic [31:0] pc_f_o
);

  flip_flop pc_reg (
    .clk_i,
    .rst_i,
    .en_ni(~stall_f_i),
    .clr_i('0),
    .d_i(pc_next_f_i),
    .q_o(pc_f_o)
  );

endmodule : fetch_reg
