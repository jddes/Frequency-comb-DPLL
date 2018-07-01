"""
XEM6010 Phase-lock box communication interface, PLL sub-module
by JD Deschenes, October 2013

"""
from __future__ import print_function

import numpy as np
    
class Loop_filters_module(object):
    # Values that are fixed in the firmware (VHDL/Verilog code)
    BUS_OFFSET_settings      = 0x0
    BUS_OFFSET_gain_p        = 0x1
    BUS_OFFSET_gain_i        = 0x2
    BUS_OFFSET_gain_ii       = 0x3
    BUS_OFFSET_gain_d        = 0x4
    BUS_OFFSET_coef_d_filt   = 0x5
    
    def __init__(self, bus_base_address, N_DIVIDE_P, N_DIVIDE_I, N_DIVIDE_II, N_DIVIDE_D, N_DIVIDE_DF):
        self.bus_base_address = bus_base_address
        self.N_DIVIDE_P = N_DIVIDE_P
        self.N_DIVIDE_I = N_DIVIDE_I
        self.N_DIVIDE_II = N_DIVIDE_II
        self.N_DIVIDE_D = N_DIVIDE_D
        self.N_DIVIDE_DF = N_DIVIDE_DF
        self.gain_p  = 0.
        self.gain_i  = 0.
        self.gain_ii = 0.
        self.gain_d  = 0.
        self.coef_d  = 0.
        
        self.N_delay_p  = 5 # TODO: put the correct values here
        self.N_delay_i  = 6 # TODO: put the correct values here
        self.N_delay_ii = 7 # TODO: put the correct values here
        self.N_delay_d  = 7 # TODO: put the correct values here
        
    def get_p_limits(self):
        # These are the real, hardware limits for the multipler operands
        # However, there is another limit which could be lower which is when
        # even the quantization noise at the input (only 1 LSB) can rail the output.
        limit_railing = 2.**(16+self.N_DIVIDE_P)/2.**self.N_DIVIDE_P
#        return (1./2.**self.N_DIVIDE_P, 2.**31/2.**self.N_DIVIDE_P)
        return (0./2.**self.N_DIVIDE_P, min([2.**31/2.**self.N_DIVIDE_P, limit_railing]))
        
    def get_i_limits(self):
        return (0./2.**self.N_DIVIDE_I, 2.**31/2.**self.N_DIVIDE_I)
        
    def get_ii_limits(self):
        return (0./2.**self.N_DIVIDE_II, 2.**31/2.**self.N_DIVIDE_II)
        

    def get_d_limits(self):
        # TODO: make sure that this applies to the D branch
        #limit_railing = 2.**(16+self.N_DIVIDE_D)/2.**self.N_DIVIDE_D
