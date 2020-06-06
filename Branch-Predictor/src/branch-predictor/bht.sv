`include "bpb.svh"

// Branch History Tracker
module bht #(
  parameter SIZE_WIDTH  = `BPB_E,
  parameter INDEX_WIDTH = `BPB_T
) (
  input                          clk_i,
  input                          rst_i,
  input                          en_i,
  input                          update_en_i,
  input                          last_taken_i,
  input        [INDEX_WIDTH-1:0] index_i,
  output logic [1:0]             state_o
);

  localparam SIZE = 2**SIZE_WIDTH;

  logic [1:0]             entries[SIZE-1:0];
  logic [1:0]             entry;
  logic [INDEX_WIDTH-1:0] last_index;

  state_switch u_state_switch (
    .last_taken_i,
    .prev_state_i(entries[last_index]),
    .next_state_o(entry)
  );

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      entries <= '{default:'0};
      last_index <= '0;
    end else if (en_i) begin
      if (update_en_i) entries[last_index] <= entry;
      last_index <= index_i;
    end
  end

  assign state_o = entries[index_i];

endmodule : bht
