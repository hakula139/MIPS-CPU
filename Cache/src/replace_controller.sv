`include "cache.vh"

module replace_controller #(
  parameter SET_SIZE     = `CACHE_E,
  parameter SEL_WIDTH    = $clog2(SET_SIZE)
) (
  input                        clk_i,
  input                        rst_i,
  input                        strategy_en_i,
  input                        write_en_i,
  input        [SEL_WIDTH-1:0] line_write_i,
  output logic [SEL_WIDTH-1:0] line_replace_o
);

  int recent_access[SET_SIZE-1:0];
  int max_access[$], max_index[$];

  always_comb begin
    if (rst_i) begin
      recent_access = '{default:'0};
    end
    if (strategy_en_i) begin
      max_access = recent_access.max();
      max_index = max_access.find_first_index with (item == max_access.pop_front());
      line_replace_o = max_index.pop_front();
    end else begin
      line_replace_o = line_write_i;
    end
    if (write_en_i) begin
      for (int i = 0; i < SET_SIZE; ++i) begin
        recent_access[i] = (i == line_replace_o) ? '0 : recent_access[i] + 1;
      end
    end
  end

endmodule : replace_controller
