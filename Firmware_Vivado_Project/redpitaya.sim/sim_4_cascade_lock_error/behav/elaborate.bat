@echo off
set xv_path=D:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xelab  -wto 55fbcb833fab42aea5d71afd7d8d1644 -m64 --debug typical --relax --mt 2 -L work -L secureip --snapshot cascade_lock_error_formatter_testbench_behav work.cascade_lock_error_formatter_testbench -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
