onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -pli "D:/Xilinx/Vivado/2015.4/lib/win64.o/libxil_vsim.dll" -L secureip -L xbip_utils_v3_0_5 -L axi_utils_v2_0_1 -L xbip_pipe_v3_0_1 -L xbip_bram18k_v3_0_1 -L mult_gen_v12_0_10 -L xbip_dsp48_wrapper_v3_0_4 -L xbip_dsp48_addsub_v3_0_1 -L xbip_dsp48_multadd_v3_0_1 -L dds_compiler_v6_0_11 -L work -lib work work.Ref_generator_DDS_2

do {wave.do}

view wave
view structure
view signals

do {Ref_generator_DDS_2.udo}

run -all

quit -force
