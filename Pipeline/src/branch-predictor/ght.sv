`timescale 1ns / 1ps

// Global History Table
module ght (
  input              clk_i,
  input              rst_i,
  input              en_i,
  input              update_en_i,
  input              last_taken_i,
  output logic [1:0] state_o
);

  logic [1:0] next_state;

  state_switch u_state_switch (
    .last_taken_i,
    .prev_state_i(state_o),
    .next_state_o(next_state)
  );

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      state_o <= '0;
    end else if (en_i & update_en_i) begin
      state_o <= next_state;
    end
  end

endmodule : ght