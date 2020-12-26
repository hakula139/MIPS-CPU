`timescale 1ns / 1ps

// Output current taken state as follows:
// Strongly taken     = 11
// Weakly taken       = 10
// Weakly not taken   = 01
// Strongly not taken = 00
module state_switch (
  input              last_taken_i,
  input        [1:0] prev_state_i,
  output logic [1:0] next_state_o
);
  always_comb begin
    unique case (prev_state_i)
      2'b00:   next_state_o = last_taken_i ? 2'b01 : 2'b00;
      2'b11:   next_state_o = last_taken_i ? 2'b11 : 2'b10;
      default: next_state_o = last_taken_i ? prev_state_i + 1 : prev_state_i - 1;
    endcase
  end
endmodule : state_switch
