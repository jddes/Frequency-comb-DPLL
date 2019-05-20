
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z010clg400-1

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}



# CHANGE DESIGN NAME HERE
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set M_AXI_GP0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_GP0 ]
  set_property -dict [ list \
CONFIG.ADDR_WIDTH {32} \
CONFIG.DATA_WIDTH {32} \
CONFIG.FREQ_HZ {125000000} \
CONFIG.PROTOCOL {AXI3} \
 ] $M_AXI_GP0
  set S_AXI_HP0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_HP0 ]
  set_property -dict [ list \
CONFIG.ADDR_WIDTH {32} \
CONFIG.ARUSER_WIDTH {0} \
CONFIG.AWUSER_WIDTH {0} \
CONFIG.BUSER_WIDTH {0} \
CONFIG.DATA_WIDTH {64} \
CONFIG.HAS_BRESP {1} \
CONFIG.HAS_BURST {1} \
CONFIG.HAS_CACHE {1} \
CONFIG.HAS_LOCK {1} \
CONFIG.HAS_PROT {1} \
CONFIG.HAS_QOS {1} \
CONFIG.HAS_REGION {1} \
CONFIG.HAS_RRESP {1} \
CONFIG.HAS_WSTRB {1} \
CONFIG.ID_WIDTH {0} \
CONFIG.MAX_BURST_LENGTH {16} \
CONFIG.NUM_READ_OUTSTANDING {1} \
CONFIG.NUM_WRITE_OUTSTANDING {1} \
CONFIG.PROTOCOL {AXI3} \
CONFIG.READ_WRITE_MODE {READ_WRITE} \
CONFIG.RUSER_WIDTH {0} \
CONFIG.SUPPORTS_NARROW_BURST {1} \
CONFIG.WUSER_WIDTH {0} \
 ] $S_AXI_HP0
  set S_AXI_HP1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_HP1 ]
  set_property -dict [ list \
CONFIG.ADDR_WIDTH {32} \
CONFIG.ARUSER_WIDTH {0} \
CONFIG.AWUSER_WIDTH {0} \
CONFIG.BUSER_WIDTH {0} \
CONFIG.DATA_WIDTH {64} \
CONFIG.HAS_BRESP {1} \
CONFIG.HAS_BURST {1} \
CONFIG.HAS_CACHE {1} \
CONFIG.HAS_LOCK {1} \
CONFIG.HAS_PROT {1} \
CONFIG.HAS_QOS {1} \
CONFIG.HAS_REGION {1} \
CONFIG.HAS_RRESP {1} \
CONFIG.HAS_WSTRB {1} \
CONFIG.ID_WIDTH {0} \
CONFIG.MAX_BURST_LENGTH {16} \
CONFIG.NUM_READ_OUTSTANDING {1} \
CONFIG.NUM_WRITE_OUTSTANDING {1} \
CONFIG.PROTOCOL {AXI3} \
CONFIG.READ_WRITE_MODE {READ_WRITE} \
CONFIG.RUSER_WIDTH {0} \
CONFIG.SUPPORTS_NARROW_BURST {1} \
CONFIG.WUSER_WIDTH {0} \
 ] $S_AXI_HP1
  set Vaux0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux0 ]
  set Vaux1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux1 ]
  set Vaux8 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux8 ]
  set Vaux9 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux9 ]
  set Vp_Vn [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vp_Vn ]

  # Create ports
  set FCLK_CLK0 [ create_bd_port -dir O -type clk FCLK_CLK0 ]
  set FCLK_CLK1 [ create_bd_port -dir O -type clk FCLK_CLK1 ]
  set FCLK_CLK2 [ create_bd_port -dir O -type clk FCLK_CLK2 ]
  set FCLK_CLK3 [ create_bd_port -dir O -type clk FCLK_CLK3 ]
  set FCLK_RESET0_N [ create_bd_port -dir O -type rst FCLK_RESET0_N ]
  set FCLK_RESET1_N [ create_bd_port -dir O -type rst FCLK_RESET1_N ]
  set FCLK_RESET2_N [ create_bd_port -dir O -type rst FCLK_RESET2_N ]
  set FCLK_RESET3_N [ create_bd_port -dir O -type rst FCLK_RESET3_N ]
  set M_AXI_GP0_ACLK [ create_bd_port -dir I -type clk M_AXI_GP0_ACLK ]
  set_property -dict [ list \
CONFIG.ASSOCIATED_BUSIF {M_AXI_GP0} \
CONFIG.FREQ_HZ {125000000} \
 ] $M_AXI_GP0_ACLK
  set S_AXI_HP0_aclk [ create_bd_port -dir I -type clk S_AXI_HP0_aclk ]
  set_property -dict [ list \
CONFIG.FREQ_HZ {125000000} \
 ] $S_AXI_HP0_aclk
  set S_AXI_HP1_aclk [ create_bd_port -dir I -type clk S_AXI_HP1_aclk ]
  set_property -dict [ list \
CONFIG.FREQ_HZ {125000000} \
 ] $S_AXI_HP1_aclk
  set clk_ext_in [ create_bd_port -dir I -type clk clk_ext_in ]
  set_property -dict [ list \
CONFIG.FREQ_HZ {200000000} \
CONFIG.PHASE {0.000} \
 ] $clk_ext_in
  set clk_to_adc [ create_bd_port -dir O -type clk clk_to_adc ]
  set gpio_io_o [ create_bd_port -dir O -from 1 -to 0 gpio_io_o ]

  # Create instance: axi_gpio_clk_sel, and set properties
  set axi_gpio_clk_sel [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_clk_sel ]
  set_property -dict [ list \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_DOUT_DEFAULT {0x00000001} \
CONFIG.C_GPIO_WIDTH {2} \
 ] $axi_gpio_clk_sel

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
CONFIG.NUM_MI {3} \
CONFIG.S00_HAS_REGSLICE {3} \
 ] $axi_interconnect_0

  # Create instance: axi_protocol_converter_0, and set properties
  set axi_protocol_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_converter_0 ]

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.2 clk_wiz_0 ]
  set_property -dict [ list \
CONFIG.CLKIN1_JITTER_PS {10.000} \
CONFIG.CLKIN1_UI_JITTER {10.000} \
CONFIG.CLKIN2_JITTER_PS {10.000} \
CONFIG.CLKIN2_UI_JITTER {10.000} \
CONFIG.CLKOUT1_DRIVES {BUFGCE} \
CONFIG.CLKOUT1_JITTER {107.081} \
CONFIG.CLKOUT1_PHASE_ERROR {89.971} \
CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125} \
CONFIG.CLKOUT2_DRIVES {BUFGCE} \
CONFIG.CLKOUT3_DRIVES {BUFGCE} \
CONFIG.CLKOUT4_DRIVES {BUFGCE} \
CONFIG.CLKOUT5_DRIVES {BUFGCE} \
CONFIG.CLKOUT6_DRIVES {BUFGCE} \
CONFIG.CLKOUT7_DRIVES {BUFGCE} \
CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
CONFIG.JITTER_OPTIONS {PS} \
CONFIG.MMCM_CLKFBOUT_MULT_F {5.000} \
CONFIG.MMCM_CLKIN1_PERIOD {5.0} \
CONFIG.MMCM_CLKIN2_PERIOD {5.0} \
CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.000} \
CONFIG.MMCM_COMPENSATION {ZHOLD} \
CONFIG.MMCM_DIVCLK_DIVIDE {1} \
CONFIG.MMCM_REF_JITTER1 {0.002} \
CONFIG.MMCM_REF_JITTER2 {0.002} \
CONFIG.OVERRIDE_MMCM {false} \
CONFIG.PRIMITIVE {MMCM} \
CONFIG.PRIM_IN_FREQ {200} \
CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} \
CONFIG.SECONDARY_IN_FREQ {200} \
CONFIG.SECONDARY_SOURCE {Single_ended_clock_capable_pin} \
CONFIG.USE_DYN_RECONFIG {true} \
CONFIG.USE_INCLK_STOPPED {false} \
CONFIG.USE_INCLK_SWITCHOVER {true} \
CONFIG.USE_PHASE_ALIGNMENT {false} \
CONFIG.USE_SAFE_CLOCK_STARTUP {true} \
 ] $clk_wiz_0

  # Create instance: proc_sys_reset, and set properties
  set proc_sys_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset ]
  set_property -dict [ list \
CONFIG.C_EXT_RST_WIDTH {1} \
 ] $proc_sys_reset

  # Create instance: processing_system7, and set properties
  set processing_system7 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7 ]
  set_property -dict [ list \
CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_EN_CLK1_PORT {1} \
CONFIG.PCW_EN_CLK2_PORT {1} \
CONFIG.PCW_EN_CLK3_PORT {1} \
CONFIG.PCW_EN_RST1_PORT {1} \
CONFIG.PCW_EN_RST2_PORT {1} \
CONFIG.PCW_EN_RST3_PORT {1} \
CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {125} \
CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {250} \
CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {200} \
CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
CONFIG.PCW_I2C0_I2C0_IO {MIO 50 .. 51} \
CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_IRQ_F2P_INTR {1} \
CONFIG.PCW_MIO_16_PULLUP {disabled} \
CONFIG.PCW_MIO_16_SLEW {fast} \
CONFIG.PCW_MIO_17_PULLUP {disabled} \
CONFIG.PCW_MIO_17_SLEW {fast} \
CONFIG.PCW_MIO_18_PULLUP {disabled} \
CONFIG.PCW_MIO_18_SLEW {fast} \
CONFIG.PCW_MIO_19_PULLUP {disabled} \
CONFIG.PCW_MIO_19_SLEW {fast} \
CONFIG.PCW_MIO_20_PULLUP {disabled} \
CONFIG.PCW_MIO_20_SLEW {fast} \
CONFIG.PCW_MIO_21_PULLUP {disabled} \
CONFIG.PCW_MIO_21_SLEW {fast} \
CONFIG.PCW_MIO_22_PULLUP {disabled} \
CONFIG.PCW_MIO_22_SLEW {fast} \
CONFIG.PCW_MIO_23_PULLUP {disabled} \
CONFIG.PCW_MIO_23_SLEW {fast} \
CONFIG.PCW_MIO_24_PULLUP {disabled} \
CONFIG.PCW_MIO_24_SLEW {fast} \
CONFIG.PCW_MIO_25_PULLUP {disabled} \
CONFIG.PCW_MIO_25_SLEW {fast} \
CONFIG.PCW_MIO_26_PULLUP {disabled} \
CONFIG.PCW_MIO_26_SLEW {fast} \
CONFIG.PCW_MIO_27_PULLUP {disabled} \
CONFIG.PCW_MIO_27_SLEW {fast} \
CONFIG.PCW_MIO_28_PULLUP {disabled} \
CONFIG.PCW_MIO_28_SLEW {fast} \
CONFIG.PCW_MIO_29_PULLUP {disabled} \
CONFIG.PCW_MIO_29_SLEW {fast} \
CONFIG.PCW_MIO_30_PULLUP {disabled} \
CONFIG.PCW_MIO_30_SLEW {fast} \
CONFIG.PCW_MIO_31_PULLUP {disabled} \
CONFIG.PCW_MIO_31_SLEW {fast} \
CONFIG.PCW_MIO_32_PULLUP {disabled} \
CONFIG.PCW_MIO_32_SLEW {fast} \
CONFIG.PCW_MIO_33_PULLUP {disabled} \
CONFIG.PCW_MIO_33_SLEW {fast} \
CONFIG.PCW_MIO_34_PULLUP {disabled} \
CONFIG.PCW_MIO_34_SLEW {fast} \
CONFIG.PCW_MIO_35_PULLUP {disabled} \
CONFIG.PCW_MIO_35_SLEW {fast} \
CONFIG.PCW_MIO_36_PULLUP {disabled} \
CONFIG.PCW_MIO_36_SLEW {fast} \
CONFIG.PCW_MIO_37_PULLUP {disabled} \
CONFIG.PCW_MIO_37_SLEW {fast} \
CONFIG.PCW_MIO_38_PULLUP {disabled} \
CONFIG.PCW_MIO_38_SLEW {fast} \
CONFIG.PCW_MIO_39_PULLUP {disabled} \
CONFIG.PCW_MIO_39_SLEW {fast} \
CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 2.5V} \
CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {125} \
CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
CONFIG.PCW_SD0_GRP_CD_IO {MIO 46} \
CONFIG.PCW_SD0_GRP_WP_ENABLE {1} \
CONFIG.PCW_SD0_GRP_WP_IO {MIO 47} \
CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SPI1_SPI1_IO {MIO 10 .. 15} \
CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UART0_UART0_IO {MIO 14 .. 15} \
CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UART1_UART1_IO {MIO 8 .. 9} \
CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {16 Bit} \
CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M16 RE-125} \
CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_USB0_RESET_ENABLE {1} \
CONFIG.PCW_USB0_RESET_IO {MIO 48} \
CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
CONFIG.PCW_USE_M_AXI_GP1 {1} \
CONFIG.PCW_USE_S_AXI_HP0 {1} \
CONFIG.PCW_USE_S_AXI_HP1 {1} \
 ] $processing_system7

  # Create instance: util_ds_buf_0, and set properties
  set util_ds_buf_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_0 ]
  set_property -dict [ list \
CONFIG.C_BUF_TYPE {BUFG} \
 ] $util_ds_buf_0

  # Create instance: xadc, and set properties
  set xadc [ create_bd_cell -type ip -vlnv xilinx.com:ip:xadc_wiz:3.2 xadc ]
  set_property -dict [ list \
CONFIG.CHANNEL_ENABLE_VAUXP0_VAUXN0 {true} \
CONFIG.CHANNEL_ENABLE_VAUXP1_VAUXN1 {true} \
CONFIG.CHANNEL_ENABLE_VAUXP8_VAUXN8 {true} \
CONFIG.CHANNEL_ENABLE_VAUXP9_VAUXN9 {true} \
CONFIG.CHANNEL_ENABLE_VP_VN {true} \
CONFIG.ENABLE_AXI4STREAM {false} \
CONFIG.EXTERNAL_MUX_CHANNEL {VP_VN} \
CONFIG.SEQUENCER_MODE {Off} \
CONFIG.SINGLE_CHANNEL_SELECTION {TEMPERATURE} \
CONFIG.XADC_STARUP_SELECTION {independent_adc} \
 ] $xadc

  # Create instance: xlconstant, and set properties
  set xlconstant [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant ]

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [ list \
CONFIG.DIN_FROM {0} \
CONFIG.DIN_TO {0} \
CONFIG.DIN_WIDTH {2} \
 ] $xlslice_0

  # Create interface connections
  connect_bd_intf_net -intf_net Vaux0_1 [get_bd_intf_ports Vaux0] [get_bd_intf_pins xadc/Vaux0]
  connect_bd_intf_net -intf_net Vaux1_1 [get_bd_intf_ports Vaux1] [get_bd_intf_pins xadc/Vaux1]
  connect_bd_intf_net -intf_net Vaux8_1 [get_bd_intf_ports Vaux8] [get_bd_intf_pins xadc/Vaux8]
  connect_bd_intf_net -intf_net Vaux9_1 [get_bd_intf_ports Vaux9] [get_bd_intf_pins xadc/Vaux9]
  connect_bd_intf_net -intf_net Vp_Vn_1 [get_bd_intf_ports Vp_Vn] [get_bd_intf_pins xadc/Vp_Vn]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins clk_wiz_0/s_axi_lite]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins xadc/s_axi_lite]
  connect_bd_intf_net -intf_net axi_interconnect_0_M02_AXI [get_bd_intf_pins axi_gpio_clk_sel/S_AXI] [get_bd_intf_pins axi_interconnect_0/M02_AXI]
  connect_bd_intf_net -intf_net axi_protocol_converter_0_M_AXI [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins axi_protocol_converter_0/M_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_ports M_AXI_GP0] [get_bd_intf_pins processing_system7/M_AXI_GP0]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP1 [get_bd_intf_pins axi_protocol_converter_0/S_AXI] [get_bd_intf_pins processing_system7/M_AXI_GP1]
  connect_bd_intf_net -intf_net processing_system7_0_ddr [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_fixed_io [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7/FIXED_IO]
  connect_bd_intf_net -intf_net s_axi_hp0_1 [get_bd_intf_ports S_AXI_HP0] [get_bd_intf_pins processing_system7/S_AXI_HP0]
  connect_bd_intf_net -intf_net s_axi_hp1_1 [get_bd_intf_ports S_AXI_HP1] [get_bd_intf_pins processing_system7/S_AXI_HP1]

  # Create port connections
  connect_bd_net -net axi_gpio_clk_sel_gpio_io_o [get_bd_ports gpio_io_o] [get_bd_pins axi_gpio_clk_sel/gpio_io_o] [get_bd_pins xlslice_0/Din]
  connect_bd_net -net clk_ext_in_1 [get_bd_ports clk_ext_in] [get_bd_pins util_ds_buf_0/BUFG_I]
  connect_bd_net -net clk_wiz_0_clk_out1 [get_bd_ports clk_to_adc] [get_bd_pins clk_wiz_0/clk_out1]
  connect_bd_net -net m_axi_gp0_aclk_1 [get_bd_ports M_AXI_GP0_ACLK] [get_bd_pins processing_system7/M_AXI_GP0_ACLK]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_protocol_converter_0/aresetn] [get_bd_pins proc_sys_reset/interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins axi_gpio_clk_sel/s_axi_aresetn] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/M02_ARESETN] [get_bd_pins clk_wiz_0/s_axi_aresetn] [get_bd_pins proc_sys_reset/peripheral_aresetn] [get_bd_pins xadc/s_axi_aresetn]
  connect_bd_net -net processing_system7_0_fclk_clk0 [get_bd_ports FCLK_CLK0] [get_bd_pins processing_system7/FCLK_CLK0]
  connect_bd_net -net processing_system7_0_fclk_clk1 [get_bd_ports FCLK_CLK1] [get_bd_pins processing_system7/FCLK_CLK1]
  connect_bd_net -net processing_system7_0_fclk_clk2 [get_bd_ports FCLK_CLK2] [get_bd_pins processing_system7/FCLK_CLK2]
  connect_bd_net -net processing_system7_0_fclk_clk3 [get_bd_ports FCLK_CLK3] [get_bd_pins axi_gpio_clk_sel/s_axi_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/M02_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_protocol_converter_0/aclk] [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins clk_wiz_0/s_axi_aclk] [get_bd_pins proc_sys_reset/slowest_sync_clk] [get_bd_pins processing_system7/FCLK_CLK3] [get_bd_pins processing_system7/M_AXI_GP1_ACLK] [get_bd_pins xadc/s_axi_aclk]
  connect_bd_net -net processing_system7_0_fclk_reset0_n [get_bd_ports FCLK_RESET0_N] [get_bd_pins processing_system7/FCLK_RESET0_N]
  connect_bd_net -net processing_system7_0_fclk_reset1_n [get_bd_ports FCLK_RESET1_N] [get_bd_pins processing_system7/FCLK_RESET1_N]
  connect_bd_net -net processing_system7_0_fclk_reset2_n [get_bd_ports FCLK_RESET2_N] [get_bd_pins processing_system7/FCLK_RESET2_N]
  connect_bd_net -net processing_system7_0_fclk_reset3_n [get_bd_ports FCLK_RESET3_N] [get_bd_pins proc_sys_reset/ext_reset_in] [get_bd_pins processing_system7/FCLK_RESET3_N]
  connect_bd_net -net s_axi_hp0_aclk [get_bd_ports S_AXI_HP0_aclk] [get_bd_pins processing_system7/S_AXI_HP0_ACLK]
  connect_bd_net -net s_axi_hp1_aclk [get_bd_ports S_AXI_HP1_aclk] [get_bd_pins processing_system7/S_AXI_HP1_ACLK]
  connect_bd_net -net util_ds_buf_0_BUFG_O [get_bd_pins clk_wiz_0/clk_in2] [get_bd_pins util_ds_buf_0/BUFG_O]
  connect_bd_net -net xadc_wiz_0_ip2intc_irpt [get_bd_pins processing_system7/IRQ_F2P] [get_bd_pins xadc/ip2intc_irpt]
  connect_bd_net -net xlconstant_dout [get_bd_pins proc_sys_reset/aux_reset_in] [get_bd_pins xlconstant/dout]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins clk_wiz_0/clk_in_sel] [get_bd_pins xlslice_0/Dout]

  # Create address segments
  create_bd_addr_seg -range 0x10000 -offset 0x80030000 [get_bd_addr_spaces processing_system7/Data] [get_bd_addr_segs axi_gpio_clk_sel/S_AXI/Reg] SEG_axi_gpio_clk_sel_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x80020000 [get_bd_addr_spaces processing_system7/Data] [get_bd_addr_segs clk_wiz_0/s_axi_lite/Reg] SEG_clk_wiz_0_Reg
  create_bd_addr_seg -range 0x40000000 -offset 0x40000000 [get_bd_addr_spaces processing_system7/Data] [get_bd_addr_segs M_AXI_GP0/Reg] SEG_system_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x80010000 [get_bd_addr_spaces processing_system7/Data] [get_bd_addr_segs xadc/s_axi_lite/Reg] SEG_xadc_Reg
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces S_AXI_HP0] [get_bd_addr_segs processing_system7/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces S_AXI_HP1] [get_bd_addr_segs processing_system7/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.5  2015-06-26 bk=1.3371 VDI=38 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port FCLK_CLK3 -pg 1 -y 250 -defaultsOSRD
preplace port S_AXI_HP1 -pg 1 -y 160 -defaultsOSRD
preplace port DDR -pg 1 -y 30 -defaultsOSRD
preplace port Vp_Vn -pg 1 -y 870 -defaultsOSRD
preplace port clk_ext_in -pg 1 -y 1060 -defaultsOSRD
preplace port Vaux0 -pg 1 -y 890 -defaultsOSRD
preplace port FCLK_RESET0_N -pg 1 -y 270 -defaultsOSRD
preplace port M_AXI_GP0_ACLK -pg 1 -y 180 -defaultsOSRD
preplace port Vaux1 -pg 1 -y 910 -defaultsOSRD
preplace port S_AXI_HP0_aclk -pg 1 -y 220 -defaultsOSRD
preplace port M_AXI_GP0 -pg 1 -y 90 -defaultsOSRD
preplace port FCLK_RESET1_N -pg 1 -y 290 -defaultsOSRD
preplace port S_AXI_HP1_aclk -pg 1 -y 240 -defaultsOSRD
preplace port FCLK_RESET3_N -pg 1 -y 330 -defaultsOSRD
preplace port FIXED_IO -pg 1 -y 50 -defaultsOSRD
preplace port FCLK_RESET2_N -pg 1 -y 310 -defaultsOSRD
preplace port FCLK_CLK0 -pg 1 -y 190 -defaultsOSRD
preplace port clk_to_adc -pg 1 -y 1090 -defaultsOSRD
preplace port FCLK_CLK1 -pg 1 -y 210 -defaultsOSRD
preplace port Vaux8 -pg 1 -y 930 -defaultsOSRD
preplace port FCLK_CLK2 -pg 1 -y 230 -defaultsOSRD
preplace port Vaux9 -pg 1 -y 950 -defaultsOSRD
preplace port S_AXI_HP0 -pg 1 -y 140 -defaultsOSRD
preplace portBus gpio_io_o -pg 1 -y 740 -defaultsOSRD
preplace inst xlslice_0 -pg 1 -lvl 4 -y 1150 -defaultsOSRD
preplace inst xlconstant -pg 1 -lvl 1 -y 620 -defaultsOSRD
preplace inst axi_protocol_converter_0 -pg 1 -lvl 3 -y 420 -defaultsOSRD
preplace inst axi_gpio_clk_sel -pg 1 -lvl 4 -y 480 -defaultsOSRD
preplace inst processing_system7 -pg 1 -lvl 3 -y 160 -defaultsOSRD
preplace inst axi_interconnect_0 -pg 1 -lvl 4 -y 270 -defaultsOSRD
preplace inst xadc -pg 1 -lvl 3 -y 920 -defaultsOSRD
preplace inst clk_wiz_0 -pg 1 -lvl 5 -y 1100 -defaultsOSRD
preplace inst util_ds_buf_0 -pg 1 -lvl 2 -y 1110 -defaultsOSRD
preplace inst proc_sys_reset -pg 1 -lvl 3 -y 650 -defaultsOSRD
preplace netloc Vaux0_1 1 0 3 NJ 890 NJ 890 N
preplace netloc processing_system7_0_ddr 1 3 3 N 10 NJ 10 NJ
preplace netloc processing_system7_0_fclk_reset3_n 1 2 4 20 550 480 580 NJ 330 N
preplace netloc s_axi_hp0_1 1 0 3 NJ 120 N 120 N
preplace netloc clk_ext_in_1 1 0 2 NJ 1060 -270
preplace netloc processing_system7_0_fclk_reset2_n 1 3 3 500 570 NJ 310 NJ
preplace netloc processing_system7_0_M_AXI_GP0 1 3 3 N 70 NJ 90 NJ
preplace netloc xlconstant_dout 1 1 2 NJ 620 -10
preplace netloc processing_system7_0_fclk_reset1_n 1 3 3 500 100 NJ 100 NJ
preplace netloc axi_interconnect_0_M02_AXI 1 3 2 560 550 900
preplace netloc Vp_Vn_1 1 0 3 NJ 870 NJ 870 N
preplace netloc processing_system7_0_M_AXI_GP1 1 2 2 20 490 460
preplace netloc xadc_wiz_0_ip2intc_irpt 1 2 2 NJ 520 460
preplace netloc s_axi_hp0_aclk 1 0 3 NJ 200 N 200 N
preplace netloc s_axi_hp1_1 1 0 3 NJ 140 N 140 N
preplace netloc axi_gpio_clk_sel_gpio_io_o 1 3 3 560 740 920 740 NJ
preplace netloc proc_sys_reset_0_interconnect_aresetn 1 2 2 30 510 540
preplace netloc axi_protocol_converter_0_M_AXI 1 3 1 530
preplace netloc Vaux8_1 1 0 3 NJ 930 NJ 930 N
preplace netloc clk_wiz_0_clk_out1 1 5 1 N
preplace netloc s_axi_hp1_aclk 1 0 3 NJ 220 N 220 N
preplace netloc processing_system7_0_fclk_reset0_n 1 3 3 510 110 NJ 110 NJ
preplace netloc axi_interconnect_0_M00_AXI 1 4 1 930
preplace netloc Vaux9_1 1 0 3 NJ 950 NJ 950 N
preplace netloc processing_system7_0_fixed_io 1 3 3 N 30 NJ 50 NJ
preplace netloc processing_system7_0_fclk_clk0 1 3 3 470 50 NJ 70 NJ
preplace netloc proc_sys_reset_0_peripheral_aresetn 1 2 3 30 1090 550 1090 N
preplace netloc axi_interconnect_0_M01_AXI 1 2 3 30 560 N 560 910
preplace netloc Vaux1_1 1 0 3 NJ 910 NJ 910 N
preplace netloc processing_system7_0_fclk_clk1 1 3 3 490 80 NJ 80 NJ
preplace netloc m_axi_gp0_aclk_1 1 0 3 NJ 160 N 160 N
preplace netloc util_ds_buf_0_BUFG_O 1 2 3 10 1100 NJ 1100 NJ
preplace netloc processing_system7_0_fclk_clk2 1 3 3 480 60 NJ 60 NJ
preplace netloc xlslice_0_Dout 1 4 1 N
preplace netloc processing_system7_0_fclk_clk3 1 2 4 0 500 520 90 940 250 NJ
levelinfo -pg 1 -460 -330 -120 250 750 1080 1280 -top -30 -bot 1210
",
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


