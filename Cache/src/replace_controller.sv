`include "cache.svh"

module replace_controller #(
  parameter SET_SIZE = `CACHE_E
) (
  input                       clk_i,
  input                       rst_i,
  input                       en_i,
  input        [SET_SIZE-1:0] hit_line_i,
  output logic [SET_SIZE-1:0] out_line_o
);

  int recent_access[SET_SIZE-1:0];

  // Encoded line number
  int line_write, line_replace;

  always_comb begin
    if (en_i) begin
      int max_index = 0;
      foreach (recent_access[i]) begin
        if (recent_access[i] > recent_access[max_index]) begin
          max_index = i;
        end
      end
      line_replace = max_index;
    end
  end
  
  always_comb begin
    line_write = '0;
    for (int i = 0; i < SET_SIZE; ++i) begin
      if (hit_line_i[i]) line_write = i;
    end
  end

  assign out_line_o = 1 << line_replace;

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      recent_access <= '{default:'0};
    end else if (en_i) begin
      foreach (recent_access[i]) begin
        recent_access[i] <= (i == line_replace) ? 0 : recent_access[i] + 1;
      end
    end
  end

endmodule : replace_controller
