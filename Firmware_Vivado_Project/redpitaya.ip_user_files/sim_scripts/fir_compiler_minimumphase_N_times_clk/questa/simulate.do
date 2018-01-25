onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -pli "/opt/Xilinx/Vivado/2015.4/lib/lnx64.o/libxil_vsim.so" -lib work fir_compiler_minimumphase_N_times_clk_opt

do {wave.do}

view wave
view structure
view signals

do {fir_compiler_minimumphase_N_times_clk.udo}

run -all

quit -force
