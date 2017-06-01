onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -pli "/opt/Xilinx/Vivado/2015.4/lib/lnx64.o/libxil_vsim.so" -L secureip -L fifo_generator_v13_0_1 -L work -lib work work.fifo_generator_0

do {wave.do}

view wave
view structure
view signals

do {fifo_generator_0.udo}

run -all

quit -force
