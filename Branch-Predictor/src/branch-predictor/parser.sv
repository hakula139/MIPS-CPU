`timescale 1ns / 1ps

module parser (
  input        [31:0] pc_i,
  input        [31:0] instr_i,
  output logic [31:0] pc_next_o,
  output logic        is_branch_o
);

  logic [5:0]  op, funct;
  logic [31:0] pc_plus_4, pc_jump, pc_branch;
  logic [31:0] ext_imm;

  assign op = instr_i[31:26];
  assign funct = instr_i[5:0];

  extend u_extend (
    .sign_i('1),
    .a_i(instr_i[15:0]),
    .result_o(ext_imm)
  );

  assign pc_plus_4 = pc_i + 32'd4;
  assign pc_jump = {pc_plus_4[31:28], instr_i[25:0], 2'b00};
  assign pc_branch = pc_plus_4 + {ext_imm[29:0], 2'b00};

  always_comb begin
    case (op)
      6'b000010, 6'b000011: {pc_next_o, is_branch_o} = {pc_jump, 1'b0};    // J, JAL
      6'b000100, 6'b000101: {pc_next_o, is_branch_o} = {pc_branch, 1'b1};  // BEQ, BNE
      default:              {pc_next_o, is_branch_o} = {pc_plus_4, 1'b0};  // JR and others
    endcase
  end

endmodule
