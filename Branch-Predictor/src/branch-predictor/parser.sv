`timescale 1ns / 1ps

module parser (
  input        [31:0] pc_i,
  input        [31:0] instr_i,
  output logic [31:0] pc_plus_4_o,
  output logic [31:0] pc_next_o,
  output logic        is_branch_o,
  output logic        is_jump_o
);

  logic [5:0]  op, funct;
  logic [31:0] pc_jump, pc_branch;
  logic [31:0] ext_imm;

  assign op = instr_i[31:26];
  assign funct = instr_i[5:0];

  extend u_extend (
    .sign_i('1),
    .a_i(instr_i[15:0]),
    .result_o(ext_imm)
  );

  assign pc_plus_4_o = pc_i + 32'd4;
  assign pc_jump = {pc_plus_4_o[31:28], instr_i[25:0], 2'b00};
  assign pc_branch = pc_plus_4_o + (ext_imm << 2);

  always_comb begin
    case (op)
      6'b000010, 6'b000011: begin
        {pc_next_o, is_branch_o, is_jump_o} = {pc_jump, 2'b01};      // J, JAL
      end
      6'b000100, 6'b000101: begin
        {pc_next_o, is_branch_o, is_jump_o} = {pc_branch, 2'b10};    // BEQ, BNE
      end
      default: begin
        {pc_next_o, is_branch_o, is_jump_o} = {pc_plus_4_o, 2'b00};  // JR and others
      end
    endcase
  end

endmodule
