onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -pli "D:/Xilinx/Vivado/2015.4/lib/win64.o/libxil_vsim.dll" -lib work complex_mult_16x16_opt

do {wave.do}

view wave
view structure
view signals

do {complex_mult_16x16.udo}

run -all

quit -force
