`include "bpb.svh"

/**
 * ENTRIES         : number of entries in the branch predictor buffer
 * INDEX_WIDTH     : index bits
 * instr_addr_i    : if this address has been recorded, then CPU can go as the BPB directs
 * is_branch_i     : in order to register the branch when first meeted
 * real_taken_i    : whether this branch should be taken according to the semantics of the instructions
 * real_addr_i     : where should this branch jumps to
 * predict_taken_o : whether this branch should be taken according to the prediction of our BPB
 * predict_addr_o  : where should this branch jumps to if it's taken
 */
module bpb #(
  parameter ENTRIES     = `BPB_E,
  parameter INDEX_WIDTH = `BPB_T
) (
  input               clk_i,
  input               rst_i,
  input               stall_i,
  input               flush_i,
  input        [31:0] instr_addr_i,
  input               is_branch_i,
  input               real_taken_i,
  input        [31:0] real_addr_i,
  output logic        predict_taken_o,
  output logic [31:0] predict_addr_o
);

endmodule : bpb
