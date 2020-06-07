`ifndef BPB_SVH
`define BPB_SVH

`timescale 1ns / 1ps

// number of entries
`define BPB_E 10
// index bits
`define BPB_T 10

`define USE_STATIC    0  // uses Static Predictor
`define USE_GLOBAL    1  // uses Global Predictor
`define USE_LOCAL     2  // uses Local Predictor
`define USE_BOTH      3  // uses Tournament Predictor (both Global and Local)

`define MODE              `USE_BOTH
`define PHT_FALLBACK_MODE `USE_GLOBAL

`endif
