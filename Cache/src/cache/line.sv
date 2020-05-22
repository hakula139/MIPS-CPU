`include "cache.svh"

module line #(
  parameter TAG_WIDTH    = `CACHE_T,
  parameter OFFSET_WIDTH = `CACHE_B
) (
  input                           clk_i,
  input                           rst_i,
  input                           write_en_i,
  input                           update_en_i,
  input                           set_valid_i,
  input                           set_dirty_i,
  input        [TAG_WIDTH-1:0]    set_tag_i,
  input        [OFFSET_WIDTH-3:0] offset_i,
  input        [31:0]             write_data_i,
  output logic                    valid_o,
  output logic                    dirty_o,
  output logic [TAG_WIDTH-1:0]    tag_o,
  output logic                    hit_o,
  output logic [31:0]             read_data_o
);

  localparam LINE_SIZE = 2**(`CACHE_B - 2);

  logic [31:0] cache_line[LINE_SIZE-1:0];

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      foreach (cache_line[i]) cache_line[i] <= '0;
      {valid_o, dirty_o, tag_o} <= '0;
    end else begin
      if (write_en_i) begin
        cache_line[offset_i] <= write_data_i;
        dirty_o <= '1;
      end
      if (update_en_i) begin
        {valid_o, dirty_o} <= {set_valid_i, set_dirty_i};
        if (write_en_i) tag_o <= set_tag_i;
      end
    end
  end

  assign hit_o = valid_o && set_tag_i == tag_o;
  assign read_data_o = cache_line[offset_i];

endmodule : line
