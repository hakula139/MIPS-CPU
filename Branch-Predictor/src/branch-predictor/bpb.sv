`include "bpb.svh"

/**
 * ENTRIES         : number of entries in the branch predictor buffer (BPB)
 * INDEX_WIDTH     : the width of index bits
 * MODE            : which predictor is selected for BPB
 * FALLBACK_MODE   : which predictor is selected as a fallback when BPB missed
 * pc_f_i          : address from Fetch stage; if this address has been cached, then CPU goes to where the BPB directs
 * instr_f_i       : instruction from Fetch stage
 * real_taken_i    : whether this branch should be taken according to the semantics of the instructions
 * pc_d_i          : address from Decode stage; check if the prediction was correct
 * instr_d_i       : instruction from Decode stage
 * predict_pc_o    : where should this branch jumps to if it's taken
 */
// Branch Prediction Buffer
module bpb #(
  parameter ENTRIES       = `BPB_E,
  parameter INDEX_WIDTH   = `BPB_T,
  parameter MODE          = `MODE,
  parameter FALLBACK_MODE = `PHT_FALLBACK_MODE
) (
  input               clk_i,
  input               rst_i,
  input               en_i,
  // Fetch stage
  input        [31:0] pc_f_i,
  input        [31:0] instr_f_i,
  // Decode stage
  input               real_taken_i,
  input        [31:0] pc_d_i,
  input        [31:0] instr_d_i,
  // Prediction
  output logic [31:0] predict_pc_o
);

  logic [31:0] pc_plus_4, pc_next;
  logic        is_branch_f, is_branch_d;

  // Parses the instruction
  parser           u_parser_f (
    .pc_i(pc_f_i),
    .instr_i(instr_f_i),
    .pc_plus_4_o(pc_plus_4),
    .pc_next_o(pc_next),
    .is_branch_o(is_branch_f)
  );
  parser           u_parser_d (
    .pc_i(),              // not used
    .instr_i(instr_d_i),
    .pc_plus_4_o(),       // not used
    .pc_next_o(),         // not used
    .is_branch_o(is_branch_d)
  );

  logic [INDEX_WIDTH-1:0] index;
  logic [1:0]             ght_state, bht_state;

  assign index = pc_f_i[INDEX_WIDTH+1:2];  // word aligned

  // Global History Tracker
  ght              u_ght (
    .clk_i,
    .rst_i,
    .en_i,
    .update_en_i(is_branch_d),
    .last_taken_i(real_taken_i),
    .state_o(ght_state)
  );
  // Branch History Tracker
  bht              u_bht (
    .clk_i,
    .rst_i,
    .en_i,
    .update_en_i(is_branch_d),
    .last_taken_i(real_taken_i),
    .index_i(index),
    .state_o(bht_state)
  );

  logic static_taken, global_taken, local_taken, fallback, mux;
  logic last_taken, last_mux, miss;
  logic last_conflict;

  assign miss = last_taken != real_taken_i;

  // Static Predictor as a fallback
  static_predictor u_static_predictor (
    .pc_i(pc_f_i),
    .pc_next_i(pc_next),
    .taken_o(static_taken)
  );
  // Pattern History Table (Global Predictor)
  pht              u_global_predictor (
    .clk_i,
    .rst_i,
    .en_i,
    .is_branch_i(is_branch_f),
    .index_i(index ^ ght_state),  // hashed index
    .update_en_i(is_branch_d),
    .last_taken_i(real_taken_i),
    .fallback_i(static_taken),
    .taken_o(global_taken)
  );
  // Pattern History Table (Local Predictor)
  pht              u_local_predictor (
    .clk_i,
    .rst_i,
    .en_i,
    .is_branch_i(is_branch_f),
    .index_i(index ^ bht_state),  // hashed index
    .update_en_i(is_branch_d),
    .last_taken_i(real_taken_i),
    .fallback_i(static_taken),
    .taken_o(local_taken)
  );
  // Pattern History Table (Selector)
  pht              u_selector (
    .clk_i,
    .rst_i,
    .en_i,
    .is_branch_i(is_branch_f),
    .index_i(index),
    .update_en_i(is_branch_d & last_conflict),
    .last_taken_i(last_mux ^ miss),
    .fallback_i(FALLBACK_MODE == `USE_GLOBAL),
    .taken_o(mux)
  );

  logic predict_taken;

  // Prediction logic
  always_comb begin
    unique case (MODE)
      `USE_STATIC: {predict_taken, mux} = {static_taken, 1'b0};
      `USE_GLOBAL: {predict_taken, mux} = {global_taken, 1'b1};
      `USE_LOCAL:  {predict_taken, mux} = {local_taken, 1'b0};
      default:     predict_taken = mux ? global_taken : local_taken;
    endcase
    predict_pc_o = predict_taken ? pc_next : pc_plus_4;
  end

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      {last_taken, last_mux, last_conflict} <= '0;
    end else if (en_i) begin
      last_taken <= predict_taken;
      last_mux <= mux;
      last_conflict <= global_taken != local_taken;
    end
  end

endmodule : bpb
