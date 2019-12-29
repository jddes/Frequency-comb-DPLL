from collections import OrderedDict
from RegistersInfo import RegisterInfo as r

# need this for the bus addresses values
from SuperLaserLand_JD_RP import SuperLaserLand_JD_RP as c
from SuperLaserLand2_JD2_PLL import PLL0_module, PLL1_module

# conversion function from dpll address-space to zynq's address space:
# this is performed either in SuperLaserLand_JD_RP.send_bus_cmd(), or upper-level functions
from RP_PLL import RP_PLL_device
d2z = lambda x: RP_PLL_device.FPGA_BASE_ADDR + 4*x
# addresses that live in the red_pitaya_top.v address space:
r2z = lambda x: RP_PLL_device.FPGA_BASE_ADDR + x
# raw addresses that map to registers in the block design's address space
r2b = lambda x: RP_PLL_device.FPGA_BASE_ADDR_XADC + x

# Build an OrderedDict of namedtuples.
# the key represents the fieldname for a single register, and the namedtuples contain the info for that reg
reg_definitions = OrderedDict([
   # 'fieldname',                  'subsystem', 'display_name', 'addr',                                        'show', 'formatting_func'
('Trigger_write',                        r('Data logger', '',   r2z(c.BUS_ADDR_TRIG_WRITE),                           True, str)),
('Mux_selector',                         r('Data logger', '',   d2z(c.BUS_ADDR_MUX_SELECTORS),                        True, str)),
('STATUS_FLAGS',                         r('', '',              d2z(c.BUS_ADDR_STATUS_FLAGS),                         True, str)),
('DITHER0_LOCKIN_REAL_LSB',              r('Dither', '',        d2z(c.BUS_ADDR_DITHER0_LOCKIN_REAL_LSB),              True, str)),
('DITHER0_LOCKIN_REAL_MSB',              r('Dither', '',        d2z(c.BUS_ADDR_DITHER0_LOCKIN_REAL_MSB),              True, str)),
('DITHER1_LOCKIN_REAL_LSB',              r('Dither', '',        d2z(c.BUS_ADDR_DITHER1_LOCKIN_REAL_LSB),              True, str)),
('DITHER1_LOCKIN_REAL_MSB',              r('Dither', '',        d2z(c.BUS_ADDR_DITHER1_LOCKIN_REAL_MSB),              True, str)),
('ZERO_DEADTIME_SAMPLES_NUMBER',         r('Counter', '',       d2z(c.BUS_ADDR_ZERO_DEADTIME_SAMPLES_NUMBER),         True, str)),
('ZERO_DEADTIME_COUNTER0_LSBS',          r('Counter', '',       d2z(c.BUS_ADDR_ZERO_DEADTIME_COUNTER0_LSBS),          True, str)),
('ZERO_DEADTIME_COUNTER0_MSBS',          r('Counter', '',       d2z(c.BUS_ADDR_ZERO_DEADTIME_COUNTER0_MSBS),          True, str)),
('ZERO_DEADTIME_COUNTER1_LSBS',          r('Counter', '',       d2z(c.BUS_ADDR_ZERO_DEADTIME_COUNTER1_LSBS),          True, str)),
('ZERO_DEADTIME_COUNTER1_MSBS',          r('Counter', '',       d2z(c.BUS_ADDR_ZERO_DEADTIME_COUNTER1_MSBS),          True, str)),
('DAC0_CURRENT',                         r('', '',              d2z(c.BUS_ADDR_DAC0_CURRENT),                         True, str)),
('DAC1_CURRENT',                         r('', '',              d2z(c.BUS_ADDR_DAC1_CURRENT),                         True, str)),
('DAC2_CURRENT',                         r('', '',              d2z(c.BUS_ADDR_DAC2_CURRENT),                         True, str)),
('vco_amplitude',                        r('VCO', '',           r2z(c.BUS_ADDR_vco_amplitude),                        True, str)),
('vco_offset',                           r('VCO', '',           r2z(c.BUS_ADDR_vco_offset),                           True, str)),
('vco_mux',                              r('VCO', '',           r2z(c.BUS_ADDR_vco_mux),                              True, str)),
('TRIG_RESET_FRONTEND',                  r('', '',              d2z(c.BUS_ADDR_TRIG_RESET_FRONTEND),                  True, str)),
('TEST_OSC',                             r('', '',              d2z(c.BUS_ADDR_TEST_OSC),                             True, str)),
('TEST_OSC_DUTY',                        r('', '',              d2z(c.BUS_ADDR_TEST_OSC_DUTY),                        True, str)),
('TRIG_SYSTEM_IDENTIFICATION',           r('VNA', '',           d2z(c.BUS_ADDR_TRIG_SYSTEM_IDENTIFICATION),           True, str)),
('number_of_cycles_integration',         r('VNA', '',           d2z(c.BUS_ADDR_number_of_cycles_integration),         True, str)),
('first_modulation_frequency_lsbs',      r('VNA', '',           d2z(c.BUS_ADDR_first_modulation_frequency_lsbs),      True, str)),
('first_modulation_frequency_msbs',      r('VNA', '',           d2z(c.BUS_ADDR_first_modulation_frequency_msbs),      True, str)),
('modulation_frequency_step_lsbs',       r('VNA', '',           d2z(c.BUS_ADDR_modulation_frequency_step_lsbs),       True, str)),
('modulation_frequency_step_msbs',       r('VNA', '',           d2z(c.BUS_ADDR_modulation_frequency_step_msbs),       True, str)),
('number_of_frequencies',                r('VNA', '',           d2z(c.BUS_ADDR_number_of_frequencies),                True, str)),
('output_gain',                          r('VNA', '',           d2z(c.BUS_ADDR_output_gain),                          True, str)),
('input_and_output_mux_selector',        r('VNA', '',           d2z(c.BUS_ADDR_input_and_output_mux_selector),        True, str)),
('VNA_mode_control',                     r('VNA', '',           d2z(c.BUS_ADDR_VNA_mode_control),                     True, str)),
('PWM0',                                 r('', '',              d2z(c.BUS_ADDR_PWM0),                                 True, str)),
('DAC_offset[0]',                        r('', '',              d2z(c.BUS_ADDR_DAC_offset[0]),                        True, str)),
('DAC_offset[1]',                        r('', '',              d2z(c.BUS_ADDR_DAC_offset[1]),                        True, str)),
('DAC_offset[2]',                        r('', '',              d2z(c.BUS_ADDR_DAC_offset[2]),                        True, str)),
('pga_gains',                            r('', '',              d2z(c.BUS_ADDR_pga_gains),                            True, str)),
('dac_limits[0]',                        r('', '',              d2z(c.BUS_ADDR_dac_limits[0]),                        True, str)),
('dac_limits[1]',                        r('', '',              d2z(c.BUS_ADDR_dac_limits[1]),                        True, str)),
('dac_limits[2]',                        r('', '',              d2z(c.BUS_ADDR_dac_limits[2]),                        True, str)),
# ('fll0_settings',                        r('', '',              d2z(c.BUS_ADDR_fll0_settings),                        True, str)),
# ('pll0_gain_p',                          r('', '',              d2z(c.BUS_ADDR_pll0_gain_p),                          True, str)),
# ('pll0_gain_i',                          r('', '',              d2z(c.BUS_ADDR_pll0_gain_i),                          True, str)),
# ('pll0_settings',                        r('', '',              d2z(c.BUS_ADDR_pll0_settings),                        True, str)),
# ('pll0_gain_ii',                         r('', '',              d2z(c.BUS_ADDR_pll0_gain_ii),                         True, str)),
# ('fll1_settings',                        r('', '',              d2z(c.BUS_ADDR_fll1_settings),                        True, str)),
# ('pll1_gain_p',                          r('', '',              d2z(c.BUS_ADDR_pll1_gain_p),                          True, str)),
# ('pll1_gain_i',                          r('', '',              d2z(c.BUS_ADDR_pll1_gain_i),                          True, str)),
# ('pll1_settings',                        r('', '',              d2z(c.BUS_ADDR_pll1_settings),                        True, str)),
# ('pll1_gain_ii',                         r('', '',              d2z(c.BUS_ADDR_pll1_gain_ii),                         True, str)),
# ('fll1_settings',                        r('', '',              d2z(c.BUS_ADDR_fll1_settings),                        True, str)),
# ('pll1_gain_p',                          r('', '',              d2z(c.BUS_ADDR_pll1_gain_p),                          True, str)),
# ('pll1_gain_i',                          r('', '',              d2z(c.BUS_ADDR_pll1_gain_i),                          True, str)),
# ('pll1_settings',                        r('', '',              d2z(c.BUS_ADDR_pll1_settings),                        True, str)),
# ('pll1_gain_ii',                         r('', '',              d2z(c.BUS_ADDR_pll1_gain_ii),                         True, str)),
('integrator1_settings',                 r('', '',              d2z(c.BUS_ADDR_integrator1_settings),                 True, str)),
('integrator2_settings',                 r('', '',              d2z(c.BUS_ADDR_integrator2_settings),                 True, str)),
('dac2_setpoint',                        r('', '',              d2z(c.BUS_ADDR_dac2_setpoint),                        True, str)),
('ref_freq0_lsbs',                       r('', '',              d2z(c.BUS_ADDR_ref_freq0_lsbs),                       True, str)),
('ref_freq0_msbs',                       r('', '',              d2z(c.BUS_ADDR_ref_freq0_msbs),                       True, str)),
('ddc_filter_select',                    r('', '',              d2z(c.BUS_ADDR_ddc_filter_select),                    True, str)),
('ddc_angle_select',                     r('', '',              d2z(c.BUS_ADDR_ddc_angle_select),                     True, str)),
('nominal_ref_freq1_lsbs',               r('', '',              d2z(c.BUS_ADDR_nominal_ref_freq1_lsbs),               True, str)),
('nominal_ref_freq1_msbs',               r('', '',              d2z(c.BUS_ADDR_nominal_ref_freq1_msbs),               True, str)),
('dither_enable[0]',                        r('Dither', '',     d2z(c.BUS_ADDR_dither_enable[0]),                        True, str)),
('dither_period_divided_by_4_minus_one[0]', r('Dither', '',     d2z(c.BUS_ADDR_dither_period_divided_by_4_minus_one[0]), True, str)),
('dither_N_periods_minus_one[0]',           r('Dither', '',     d2z(c.BUS_ADDR_dither_N_periods_minus_one[0]),           True, str)),
('dither_amplitude[0]',                     r('Dither', '',     d2z(c.BUS_ADDR_dither_amplitude[0]),                     True, str)),
('dither_mode_auto[0]',                     r('Dither', '',     d2z(c.BUS_ADDR_dither_mode_auto[0]),                     True, str)),
('dither_enable[1]',                        r('Dither', '',     d2z(c.BUS_ADDR_dither_enable[1]),                        True, str)),
('dither_period_divided_by_4_minus_one[1]', r('Dither', '',     d2z(c.BUS_ADDR_dither_period_divided_by_4_minus_one[1]), True, str)),
('dither_N_periods_minus_one[1]',           r('Dither', '',     d2z(c.BUS_ADDR_dither_N_periods_minus_one[1]),           True, str)),
('dither_amplitude[1]',                     r('Dither', '',     d2z(c.BUS_ADDR_dither_amplitude[1]),                     True, str)),
('dither_mode_auto[1]',                     r('Dither', '',     d2z(c.BUS_ADDR_dither_mode_auto[1]),                     True, str)),
('dither_enable[2]',                        r('Dither', '',     d2z(c.BUS_ADDR_dither_enable[2]),                        True, str)),
('dither_period_divided_by_4_minus_one[2]', r('Dither', '',     d2z(c.BUS_ADDR_dither_period_divided_by_4_minus_one[2]), True, str)),
('dither_N_periods_minus_one[2]',           r('Dither', '',     d2z(c.BUS_ADDR_dither_N_periods_minus_one[2]),           True, str)),
('dither_amplitude[2]',                     r('Dither', '',     d2z(c.BUS_ADDR_dither_amplitude[2]),                     True, str)),
('dither_mode_auto[2]',                     r('Dither', '',     d2z(c.BUS_ADDR_dither_mode_auto[2]),                     True, str)),
('phase_residuals_threshold[0]',         r('', '',              d2z(c.BUS_ADDR_phase_residuals_threshold[0]),         True, str)),
('phase_residuals_threshold[1]',         r('', '',              d2z(c.BUS_ADDR_phase_residuals_threshold[1]),         True, str)),
('freq_residuals0_threshold',            r('', '',              d2z(c.BUS_ADDR_freq_residuals0_threshold),            True, str)),
('clk_divider_modulus',                  r('', '',              d2z(c.BUS_ADDR_clk_divider_modulus),                  True, str)),
('triangular_averaging',                 r('', '',              d2z(c.BUS_ADDR_triangular_averaging),                 True, str)),
('residuals_streaming',                  r('', '',              d2z(c.BUS_ADDR_residuals_streaming),                  True, str)),
('clk_divider_phase_adjust',             r('', '',              d2z(c.BUS_ADDR_clk_divider_phase_adjust),             True, str)),
('prbs_settings',                        r('', '',              d2z(c.BUS_ADDR_prbs_settings),                        True, str)),
('prbs_size',                            r('', '',              d2z(c.BUS_ADDR_prbs_size),                            True, str)),
('mux_pll2',                             r('', '',              d2z(c.BUS_ADDR_mux_pll2),                             True, str)),
('openLoopGain[0]',                      r('', '',              d2z(c.BUS_ADDR_openLoopGain[0]),                      True, str)),
('openLoopGain[1]',                      r('', '',              d2z(c.BUS_ADDR_openLoopGain[1]),                      True, str)),
('openLoopGain[2]',                      r('', '',              d2z(c.BUS_ADDR_openLoopGain[2]),                      True, str)),

('PLL0 settings',     r('PLL/PLL0', '', d2z(PLL0_module.bus_base_address+PLL0_module.BUS_OFFSET_settings)   , True, str)),
('PLL0 gain_p',       r('PLL/PLL0', '', d2z(PLL0_module.bus_base_address+PLL0_module.BUS_OFFSET_gain_p)     , True, str)),
('PLL0 gain_i',       r('PLL/PLL0', '', d2z(PLL0_module.bus_base_address+PLL0_module.BUS_OFFSET_gain_i)     , True, str)),
('PLL0 gain_ii',      r('PLL/PLL0', '', d2z(PLL0_module.bus_base_address+PLL0_module.BUS_OFFSET_gain_ii)    , True, str)),
('PLL0 gain_d',       r('PLL/PLL0', '', d2z(PLL0_module.bus_base_address+PLL0_module.BUS_OFFSET_gain_d)     , True, str)),
('PLL0 coef_d_filt',  r('PLL/PLL0', '', d2z(PLL0_module.bus_base_address+PLL0_module.BUS_OFFSET_coef_d_filt), True, str)),

('PLL1 settings',     r('PLL/PLL1', '', d2z(PLL1_module.bus_base_address+PLL1_module.BUS_OFFSET_settings)   , True, str)),
('PLL1 gain_p',       r('PLL/PLL1', '', d2z(PLL1_module.bus_base_address+PLL1_module.BUS_OFFSET_gain_p)     , True, str)),
('PLL1 gain_i',       r('PLL/PLL1', '', d2z(PLL1_module.bus_base_address+PLL1_module.BUS_OFFSET_gain_i)     , True, str)),
('PLL1 gain_ii',      r('PLL/PLL1', '', d2z(PLL1_module.bus_base_address+PLL1_module.BUS_OFFSET_gain_ii)    , True, str)),
('PLL1 gain_d',       r('PLL/PLL1', '', d2z(PLL1_module.bus_base_address+PLL1_module.BUS_OFFSET_gain_d)     , True, str)),
('PLL1 coef_d_filt',  r('PLL/PLL1', '', d2z(PLL1_module.bus_base_address+PLL1_module.BUS_OFFSET_coef_d_filt), True, str)),

('xadc_base_addr',                       r('Block Design', '',  r2b(c.xadc_base_addr),                                True, str)),
('clkw_base_addr',                       r('Block Design', '',  r2b(c.clkw_base_addr),                                True, str)),
('clk_sel_base_addr',                    r('Block Design', '',  r2b(c.clk_sel_base_addr),                             True, str)),
('clk_freq_reg1',                        r('Block Design', '',  r2b(c.clk_freq_reg1),                                 True, hex)),
('clk_freq_reg2',                        r('Block Design', '',  r2b(c.clk_freq_reg2),                                 True, hex)),
('clk_freq_reg3',                        r('Block Design', '',  r2b(c.clk_freq_reg3),                                 True, hex)),
('Vccint',                               r('Block Design', '',  r2b(c.BUS_ADDR_Vccint),                               True, str)),
('Vccaux',                               r('Block Design', '',  r2b(c.BUS_ADDR_Vccaux),                               True, str)),
('Vbram',                                r('Block Design', '',  r2b(c.BUS_ADDR_Vbram),                                True, str)),
('Zynq_Temp',                            r('Block Design', '',  r2b(c.BUS_ADDR_Zynq_Temp),                            True, str)),

('Divclk_Divide & ClkFbOut_Mult',        r('MMCM', '',          r2b(c.clkw_base_addr + 0x200),                     True, hex)),
('Clkout0_Divide',                       r('MMCM', '',          r2b(c.clkw_base_addr + 0x208),                     True, hex)),
('MMCM Status',                          r('MMCM', '',          r2b(c.clkw_base_addr + 0x04),                      True, hex)),
('MMCM Load new conf',                   r('MMCM', '',          r2b(c.clkw_base_addr + 0x25C),                     True, hex)),
('Clk sel&reset',                        r('MMCM', '',          r2b(c.clk_sel_base_addr),                          True, hex)),


])

# for index, addr  in enumerate(c.BUS_ADDR_XADC_CHAN):
#     reg_definitions['xadc_chan[%d]' % index] = r('Block Design', '', r2b(addr), True, str)

# map registers names or addresses to another one for event monitoring purposes.
# this is used for example to handle the case where reads and writes to a given register
# actually use different addresses.
#
# In the case of the Red Pitaya DPLL code, all the reads are done through a separate module than the writes.
reg_aliasing = {}
for field_name, reg_info in reg_definitions.items():
    base_addr_mask = 0xF000_0000
    if reg_info.addr & base_addr_mask == RP_PLL_device.FPGA_BASE_ADDR:
        read_addr = reg_info.addr | (2 << 20)
        reg_aliasing[hex(read_addr)] = field_name
        print("Aliasing events on %s to %s" % (hex(read_addr), reg_aliasing[hex(read_addr)]))

