`timescale 1ns / 1ps

// Global History Tracker
module ght (
  input              clk_i,
  input              rst_i,
  input              en_i,
  input              update_en_i,
  input              last_taken_i,
  output logic [1:0] state_o
);

  logic [1:0] last_state;

  state_switch u_state_switch (
    .last_taken_i,
    .prev_state_i(last_state),
    .next_state_o(state_o)
  );

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      last_state <= '0;
    end else if (en_i & update_en_i) begin
      last_state <= state_o;
    end
  end

endmodule : ght