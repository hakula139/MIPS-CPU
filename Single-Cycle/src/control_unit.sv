`timescale 1ns / 1ps

module control_unit (
  input        [5:0] op_i,
  input        [5:0] funct_i,
  input              zero_i,
  output logic       mem_to_reg_o,
  output logic       mem_write_o,
  output logic       pc_src_o,
  output logic       jump_o,
  output logic [3:0] alu_control_o,
  output logic       alu_src_o,
  output logic       reg_dst_o,
  output logic       reg_write_o
);

  logic [2:0] alu_op;
  logic       branch;

  main_dec u_main_dec (
    .op_i,
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

  assign pc_src_o = branch & zero_i;

endmodule : control_unit

// Main decoder
module main_dec (
  input        [5:0] op_i,
  output logic       mem_to_reg_o,
  output logic       mem_write_o,
  output logic       branch_o,
  output logic       jump_o,
  output logic [2:0] alu_op_o,
  output logic       alu_src_o,
  output logic       reg_dst_o,
  output logic       reg_write_o
);

  logic [7:0] bundle;
  assign {reg_write_o, reg_dst_o, alu_src_o, alu_op_o,
          jump_o, branch_o, mem_write_o, mem_to_reg_o} = bundle;

  always_comb begin
    unique case (op_i)
      6'b000000: bundle <= 10'b11_0100_00_00;  // R-type (ADD, SUB, AND, OR, SLT)
      6'b001000: bundle <= 10'b10_1000_00_00;  // ADDI
      6'b001100: bundle <= 10'b10_1010_00_00;  // ANDI
      6'b001101: bundle <= 10'b10_1110_00_00;  // ORI
      6'b001010: bundle <= 10'b10_1111_00_00;  // SLTI
      6'b101011: bundle <= 10'b0x_1000_00_1x;  // SW
      6'b100011: bundle <= 10'b10_1000_00_01;  // LW
      6'b000010: bundle <= 10'b0x_xxxx_1x_0x;  // J
      6'b000100: bundle <= 10'b0x_0001_01_0x;  // BEQ
      default:   bundle <= 10'bxx_xxxx_xx_xx;  // illegal op
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
      3'b000: alu_control_o <= 4'd2;  // ADD (for ADDI, SW, LW)
      3'b001: alu_control_o <= 4'd6;  // SUB (for BEQ)
      3'b010: alu_control_o <= 4'd0;  // AND (for ANDI)
      3'b110: alu_control_o <= 4'd1;  // OR  (for ORI)
      3'b111: alu_control_o <= 4'd7;  // SLT (for SLTI)
      default: begin                  // R-type
        unique case (funct_i)
          6'b000000: alu_control_o <= 4'd3;  // SLL
          6'b000010: alu_control_o <= 4'd8;  // SRL
          6'b000011: alu_control_o <= 4'd9;  // SRA
          6'b100000: alu_control_o <= 4'd2;  // ADD
          6'b100010: alu_control_o <= 4'd6;  // SUB
          6'b100100: alu_control_o <= 4'd0;  // AND
          6'b100101: alu_control_o <= 4'd1;  // OR
          6'b101010: alu_control_o <= 4'd7;  // SLT
          default:   alu_control_o <= 4'dx;  // illegal funct
        endcase
      end
    endcase
  end

endmodule : alu_dec
