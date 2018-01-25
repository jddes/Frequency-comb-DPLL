vlib work
vlib msim

vlib msim/fifo_generator_v13_0_1
vlib msim/work

vmap fifo_generator_v13_0_1 msim/fifo_generator_v13_0_1
vmap work msim/work

vcom -work fifo_generator_v13_0_1 -64 -93 \
"../../../ipstatic/fifo_generator_v13_0_1/simulation/fifo_generator_vhdl_beh.vhd" \
"../../../ipstatic/fifo_generator_v13_0_1/hdl/fifo_generator_v13_0_rfs.vhd" \

vcom -work work -64 -93 \
"../../../../redpitaya.srcs/sources_1/ip/FIFO_addr_packed/sim/FIFO_addr_packed.vhd" \

