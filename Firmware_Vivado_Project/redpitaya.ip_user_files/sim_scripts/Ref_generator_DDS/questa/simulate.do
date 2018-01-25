onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -pli "D:/Xilinx/Vivado/2015.4/lib/win64.o/libxil_vsim.dll" -lib work Ref_generator_DDS_opt

do {wave.do}

view wave
view structure
view signals

do {Ref_generator_DDS.udo}

run -all

quit -force
