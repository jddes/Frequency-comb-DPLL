// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Jan 30 05:14:25 2018
// Host        : jdbureau running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               D:/Repo/Frequency-comb-DPLL/Firmware_Vivado_Project/redpitaya.srcs/sources_1/ip/Ref_generator_DDS_2/Ref_generator_DDS_2_stub.v
// Design      : Ref_generator_DDS_2
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dds_compiler_v6_0_11,Vivado 2015.4" *)
module Ref_generator_DDS_2(aclk, s_axis_phase_tvalid, s_axis_phase_tdata, m_axis_data_tvalid, m_axis_data_tdata)
/* synthesis syn_black_box black_box_pad_pin="aclk,s_axis_phase_tvalid,s_axis_phase_tdata[15:0],m_axis_data_tvalid,m_axis_data_tdata[31:0]" */;
  input aclk;
  input s_axis_phase_tvalid;
  input [15:0]s_axis_phase_tdata;
  output m_axis_data_tvalid;
  output [31:0]m_axis_data_tdata;
endmodule
