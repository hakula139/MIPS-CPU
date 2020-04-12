`timescale 1ns / 1ps

// Since our TA has hard-coded variable names into the grader, we have
// to name the variables like this, regardless of the coding style.

// Pipeline 32-bit MIPS processor
module mips (
  input               clk,
  input               reset,
  input        [31:0] instr,
  input        [31:0] readdata,
  output logic [31:0] pc,
  output logic        memwrite,
  output logic [31:0] aluout,
  output logic [31:0] writedata
);

  logic [1:0]  branch_d;
  logic        pc_src_d;
  logic [31:0] pc_branch_d, pc_plus_4_d;
  logic [31:0] reg_data_1_d;
  logic [2:0]  jump_d;
  logic [31:0] instr_d;
  logic [4:0]  rs_d, rt_d;

  logic        reg_write_e, reg_dst_e;
  logic [1:0]  alu_src_e;
  logic [3:0]  alu_control_e;
  logic [2:0]  jump_e;
  logic        mem_write_e, mem_to_reg_e;
  logic [31:0] reg_data_1_e, reg_data_2_e;
  logic [4:0]  rs_e, rt_e, rd_e, shamt_e;
  logic [4:0]  write_reg_e;
  logic [31:0] sign_imm_e;

  logic        reg_write_m;
  logic        mem_to_reg_m;
  logic [4:0]  write_reg_m;

  logic        reg_write_w;
  logic [4:0]  write_reg_w;
  logic [31:0] result_w;

  logic        stall_f, stall_d, flush_d, flush_e;
  logic        forward_a_d, forward_b_d, forward_a_e, forward_b_e;

  assign       flush_d = pc_src_d | jump_d;

  fetch        u_fetch (
    .clk_i(clk),
    .rst_i(reset),
    .instr_f_i(instr),
    .pc_branch_d_i(pc_branch_d),
    .pc_src_d_i(pc_src_d),
    .reg_data_1_d_i(reg_data_1_d),
    .jump_d_i(jump_d),
    .stall_f_i(stall_f),
    .stall_d_i(stall_d),
    .flush_d_i(flush_d),
    .pc_f_o(pc),
    .pc_plus_4_d_o(pc_plus_4_d),
    .instr_d_o(instr_d)
  );

  decode       u_decode (
    .clk_i(clk),
    .rst_i(reset),
    .pc_plus_4_d_i(pc_plus_4_d),
    .instr_d_i(instr_d),
    .alu_out_m_i(aluout),
    .reg_write_w_i(reg_write_w),
    .write_reg_w_i(write_reg_w),
    .result_w_i(result_w),
    .forward_a_d_i(forward_a_d),
    .forward_b_d_i(forward_b_d),
    .flush_e_i(flush_e),
    .branch_d_o(branch_d),
    .pc_src_d_o(pc_src_d),
    .pc_branch_d_o(pc_branch_d),
    .rs_d_o(rs_d),
    .rt_d_o(rt_d),
    .reg_write_e_o(reg_write_e),
    .reg_dst_e_o(reg_dst_e),
    .alu_src_e_o(alu_src_e),
    .alu_control_e_o(alu_control_e),
    .jump_e_o(jump_e),
    .mem_write_e_o(mem_write_e),
    .mem_to_reg_e_o(mem_to_reg_e),
    .reg_data_1_e_o(reg_data_1_e),
    .reg_data_2_e_o(reg_data_2_e),
    .rs_e_o(rs_e),
    .rt_e_o(rt_e),
    .rd_e_o(rd_e),
    .shamt_e_o(shamt_e),
    .sign_imm_e_o(sign_imm_e)
  );

  execute      u_execute (
    .clk_i(clk),
    .rst_i(reset),
    .reg_write_e_i(reg_write_e),
    .reg_dst_e_i(reg_dst_e),
    .alu_src_e_i(alu_src_e),
    .alu_control_e_i(alu_control_e),
    .jump_e_i(jump_e),
    .mem_write_e_i(mem_write_e),
    .mem_to_reg_e_i(mem_to_reg_e),
    .reg_data_1_e_i(reg_data_1_e),
    .reg_data_2_e_i(reg_data_2_e),
    .rt_e_i(rt_e),
    .rd_e_i(rd_e),
    .shamt_e_i(shamt_e),
    .sign_imm_e_i(sign_imm_e),
    .result_w_i(result_w),
    .forward_a_e_i(forward_a_e),
    .forward_b_e_i(forward_b_e),
    .write_reg_e_o(write_reg_e),
    .reg_write_m_o(reg_write_m),
    .mem_write_m_o(memwrite),
    .mem_to_reg_m_o(mem_to_reg_m),
    .alu_out_m_o(aluout),
    .write_data_m_o(writedata),
    .write_reg_m_o(write_reg_m)
  );

  hazard_unit  u_hazard_unit (
    .rs_d_i(rs_d),
    .rt_d_i(rt_d),
    .branch_d_i(branch_d),
    .rs_e_i(rs_e),
    .rt_e_i(rt_e),
    .write_reg_e_i(write_reg_e),
    .mem_to_reg_e_i(mem_to_reg_e),
    .reg_write_e_i(reg_write_e),
    .write_reg_m_i(write_reg_m),
    .mem_to_reg_m_i(mem_to_reg_m),
    .reg_write_m_i(reg_write_m),
    .write_reg_w_i(write_reg_w),
    .reg_write_w_i(reg_write_w),
    .stall_f_o(stall_f),
    .stall_d_o(stall_d),
    .forward_a_d_o(forward_a_d),
    .forward_b_d_o(forward_b_d),
    .flush_e_o(flush_e),
    .forward_a_e_o(forward_a_e),
    .forward_b_e_o(forward_b_e)
  );

endmodule : mips
