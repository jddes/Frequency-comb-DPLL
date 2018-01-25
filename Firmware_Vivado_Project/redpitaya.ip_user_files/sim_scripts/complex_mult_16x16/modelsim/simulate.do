onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -pli "D:/Xilinx/Vivado/2015.4/lib/win64.o/libxil_vsim.dll" -L secureip -L xbip_utils_v3_0_5 -L axi_utils_v2_0_1 -L xbip_pipe_v3_0_1 -L xbip_bram18k_v3_0_1 -L mult_gen_v12_0_10 -L cmpy_v6_0_10 -L work -lib work work.complex_mult_16x16

do {wave.do}

view wave
view structure
view signals

do {complex_mult_16x16.udo}

run -all

quit -force
