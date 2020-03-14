`timescale 1ns / 1ps

// Control unit
module controller
(
  input logic [5:0] op, funct,
  input logic zero,
  output logic memToReg, memWrite,
  output logic pcSrc, aluSrc,
  output logic regDst, regWrite,
  output logic jump,
  output logic [3:0] aluControl
);
  logic [2:0] aluOp;
  logic branch;
  maindec md(
            op,                  // input
            memToReg, memWrite,  // output
            branch, aluSrc,      // output
            regDst, regWrite,    // output
            jump,                // output
            aluOp                // output
          );
  aludec  ad(
            aluOp,      // input
            funct,      // input
            aluControl  // output
          );
  assign pcSrc = branch & zero;
endmodule: controller

// Main decoder
module maindec
(
  input logic [5:0] op,
  output logic memToReg, memWrite,
  output logic branch, aluSrc,
  output logic regDst, regWrite,
  output logic jump,
  output logic [2:0] aluOp
);
  logic [7:0] bundle;
  assign {regWrite, regDst, aluSrc, branch, memWrite, memToReg, jump, aluOp} = bundle;
  always_comb begin
    unique case(op) inside
      6'b000000: bundle <= 10'b1100000_100;  // Rtype (ADD, SUB, AND, OR, SLT)
      6'b001000: bundle <= 10'b1010000_000;  // ADDI
      6'b001100: bundle <= 10'b1010000_010;  // ANDI
      6'b001101: bundle <= 10'b1010000_110;  // ORI
      6'b001010: bundle <= 10'b1010000_111;  // SLTI
      6'b101011: bundle <= 10'b0x101x0_000;  // SW
      6'b100011: bundle <= 10'b1010010_000;  // LW
      6'b000010: bundle <= 10'b0xxx0x1_xxx;  // JUMP
      6'b000100: bundle <= 10'b0x010x0_001;  // BEQ
      default:   bundle <= 10'bxxxxxxx_xxx;  // error
    endcase
  end
endmodule: maindec

// ALU decoder
module aludec
(
  input logic [2:0] aluOp,
  input logic [5:0] funct,
  output logic [3:0] aluControl
);
  always_comb begin
    unique case(aluOp) inside
      3'b000: aluControl <= 4'd2;  // ADD
      3'b001: aluControl <= 4'd6;  // SUB
      3'b010: aluControl <= 4'd0;  // AND
      3'b110: aluControl <= 4'd1;  // OR
      3'b111: aluControl <= 4'd7;  // SLT
      default:  // 3'b100
      unique case(funct) inside
        6'b000000: aluControl <= 4'd3;  // SLL
        6'b000010: aluControl <= 4'd8;  // SRL
        6'b000011: aluControl <= 4'd9;  // SRA
        6'b100000: aluControl <= 4'd2;  // ADD
        6'b100010: aluControl <= 4'd6;  // SUB
        6'b100100: aluControl <= 4'd0;  // AND
        6'b100101: aluControl <= 4'd1;  // OR
        6'b101010: aluControl <= 4'd7;  // SLT
        default:   aluControl <= 4'dx;  // error
      endcase
    endcase
  end
endmodule: aludec
