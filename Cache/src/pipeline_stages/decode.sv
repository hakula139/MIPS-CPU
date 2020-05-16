`timescale 1ns / 1ps

module decode (
  input               clk_i,
  input               rst_i,
  input        [31:0] pc_plus_4_d_i,
  input        [31:0] instr_d_i,
  input        [31:0] alu_out_m_i,
  input               reg_write_w_i,
  input        [4:0]  write_reg_w_i,
  input        [31:0] result_w_i,
  input               forward_a_d_i,
  input               forward_b_d_i,
  input               stall_e_i,
  input               flush_e_i,
  output logic [1:0]  branch_d_o,
  output logic        pc_src_d_o,
  output logic [2:0]  jump_d_o,
  output logic [31:0] pc_branch_d_o,
  output logic [31:0] src_a_d_o,
  output logic [4:0]  rs_d_o,
  output logic [4:0]  rt_d_o,
  output logic        reg_write_e_o,
  output logic        reg_dst_e_o,
  output logic [1:0]  alu_src_e_o,
  output logic [3:0]  alu_control_e_o,
  output logic [2:0]  jump_e_o,
  output logic        mem_write_e_o,
  output logic        mem_to_reg_e_o,
  output logic [31:0] pc_plus_4_e_o,
  output logic [31:0] reg_data_1_e_o,
  output logic [31:0] reg_data_2_e_o,
  output logic [4:0]  rs_e_o,
  output logic [4:0]  rt_e_o,
  output logic [4:0]  rd_e_o,
  output logic [4:0]  shamt_e_o,
  output logic [31:0] ext_imm_e_o
);

  logic        equal_d, mem_to_reg_d, mem_write_d, reg_dst_d, reg_write_d, sign_d;
  logic [3:0]  alu_control_d;
  logic [1:0]  alu_src_d;
  logic [12:0] control_d, control_e;

  logic [31:0] reg_data_1_d, reg_data_2_d, src_b_d;

  logic [4:0]  rd_d, shamt_d;
  logic [31:0] ext_imm_d;

  // Control unit logic
  control_unit u_control_unit (
    .op_i(instr_d_i[31:26]),
    .funct_i(instr_d_i[5:0]),
    .equal_i(equal_d),
    .mem_to_reg_o(mem_to_reg_d),
    .mem_write_o(mem_write_d),
    .branch_o(branch_d_o),
    .jump_o(jump_d_o),
    .alu_control_o(alu_control_d),
    .alu_src_o(alu_src_d),
    .reg_dst_o(reg_dst_d),
    .reg_write_o(reg_write_d),
    .sign_o(sign_d)
  );
  assign pc_src_d_o = (branch_d_o[0] & equal_d) | (branch_d_o[1] & ~equal_d);
  assign control_d  = {reg_write_d, reg_dst_d, alu_src_d, alu_control_d,
                       jump_d_o, mem_write_d, mem_to_reg_d};

  // Register file logic
  reg_file     u_reg_file (
    .clk_i,
    .rst_i,
    .we3_i(reg_write_w_i),
    .wa3_i(write_reg_w_i),
    .wd3_i(result_w_i),
    .ra1_i(instr_d_i[25:21]),
    .ra2_i(instr_d_i[20:16]),
    .rd1_o(reg_data_1_d),
    .rd2_o(reg_data_2_d)
  );
  mux2         src_a_mux2 (
    .data0_i(reg_data_1_d),
    .data1_i(alu_out_m_i),
    .select_i(forward_a_d_i),
    .result_o(src_a_d_o)
  );
  mux2         src_b_mux2 (
    .data0_i(reg_data_2_d),
    .data1_i(alu_out_m_i),
    .select_i(forward_b_d_i),
    .result_o(src_b_d)
  );
  equal_cmp    u_equal_cmp (
    .a_i(src_a_d_o),
    .b_i(src_b_d),
    .equal_o(equal_d)
  );

  assign rs_d_o  = instr_d_i[25:21];
  assign rt_d_o  = instr_d_i[20:16];
  assign rd_d    = instr_d_i[15:11];
  assign shamt_d = instr_d_i[10:6];

  // PC branch logic
  extend       u_extend (
    .sign_i(sign_d),
    .a_i(instr_d_i[15:0]),
    .result_o(ext_imm_d)
  );
  adder        u_adder (
    .a_i(pc_plus_4_d_i),
    .b_i({ext_imm_d[29:0], 2'b00}),  // ext_imm_d * 4
    .result_o(pc_branch_d_o)
  );

  // Execute stage pipeline register logic
  execute_reg  u_execute_reg (
    .clk_i,
    .rst_i,
    .stall_e_i,
    .flush_e_i,
    .control_d_i(control_d),
    .pc_plus_4_d_i,
    .reg_data_1_d_i(reg_data_1_d),
    .reg_data_2_d_i(reg_data_2_d),
    .rs_d_i(rs_d_o),
    .rt_d_i(rt_d_o),
    .rd_d_i(rd_d),
    .shamt_d_i(shamt_d),
    .ext_imm_d_i(ext_imm_d),
    .control_e_o(control_e),
    .pc_plus_4_e_o,
    .reg_data_1_e_o,
    .reg_data_2_e_o,
    .rs_e_o,
    .rt_e_o,
    .rd_e_o,
    .shamt_e_o,
    .ext_imm_e_o
  );
  assign {reg_write_e_o, reg_dst_e_o, alu_src_e_o, alu_control_e_o,
          jump_e_o, mem_write_e_o, mem_to_reg_e_o} = control_e;

endmodule : decode
