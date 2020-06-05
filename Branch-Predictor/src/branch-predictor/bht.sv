`include "bpb.svh"

// Branch History Tracker (Local Predictor)
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
  output logic [1:0]             taken_o
);

  localparam SIZE = 2**SIZE_WIDTH;

  logic [1:0]             entry[SIZE-1:0];
  logic [1:0]             data;
  logic [INDEX_WIDTH-1:0] last_index;

  state_switch u_state_switch (
    .last_taken_i,
    .prev_data_i(entry[last_index]),
    .next_data_o(data)
  );

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      entry <= '{default:'0};
      last_index <= '0;
    end else if (en_i) begin
      if (update_en_i) entry[last_index] <= data;
      last_index <= index_i;
    end
  end

  assign taken_o = entry[index_i];

endmodule : bht
