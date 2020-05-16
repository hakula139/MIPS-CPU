`timescale 1ns / 1ps

module fetch (
  input               clk_i,
  input               rst_i,
  input        [31:0] instr_f_i,
  input        [31:0] pc_branch_d_i,
  input               pc_src_d_i,
  input        [31:0] src_a_d_i,
  input        [2:0]  jump_d_i,
  input               stall_f_i,
  input               stall_d_i,
  input               flush_d_i,
  output logic [31:0] pc_f_o,
  output logic [31:0] pc_plus_4_d_o,
  output logic [31:0] instr_d_o
);

  logic [31:0] pc_next_f, pc_branch_next_f, pc_plus_4_f;

  // PC logic
  fetch_reg  u_fetch_reg (
    .clk_i,
    .rst_i,
    .stall_f_i,
    .pc_next_f_i(pc_next_f),
    .pc_f_o
  );
  adder      u_adder (
    .a_i(pc_f_o),
    .b_i(32'd4),
    .result_o(pc_plus_4_f)
  );
  mux2       pc_branch_next_mux2 (
    .data0_i(pc_plus_4_f),
    .data1_i(pc_branch_d_i),
    .select_i(pc_src_d_i),
    .result_o(pc_branch_next_f)
  );
  mux4       pc_next_mux4 (
    .data0_i(pc_branch_next_f),
    .data1_i({pc_plus_4_f[31:28], instr_d_o[25:0], 2'b00}),  // word aligned
    .data2_i(src_a_d_i),       // the value in register $ra
    .data3_i(),                // not used
    .select_i(jump_d_i[1:0]),
    .result_o(pc_next_f)
  );

  // Decode stage pipeline register logic
  decode_reg u_decode_reg (
    .clk_i,
    .rst_i,
    .stall_d_i,
    .flush_d_i,
    .pc_plus_4_f_i(pc_plus_4_f),
    .instr_f_i,
    .pc_plus_4_d_o,
    .instr_d_o
  );

endmodule : fetch
