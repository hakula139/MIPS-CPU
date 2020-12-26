`ifndef STATIC_PREDICTOR_SVH
`define STATIC_PREDICTOR_SVH

`timescale 1ns / 1ps

`define NOT_TAKEN 0  // always not-taken
`define TAKEN     1  // always taken
`define BTFNT     2  // backward-taken, forward not-taken

`define FALLBACK_MODE `BTFNT

`endif
