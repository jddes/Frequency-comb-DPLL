set_property SRC_FILE_INFO {cfile:d:/Repo/Frequency-comb-DPLL/Firmware_Vivado_Project/redpitaya.srcs/sources_1/ip/clk_10MHz_sync/clk_10MHz_sync.xdc rfile:../../../redpitaya.srcs/sources_1/ip/clk_10MHz_sync/clk_10MHz_sync.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
set_property src_info {type:SCOPED_XDC file:1 line:56 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.08
