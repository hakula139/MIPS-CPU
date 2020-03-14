`timescale 1ns / 1ps

module datapath
(
  input logic clk, reset,
  input logic memToReg,
  input logic pcSrc,
  input logic aluSrc, 
  input logic regDst, regWrite,
  input logic jump,
  input logic [3:0] aluControl,
  input logic [31:0] instr,
  input logic [31:0] readData,
  output logic zero,
  output logic [31:0] aluResult,
  output logic [31:0] pc,
  output logic [31:0] writeData
);
  logic [4:0] writeReg;
  logic [31:0] pcNext, pcNextBranch, pcPlus4, pcBranch;
  logic [31:0] signImm;
  logic [31:0] srcA, srcB;
  logic [31:0] result;

  // Next PC logic
  flopr #(.WIDTH(32))
        pcReg(
          .clk(clk), .reset(reset),
          .d(pcNext),
          .q(pc)
        );
  adder pcAdd4(
          .a(pc), .b(32'd4),
          .y(pcPlus4)
        );
  adder pcAddImm(
          .a(pcPlus4), .b({signImm[29:0], 2'b00}),
          .y(pcBranch)
        );
  mux2  #(.WIDTH(32))
        pcBranchMux(
          .d0(pcPlus4), .d1(pcBranch),
          .s(pcSrc),
          .y(pcNextBranch)
        );
  mux2  #(.WIDTH(32))
        pcJumpMux(
          .d0(pcNextBranch), .d1({pcPlus4[31:28], instr[25:0], 2'b00}),
          .s(jump),
          .y(pcNext)
        );

  // Register file logic
  regfile rf(
            .clk(clk), .reset(reset),
            .regWriteEn(regWrite),
            .regWriteAddr(writeReg),
            .regwriteData(result),
            .rsAddr(instr[25:21]), .rtAddr(instr[20:16]),
            .rsData(srcA), .rtData(writeData)
          );
  mux2    #(.WIDTH(5))
          writeRegMux(
            .d0(instr[20:16]), .d1(instr[15:11]),
            .s(regDst),
            .y(writeReg)
          );
  mux2    #(.WIDTH(32))
          resultMux(
            .d0(aluResult), .d1(readData),
            .s(memToReg),
            .y(result)
          );
  signext se(
            .a(instr),
            .a(signImm)
          );

  // ALU logic
  mux2  #(.WIDTH(32))
        srcBMux(
          .d0(writeData), .d1(signImm),
          .s(aluSrc),
          .y(srcB)
        );
  alu   alu(
          .aluControl(aluControl),
          .a(srcA), .b(srcB),
          .aluResult(aluResult),
          .zero(zero)
        );
endmodule: datapath
