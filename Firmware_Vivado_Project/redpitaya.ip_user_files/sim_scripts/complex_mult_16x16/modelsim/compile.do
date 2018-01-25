vlib work
vlib msim

vlib msim/xbip_utils_v3_0_5
vlib msim/axi_utils_v2_0_1
vlib msim/xbip_pipe_v3_0_1
vlib msim/xbip_bram18k_v3_0_1
vlib msim/mult_gen_v12_0_10
vlib msim/cmpy_v6_0_10
vlib msim/work

vmap xbip_utils_v3_0_5 msim/xbip_utils_v3_0_5
vmap axi_utils_v2_0_1 msim/axi_utils_v2_0_1
vmap xbip_pipe_v3_0_1 msim/xbip_pipe_v3_0_1
vmap xbip_bram18k_v3_0_1 msim/xbip_bram18k_v3_0_1
vmap mult_gen_v12_0_10 msim/mult_gen_v12_0_10
vmap cmpy_v6_0_10 msim/cmpy_v6_0_10
vmap work msim/work

vcom -work xbip_utils_v3_0_5 -64 -93 \
"../../../ipstatic/xbip_utils_v3_0_5/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_1 -64 -93 \
"../../../ipstatic/axi_utils_v2_0_1/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_1 -64 -93 \
"../../../ipstatic/xbip_pipe_v3_0_1/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \
"../../../ipstatic/xbip_pipe_v3_0_1/hdl/xbip_pipe_v3_0.vhd" \

vcom -work xbip_bram18k_v3_0_1 -64 -93 \
"../../../ipstatic/xbip_bram18k_v3_0_1/hdl/xbip_bram18k_v3_0_vh_rfs.vhd" \
"../../../ipstatic/xbip_bram18k_v3_0_1/hdl/xbip_bram18k_v3_0.vhd" \

vcom -work mult_gen_v12_0_10 -64 -93 \
"../../../ipstatic/mult_gen_v12_0_10/hdl/mult_gen_v12_0_vh_rfs.vhd" \
"../../../ipstatic/mult_gen_v12_0_10/hdl/mult_gen_v12_0.vhd" \

vcom -work cmpy_v6_0_10 -64 -93 \
"../../../ipstatic/cmpy_v6_0_10/hdl/cmpy_v6_0_vh_rfs.vhd" \
"../../../ipstatic/cmpy_v6_0_10/hdl/cmpy_v6_0.vhd" \

vcom -work work -64 -93 \
"../../../../redpitaya.srcs/sources_1/ip/complex_mult_16x16/sim/complex_mult_16x16.vhd" \

