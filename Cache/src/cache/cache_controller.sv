`include "cache_controller.svh"
`include "cache.svh"

/**
 * en_i             : en in cache module
 * write_en_i       : cache writing enable signal, from write_en in cache module
 * addr_i           : cache read/write address from processor
 * hit_i, dirty_i   : from set module
 * tag_line_i       : the tag of dirty line from set module
 *
 * control_o        : {write_en, update_en, set_valid, set_dirty, strategy_en, offset_sel, mem_write_en}
 * mem_addr_o       : memory address
 * state_o          : the current state of FSM
 *
 * write_en         : writing enable signal to cache line
 * update_en        : updating enable signal to cache line (without writing)
 * mem_write_en     : writing enable signal to memory, controls whether to write to memory
 * set_valid        : control signal for cache line
 * set_dirty        : control signal for cache line
 * offset_sel       : control signal for cache line and this may be used in other places
 */
module cache_controller #(
  parameter TAG_WIDTH    = `CACHE_T,
  parameter SET_WIDTH    = `CACHE_S,
  parameter OFFSET_WIDTH = `CACHE_B
) (
  input                           clk_i,
  input                           rst_i,
  input                           en_i,
  input                           write_en_i,
  input                           hit_i,
  input                           dirty_i,
  input        [TAG_WIDTH-1:0]    tag_line_i,
  input        [31:0]             addr_i,
  output logic [6:0]              control_o,
  output logic [31:0]             mem_addr_o,
  output logic [OFFSET_WIDTH-3:0] offset_line_o,
  output logic [`STATE_WIDTH-1:0] state_o
);

  localparam LINE_SIZE  = 2**(`CACHE_B - 2);
  localparam WAIT_TIME  = LINE_SIZE;

  // Address related
  logic [TAG_WIDTH-1:0]    tag;
  logic [SET_WIDTH-1:0]    index;
  logic [OFFSET_WIDTH-3:0] offset;

  assign tag = addr_i[31:32-TAG_WIDTH];
  assign index = addr_i[31-TAG_WIDTH:OFFSET_WIDTH];
  assign offset = addr_i[OFFSET_WIDTH-1:2];

  // FSM related
  logic [31:0]             wait_time;
  logic                    wait_rst;

  counter              u_counter (
    .clk_i,
    .rst_i(rst_i | wait_rst),
    .en_i,
    .time_o(wait_time)
  );

  cache_controller_fsm u_cache_controller_fsm (
    .clk_i,
    .rst_i,
    .en_i,
    .write_en_i,
    .time_i(wait_time),
    .hit_i,
    .dirty_i,
    .state_o
  );

  assign offset_line_o = (wait_time < LINE_SIZE) ? wait_time : LINE_SIZE - 1;

  always_comb begin
    if (en_i) begin
      case (state_o)
        `WRITE_BACK, `ONLY_WRITE: begin
          wait_rst = wait_time == WAIT_TIME - 1;
          mem_addr_o = {tag_line_i, index, offset_line_o, 2'b00};
          control_o = 7'b0110001;
        end
        `READ_MEM: begin
          wait_rst = wait_time == WAIT_TIME - 1;
          mem_addr_o = {tag, index, offset_line_o, 2'b00};
          control_o = wait_rst ? 7'b1110100 : 7'b1100100;
        end
        default: begin
          wait_rst = ~hit_i | (~write_en_i & dirty_i);
          mem_addr_o = {tag, index, offset_line_o, 2'b00};
          control_o = {write_en_i, 1'b0, write_en_i, write_en_i, 3'b110};
        end
      endcase
    end else begin
      wait_rst = '0;
      mem_addr_o = '0;
      control_o = '0;
    end
  end

endmodule : cache_controller

module cache_controller_fsm #(
  parameter LINE_SIZE  = 2**(`CACHE_B - 2)
) (
  input                           clk_i,
  input                           rst_i,
  input                           en_i,
  input                           write_en_i,
  input        [31:0]             time_i,
  input                           hit_i,
  input                           dirty_i,
  output logic [`STATE_WIDTH-1:0] state_o
);

  localparam WAIT_TIME = LINE_SIZE;

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      state_o <= `INITIAL;
    end else if (en_i) begin
      case (state_o)
        `WRITE_BACK: if (time_i == WAIT_TIME - 1) state_o <= `READ_MEM;
        `READ_MEM, `ONLY_WRITE: if (time_i == WAIT_TIME - 1) state_o <= `INITIAL;
        default: begin
          if (~hit_i) state_o <= dirty_i ? `WRITE_BACK : `READ_MEM;
          if (~write_en_i & dirty_i) state_o <= `ONLY_WRITE;
        end
      endcase
    end
  end

endmodule : cache_controller_fsm

module counter #(
  parameter LINE_SIZE  = 2**(`CACHE_B - 2)
) (
  input               clk_i,
  input               rst_i,
  input               en_i,
  output logic [31:0] time_o
);
  always_ff @(posedge clk_i) begin
    if (rst_i) time_o <= '0;
    else if (en_i) time_o <= time_o + 1;
  end
endmodule : counter
