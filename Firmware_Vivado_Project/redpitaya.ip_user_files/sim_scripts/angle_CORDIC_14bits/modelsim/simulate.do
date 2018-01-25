onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -pli "D:/Xilinx/Vivado/2015.4/lib/win64.o/libxil_vsim.dll" -L secureip -L xbip_utils_v3_0_5 -L c_reg_fd_v12_0_1 -L xbip_dsp48_wrapper_v3_0_4 -L xbip_pipe_v3_0_1 -L xbip_dsp48_addsub_v3_0_1 -L xbip_addsub_v3_0_1 -L c_addsub_v12_0_8 -L xbip_bram18k_v3_0_1 -L mult_gen_v12_0_10 -L axi_utils_v2_0_1 -L cordic_v6_0_9 -L work -lib work work.angle_CORDIC_14bits

do {wave.do}

view wave
view structure
view signals

do {angle_CORDIC_14bits.udo}

run -all

quit -force
