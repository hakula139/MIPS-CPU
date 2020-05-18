`include "cache.svh"

/**
 * control_i       : control signals from cache_controller
 * addr_i          : cache read/write address from processor
 * write_data_i    : cache write data from processor
 * mem_addr_i      : memory read/write address
 * mem_read_data_i : data read from memory
 * 
 * hit_o           : whether cache set hits
 * dirty_o         : from the cache line selected by addr
                     (cache line's tag is equal to addr's tag)
 * read_data_o     : cache read data
 */
module set #(
  parameter TAG_WIDTH    = `CACHE_T,
  parameter OFFSET_WIDTH = `CACHE_B,
  parameter SET_SIZE     = `CACHE_E
) (
  input                        clk_i,
  input                        rst_i,
  input        [4:0]           control_i,
  input        [31:0]          addr_i,
  input        [31:0]          write_data_i,
  input        [31:0]          mem_addr_i,
  input        [31:0]          mem_read_data_i,
  output logic                 hit_o,
  output logic                 dirty_o,
  output logic [TAG_WIDTH-1:0] tag_o,
  output logic [31:0]          read_data_o
);

  localparam SEL_WIDTH = $clog2(SET_SIZE);

  // Cache controller signals
  logic write_en, set_valid, set_dirty, strategy_en, offset_sel;

  assign {write_en, set_valid, set_dirty, strategy_en, offset_sel} = control_i;

  // Line control signals
  logic [SET_SIZE-1:0]  write_en_line;

  // Line outputs
  logic [SET_SIZE-1:0]  valid_line, dirty_line, hit_line, out_line;
  logic [TAG_WIDTH-1:0] tag_line[SET_SIZE-1:0];
  logic [31:0]          read_data_line[SET_SIZE-1:0];

  // Set control signals and inputs
  logic [TAG_WIDTH-1:0]    set_tag;
  logic [OFFSET_WIDTH-3:0] offset;
  logic [31:0]             write_data;
  logic [SET_SIZE-1:0]     mask;

  assign dirty_o = |dirty_line;
  assign hit_o = |hit_line;

  assign set_tag = addr_i[31:32-TAG_WIDTH];
  assign offset = offset_sel ? addr_i[OFFSET_WIDTH-1:2] : mem_addr_i[OFFSET_WIDTH-1:2];
  assign write_data = offset_sel ? write_data_i : mem_read_data_i;
  assign mask = hit_o ? hit_line : out_line;
  assign write_en_line = write_en ? mask : '0;

  always_comb begin
    tag_o = '0;
    read_data_o = '0;
    for (int i = 0; i < SET_SIZE; ++i) begin
      if (mask[i]) begin
        tag_o = tag_line[i];
        read_data_o = read_data_line[i];
      end
    end
  end

  replace_controller u_replace_controller (
    .clk_i,
    .rst_i,
    .en_i(strategy_en & hit_o),
    .hit_line_i(hit_line),
    .out_line_o(out_line)
  );

  line               u_line[SET_SIZE-1:0] (
    .clk_i,
    .rst_i,
    .write_en_i(write_en_line),
    .set_valid_i(set_valid),
    .set_dirty_i(set_dirty),
    .set_tag_i(set_tag),
    .offset_i(offset),
    .write_data_i(write_data),
    .valid_o(valid_line),
    .dirty_o(dirty_line),
    .tag_o(tag_line),
    .hit_o(hit_line),
    .read_data_o(read_data_line)
  );

endmodule : set
