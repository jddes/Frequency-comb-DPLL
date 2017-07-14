// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Jul 04 15:50:24 2017
// Host        : DESKTOP-OULANE9 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {D:/Users/Alex/Documents/GitHub/Frequency-comb-DPLL/Firmware Vivado
//               Project/redpitaya.srcs/sources_1/ip/pll_18x32_mult_d/pll_18x32_mult_d_stub.v}
// Design      : pll_18x32_mult_d
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "mult_gen_v12_0_10,Vivado 2015.4" *)
module pll_18x32_mult_d(CLK, A, B, SCLR, P)
/* synthesis syn_black_box black_box_pad_pin="CLK,A[17:0],B[31:0],SCLR,P[49:0]" */;
  input CLK;
  input [17:0]A;
  input [31:0]B;
  input SCLR;
  output [49:0]P;
endmodule
