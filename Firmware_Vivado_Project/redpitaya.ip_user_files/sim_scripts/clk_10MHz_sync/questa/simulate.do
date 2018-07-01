onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -pli "C:/Xilinx/Vivado/2015.4/lib/win64.o/libxil_vsim.dll" -lib work clk_10MHz_sync_opt

do {wave.do}

view wave
view structure
view signals

do {clk_10MHz_sync.udo}

run -all

quit -force
