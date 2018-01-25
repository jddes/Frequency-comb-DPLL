// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Jan 09 19:19:34 2018
// Host        : jdbureau running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {d:/Repo/Frequency-comb-DPLL/Firmware Vivado
//               Project/redpitaya.srcs/sources_1/ip/angle_CORDIC_14bits/angle_CORDIC_14bits_stub.v}
// Design      : angle_CORDIC_14bits
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "cordic_v6_0_9,Vivado 2015.4" *)
module angle_CORDIC_14bits(aclk, s_axis_cartesian_tvalid, s_axis_cartesian_tdata, m_axis_dout_tvalid, m_axis_dout_tdata)
/* synthesis syn_black_box black_box_pad_pin="aclk,s_axis_cartesian_tvalid,s_axis_cartesian_tdata[31:0],m_axis_dout_tvalid,m_axis_dout_tdata[31:0]" */;
  input aclk;
  input s_axis_cartesian_tvalid;
  input [31:0]s_axis_cartesian_tdata;
  output m_axis_dout_tvalid;
  output [31:0]m_axis_dout_tdata;
endmodule
