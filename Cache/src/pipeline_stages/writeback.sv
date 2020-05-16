`timescale 1ns / 1ps

module writeback (
  input               clk_i,
  input               rst_i,
  input               mem_to_reg_w_i,
  input        [31:0] alu_out_w_i,
  input        [31:0] read_data_w_i,
  output logic [31:0] result_w_o
);

  mux2 result_mux2 (
    .data0_i(alu_out_w_i),
    .data1_i(read_data_w_i),
    .select_i(mem_to_reg_w_i),
    .result_o(result_w_o)
  );

endmodule : writeback
