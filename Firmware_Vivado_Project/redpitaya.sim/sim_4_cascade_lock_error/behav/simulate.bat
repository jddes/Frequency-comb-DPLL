@echo off
set xv_path=D:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xsim cascade_lock_error_formatter_testbench_behav -key {Behavioral:sim_4_cascade_lock_error:Functional:cascade_lock_error_formatter_testbench} -tclbatch cascade_lock_error_formatter_testbench.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
