`timescale 1ns / 1ps

// Output current taken state as follows:
// Strongly taken     = 11
// Weakly taken       = 10
// Weakly not taken   = 01
// Strongly not taken = 00
module state_switch (
  input              last_taken_i,
  input        [1:0] prev_data_i,
  output logic [1:0] next_data_o
);
  assign next_data_o = {prev_data_i[0], last_taken_i};
endmodule : state_switch
