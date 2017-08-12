// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "mult_gen_v12_0_10,Vivado 2015.4" *)
module system_identification_outputgain_mult(CLK, A, B, SCLR, P);
  input CLK;
  input [15:0]A;
  input [17:0]B;
  input SCLR;
  output [15:0]P;
endmodule
