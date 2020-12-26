`include "static_predictor.svh"

module static_predictor #(
  parameter FALLBACK_MODE = `FALLBACK_MODE
) (
  input        [31:0] pc_i,
  input        [31:0] pc_next_i,
  output logic        taken_o
);
  always_comb begin
    unique case (FALLBACK_MODE)
      `TAKEN:  taken_o = '1;
      `BTFNT:  taken_o = pc_next_i < pc_i;
      default: taken_o = '0;
    endcase
  end
endmodule : static_predictor
