@echo off
set xv_path=D:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xsim addr_packed_testbench_behav -key {Behavioral:sim_1:Functional:addr_packed_testbench} -tclbatch addr_packed_testbench.tcl -view D:/Users/Alex/Documents/GitHub/Frequency-comb-DPLL/Firmware Vivado Project/n_times_clk_fir_wrapper_testbench_behav.wcfg -view D:/Users/Alex/Documents/GitHub/Frequency-comb-DPLL/Firmware Vivado Project/system_identification_vna_with_dither_testbench_behav.wcfg -view D:/Users/Alex/Documents/GitHub/Frequency-comb-DPLL/Firmware Vivado Project/registers_read_testbench_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
