`timescale 1ns / 1ps

// Global History Tracker (Global Predictor)
module ght (
  input              clk_i,
  input              rst_i,
  input              en_i,
  input              update_en_i,
  input              last_taken_i,
  output logic [1:0] taken_o
);

  logic [1:0] last_data;

  state_switch u_state_switch (
    .last_taken_i,
    .prev_data_i(last_data),
    .next_data_o(taken_o)
  );

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      taken_o <= '0;
      last_data <= '0;
    end else if (en_i & update_en_i) begin
      last_data <= taken_o;
    end
  end

endmodule : ght