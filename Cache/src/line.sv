`include "cache.vh"

module line #(
  parameter TAG_WIDTH    = `CACHE_T,
  parameter OFFSET_WIDTH = `CACHE_B,
	parameter LINE_SIZE    = 2**(`CACHE_B - 2)
) (
  input                           clk_i,
  input                           rst_i,
  input                           write_en_i,
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

  logic [31:0] cache_line[LINE_SIZE-1:0];

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      for (int i = 0; i < LINE_SIZE; ++i) begin
        cache_line[i] <= '0;
      end
      {valid_o, dirty_o, tag_o} <= '0;
    end
    if (write_en_i) begin
      cache_line[offset_i] <= write_data_i;
      {valid_o, dirty_o, tag_o} <= {set_valid_i, set_dirty_i, set_tag_i};
		end
  end

  assign hit_o = valid_o && set_tag_i == tag_o;
  assign read_data_o = hit_o ? cache_line[offset_i] : '0;

endmodule : line