#        return (1./2.**self.N_DIVIDE_P, 2.**31/2.**self.N_DIVIDE_P)
        return (0./2.**self.N_DIVIDE_D, 2.**31/2.**self.N_DIVIDE_D)        
        
    def get_df_limits(self):
        return (1./2.**self.N_DIVIDE_DF, 2.**31/2.**self.N_DIVIDE_DF, 2.**self.N_DIVIDE_DF)
        
    def get_current_gains(self):
        return ( self.gain_p, self.gain_i, self.gain_ii )
        
    def get_current_transfer_function(self, freq_axis, fs):
        
        unit_delay_phase_ramp = 2*np.pi * freq_axis/fs
        H_cumsum = 1/(1-np.exp(1j*unit_delay_phase_ramp))
        
        afilt = self.coef_d
        H_filt = afilt/(1-(1-afilt)*np.exp(1j*unit_delay_phase_ramp))
        H_diff = (1-np.exp(1j*unit_delay_phase_ramp))
        
        # The transfer function is the sum of the four terms (P, I, II, D)
        H_loop_filters = self.gain_i * H_cumsum * np.exp(-1j*self.N_delay_i * unit_delay_phase_ramp)
        H_loop_filters = H_loop_filters + self.gain_ii * H_cumsum**2 * np.exp(-1j*self.N_delay_ii * unit_delay_phase_ramp)
        H_loop_filters = H_loop_filters + self.gain_p * np.exp(-1j*self.N_delay_p * unit_delay_phase_ramp)
        H_loop_filters = H_loop_filters + self.gain_d * H_diff * H_filt * np.exp(-1j*self.N_delay_d * unit_delay_phase_ramp)
        #H_loop_filters = self.gain_d * (0.5) * H_diff * np.exp(-1j*self.N_delay_d * unit_delay_phase_ramp)
        #print(H_loop_filters)

        return H_loop_filters

        
    def set_pll_settings(self, sl, gain_p, gain_i, gain_ii, gain_d, coef_d, bLock):
        # Register format is:
        # gain_p  (32 bits signed, actual gain is gain_p/ 2**N_DIVIDE_P)
        # gain_i  (32 bits signed, actual gain is gain_i/ 2**N_DIVIDE_I)
        # gain_ii (32 bits signed, actual gain is gain_ii/2**N_DIVIDE_II)
        # settings register: 1 bit: bLock
        bDebugOutput = False
        
        if gain_p > (2**31 - 1)/2.**self.N_DIVIDE_P:
            if bDebugOutput:
                print('Error: P Gain clamped.')
            gain_p = (2**31 - 1)/2.**self.N_DIVIDE_P
        if gain_i > (2**31 - 1)/2.**self.N_DIVIDE_I:
            if bDebugOutput:
                print('Error: I Gain clamped.')
            gain_i = (2**31 - 1)/2.**self.N_DIVIDE_I
            
        if gain_ii > (2**31 - 1)/2.**self.N_DIVIDE_II:
            if bDebugOutput:
                print('Error: II Gain clamped.:')
                print('gain_ii = %e' % gain_ii)
                print('gain_ii > %e' % ((2**31 - 1)/2.**self.N_DIVIDE_II))
            gain_ii = (2**31 - 1)/2.**self.N_DIVIDE_II
        if gain_d > (2**31 - 1)/2.**self.N_DIVIDE_D:
            if bDebugOutput:
                print('Error: D Gain clamped.')
            gain_d = (2**31 - 1)/2.**self.N_DIVIDE_D
        if coef_d > (2**18 - 1)/2.**self.N_DIVIDE_DF:
            if bDebugOutput:
                print('Error: DF Coef clamped.')
            coef_d = (2**18 - 1)/2.**self.N_DIVIDE_DF
            
        
        gain_p_int = int(round(gain_p*2.**self.N_DIVIDE_P))
        gain_i_int = int(round(gain_i*2.**self.N_DIVIDE_I))
        gain_ii_int = int(round(gain_ii*2.**self.N_DIVIDE_II))
        gain_d_int = int(round(gain_d*2.**self.N_DIVIDE_D))
        coef_d_int = int(round(coef_d*2.**self.N_DIVIDE_DF))

        
        self.gain_p = gain_p_int/2.**self.N_DIVIDE_P
        self.gain_i = gain_i_int/2.**self.N_DIVIDE_I
        self.gain_ii = gain_ii_int/2.**self.N_DIVIDE_II
        self.gain_d = gain_d_int/2.**self.N_DIVIDE_D
        self.coef_d = coef_d_int/2.**self.N_DIVIDE_DF
        
        if bDebugOutput:
            print('P_gain = %e, in integer: P_gain = %d = 2^%.2f' % (self.gain_p, gain_p_int, np.log2(abs(gain_p_int)+0.1)))
            print('I_gain = %e, in integer: I_gain = %d = 2^%.2f' % (self.gain_i, gain_i_int, np.log2(abs(gain_i_int)+0.1)))
            print('II_gain = %e, in integer: II_gain = %d = 2^%.2f' % (self.gain_ii, gain_ii_int, np.log2(abs(gain_ii_int)+0.1)))
            print('D_gain = %e, in integer: D_gain = %d = 2^%.2f' % (self.gain_d, gain_d_int, np.log2(abs(gain_d_int)+0.1)))
            print('DF_gain = %e, in integer: DF_gain = %d = 2^%.2f' % (self.coef_d, coef_d_int, np.log2(abs(coef_d_int)+0.1)))
        
        # Send P gain
        # int_bits15_to_0 = gain_p_int & 0xFFFF
        # int_bits31_to_16 = (gain_p_int & 0xFFFF0000) >> 16
        # sl.send_bus_cmd(self.bus_base_address + self.BUS_OFFSET_gain_p, int_bits15_to_0, int_bits31_to_16)
        sl.send_bus_cmd_32bits(self.bus_base_address + self.BUS_OFFSET_gain_p, gain_p_int)
