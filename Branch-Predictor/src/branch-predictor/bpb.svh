`ifndef BPB_SVH
`define BPB_SVH

`timescale 1ns / 1ps

// number of entries
`define BPB_E 8
// index bits
`define BPB_T 10

`define USE_STATIC    0  // uses Static Predictor
`define USE_GLOBAL    1  // uses Global Predictor
`define USE_LOCAL     2  // uses Local Predictor
`define USE_TWO_LEVEL 3  // uses Two-Level Predictor (Global and Local)

`define MODE              `USE_TWO_LEVEL
`define PHT_FALLBACK_MODE `USE_GLOBAL

`endif
