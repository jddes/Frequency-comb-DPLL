onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -pli "C:/Xilinx/Vivado/2015.4/lib/win64.o/libxil_vsim.dll" -L unisims_ver -L unimacro_ver -L secureip -L work -lib work work.clk_10MHz_sync work.glbl

do {wave.do}

view wave
view structure
view signals

do {clk_10MHz_sync.udo}

run -all

quit -force
