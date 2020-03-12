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
  output logic [2:0] aluControl
);
  logic [1:0] aluOp;
  logic branch;
  maindec md(
            op,                  // input
            memToReg, memWrite,  // output
            branch, aluSrc,      // output
            regDst, regWrite,    // output
            jump,                // output
            aluOp                // output
          );
  aludec ad(
           funct,      // input
           aluOp,      // input
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
  output logic [1:0] aluOp
);
  logic [7:0] bundle;
  assign {regWrite, regDst, aluSrc, branch, memWrite, memToReg, aluOp} = bundle;
  always_comb begin
    unique case(op) inside
      6'b000000: bundle <= 8'b11000010;  // Rtype
      6'b101011: bundle <= 8'b0x101x00;  // SW
      6'b100011: bundle <= 8'b10100100;  // LW
      6'b000100: bundle <= 8'b0x010x01;  // BEQ
      default: bundle <= 8'bxxxxxxxx;  // error
    endcase
  end
endmodule: maindec

// ALU decoder
module aludec
(
  input logic [5:0] funct,
  input logic [1:0] aluOp,
  output logic [2:0] aluControl
);
  always_comb begin
    unique case(aluOp) inside
      2'b00: aluControl <= 3'd2;  // ADD
      2'b01: aluControl <= 3'd6;  // SUB
      default: unique case(funct) inside
        6'b100000: aluControl <= 3'd2;  // ADD
        6'b100010: aluControl <= 3'd6;  // SUB
        6'b100100: aluControl <= 3'd0;  // AND
        6'b100101: aluControl <= 3'd1;  // OR
        6'b101010: aluControl <= 3'd7;  // SLT
        default: aluControl <= 3'dx;    // error
      endcase
    endcase
  end
endmodule: aludec
