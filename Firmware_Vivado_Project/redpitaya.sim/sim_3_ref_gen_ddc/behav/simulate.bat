@echo off
set xv_path=D:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xsim ddc_external_ref_generator_testbench_behav -key {Behavioral:sim_3_ref_gen_ddc:Functional:ddc_external_ref_generator_testbench} -tclbatch ddc_external_ref_generator_testbench.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
