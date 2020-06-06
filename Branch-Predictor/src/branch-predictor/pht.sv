`include "bpb.svh"

// Pattern History Table
module pht #(
  parameter INDEX_WIDTH = `BPB_T
) (
  input                          clk_i,
  input                          rst_i,
  input                          en_i,
  // Fetch stage
  input                          is_branch_i,
  input        [INDEX_WIDTH-1:0] index_i,
  // Decode stage
  input                          update_en_i,
  input                          last_taken_i,
  // Prediction & Fallback
  input                          fallback_i,
  output logic                   taken_o
);

  localparam SIZE = 2**INDEX_WIDTH;

  logic                   hit;
  logic [1:0]             entries[SIZE-1:0];
  logic [1:0]             entry;
  logic [SIZE-1:0]        valid;
  logic [INDEX_WIDTH-1:0] last_index;

  assign hit = valid[index_i];

  state_switch u_state_switch (
    .last_taken_i,
    .prev_state_i(entries[last_index]),
    .next_state_o(entry)
  );
  
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      entries <= '{default:'0};
      valid <= '0;
      last_index <= '0;
    end else if (en_i) begin
      if (is_branch_i & ~hit) begin
        entries[index_i] <= fallback_i;
        valid[index_i] <= 1'b1;
      end
      if (update_en_i) begin
        entries[last_index] <= entry;
      end
      last_index <= index_i;
    end
  end

  assign taken_o = hit ? entries[index_i][1] : fallback_i;

endmodule : pht
