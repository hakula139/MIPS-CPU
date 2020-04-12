`timescale 1ns / 1ps

module datapath (
  input               clk_i,
  input               rst_i,
  input        [25:0] instr_i,
  input               mem_to_reg_i,
  input               pc_src_i,
  input        [2:0]  jump_i,
  input        [3:0]  alu_control_i,
  input        [1:0]  alu_src_i,
  input               reg_dst_i,
  input               reg_write_i,
  input        [31:0] read_data_i,
  output logic [31:0] pc_o,
  output logic [31:0] alu_result_o,
  output logic        zero_o,
  output logic [31:0] write_data_o
);

  logic [31:0] pc_next, pc_branch_next, pc_plus_4, pc_branch;
  logic [4:0]  write_reg;
  logic [31:0] write_reg_data, read_reg_data;
  logic [31:0] sign_imm;
  logic [31:0] src_a, src_b;
  logic [31:0] result;

  // Next PC logic
  flip_flop pc_reg (
    .clk_i,
    .rst_i,
    .d_i(pc_next),
    .q_o(pc_o)
  );
  adder     u1_adder (
    .a_i(pc_o),
    .b_i(32'd4),
    .result_o(pc_plus_4)
  );
  adder     u2_adder (
    .a_i(pc_plus_4),
    .b_i({sign_imm[29:0], 2'b00}),  // sign_imm * 4
    .result_o(pc_branch)
  );
  mux2      pc_branch_next_mux2 (
    .data0_i(pc_plus_4),
    .data1_i(pc_branch),
    .select_i(pc_src_i),
    .result_o(pc_branch_next)
  );
  mux4      pc_next_mux4 (
    .data0_i(pc_branch_next),
    .data1_i({pc_plus_4[31:28], instr_i[25:0], 2'b00}),  // word aligned
    .data2_i(read_reg_data),  // the value in register $ra
    .data3_i(),               // not used
    .select_i(jump_i[1:0]),
    .result_o(pc_next)
  );

  // Register file logic
  reg_file  u_reg_file (
    .clk_i,
    .rst_i,
    .we3_i(reg_write_i),
    .wa3_i(write_reg),
    .wd3_i(write_reg_data),
    .ra1_i(instr_i[25:21]),
    .ra2_i(instr_i[20:16]),
    .rd1_o(read_reg_data),
    .rd2_o(write_data_o)
  );
  mux4 #(5) write_reg_mux4 (
    .data0_i(instr_i[20:16]),
    .data1_i(instr_i[15:11]),
    .data2_i(5'b11111),  // register $ra
    .data3_i(),          // not used
    .select_i({jump_i[2], reg_dst_i}),
    .result_o(write_reg)
  );
  mux2      result_mux2 (
    .data0_i(alu_result_o),
    .data1_i(read_data_i),
    .select_i(mem_to_reg_i),
    .result_o(result)
  );
  mux2      write_reg_data_mux2 (
    .data0_i(result),
    .data1_i(pc_plus_4),
    .select_i(jump_i[2]),
    .result_o(write_reg_data)
  );
  sign_ext  u1_sign_ext (
    .a_i(instr_i[15:0]),
    .result_o(sign_imm)
  );

  // ALU logic
  mux2      src_a_mux2 (
    .data0_i(read_reg_data),
    .data1_i({27'b0, instr_i[10:6]}),
    .select_i(alu_src_i[1]),
    .result_o(src_a)
  );
  mux2      src_b_mux2 (
    .data0_i(write_data_o),
    .data1_i(sign_imm),
    .select_i(alu_src_i[0]),
    .result_o(src_b)
  );
  alu       u_alu (
    .a_i(src_a),
    .b_i(src_b),
    .alu_control_i,
    .result_o(alu_result_o),
    .zero_o
  );

endmodule : datapath
