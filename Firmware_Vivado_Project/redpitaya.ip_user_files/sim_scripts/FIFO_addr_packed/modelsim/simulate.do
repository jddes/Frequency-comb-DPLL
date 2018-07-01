onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -pli "D:/Xilinx/Vivado/2015.4/lib/win64.o/libxil_vsim.dll" -L secureip -L fifo_generator_v13_0_1 -L work -lib work work.FIFO_addr_packed

do {wave.do}

view wave
view structure
view signals

do {FIFO_addr_packed.udo}

run -all

quit -force
