@echo off
set xv_path=D:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xsim lock_on_trigger_testbench_behav -key {Behavioral:sim_3_triglock:Functional:lock_on_trigger_testbench} -tclbatch lock_on_trigger_testbench.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
