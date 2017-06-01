proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  set_property design_mode GateLvl [current_fileset]
  set_property webtalk.parent_dir D:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.cache/wt [current_project]
  set_property parent.project_path D:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.xpr [current_project]
  set_property ip_repo_paths d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.cache/ip [current_project]
  set_property ip_output_repo d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.cache/ip [current_project]
  add_files -quiet D:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.runs/synth_1/red_pitaya_top.dcp
  add_files -quiet d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/LO_DDS/LO_DDS.dcp
  set_property netlist_only true [get_files d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/LO_DDS/LO_DDS.dcp]
  add_files -quiet D:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.runs/angle_CORDIC_synth_1/angle_CORDIC.dcp
  set_property netlist_only true [get_files D:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.runs/angle_CORDIC_synth_1/angle_CORDIC.dcp]
  add_files -quiet D:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.runs/input_multiplier_synth_1/input_multiplier.dcp
  set_property netlist_only true [get_files D:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.runs/input_multiplier_synth_1/input_multiplier.dcp]
  add_files -quiet D:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.runs/pll_32x32_mult_ii_synth_1/pll_32x32_mult_ii.dcp
  set_property netlist_only true [get_files D:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.runs/pll_32x32_mult_ii_synth_1/pll_32x32_mult_ii.dcp]
  add_files -quiet D:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.runs/pll_wide_mult_synth_1/pll_wide_mult.dcp
  set_property netlist_only true [get_files D:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.runs/pll_wide_mult_synth_1/pll_wide_mult.dcp]
  add_files -quiet D:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.runs/system_identification_outputgain_mult_synth_1/system_identification_outputgain_mult.dcp
  set_property netlist_only true [get_files D:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.runs/system_identification_outputgain_mult_synth_1/system_identification_outputgain_mult.dcp]
  add_files -quiet D:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.runs/fir_compiler_minimumphase_N_times_clk_synth_1/fir_compiler_minimumphase_N_times_clk.dcp
  set_property netlist_only true [get_files D:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.runs/fir_compiler_minimumphase_N_times_clk_synth_1/fir_compiler_minimumphase_N_times_clk.dcp]
  add_files -quiet D:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.runs/fifo_generator_0_synth_1/fifo_generator_0.dcp
  set_property netlist_only true [get_files D:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.runs/fifo_generator_0_synth_1/fifo_generator_0.dcp]
  read_xdc -prop_thru_buffers -ref system_proc_sys_reset_0 d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/bd/system/ip/system_proc_sys_reset_0/system_proc_sys_reset_0_board.xdc
  set_property processing_order EARLY [get_files d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/bd/system/ip/system_proc_sys_reset_0/system_proc_sys_reset_0_board.xdc]
  read_xdc -ref system_proc_sys_reset_0 d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/bd/system/ip/system_proc_sys_reset_0/system_proc_sys_reset_0.xdc
  set_property processing_order EARLY [get_files d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/bd/system/ip/system_proc_sys_reset_0/system_proc_sys_reset_0.xdc]
  read_xdc -ref system_processing_system7_0 -cells inst d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/bd/system/ip/system_processing_system7_0/system_processing_system7_0.xdc
  set_property processing_order EARLY [get_files d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/bd/system/ip/system_processing_system7_0/system_processing_system7_0.xdc]
  read_xdc -ref system_xadc_0 -cells inst d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/bd/system/ip/system_xadc_0/system_xadc_0.xdc
  set_property processing_order EARLY [get_files d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/bd/system/ip/system_xadc_0/system_xadc_0.xdc]
  read_xdc -mode out_of_context -ref angle_CORDIC -cells U0 d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/angle_CORDIC/angle_CORDIC_ooc.xdc
  set_property processing_order EARLY [get_files d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/angle_CORDIC/angle_CORDIC_ooc.xdc]
  read_xdc -mode out_of_context -ref input_multiplier -cells U0 d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/input_multiplier/input_multiplier_ooc.xdc
  set_property processing_order EARLY [get_files d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/input_multiplier/input_multiplier_ooc.xdc]
  read_xdc -mode out_of_context -ref pll_32x32_mult_ii -cells U0 d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/pll_32x32_mult_ii/pll_32x32_mult_ii_ooc.xdc
  set_property processing_order EARLY [get_files d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/pll_32x32_mult_ii/pll_32x32_mult_ii_ooc.xdc]
  read_xdc -mode out_of_context -ref pll_wide_mult -cells U0 d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/pll_wide_mult/pll_wide_mult_ooc.xdc
  set_property processing_order EARLY [get_files d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/pll_wide_mult/pll_wide_mult_ooc.xdc]
  read_xdc -mode out_of_context -ref system_identification_outputgain_mult -cells U0 d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/system_identification_outputgain_mult/system_identification_outputgain_mult_ooc.xdc
  set_property processing_order EARLY [get_files d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/system_identification_outputgain_mult/system_identification_outputgain_mult_ooc.xdc]
  read_xdc -mode out_of_context -ref fir_compiler_minimumphase_N_times_clk -cells U0 d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/fir_compiler_minimumphase_N_times_clk/fir_compiler_minimumphase_N_times_clk_ooc.xdc
  set_property processing_order EARLY [get_files d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/fir_compiler_minimumphase_N_times_clk/fir_compiler_minimumphase_N_times_clk_ooc.xdc]
  read_xdc -ref fir_compiler_minimumphase_N_times_clk -cells U0 d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/fir_compiler_minimumphase_N_times_clk/fir_compiler_v7_2_5/constraints/fir_compiler_v7_2.xdc
  set_property processing_order EARLY [get_files d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/fir_compiler_minimumphase_N_times_clk/fir_compiler_v7_2_5/constraints/fir_compiler_v7_2.xdc]
  read_xdc -mode out_of_context -ref fifo_generator_0 -cells U0 d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/fifo_generator_0/fifo_generator_0_ooc.xdc
  set_property processing_order EARLY [get_files d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/fifo_generator_0/fifo_generator_0_ooc.xdc]
  read_xdc -ref fifo_generator_0 -cells U0 d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/fifo_generator_0/fifo_generator_0/fifo_generator_0.xdc
  set_property processing_order EARLY [get_files d:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/sources_1/ip/fifo_generator_0/fifo_generator_0/fifo_generator_0.xdc]
  read_xdc D:/Projets_Xilinx/RedPitayaLink/fpga/project/redpitaya.srcs/constrs_1/imports/sdc/red_pitaya.xdc
  link_design -top red_pitaya_top -part xc7z010clg400-1
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  catch {write_debug_probes -quiet -force debug_nets}
  opt_design 
  write_checkpoint -force red_pitaya_top_opt.dcp
  report_drc -file red_pitaya_top_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  catch {write_hwdef -file red_pitaya_top.hwdef}
  place_design 
  write_checkpoint -force red_pitaya_top_placed.dcp
  report_io -file red_pitaya_top_io_placed.rpt
  report_utilization -file red_pitaya_top_utilization_placed.rpt -pb red_pitaya_top_utilization_placed.pb
  report_control_sets -verbose -file red_pitaya_top_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force red_pitaya_top_routed.dcp
  report_drc -file red_pitaya_top_drc_routed.rpt -pb red_pitaya_top_drc_routed.pb
  report_timing_summary -warn_on_violation -max_paths 10 -file red_pitaya_top_timing_summary_routed.rpt -rpx red_pitaya_top_timing_summary_routed.rpx
  report_power -file red_pitaya_top_power_routed.rpt -pb red_pitaya_top_power_summary_routed.pb
  report_route_status -file red_pitaya_top_route_status.rpt -pb red_pitaya_top_route_status.pb
  report_clock_utilization -file red_pitaya_top_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  catch { write_mem_info -force red_pitaya_top.mmi }
  write_bitstream -force red_pitaya_top.bit 
  catch { write_sysdef -hwdef red_pitaya_top.hwdef -bitfile red_pitaya_top.bit -meminfo red_pitaya_top.mmi -file red_pitaya_top.sysdef }
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

