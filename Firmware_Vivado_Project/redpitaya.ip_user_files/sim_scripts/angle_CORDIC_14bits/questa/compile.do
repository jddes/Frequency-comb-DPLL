vlib work
vlib msim

vlib msim/xbip_utils_v3_0_5
vlib msim/c_reg_fd_v12_0_1
vlib msim/xbip_dsp48_wrapper_v3_0_4
vlib msim/xbip_pipe_v3_0_1
vlib msim/xbip_dsp48_addsub_v3_0_1
vlib msim/xbip_addsub_v3_0_1
vlib msim/c_addsub_v12_0_8
vlib msim/xbip_bram18k_v3_0_1
vlib msim/mult_gen_v12_0_10
vlib msim/axi_utils_v2_0_1
vlib msim/cordic_v6_0_9
vlib msim/work

vmap xbip_utils_v3_0_5 msim/xbip_utils_v3_0_5
vmap c_reg_fd_v12_0_1 msim/c_reg_fd_v12_0_1
vmap xbip_dsp48_wrapper_v3_0_4 msim/xbip_dsp48_wrapper_v3_0_4
vmap xbip_pipe_v3_0_1 msim/xbip_pipe_v3_0_1
vmap xbip_dsp48_addsub_v3_0_1 msim/xbip_dsp48_addsub_v3_0_1
vmap xbip_addsub_v3_0_1 msim/xbip_addsub_v3_0_1
vmap c_addsub_v12_0_8 msim/c_addsub_v12_0_8
vmap xbip_bram18k_v3_0_1 msim/xbip_bram18k_v3_0_1
vmap mult_gen_v12_0_10 msim/mult_gen_v12_0_10
vmap axi_utils_v2_0_1 msim/axi_utils_v2_0_1
vmap cordic_v6_0_9 msim/cordic_v6_0_9
vmap work msim/work

vcom -work xbip_utils_v3_0_5 -64 \
"../../../ipstatic/xbip_utils_v3_0_5/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work c_reg_fd_v12_0_1 -64 \
"../../../ipstatic/c_reg_fd_v12_0_1/hdl/c_reg_fd_v12_0_vh_rfs.vhd" \
"../../../ipstatic/c_reg_fd_v12_0_1/hdl/c_reg_fd_v12_0.vhd" \

vcom -work xbip_dsp48_wrapper_v3_0_4 -64 \
"../../../ipstatic/xbip_dsp48_wrapper_v3_0_4/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_1 -64 \
"../../../ipstatic/xbip_pipe_v3_0_1/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \
"../../../ipstatic/xbip_pipe_v3_0_1/hdl/xbip_pipe_v3_0.vhd" \

vcom -work xbip_dsp48_addsub_v3_0_1 -64 \
"../../../ipstatic/xbip_dsp48_addsub_v3_0_1/hdl/xbip_dsp48_addsub_v3_0_vh_rfs.vhd" \
"../../../ipstatic/xbip_dsp48_addsub_v3_0_1/hdl/xbip_dsp48_addsub_v3_0.vhd" \

vcom -work xbip_addsub_v3_0_1 -64 \
"../../../ipstatic/xbip_addsub_v3_0_1/hdl/xbip_addsub_v3_0_vh_rfs.vhd" \
"../../../ipstatic/xbip_addsub_v3_0_1/hdl/xbip_addsub_v3_0.vhd" \

vcom -work c_addsub_v12_0_8 -64 \
"../../../ipstatic/c_addsub_v12_0_8/hdl/c_addsub_v12_0_vh_rfs.vhd" \
"../../../ipstatic/c_addsub_v12_0_8/hdl/c_addsub_v12_0.vhd" \

vcom -work xbip_bram18k_v3_0_1 -64 \
"../../../ipstatic/xbip_bram18k_v3_0_1/hdl/xbip_bram18k_v3_0_vh_rfs.vhd" \
"../../../ipstatic/xbip_bram18k_v3_0_1/hdl/xbip_bram18k_v3_0.vhd" \

vcom -work mult_gen_v12_0_10 -64 \
"../../../ipstatic/mult_gen_v12_0_10/hdl/mult_gen_v12_0_vh_rfs.vhd" \
"../../../ipstatic/mult_gen_v12_0_10/hdl/mult_gen_v12_0.vhd" \

vcom -work axi_utils_v2_0_1 -64 \
"../../../ipstatic/axi_utils_v2_0_1/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work cordic_v6_0_9 -64 \
"../../../ipstatic/cordic_v6_0_9/hdl/cordic_v6_0_vh_rfs.vhd" \
"../../../ipstatic/cordic_v6_0_9/hdl/cordic_v6_0.vhd" \

vcom -work work -64 \
"../../../../redpitaya.srcs/sources_1/ip/angle_CORDIC_14bits/sim/angle_CORDIC_14bits.vhd" \

