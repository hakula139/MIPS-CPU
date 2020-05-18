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
    line_write = '0;
    for (int i = 0; i < SET_SIZE; ++i) begin
      if (hit_line_i[i]) line_write = i;
      out_line_o[i] = line_replace == i;
    end
  end

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      recent_access = '{default:'0};
    end else if (en_i) begin
      int max_access[$], max_index[$];
      max_access = recent_access.max();
      max_index = max_access.find_first_index with (item == max_access.pop_front());
      line_replace = max_index.pop_front();
      foreach (recent_access[i]) begin
        recent_access[i] = (i == line_replace) ? 0 : recent_access[i] + 1;
      end
    end else begin
      line_replace = line_write;
    end
  end

endmodule : replace_controller
