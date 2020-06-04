`timescale 1ns / 1ps

module control_unit (
  input        [5:0] op_i,
  input        [5:0] funct_i,
  input              zero_i,
  output logic       mem_to_reg_o,
  output logic       mem_write_o,
  output logic       pc_src_o,
  output logic [2:0] jump_o,
  output logic [3:0] alu_control_o,
  output logic [1:0] alu_src_o,
  output logic       reg_dst_o,
  output logic       reg_write_o
);

  logic [2:0] alu_op;
  logic [1:0] branch;

  main_dec u_main_dec (
    .op_i,
    .funct_i,
    .mem_to_reg_o,
    .mem_write_o,
    .branch_o(branch),
    .jump_o,
    .alu_op_o(alu_op),
    .alu_src_o,
    .reg_dst_o,
    .reg_write_o
  );

  alu_dec  u_alu_dec (
    .funct_i,
    .alu_op_i(alu_op),
    .alu_control_o
  );

  assign pc_src_o = (branch[0] & zero_i) | (branch[1] & ~zero_i);

endmodule : control_unit

// Main decoder
module main_dec (
  input        [5:0] op_i,
  input        [5:0] funct_i,
  output logic       mem_to_reg_o,
  output logic       mem_write_o,
  output logic [1:0] branch_o,
  output logic [2:0] jump_o,
  output logic [2:0] alu_op_o,
  output logic [1:0] alu_src_o,
  output logic       reg_dst_o,
  output logic       reg_write_o
);

  logic [13:0] bundle;
  assign {reg_write_o, reg_dst_o, alu_src_o, alu_op_o,
          jump_o, branch_o, mem_write_o, mem_to_reg_o} = bundle;

  always_comb begin
    unique case (op_i)
      6'b000000: begin
        unique casez (funct_i)
          6'b0000??: bundle = 14'b11_10100_000_00_00;  // SLL, SRL, SRA
          6'b001000: bundle = 14'b0x_xxxxx_010_xx_0x;  // JR
          default:   bundle = 14'b11_00100_000_00_00;  // R-type
        endcase
      end
      6'b000010: bundle = 14'b0x_xxxxx_001_xx_0x;   // J
      6'b000011: bundle = 14'b10_xxxxx_101_xx_0x;   // JAL
      6'b000100: bundle = 14'b0x_00001_000_01_0x;   // BEQ
      6'b000101: bundle = 14'b0x_00001_000_10_0x;   // BNE
      6'b001000: bundle = 14'b10_01000_000_00_00;   // ADDI
      6'b001010: bundle = 14'b10_01111_000_00_00;   // SLTI
      6'b001100: bundle = 14'b10_01010_000_00_00;   // ANDI
      6'b001101: bundle = 14'b10_01110_000_00_00;   // ORI
      6'b100011: bundle = 14'b10_01000_000_00_01;   // LW
      6'b101011: bundle = 14'b0x_01000_000_00_1x;   // SW
      default:   bundle = 14'bxx_xxxxx_xxx_xx_xx;   // illegal op
    endcase
  end

endmodule : main_dec

// ALU decoder
module alu_dec (
  input        [5:0] funct_i,
  input        [2:0] alu_op_i,
  output logic [3:0] alu_control_o
);

  always_comb begin
    unique case (alu_op_i)
      3'b000: alu_control_o = 4'd2;  // ADD (for ADDI, LW, SW)
      3'b001: alu_control_o = 4'd6;  // SUB (for BEQ, BNE)
      3'b010: alu_control_o = 4'd0;  // AND (for ANDI)
      3'b110: alu_control_o = 4'd1;  // OR  (for ORI)
      3'b111: alu_control_o = 4'd7;  // SLT (for SLTI)
      default: begin                  // R-type
        unique case (funct_i)
          6'b000000: alu_control_o = 4'd3;  // SLL
          6'b000010: alu_control_o = 4'd8;  // SRL
          6'b000011: alu_control_o = 4'd9;  // SRA
          6'b100000: alu_control_o = 4'd2;  // ADD
          6'b100010: alu_control_o = 4'd6;  // SUB
          6'b100100: alu_control_o = 4'd0;  // AND
          6'b100101: alu_control_o = 4'd1;  // OR
          6'b101010: alu_control_o = 4'd7;  // SLT
          default:   alu_control_o = 4'dx;  // illegal funct
        endcase
      end
    endcase
  end

endmodule : alu_dec
