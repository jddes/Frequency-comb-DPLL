@echo off
set xv_path=D:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xsim ddc_frontend_lowpass_filter_testbench_behav -key {Behavioral:sim_1:Functional:ddc_frontend_lowpass_filter_testbench} -tclbatch ddc_frontend_lowpass_filter_testbench.tcl -view D:/Projets_Xilinx/RedPitayaLink/fpga/project/n_times_clk_fir_wrapper_testbench_behav.wcfg -view D:/Projets_Xilinx/RedPitayaLink/fpga/project/system_identification_vna_with_dither_testbench_behav.wcfg -view D:/Projets_Xilinx/RedPitayaLink/fpga/project/registers_read_testbench_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
