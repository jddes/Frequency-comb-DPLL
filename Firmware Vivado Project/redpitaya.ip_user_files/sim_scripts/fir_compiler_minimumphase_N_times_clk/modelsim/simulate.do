onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -pli "/opt/Xilinx/Vivado/2015.4/lib/lnx64.o/libxil_vsim.so" -L secureip -L xbip_utils_v3_0_5 -L axi_utils_v2_0_1 -L fir_compiler_v7_2_5 -L xil_defaultlib -lib work xil_defaultlib.fir_compiler_minimumphase_N_times_clk

do {wave.do}

view wave
view structure
view signals

do {fir_compiler_minimumphase_N_times_clk.udo}

run -all

quit -force
