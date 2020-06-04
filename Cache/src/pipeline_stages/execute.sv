`timescale 1ns / 1ps

module execute (
  input               clk_i,
  input               rst_i,
  input               reg_write_e_i,
  input               reg_dst_e_i,
  input        [1:0]  alu_src_e_i,
  input        [3:0]  alu_control_e_i,
  input        [2:0]  jump_e_i,
  input               mem_write_e_i,
  input               mem_to_reg_e_i,
  input        [31:0] pc_plus_4_e_i,
  input        [31:0] reg_data_1_e_i,
  input        [31:0] reg_data_2_e_i,
  input        [4:0]  rt_e_i,
  input        [4:0]  rd_e_i,
  input        [4:0]  shamt_e_i,
  input        [31:0] ext_imm_e_i,
  input        [31:0] result_w_i,
  input        [1:0]  forward_a_e_i,
  input        [1:0]  forward_b_e_i,
  output logic [4:0]  write_reg_e_o,
  output logic        reg_write_m_o,
  output logic        mem_write_m_o,
  output logic        mem_to_reg_m_o,
  output logic [31:0] alu_out_m_o,
  output logic [31:0] write_data_m_o,
  output logic [4:0]  write_reg_m_o
);

  logic [2:0]  control_e, control_m;
  logic [31:0] read_reg_data_e, write_reg_data_e, write_data_e, src_a_e, src_b_e, alu_out_e;

  assign control_e = {reg_write_e_i, mem_write_e_i, mem_to_reg_e_i};

  // ALU logic
  mux4       read_reg_data_mux4 (
    .data0_i(reg_data_1_e_i),
    .data1_i(result_w_i),
    .data2_i(alu_out_m_o),
    .data3_i(),  // not used
    .select_i(forward_a_e_i),
    .result_o(read_reg_data_e)
  );
  mux2       src_a_mux2 (
    .data0_i(read_reg_data_e),
    .data1_i({27'b0, shamt_e_i}),
    .select_i(alu_src_e_i[1]),
    .result_o(src_a_e)
  );
  mux4       write_data_mux4 (
    .data0_i(reg_data_2_e_i),
    .data1_i(result_w_i),
    .data2_i(alu_out_m_o),
    .data3_i(),  // not used
    .select_i(forward_b_e_i),
    .result_o(write_data_e)
  );
  mux2       src_b_mux2 (
    .data0_i(write_data_e),
    .data1_i(ext_imm_e_i),
    .select_i(alu_src_e_i[0]),
    .result_o(src_b_e)
  );
  alu        u_alu (
    .a_i(src_a_e),
    .b_i(src_b_e),
    .alu_control_i(alu_control_e_i),
    .result_o(alu_out_e),
    .zero_o()  // not used
  );

  // Write register logic
  mux2       write_reg_data_mux2 (
    .data0_i(alu_out_e),
    .data1_i(pc_plus_4_e_i),
    .select_i(jump_e_i[2]),
    .result_o(write_reg_data_e)
  );
  mux4 #(5)  write_reg_mux4 (
    .data0_i(rt_e_i),
    .data1_i(rd_e_i),
    .data2_i(5'b11111),  // register $ra
    .data3_i(),          // not used
    .select_i({jump_e_i[2], reg_dst_e_i}),
    .result_o(write_reg_e_o)
  );

  // Memory stage pipeline register logic
  memory_reg u_memory_reg (
    .clk_i,
    .rst_i,
    .control_e_i(control_e),
    .alu_out_e_i(write_reg_data_e),
    .write_data_e_i(write_data_e),
    .write_reg_e_i(write_reg_e_o),
    .control_m_o(control_m),
    .alu_out_m_o,
    .write_data_m_o,
    .write_reg_m_o
  );
  assign {reg_write_m_o, mem_write_m_o, mem_to_reg_m_o} = control_m;

endmodule : execute