#        print('int_bits15_to_0 = %d, int_bits31_to_16 = %d' % (int_bits15_to_0, int_bits31_to_16))
        
        # Send I gain
        # int_bits15_to_0 = gain_i_int & 0xFFFF
        # int_bits31_to_16 = (gain_i_int & 0xFFFF0000) >> 16
        # sl.send_bus_cmd(self.bus_base_address + self.BUS_OFFSET_gain_i, int_bits15_to_0, int_bits31_to_16)
        sl.send_bus_cmd_32bits(self.bus_base_address + self.BUS_OFFSET_gain_i, gain_i_int)
        #print('address = %x' % (self.bus_base_address + self.BUS_OFFSET_gain_i))
        
        # Send II gain
        # int_bits15_to_0 = gain_ii_int & 0xFFFF
        # int_bits31_to_16 = (gain_ii_int & 0xFFFF0000) >> 16
        # sl.send_bus_cmd(self.bus_base_address + self.BUS_OFFSET_gain_ii, int_bits15_to_0, int_bits31_to_16)
        sl.send_bus_cmd_32bits(self.bus_base_address + self.BUS_OFFSET_gain_ii, gain_ii_int)
            
        # Send D gain
        # int_bits15_to_0 = gain_d_int & 0xFFFF
        # int_bits31_to_16 = (gain_d_int & 0xFFFF0000) >> 16
        # sl.send_bus_cmd(self.bus_base_address + self.BUS_OFFSET_gain_d, int_bits15_to_0, int_bits31_to_16)
        sl.send_bus_cmd_32bits(self.bus_base_address + self.BUS_OFFSET_gain_d, gain_d_int)
            
        # Send DF gain
        # int_bits15_to_0 = coef_d_int & 0xFFFF
        # int_bits31_to_16 = (coef_d_int & 0xFFFF0000) >> 16
        # sl.send_bus_cmd(self.bus_base_address + self.BUS_OFFSET_coef_d_filt, int_bits15_to_0, int_bits31_to_16)
        sl.send_bus_cmd_32bits(self.bus_base_address + self.BUS_OFFSET_coef_d_filt, coef_d_int)
        
        # Send lock/unlock setting
        sl.send_bus_cmd(self.bus_base_address + self.BUS_OFFSET_settings, bLock, 0)

    def get_pll_settings(self, sl):
        gain_p_raw  = sl.read_RAM_dpll_wrapper_signed(self.bus_base_address + self.BUS_OFFSET_gain_p)
        gain_i_raw  = sl.read_RAM_dpll_wrapper_signed(self.bus_base_address + self.BUS_OFFSET_gain_i)
        gain_ii_raw = sl.read_RAM_dpll_wrapper_signed(self.bus_base_address + self.BUS_OFFSET_gain_ii)
        gain_d_raw  = sl.read_RAM_dpll_wrapper_signed(self.bus_base_address + self.BUS_OFFSET_gain_d)
        coef_d_raw  = sl.read_RAM_dpll_wrapper_signed(self.bus_base_address + self.BUS_OFFSET_coef_d_filt)
        bLock       = sl.read_RAM_dpll_wrapper_signed(self.bus_base_address + self.BUS_OFFSET_settings)

        self.gain_p  = gain_p_raw/2.**self.N_DIVIDE_P
        self.gain_i  = gain_i_raw/2.**self.N_DIVIDE_I
        self.gain_ii = gain_ii_raw/2.**self.N_DIVIDE_II
        self.gain_d  = gain_d_raw/2.**self.N_DIVIDE_D
        self.coef_d  = coef_d_raw/2.**self.N_DIVIDE_DF
        self.bLock   = bLock
        return (self.gain_p,  self.gain_i, self.gain_ii, self.gain_d, self.coef_d, self.bLock)




class PLL0_module(Loop_filters_module):
    
    # Values that are fixed in the firmware (VHDL/Verilog code, file dpll_wrapper.v)
    bus_base_address = 0x7000
    N_DIVIDE_P = 24-11 # changed 2017-05-02 by JDD from 24 to 24-11 to recenter gain for RedPitaya connected to a laser with 8e8 Hz/V of VCO gain and 20 kHz of 1st order cutoff
    N_DIVIDE_I = 24
    N_DIVIDE_II = 35
    N_DIVIDE_D = 0
    N_DIVIDE_DF = 18
    
    def __init__(self, sl):
        super(PLL0_module, self).__init__(self.bus_base_address, self.N_DIVIDE_P, self.N_DIVIDE_I, self.N_DIVIDE_II, self.N_DIVIDE_D, self.N_DIVIDE_DF)
        
class PLL1_module(Loop_filters_module):
    
    # Values that are fixed in the firmware (VHDL/Verilog code, file dpll_wrapper.v)
    bus_base_address = 0x7010
    N_DIVIDE_P = 11
    N_DIVIDE_I = 18
    N_DIVIDE_II = 29
    N_DIVIDE_D = 0
    N_DIVIDE_DF = 18

    def __init__(self, sl):
        super(PLL1_module, self).__init__(self.bus_base_address, self.N_DIVIDE_P, self.N_DIVIDE_I, self.N_DIVIDE_II, self.N_DIVIDE_D, self.N_DIVIDE_DF)
        
        
class PLL2_module(Loop_filters_module):
    
    # Values that are fixed in the firmware (VHDL/Verilog code)
    bus_base_address = 0x7020
    N_DIVIDE_P = 11
    N_DIVIDE_I = 40
    N_DIVIDE_II = 29
    N_DIVIDE_D = 0
    N_DIVIDE_DF = 18

    
    def __init__(self, sl):
        super(PLL2_module, self).__init__(self.bus_base_address, self.N_DIVIDE_P, self.N_DIVIDE_I, self.N_DIVIDE_II, self.N_DIVIDE_D, self.N_DIVIDE_DF)
        
