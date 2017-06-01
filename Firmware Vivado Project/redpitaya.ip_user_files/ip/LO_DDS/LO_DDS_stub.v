// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (lin64) Build 1412921 Wed Nov 18 09:44:32 MST 2015
// Date        : Fri Jan 15 01:31:10 2016
// Host        : jd-VirtualBox running 64-bit Ubuntu 14.04.3 LTS
// Command     : write_verilog -force -mode synth_stub
//               /media/sf_D/Projets_Xilinx/digital_servo_fpga_firmware/dpll_firmware_redpitaya/dpll_firmware_redpitaya.runs/LO_DDS_synth_1/LO_DDS_stub.v
// Design      : LO_DDS
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dds_compiler_v6_0_11,Vivado 2015.4" *)
module LO_DDS(aclk, s_axis_phase_tvalid, s_axis_phase_tdata, m_axis_data_tvalid, m_axis_data_tdata, m_axis_phase_tvalid, m_axis_phase_tdata)
/* synthesis syn_black_box black_box_pad_pin="aclk,s_axis_phase_tvalid,s_axis_phase_tdata[47:0],m_axis_data_tvalid,m_axis_data_tdata[31:0],m_axis_phase_tvalid,m_axis_phase_tdata[47:0]" */;
  input aclk;
  input s_axis_phase_tvalid;
  input [47:0]s_axis_phase_tdata;
  output m_axis_data_tvalid;
  output [31:0]m_axis_data_tdata;
  output m_axis_phase_tvalid;
  output [47:0]m_axis_phase_tdata;
endmodule
