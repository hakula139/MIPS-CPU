`timescale 1ns / 1ps

// 32-bit register file with active-high asynchronous reset
module reg_file (
  input               clk_i,
  input               rst_i,
  input               we3_i,  // reg_write_en
  input        [4:0]  wa3_i,  // reg_write_addr
  input        [31:0] wd3_i,  // reg_write_data
  input        [4:0]  ra1_i,  // reg_read_addr_1
  input        [4:0]  ra2_i,  // reg_read_addr_2
  output logic [31:0] rd1_o,  // reg_read_data_1
  output logic [31:0] rd2_o   // reg_read_data_2
);

  logic [31:0] rf[31:0];
  integer i;

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      for (i = 0; i < 32; ++i) rf[i] <= '0;
    end else if (we3_i) begin
      rf[wa3_i] <= wd3_i;
    end
  end

  // Register 0 hardwired to 0
  assign rd1_o = !ra1_i ? '0 : rf[ra1_i];
  assign rd2_o = !ra2_i ? '0 : rf[ra2_i];

endmodule : reg_file
