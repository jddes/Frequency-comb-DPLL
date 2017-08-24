@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xelab  -wto 55fbcb833fab42aea5d71afd7d8d1644 -m64 --debug typical --relax --mt 2 -L work -L secureip --snapshot frequency_testbench_behav work.frequency_testbench -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
