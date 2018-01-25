onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -pli "D:/Xilinx/Vivado/2015.4/lib/win64.o/libxil_vsim.dll" -lib work angle_CORDIC_14bits_opt

do {wave.do}

view wave
view structure
view signals

do {angle_CORDIC_14bits.udo}

run -all

quit -force
