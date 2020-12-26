`include "cache.svh"
`include "cache_controller.svh"

/**
 * NOTE: The sum of TAG_WIDTH, SET_WIDTH and OFFSET_WIDTH should be 32
 *
 * TAG_WIDTH    : (t) tag bits
 * SET_WIDTH    : (s) set index bits, the number of sets is 2**SET_WIDTH
 * OFFSET_WIDTH : (b) block offset bits
 * LINES        : the number of lines per set
 *
 * stall        : in order to synchronize instruction memory cache and data
                  memory cache, you may need this so that two caches will write
                  data at most once per instruction respectively.
 *
 * input_ready  : whether input data from processor are ready
 * addr         : cache read/write address from processor
 * write_data   : cache write data from processor
 * w_en         : cache write enable
 * hit          : whether cache hits
 * read_data    : data read from cache
 *
 * maddr        : memory address
 * mwrite_data  : data written to memory
 * m_wen        : memory write enable
 * mread_data   : data read from memory
 */
module cache #(
  parameter TAG_WIDTH    = `CACHE_T,
  parameter SET_WIDTH    = `CACHE_S,
  parameter OFFSET_WIDTH = `CACHE_B,
  parameter SET_SIZE     = `CACHE_E
) (
  input               clk,
  input               reset,
  input               stall,

  // Interface with CPU
  input               input_ready,
  input               w_en,
  input        [31:0] addr,
  input        [31:0] write_data,
  output logic        hit,
  output logic [31:0] read_data,

  // Interface with memory
  input        [31:0] mread_data,
  output logic        m_wen,
  output logic [31:0] maddr,
  output logic [31:0] mwrite_data
);

  localparam SET_NUM = 2**SET_WIDTH;

  // Address related
  logic [TAG_WIDTH-1:0]    tag;
  logic [SET_WIDTH-1:0]    index;
  logic [OFFSET_WIDTH-3:0] offset;

  assign tag = addr[31:32-TAG_WIDTH];
  assign index = addr[31-TAG_WIDTH:OFFSET_WIDTH];
  assign offset = addr[OFFSET_WIDTH-1:2];

  // Cache controller signals
  logic [6:0]              control;
  logic [OFFSET_WIDTH-3:0] offset_line;
  logic [`STATE_WIDTH-1:0] state;
  logic                    default_mode;

  assign default_mode = state == `INITIAL;

  // Set control signals
  logic [5:0]              control_set[SET_NUM-1:0];

  always_comb begin
    foreach (control_set[i]) begin
      control_set[i] = (i == index) ? control[6:1] : '0;
    end
  end

  // Set outputs
  logic [SET_NUM-1:0]      hit_set, dirty_set;
  logic                    hit_cache;
  logic [TAG_WIDTH-1:0]    tag_set[SET_NUM-1:0];
  logic [TAG_WIDTH-1:0]    tag_line;
  logic [31:0]             read_data_set[SET_NUM-1:0];

  assign hit_cache = hit_set[index];
  assign hit = hit_cache & default_mode;
  assign dirty = dirty_set[index];
  assign tag_line = tag_set[index];
  assign read_data = hit_cache ? read_data_set[index] : '0;

  assign m_wen = control[0];
  assign mwrite_data = read_data_set[index];

  cache_controller u_cache_controller (
    .clk_i(clk),
    .rst_i(reset),
    .en_i(~stall & input_ready),
    .write_en_i(w_en),
    .hit_i(hit_cache),
    .dirty_i(dirty),
    .tag_line_i(tag_line),
    .addr_i(addr),
    .control_o(control),
    .mem_addr_o(maddr),
    .offset_line_o(offset_line),
    .state_o(state)
  );

  set              u_set[SET_NUM-1:0] (
    .clk_i(clk),
    .rst_i(reset),
    .control_i(control_set),
    .addr_i(addr),
    .write_data_i(write_data),
    .mem_addr_i({addr[31:OFFSET_WIDTH], offset_line, 2'b00}),
    .mem_read_data_i(mread_data),
    .hit_o(hit_set),
    .dirty_o(dirty_set),
    .tag_o(tag_set),
    .read_data_o(read_data_set)
  );

endmodule : cache
