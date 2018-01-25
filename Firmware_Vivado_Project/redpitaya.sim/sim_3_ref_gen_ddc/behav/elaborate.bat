@echo off
set xv_path=D:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xelab  -wto 55fbcb833fab42aea5d71afd7d8d1644 -m64 --debug typical --relax --mt 2 -L work -L xbip_utils_v3_0_5 -L axi_utils_v2_0_1 -L xbip_pipe_v3_0_1 -L xbip_bram18k_v3_0_1 -L mult_gen_v12_0_10 -L xbip_dsp48_wrapper_v3_0_4 -L xbip_dsp48_addsub_v3_0_1 -L xbip_dsp48_multadd_v3_0_1 -L dds_compiler_v6_0_11 -L xil_defaultlib -L cmpy_v6_0_10 -L c_reg_fd_v12_0_1 -L xbip_addsub_v3_0_1 -L c_addsub_v12_0_8 -L cordic_v6_0_9 -L secureip --snapshot ddc_external_ref_generator_testbench_behav work.ddc_external_ref_generator_testbench -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
