@echo off
set xv_path=D:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xsim max5541_spi_dac_interface_testbench_behav -key {Behavioral:sim_3_max5541_spi_dac:Functional:max5541_spi_dac_interface_testbench} -tclbatch max5541_spi_dac_interface_testbench.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
