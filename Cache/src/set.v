`include "cache.vh"

/**
 * ctls       : control signals from cache_controller
 * addr       : cache read/write address from processor
 * write_data : cache write data from processor
 * mread_data : data read from memory
 * 
 * hit        : whether cache set hits
 * dirty      : from the cache line selected by addr
 								(cache line's tag is equal to addr's tag)
 */
module set #(
	parameter TAG_WIDTH    = `CACHE_T,
	parameter OFFSET_WIDTH = `CACHE_B,
	parameter LINES        = `CACHE_E
) (
	input                     clk, reset,
	input  [OFFSET_WIDTH+2:0] ctls,
	input  [31:0]             addr, write_data, mread_data,
	output                    hit, dirty,
	output [31:0]             read_data
);

wire 									  w_en, set_valid, set_dirty, init, offset_sw;
wire [OFFSET_WIDTH-3:0] offset;

// control signals will be assigned to the target line instance.
assign {w_en, set_valid, set_dirty, offset, strategy_en, offset_sel} = ctls;

/**
 * TODO: Your code here
 */

endmodule
