`include "cache.vh"

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
  parameter SET_SIZE     = `CACHE_E,
  parameter SEL_WIDTH    = $clog2(SET_SIZE)
) (
  input                        clk_i,
  input                        rst_i,
  input        [5:0]           control_i,
  input        [31:0]          addr_i,
  input        [31:0]          write_data_i,
  input        [31:0]          mem_addr_i,
  input        [31:0]          mem_read_data_i,
  output logic                 hit_o,
  output logic                 dirty_o,
  output logic [TAG_WIDTH-1:0] tag_dirty_line_o,
  output logic [31:0]          read_data_o
);

  logic                    write_en, update_en, set_valid, set_dirty, strategy_en, offset_sel;
  logic                    all_valid;
  logic [SEL_WIDTH-1:0]    line_write, line_replace;
  logic [SET_SIZE-1:0]     write_en_line, update_en_line, set_valid_line, set_dirty_line;
  logic [TAG_WIDTH-1:0]    tag;
  logic [TAG_WIDTH-1:0]    tag_line[SET_SIZE-1:0];
  logic [OFFSET_WIDTH-3:0] offset;
  logic [31:0]             write_data;
  logic [SET_SIZE-1:0]     valid_line, dirty_line, hit_line;
  logic [31:0]             read_data_line[SET_SIZE-1:0];

  assign {write_en, update_en, set_valid, set_dirty, strategy_en, offset_sel} = control_i;
  assign tag = addr_i[31:32-TAG_WIDTH];
  assign offset = offset_sel ? addr_i[OFFSET_WIDTH-1:2] : mem_addr_i[OFFSET_WIDTH-1:2];
  assign write_data = offset_sel ? write_data_i : mem_read_data_i;

  replace_controller u_replace_controller (
    .clk_i,
    .rst_i,
    .strategy_en_i(strategy_en & all_valid),
    .write_en_i(write_en),
    .line_write_i(line_write),
    .line_replace_o(line_replace)
  );

  line               u_line[SET_SIZE-1:0] (
    .clk_i,
    .rst_i,
    .write_en_i(write_en_line),
    .update_en_i(update_en_line),
    .set_valid_i(set_valid_line),
    .set_dirty_i(set_dirty_line),
    .set_tag_i(tag),
    .offset_i(offset),
    .write_data_i(write_data),
    .valid_o(valid_line),
    .dirty_o(dirty_line),
    .tag_o(tag_line),
    .hit_o(hit_line),
    .read_data_o(read_data_line)
  );

  assign all_valid = ~|(~valid_line);  // all lines are valid
  assign dirty_o = |dirty_line;
  assign hit_o = |hit_line;

  always_comb begin
    if (write_en) begin
      if (hit_o | ~all_valid) begin
        int ok = 0, flag = 0;
        for (int i = 0; i < SET_SIZE; ++i) begin
          if (hit_o) flag = hit_line[i];
          else if (~all_valid) flag = ~valid_line[i];
          if (!ok && flag) begin
            line_write = i;
            ok = 1;
          end else begin
            write_en_line[i] = '0;
          end
        end
      end else begin
        line_write = line_replace;
      end
      write_en_line[line_write] = '1;
    end
    if (update_en) begin
      update_en_line[line_write] = '1;
      set_valid_line[line_write] = set_valid;
      set_dirty_line[line_write] = set_dirty;
    end else begin
      write_en_line = '0;
      if (hit_o) begin
        for (int i = 0; i < SET_SIZE; ++i) begin
          if (hit_line[i]) begin
            tag_dirty_line_o = tag_line[i];
            read_data_o = read_data_line[i];
          end
        end
      end else begin
        read_data_o = '0;
      end
    end
  end

endmodule : set
