@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xelab  -wto 55fbcb833fab42aea5d71afd7d8d1644 -m64 --debug typical --relax --mt 2 -L xbip_utils_v3_0_5 -L axi_utils_v2_0_1 -L fir_compiler_v7_2_5 -L work -L secureip --snapshot ddc_frontend_lowpass_filter_testbench_behav work.ddc_frontend_lowpass_filter_testbench -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
