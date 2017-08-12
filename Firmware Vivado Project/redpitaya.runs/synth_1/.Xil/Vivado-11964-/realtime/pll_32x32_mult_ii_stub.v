// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "mult_gen_v12_0_10,Vivado 2015.4" *)
module pll_32x32_mult_ii(CLK, A, B, SCLR, P);
  input CLK;
  input [31:0]A;
  input [31:0]B;
  input SCLR;
  output [63:0]P;
endmodule
