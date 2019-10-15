# -*- coding: utf-8 -*-
"""
XEM6010 Phase-lock box communication interface,
by JD Deschenes, October 2013
Modified January 2016 to interface with the Red Pitaya port of the phase-lock box

"""
from __future__ import print_function

# import ok       # used to talk to the FPGA board
import time     # used for time.sleep()
import numpy as np
from scipy.signal import lfilter

import sys

import os, errno    # for makesurepathexists()

import traceback
import weakref

from SuperLaserLand2_JD2_PLL import PLL0_module, PLL1_module, PLL2_module
import RP_PLL

import logging

class SuperLaserLand_JD_RP:
	# Data members:
	############################################################
	# System parameters:
	fs = 125e6  # adc sampling rate
	bDDR2InUse = False  # Each function that uses the DDR2 logger module should make sure that this isn't set before changing any setting
	bCommunicationLogging = False   # Turn On/Off logging of the USB communication with the FPGA box
	bVerbose = False
	
	
	ddc0_frequency_in_hz = 25e6
	ddc1_frequency_in_hz = 25e6
	ddc0_frequency_in_int = int(round(25e6/100e6 * 2**48)) # Default DDC 0 reference frequency, has to match the current firmware value to be correct, otherwise we simply have to set it explicitely using set_ddc0_ref_freq()    
	ddc1_frequency_in_int = int(round(25e6/100e6 * 2**48)) # Default DDC 0 reference frequency, has to match the current firmware value to be correct, otherwise we simply have to set it explicitely using set_ddc0_ref_freq()    
	ADC0_gain = 1. #  * 31.65/25.35  # calibrated one particular RP unit against a scope, not sure if it will improve cal of others or not. JDD 2019-04-26.
	ADC1_gain = 1. #  * 31.65/25.35  # calibrated one particular RP unit against a scope, not sure if it will improve cal of others or not. JDD 2019-04-26.
	DAC0_gain = 1
	DAC1_gain = 1
	DAC2_gain = 2
	DACs_limit_low = [-2**15, -2**15, 0]
	DACs_limit_high = [2**15-1, 2**15-1, 2**16-1]
	DACs_offset = [2**14, 2**14, -2**15]


	output_vco = [0, 0, 0]
	
	# Default gate time in samples for the frequency counter:
	N_CYCLES_GATE_TIME = 125e6
	# Triangular averaging is on by default:
	bTriangularAveraging = 1
	
	# variables for the dither lock-in:
	modulation_period_divided_by_4_minus_one = [0, 0, 0]
	N_periods_integration_minus_one = [0, 0, 0]
	dither_amplitude = [0, 0, 0]
	dither_enable = [0, 0, 0]
	dither_mode_auto = [1, 1, 1] # 1 means automatic (on when lock is off, off when lock is on), 0 means manual
	lock_read = [0, 0, 0]
	# Hardware-specific values that won't change unless we port the code to a different hardware platform or modify the hardware itself
	Vref_DAC2 = 3.3
	
	# Values for the residuals streaming core (not currently implemented on the RedPitaya DPLL):
	residuals_trigger_delay = 10
	residuals_boxcar_filter_size = 10
	residuals_data_delay = 10
	
	## Internal FIFO queues for holding the slow dac and frequency counter outputs:
	dac0_fifo                = np.array([])
	dac1_fifo                = np.array([])
	dac2_fifo                = np.array([])
	counter0_fifo            = np.array([])
	counter1_fifo            = np.array([])
	time_counter_fifo        = np.array([])
	# this holds a sample number used to make sure that we don't grab the same counter samples twice
	last_zdtc_samples_number_counter = [0, 0]
	
	last_freq_update = 0
	new_freq_setting_number = 0

	# addresses from the "IP integrator block design" (see address editor)
	# there is also an offset of 0x8000_0000 applied in RP_PLL
	xadc_base_addr    = 0x0001_0000
	clkw_base_addr    = 0x0002_0000
	clk_sel_base_addr = 0x0003_0000
	clk_freq_reg1     = 0x0004_0000
	clk_freq_reg2     = 0x0004_0008
	clk_freq_reg3     = 0x0005_0000
	
	############################################################
	# CONSTANTS for endpoint numbers:
	# Inputs to the FPGA:
	ENDPOINT_CMD_ADDR                                   = 0x0
	ENDPOINT_CMD_DATA1IN                                = 0x1
	ENDPOINT_CMD_DATA2IN                                = 0x2
	BUS_ADDR_MUX_SELECTORS                              = 0x3
	ENDPOINT_MUX_CLOCK_SOURCE                           = 0x4
	ENDPOINT_EXTERNAL_FIFO_RESET                        = 0x5
	ENDPOINT_CMD_TRIG                                   = 0x40
	
	# # LEGACY, Opal-Kelly-style "endpoints":
	# ENDPOINT_STATUS_FLAGS_OUT = 0x25
	# # Outputs from the dither0 lock-in:
	# ENDPOINT_DITHER0_LOCKIN_REAL = 0x26 # endpoints 0x26 to 0x28 are part of this signal
	
	# ENDPOINT_DITHER1_LOCKIN_REAL = 0x29 # endpoints 0x29 to 0x2b are part of this signal
	
	# ENDPOINT_DITHER2_LOCKIN_REAL = 0x2c # endpoints 0x2c to 0x2e are part of this signal
	# ENDPOINT_DEBUGGING           = 0x2f
	
	# new-style addresses (Zynq)
	BUS_ADDR_STATUS_FLAGS                               = 0x00025
	BUS_ADDR_DITHER0_LOCKIN_REAL_LSB                    = 0x00026
	BUS_ADDR_DITHER0_LOCKIN_REAL_MSB                    = 0x00027
	BUS_ADDR_DITHER1_LOCKIN_REAL_LSB                    = 0x00029
	BUS_ADDR_DITHER1_LOCKIN_REAL_MSB                    = 0x0002a
	
	# these need to be read sequentially (BUS_ADDR_ZERO_DEADTIME_SAMPLES_NUMBER first, then the others).
	# this is to ensure that all the signals get sampled at the same time in registers_read.vhd
	BUS_ADDR_ZERO_DEADTIME_SAMPLES_NUMBER               = 0x00030
	BUS_ADDR_ZERO_DEADTIME_COUNTER0_LSBS                = 0x00031
	BUS_ADDR_ZERO_DEADTIME_COUNTER0_MSBS                = 0x00032
	BUS_ADDR_ZERO_DEADTIME_COUNTER1_LSBS                = 0x00033
	BUS_ADDR_ZERO_DEADTIME_COUNTER1_MSBS                = 0x00034
	BUS_ADDR_DAC0_CURRENT                               = 0x00035
	BUS_ADDR_DAC1_CURRENT                               = 0x00036
	BUS_ADDR_DAC2_CURRENT                               = 0x00037
	
	# Address to change the amplitude and the offset of the VCO
	BUS_ADDR_vco_amplitude                              = (6 << 20) + 0x00000
	BUS_ADDR_vco_offset                            		= (5 << 20) + 0x00004

	# This mux connect the VCO to the selected DAC 
	BUS_ADDR_vco_mux                                    = (5 << 20) + 0x00000
	
	
	
	PIPE_ADDRESS_DDR2_LOGGER                            = 0xA1
	PIPE_ADDRESS_ZERO_DEADTIME_COUNTER0                 = 0xA2
	PIPE_ADDRESS_ZERO_DEADTIME_COUNTER1                 = 0xA3
	PIPE_ADDRESS_DACS_MONITORING                        = 0xA4
	PIPE_ADDRESS_RESIDUALS0                             = 0xA5
	PIPE_ADDRESS_RESIDUALS1                             = 0xA6
	
	# Trigger commands constants (Legacy)
	TRIG_RESET                                          = 0
	TRIG_CMD_STROBE                                     = 1
	TRIG_SYSTEM_IDENTIFICATION                          = 2
	TRIG_CRASH_MEMORY_DUMP                              = 3
	TRIG_RESET_FRONTEND                                 = 4
	
	# New "triggers" style:
	BUS_ADDR_TRIG_RESET                                 = 0x41
	BUS_ADDR_TRIG_SYSTEM_IDENTIFICATION                 = 0x42
	# BUS_ADDR_TRIG_CRASH_MEMORY_DUMP = 0x43
	BUS_ADDR_TRIG_RESET_FRONTEND                        = 0x44
	
	DATA_LOGGER_ZYNQ_INDEX                              = 1  # taken from red_pitaya_top.v, from this line: .sys_wen              (  sys_wen[1]                 ),  // write enable
	BUS_ADDR_TRIG_WRITE                                 = (DATA_LOGGER_ZYNQ_INDEX<<20) + 0x1004    # writing anything to this address triggers the write mode in ram_data_logger.vhd
	# NOTE THAT THIS MODULE (ram_data_logger.vhd) IS IMPLEMENTED OUTSIDE OF DPLL_WRAPPER.V AND THUS IT is part of a different address mapping: this is a direct address offset in the Zynq address space, contrary to most of the other addresses here, which are multiplied by 4 by the conversion layer to avoid breaking 32 bits boundaries
	
	# Addresses for the internal 'cmd' register bus:
	###########################################################################
	
	BUS_ADDR_TEST_OSC                                   = 0x0046
	BUS_ADDR_TEST_OSC_DUTY                              = 0x0048
	# clock select register. 0 = internal, 1 = external
	BUS_ADDR_CLK_SEL                                    = 0x0049

	# Addresses for the system identification VNA:
	BUS_ADDR_number_of_cycles_integration               = 0x5000
	BUS_ADDR_first_modulation_frequency_lsbs            = 0x5001
	BUS_ADDR_first_modulation_frequency_msbs            = 0x5002
	BUS_ADDR_modulation_frequency_step_lsbs             = 0x5003
	BUS_ADDR_modulation_frequency_step_msbs             = 0x5004
	BUS_ADDR_number_of_frequencies                      = 0x5005
	BUS_ADDR_output_gain                                = 0x5006
	BUS_ADDR_input_and_output_mux_selector              = 0x5007
	BUS_ADDR_VNA_mode_control                           = 0x5008
	
	# Address for PWM0
	BUS_ADDR_PWM0                                       = 0x6621    
	
	# Addresses for the output DAC offsets:
	BUS_ADDR_DAC_offset                                = [0x6000, 0x6001, 0x6002]
	
	# Programmable gain amplifier settings (order: ADC0, ADC1, DAC0, DAC1, 3 bits each)
	BUS_ADDR_pga_gains                                  = 0x6100
	# DAC limits
	BUS_ADDR_dac_limits                                = (0x6101, 0x6102, 0x6103)
	
	#    # Loop filters settings:
	#    BUS_ADDR_fll0_settings                      = 0x7000
	#    BUS_ADDR_pll0_gain_p                        = 0x7001
	#    BUS_ADDR_pll0_gain_i                        = 0x7002
	#    BUS_ADDR_pll0_settings                      = 0x7003
	#    BUS_ADDR_pll0_gain_ii                       = 0x7004
	#    
	#    BUS_ADDR_fll1_settings                      = 0x7010
	#    BUS_ADDR_pll1_gain_p                        = 0x7011
	#    BUS_ADDR_pll1_gain_i                        = 0x7012
	#    BUS_ADDR_pll1_settings                      = 0x7013
	#    BUS_ADDR_pll1_gain_ii                       = 0x7014
	#    
	#    BUS_ADDR_fll1_settings                      = 0x7020
	#    BUS_ADDR_pll1_gain_p                        = 0x7021
	#    BUS_ADDR_pll1_gain_i                        = 0x7022
	#    BUS_ADDR_pll1_settings                      = 0x7023
	#    BUS_ADDR_pll1_gain_ii                       = 0x7024
	
	BUS_ADDR_integrator1_settings                       = 0x7020
	BUS_ADDR_integrator2_settings                       = 0x7021
	
	BUS_ADDR_dac2_setpoint                              = 0x7024
	
	# DDC 0 settings
	BUS_ADDR_ref_freq0_lsbs                             = 0x8000
	BUS_ADDR_ref_freq0_msbs                             = 0x8001
	BUS_ADDR_ddc_filter_select                          = 0x8002
	BUS_ADDR_ddc_angle_select                           = 0x8004
	
	# DDC 1 settings. This one is more complicated since we have included dfr phase generation and synchronized frequency changes.
	BUS_ADDR_nominal_ref_freq1_lsbs                     = 0x8010
	BUS_ADDR_nominal_ref_freq1_msbs                     = 0x8011
	BUS_ADDR_new_ref_freq1_lsbs                         = 0x8012
	BUS_ADDR_new_ref_freq1_msbs                         = 0x8013
	# This is an 80 bits register
	BUS_ADDR_dfr_phase_modulus1                         = 0x8014
	BUS_ADDR_dfr_phase_modulus2                         = 0x8015
	BUS_ADDR_dfr_phase_modulus3                         = 0x8016
	BUS_ADDR_dfr_phase_modulus4                         = 0x8017
	# This is an 80 bits register
	BUS_ADDR_dfr_phase_adjust1                          = 0x8018
	BUS_ADDR_dfr_phase_adjust2                          = 0x8019
	BUS_ADDR_dfr_phase_adjust3                          = 0x801A
	BUS_ADDR_dfr_phase_adjust4                          = 0x801B

	# This is an 80 bits register
	BUS_ADDR_delta_fr1                                  = 0x8022
	BUS_ADDR_delta_fr2                                  = 0x8023
	BUS_ADDR_delta_fr3                                  = 0x8024
	BUS_ADDR_delta_fr4                                  = 0x8025
	BUS_ADDR_ref1_state_control                         = 0x8026
	
	
	
	# DAC0 Dither and Lock-in settings:
	BUS_ADDR_dither_enable                             = [0x8100, 0x8200, 0x8300]
	BUS_ADDR_dither_period_divided_by_4_minus_one      = [0x8101, 0x8201, 0x8301]
	BUS_ADDR_dither_N_periods_minus_one                = [0x8102, 0x8202, 0x8302]
	BUS_ADDR_dither_amplitude                          = [0x8103, 0x8203, 0x8303]
	BUS_ADDR_dither_mode_auto 						   = [0x8104, 0x8204, 0x8304] # For reconnection purpose

	BUS_ADDR_phase_residuals_threshold                 = [0x8400, 0x8401]
	BUS_ADDR_freq_residuals0_threshold                  = 0x8410
	
	BUS_ADDR_clk_divider_modulus                        = 0x8500
	BUS_ADDR_triangular_averaging                       = 0x8501
	BUS_ADDR_residuals_streaming                        = 0x8502
	BUS_ADDR_clk_divider_phase_adjust                   = 0x8503
	
	# PRBS generator setting (output is ORed with the programmable clk divider, which both run on the 2x clock (200 MHz)).
	BUS_ADDR_prbs_settings                              = 0x8600
	BUS_ADDR_prbs_size                                  = 0x8601

	# mux to select which signal goes in pll2 : the output of the DEMOD1, PLL1 or DEMOD2
	BUS_ADDR_mux_pll2                                   = 0x9000

	BUS_ADDR_openLoopGain 								= [0x9010, 0x9011, 0x9012]



	############################################################
	
	############################################################
	# Constants for the input multiplex going to the DDR2Logger
	SELECT_ADC0          = 0
	SELECT_ADC1          = 1
	SELECT_DDC0          = 2
	SELECT_DDC1          = 3
	SELECT_VNA           = 4
	SELECT_COUNTER       = 5
	SELECT_DAC0          = 6
	SELECT_DAC1          = 7
	SELECT_DAC2          = 8
	SELECT_CRASH_MONITOR = 2**4
	SELECT_IN10          = 2**4 + 2**3
	LOGGER_MUX = {
		'ADC0':          0,
		'ADC1':          1,
		'DDC0':          2,
		'DDC1':          3,
		'VNA':           4,
		'COUNTER':       5,
		'DAC0':          6,
		'DAC1':          7,
		'DAC2':          8,
		'CRASH_MONITOR': 2**4,
		'IN10':          2**4 + 2**3,
		}
	############################################################
	
	def __init__(self, controller = None):
		self.logger = logging.getLogger(__name__)
		self.logger_name = ':SuperLaserLand_JD_RP'

		strNameTemplate = time.strftime("data_logging\\%m_%d_%Y_%H_%M_%S_")
		# Create the subdirectory if it doesn't exist:
		self.make_sure_path_exists('data_logging')
		
		if self.bCommunicationLogging == True:
			strCurrentName = strNameTemplate + 'SuperLaserLand_log.txt'
			self.log_file = open(strCurrentName, 'w')
	
		self.ddc0_filter_select = 0
		self.ddc1_filter_select = 0
		self.ddc0_angle_select = 0
		self.ddc1_angle_select = 0
		self.residuals0_phase_or_freq = 0
		self.residuals1_phase_or_freq = 0
		if controller is not None:
			self.controller = weakref.proxy(controller)
		else:
			self.controller = None

		self.dev = RP_PLL.RP_PLL_device(self.controller)

	
		
	def openDevice(self, bConfigure=True, strSerial='', strFirmware='superlaserland.bit'):
		if self.bVerbose == True:
			print('OpenDevice')
			
		if self.bCommunicationLogging == True:
			self.log_file.write('open()\n')

		error_code = 0    

		# Initialize sub-modules, which handle the communication with specific firmware components        
		self.initSubModules()
		
		return error_code

		
	def resetFrontend(self):
		if self.bVerbose == True:
			print('resetFrontend')
			
		print('Resetting FPGA (resetFrontend)...')
		# self.dev.ActivateTriggerIn(self.ENDPOINT_CMD_TRIG, self.TRIG_RESET_FRONTEND)
		self.dev.write_Zynq_register_uint32(self.BUS_ADDR_TRIG_RESET_FRONTEND*4, 0)
		
		# self.dev.ActivateTriggerIn(self.ENDPOINT_CMD_TRIG, self.TRIG_RESET)



	# From: http://stackoverflow.com/questions/273192/create-directory-if-it-doesnt-exist-for-file-write
	def make_sure_path_exists(self, path):
		if self.bVerbose == True:
			print('make_sure_path_exists')
			
		try:
			os.makedirs(path)
		except OSError as exception:
			if exception.errno != errno.EEXIST:
				raise
		
	def initSubModules(self):
		if self.bVerbose == True:
			print('initSubModules')
			
		if self.bCommunicationLogging == True:
			self.log_file.write('initSubModules()\n')
		# self.pll will contain a list of references to the three PLL loop filters modules
		#self.pll = (PLL0_module(self), PLL1_module(self), PLL2_module(self))
		self.pll = (PLL0_module(self), PLL1_module(self))
		
		
		# Stop the residuals fifo from filling up
		# self.setResidualsStreamingResetMode(1) #Not implemented in the Red Pitaya anymore
		
		
	def send_bus_cmd(self, bus_address, data1, data2):
		if self.bVerbose == True:
			print('send_bus_cmd')
			
		if self.bCommunicationLogging == True:
			self.log_file.write('send_bus_cmd(), address = 0x{:X}, data1 = {}, data2 = {}\n'.format(bus_address, data1, data2))
			print('send_bus_cmd() %X' % bus_address)
		
		self.dev.write_Zynq_register_uint32(int(bus_address)*4, (int(data2)<<16) + int(data1))

		
	def send_bus_cmd_32bits(self, bus_address, data_32bits):
		if self.bVerbose == True:
			print('send_bus_cmd_32bits')
		#print(sys._getframe().f_back.f_code.co_name)
		self.dev.write_Zynq_register_uint32(int(bus_address)*4, int(data_32bits))
			
		# data_lsbs = int(data_32bits) & 0xFFFF
		# data_msbs = (int(data_32bits) & 0xFFFF0000) >> 16
#        print('lsbs = %d, msbs = %d' % (data_lsbs, data_msbs))
		# self.send_bus_cmd(bus_address, data_lsbs, data_msbs)
		
	def send_bus_cmd_16bits(self, bus_address, data_16bits):
		if self.bVerbose == True:
			print('send_bus_cmd_16bits')
			
		data_lsbs = int(data_16bits) & 0xFFFF
		# self.send_bus_cmd(bus_address, data_lsbs, 0)

		self.dev.write_Zynq_register_uint32(int(bus_address)*4, data_lsbs)
		
		
	def setup_write(self, selector, Num_samples):
		if self.bVerbose == True:
			print('setup_write')
			
		if self.bCommunicationLogging == True:
			self.log_file.write('setup_write(), selector = {}, Num_samples = {}\n'.format(selector, Num_samples))
		
		# Set the clk divider (not implemented)
		self.clk_divider = 1
		
		# self.Num_samples_write = int(np.floor(Num_samples/64)*64)  # legacy: must be a multiple of 64 to yield 1024 bits per block
		self.Num_samples_write = int(Num_samples)  # no such restriction with the Red Pitaya implementation

#        if Num_samples != self.Num_samples_write:
#            print('Warning: Number of samples changed from %d to %d.' % (Num_samples, self.Num_samples_write))
		self.Num_samples_read = self.Num_samples_write
		
		# Set the clock divider (never used)
		# self.send_bus_cmd(self.BUS_ADDR_CLK_DIVIDER, self.clk_divider, 0)
		
		# Set the number of samples, actual number will be 1024*data_in1 value
		# self.dev.SetWireInValue(self.ENDPOINT_CMD_DATA1IN, int(self.Num_samples_write/1024) + 1)
		#self.dev.SetWireInValue(self.ENDPOINT_CMD_ADDR, self.BUS_ADDR_WRITE_ENABLE)
		self.dev.UpdateWireIns()    # Write wires values to FPGA

		# Select which data bus to put in the RAM:
		self.last_selector = selector
		self.dev.SetWireInValue(self.BUS_ADDR_MUX_SELECTORS, self.last_selector)
		self.dev.UpdateWireIns()    # Write wires values to FPGA

		# We don't strobe the trigger line because we want to give the user the
		# chance to setup more stuff (system identification module for example) before launching the read

	def setup_ADC0_write(self, Num_samples):
		if self.bVerbose == True:
			print('setup_ADC0_write')
			
		self.setup_write(self.LOGGER_MUX['ADC0'], Num_samples)
	def setup_ADC1_write(self, Num_samples):
		if self.bVerbose == True:
			print('setup_ADC1_write')
			
		self.setup_write(self.LOGGER_MUX['ADC1'], Num_samples)
	def setup_DDC0_write(self, Num_samples):
		if self.bVerbose == True:
			print('setup_DDC0_write')
			
		self.setup_write(self.LOGGER_MUX['DDC0'], Num_samples)
	def setup_DDC1_write(self, Num_samples):
		if self.bVerbose == True:
			print('setup_DDC1_write')
			
		self.setup_write(self.LOGGER_MUX['DDC1'], Num_samples)
	def setup_counter_write(self, Num_samples):
		if self.bVerbose == True:
			print('setup_counter_write')
			
		self.setup_write(self.LOGGER_MUX['COUNTER'], Num_samples)
	def setup_DAC0_write(self, Num_samples):
		if self.bVerbose == True:
			print('setup_DAC0_write')
			
		self.setup_write(self.LOGGER_MUX['DAC0'], Num_samples)
	def setup_DAC1_write(self, Num_samples):
		if self.bVerbose == True:
			print('setup_DAC1_write')
			
		self.setup_write(self.LOGGER_MUX['DAC1'], Num_samples)
		
	def setup_DAC2_write(self, Num_samples):
		if self.bVerbose == True:
			print('setup_DAC2_write')
			
		self.setup_write(self.LOGGER_MUX['DAC2'], Num_samples)
		
	def compute_integration_time_for_syst_ident(self, System_settling_time, first_modulation_frequency_in_hz):
		# There are four constraints on this value:
		# First of all, the output rate of the block depends on this value so it has to be kept under some limit (one block of data every ~20 clock cycles)
		# The second is the settling time of the impulse response of the system to be identified
		# the third is that we need to integrate long enough to reject the tone at twice the modulation frequency (after the multiplier)
		# the fourth is the overall SNR, which depends on the modulation amplitude and how much noise there is already on the system output
		# This last one is easy to handle; the measured transfer function will be very noisy if we don't integrate long enough
		return int((max((20, System_settling_time*self.fs, 1/(first_modulation_frequency_in_hz)*self.fs))))
		
	def setup_system_identification(self, input_select, output_select, first_modulation_frequency_in_hz, last_modulation_frequency_in_hz, number_of_frequencies, System_settling_time, output_amplitude, bDither=False):    
		if self.bVerbose == True:
			print('setup_system_identification')
			
		if self.bCommunicationLogging == True:
			self.log_file.write('setup_system_identification(), ...\n')
		# This is slightly more involved, because we have a lot of other stuff to setup
		# in addition to calling setup_write()
		
#        print('Setting up system identification variables...')
		self.System_settling_time = System_settling_time
		self.first_modulation_frequency_in_hz = first_modulation_frequency_in_hz
		self.last_modulation_frequency_in_hz = last_modulation_frequency_in_hz
		self.number_of_frequencies = number_of_frequencies
		
		# Num_samples computed below has to be a multiple of 64.  We back out how many frequencies we need to ask from this.
		print('number of frequencies before = %d' % self.number_of_frequencies)
		num_samples_desired = self.number_of_frequencies*(2*64+32)/16
#        num_samples_desired = int(round(num_samples_desired/64)*64) # enforces a multiple of 64. this was only necessary with the Opal Kelly interface
		self.number_of_frequencies = int(num_samples_desired*16/(2*64+32))
		if self.number_of_frequencies == 0:
			self.number_of_frequencies = 1
		print('number of frequencies after = %d' % self.number_of_frequencies)
#        self.number_of_frequencies = int(np.floor(self.number_of_frequencies/8)*8)    # Must be a multiple of eight to keep the data on DDR2 burst boundaries
		
		self.modulation_frequency_step_in_hz = (self.last_modulation_frequency_in_hz-self.first_modulation_frequency_in_hz)/self.number_of_frequencies;
		self.first_modulation_frequency = int(2**48 * self.first_modulation_frequency_in_hz/self.fs)
		self.modulation_frequency_step = int(2**48 * self.modulation_frequency_step_in_hz/self.fs)
		
		self.number_of_cycles_integration = self.compute_integration_time_for_syst_ident(self.System_settling_time, self.first_modulation_frequency_in_hz)
		
		
		self.output_gain = output_amplitude
		# Bit 1 and 0 select between one of the four inputs, in that order:
		# ADCraw0
		# ADCraw1
		# DDC_inst_freq0
		# DDC_inst_freq1
		# Bit 2 and 3 selects between one of the two ouputs, in that order:
		# DAC 0
		# DAC 1
		# DAC 2
		# DAC 2
		self.input_and_output_mux_selector = 1*2**2+ (1)   # LSB = '0' selects ADC 0, LSB = '1' selects ADC 1, bit 2 = '0' selects DAC0, bit 2 = '1' selects DAC1
		self.input_and_output_mux_selector = output_select * 2**2 + input_select

		self.send_bus_cmd(self.BUS_ADDR_number_of_cycles_integration, int((self.number_of_cycles_integration & 0xFFFF)), int((self.number_of_cycles_integration & 0xFFFF0000) >> 16))
		self.send_bus_cmd(self.BUS_ADDR_first_modulation_frequency_lsbs, int((self.first_modulation_frequency & 0xFFFF)), int((self.first_modulation_frequency & 0xFFFF0000) >> 16))
		self.send_bus_cmd(self.BUS_ADDR_first_modulation_frequency_msbs, int((self.first_modulation_frequency & 0xFFFF00000000) >> 32), 0)
		self.send_bus_cmd(self.BUS_ADDR_modulation_frequency_step_lsbs, int((self.modulation_frequency_step & 0xFFFF)), int((self.modulation_frequency_step & 0xFFFF0000) >> 16))
		self.send_bus_cmd(self.BUS_ADDR_modulation_frequency_step_msbs, int((self.modulation_frequency_step & 0xFFFF00000000) >> 32), 0)
		self.send_bus_cmd(self.BUS_ADDR_number_of_frequencies, self.number_of_frequencies, 0)
		self.send_bus_cmd(self.BUS_ADDR_output_gain, int((self.output_gain & 0xFFFF)), int((self.output_gain & 0xFFFF0000) >> 16))
		self.send_bus_cmd(self.BUS_ADDR_input_and_output_mux_selector, self.input_and_output_mux_selector, 0)
		# If we are setting up settings for a system identification, we need to stop the dither:
		if bDither == False:
			self.setVNA_mode_register(0, 1, 0)   # Set no dither, stop any dither, and sine wave output
		# This makes sure that the output mode is 'sine wave' rather than 'square wave'
		self.setVNA_mode_register(0, 0, 0)   # Set no dither, no stop, and sine wave output
		
		# Need to also setup the write for enough samples that the VNA will put out:
		# This needs to be done last, so that the next call to trigger_write(self) works correctly.
		Num_samples = self.number_of_frequencies*(2*64+32)/16
		print('setup_system_identification(): Num_samples = %d' % Num_samples)
		print('Num_samples = %d' % Num_samples)
#        print('self.number_of_frequencies = %d' % self.number_of_frequencies)
		self.setup_write(self.LOGGER_MUX['VNA'], Num_samples)
		
	def setVNA_mode_register(self, trigger_dither, stop_flag, bSquareWave):
		if self.bVerbose == True:
			print('setVNA_mode_register')
			
		register_value = stop_flag + 2*trigger_dither + 4*bSquareWave
		self.send_bus_cmd(self.BUS_ADDR_VNA_mode_control, register_value, 0)
		
	def trigger_write(self):
		if self.bVerbose == True:
			print('trigger_write')
			
		if self.bCommunicationLogging == True:
			self.log_file.write('trigger_write()\n')
		# Start writing data to the BRAM:
		self.dev.write_Zynq_register_uint32(self.BUS_ADDR_TRIG_WRITE, 0)
		#self.dev.ActivateTriggerIn(self.ENDPOINT_CMD_TRIG, self.TRIG_CMD_STROBE)
		
	def trigger_system_identification(self):
		if self.bVerbose == True:
			print('trigger_system_identification')
			
		if self.bCommunicationLogging == True:
			self.log_file.write('trigger_system_identification()\n')
		# Start writing data to the DDR2 RAM:
		# self.dev.ActivateTriggerIn(self.ENDPOINT_CMD_TRIG, self.TRIG_CMD_STROBE)
		self.dev.write_Zynq_register_uint32(self.BUS_ADDR_TRIG_WRITE, 0)
		# Start the system identification process:
		# self.dev.ActivateTriggerIn(self.ENDPOINT_CMD_TRIG, self.TRIG_SYSTEM_IDENTIFICATION)
		self.dev.write_Zynq_register_uint32(self.BUS_ADDR_TRIG_SYSTEM_IDENTIFICATION*4, 0)
				
	def wait_for_write(self):
		if self.bVerbose == True:
			print('wait_for_write')
			
		# Wait, seems necessary because setting the DDR2Logger to 'read' mode overrides the 'write' mode
		write_delay = 1.1*1024*(int(self.Num_samples_write/1024) + 1)/(self.fs/(2*self.clk_divider))
		time.sleep(write_delay)
		
	def get_system_identification_wait_time(self):
		if self.bVerbose == True:
			print('get_system_identification_wait_time')
			
		return 1.1*2*self.number_of_cycles_integration*self.number_of_frequencies/self.fs
		
	def wait_for_system_identification(self):
		if self.bVerbose == True:
			print('wait_for_system_identification')
			
#        print(1.1*2*self.number_of_cycles_integration*self.number_of_frequencies/self.fs)
		time.sleep(self.get_system_identification_wait_time())
		
		

	def read_raw_bytes_from_DDR2(self):
		if self.bVerbose == True:
			print('read_raw_bytes_from_DDR2')

		if self.bCommunicationLogging == True:
			self.log_file.write('read_raw_bytes_from_DDR2()\n')

		bytes_per_sample = 2
		Num_bytes_read = self.Num_samples_read*bytes_per_sample

		data_buffer = self.dev.read_Zynq_buffer_int16(self.Num_samples_read)

		if Num_bytes_read != len(data_buffer):
			print('Error: did not receive the expected number of bytes. expected: %d, Received: %d' % (Num_bytes_read, len(data_buffer)))

		# convert to numpy array
		data_buffer = np.fromstring(data_buffer, dtype=np.uint8)

		return data_buffer

		
	def extractBit(self, value, N_bit):
		if self.bVerbose == True:
			print('extractBit')
			
		single_bit = (value & (1 << N_bit)) >> N_bit
		return single_bit
		
	def readStatusFlags(self):
		if self.bVerbose == True:
			print('readStatusFlags')
			
		# We first need to check if the fifo has enough samples to send us:        

		# status_flags = self.dev.GetWireOutValue(self.ENDPOINT_STATUS_FLAGS_OUT) # get value from dev object into our script
		status_flags = self.dev.read_Zynq_register_uint32(self.BUS_ADDR_STATUS_FLAGS*4) # get value from dev object into our script
#        print(status_flags)
		output0_has_data        = (self.extractBit(status_flags, 0) == 0)
		output1_has_data        = (self.extractBit(status_flags, 1) == 0)
		PipeA1FifoEmpty         = self.extractBit(status_flags, 2)
		crash_monitor_has_data  = self.extractBit(status_flags, 3)
		
#        output0_has_data = ((status_flags & (1 << 0)) >> 0 == 0)
#        output1_has_data = ((status_flags & (1 << 1)) >> 1 == 0)
#        PipeA1FifoEmpty  = ((status_flags & (1 << 2)) >> 2 == 1)
#        PipeA1FifoEmpty  = ((status_flags & (1 << 2)) >> 2 == 1)
		
		return (output0_has_data, output1_has_data, PipeA1FifoEmpty, crash_monitor_has_data)
		
	def readLEDs(self):
		if self.bVerbose == True:
			print('readLEDs')
			
		# We first need to check if the fifo has enough samples to send us:        
		# status_flags = self.dev.GetWireOutValue(self.ENDPOINT_STATUS_FLAGS_OUT) # get value from dev object into our script
		status_flags = self.dev.read_Zynq_register_uint32(self.BUS_ADDR_STATUS_FLAGS*4) # get value from dev object into our script
		# print(status_flags)

		LED_G0        = self.extractBit(status_flags, 4)
		LED_R0        = self.extractBit(status_flags, 5)
		
		LED_G1        = self.extractBit(status_flags, 6)
		LED_R1        = self.extractBit(status_flags, 7)
		
		LED_G2        = self.extractBit(status_flags, 8)
		LED_R2        = self.extractBit(status_flags, 9)
		
		return (LED_G0, LED_R0, LED_G1, LED_R1, LED_G2, LED_R2)
		
	def readResidualsStreamingStatus(self):
		if self.bVerbose == True:
			print('readResidualsStreamingStatus')
			
		# We first need to check if the fifo has enough samples to send us:        
		self.dev.UpdateWireOuts()    # read values from FPGA into dev object
		status_flags = self.dev.GetWireOutValue(self.ENDPOINT_STATUS_FLAGS_OUT) # get value from dev object into our script
#        print(status_flags)
		residuals0_fifo_has_data        = (self.extractBit(status_flags, 10) == 0)
		residuals1_fifo_has_data        = (self.extractBit(status_flags, 11) == 0)
		
		
		return (residuals0_fifo_has_data, residuals1_fifo_has_data)
		
	def setResidualsStreamingSettings(self, data_delay, trigger_delay, boxcar_filter_size, rst_residuals_streaming):
		if self.bVerbose == True:
			print('setResidualsStreamingSettings')
			
		#.register_output({residuals_trigger_delay, residuals_boxcar_filter_size, rst_residuals_streaming}), 
	
		# check limits for input parameters:
		if boxcar_filter_size < 2:
			print('boxcar filter size too small')
			boxcar_filter_size = 5
		if boxcar_filter_size > 31:
			print('boxcar filter size too big')
			boxcar_filter_size = 5
	
		if trigger_delay < 1:
			print('trigger_delay too small')
			trigger_delay = 1
		if trigger_delay > 2**10-1:
			print('trigger_delay too big')
			trigger_delay = 2**10-1
			
		if data_delay < 1:
			print('data_delay too small')
			data_delay = 1
		if data_delay > 2**8-1:
			print('data_delay too big')
			data_delay = 2**8-1
		
		if rst_residuals_streaming != 0 and rst_residuals_streaming != 1:
			rst_residuals_streaming = 1
			print('Invalid reset value')
			
		# Save the actual values:
		self.residuals_boxcar_filter_size = boxcar_filter_size
		self.residuals_trigger_delay = trigger_delay
		self.residuals_data_delay = data_delay
			
		# Actual write to the register:
		register_value = rst_residuals_streaming + (boxcar_filter_size<<1) + (trigger_delay<<6) + (data_delay<<16)
		# print('register_value = %d' % register_value)
		# print('register_value_bin = %s' % bin(register_value))
		assert register_value < 2**32-1, 'setResidualsStreamingSettings():: register value too high'
		self.send_bus_cmd_32bits(self.BUS_ADDR_residuals_streaming, register_value)
		
	def setResidualsStreamingResetMode(self, rst_residuals_streaming):
		if self.bVerbose == True:
			print('setResidualsStreamingResetMode')
			
		# This changes the reset state of the streaming core without changing the other settings:
		trigger_delay = self.residuals_trigger_delay
		boxcar_filter_size = self.residuals_boxcar_filter_size
		data_delay = self.residuals_data_delay
		
		self.setResidualsStreamingSettings(data_delay, trigger_delay, boxcar_filter_size, rst_residuals_streaming)

	def read_raw_bytes_from_pipe(self, PipeAddress, Num_bytes_read):
		if self.bVerbose == True:
			print('read_raw_bytes_from_pipe')
			
		if self.bCommunicationLogging == True:
			self.log_file.write('read_raw_bytes_from_pipe()\n')

		print("read_raw_bytes_from_pipe: currently unimplemented (needs to switch to memory-mapped registers)")
		return None
		
		# Read data from pipe:
		start_time = time.time()
		#buffer = bytearray("\x00"*2048)
		
		# Implement the read from the byte as multiple calls to ReadFromPipeOut()
		# Since the function seems to hang when we ask for more than 16 MB (2^24 bytes)
		block_size_in_bytes = 2**23  # 8 MB blocks
		Num_of_full_8MB_blocks = np.floor(Num_bytes_read/block_size_in_bytes)
#        print('Num_of_full_8MB_blocks = %d' % Num_of_full_8MB_blocks)
		bytes_left = Num_bytes_read
		
		#buffer_all = "\xAA"*Num_bytes_read
		buffer_all = np.zeros(Num_bytes_read, dtype=np.uint8)
		output_index = 0
#        print(bytes_left)
		while bytes_left >= block_size_in_bytes:
#            print('Reading a 8 MB block...')
			# Read in a full 8 MB block
			buffer_full_block = "\xAA"*block_size_in_bytes
			error_code = self.dev.ReadFromPipeOut(PipeAddress, buffer_full_block)
			if error_code != len(buffer_full_block):
				print('Error: did not receive the expected number of bytes, error code:')
				print(error_code)
#            else:
#                print '%f MB received successfully' % (len(buffer_full_block)/1024./1024.)    
			#endif
			#buffer_all[output_index:output_index+block_size_in_bytes] = map(ord, buffer_full_block)
			buffer_all[output_index:output_index+block_size_in_bytes] = np.fromstring(buffer_full_block, dtype=np.uint8)
			output_index = output_index + block_size_in_bytes
			bytes_left = bytes_left - block_size_in_bytes
			
		#end while
		# We might need to read a final buffer < 8 MB
		if bytes_left > 0:
#            print('Reading the final block < 8 MB...')
			buffer_small = "\xAA"*bytes_left
			error_code = self.dev.ReadFromPipeOut(PipeAddress, buffer_small)
			if error_code != len(buffer_small):
				print('Error: did not receive the expected number of bytes, error code:')
				print(error_code)
#            else:
#                print '%f MB received successfully' % (len(buffer_small)/1024./1024.)    
			#endif
			#buffer_all[output_index:output_index+bytes_left] = map(ord, buffer_small)
			buffer_all[output_index:output_index+bytes_left] = np.fromstring(buffer_small, dtype=np.uint8)
			bytes_left = bytes_left - bytes_left    # = 0
		# End if, reading a block < 8 MB
			
#        print('Transfer done!')
		
		if error_code < 0:
			print('Error: did not receive the expected number of bytes, error code:')
			print(error_code)
#        else:
#            print '%f MB received successfully' % (Num_bytes_read/1024./1024.)    
		# endif
			
		elapsed_time = time.time() - start_time
		if elapsed_time == 0: elapsed_time = 1e-6
		self.last_throughput = Num_bytes_read/elapsed_time  # throughput in bytes/sec
#        print('elapsed time = %f seconds' % elapsed_time)
#        print('Throughput = %f MB/sec' % (self.last_throughput/1024/1024))
			
		return buffer_all
			
			
	def read_adc_samples_from_DDR2(self):
		if self.bVerbose == True:
			print('read_adc_samples_from_DDR2')
			
		if self.bCommunicationLogging == True:
			self.log_file.write('read_adc_samples_from_DDR2()\n')

		data_buffer = self.read_raw_bytes_from_DDR2()
		if self.last_selector == self.LOGGER_MUX['DAC2']:
			# DAC 2 samples are unsigned 16-bits
			samples_out = np.frombuffer(data_buffer, dtype=np.uint16)
		else:
			# All the other data sources are signed 16-bits
			samples_out = np.frombuffer(data_buffer, dtype=np.int16)

		if len(samples_out) == 0:
			ref_exp = np.array([1.0,])
			return (samples_out, ref_exp)

		

		# There is one additional thing we need to take care:
		# Samples #4 and 5 (counting from 0) contain the DDC reference exponential for this data packet:
		ref_exp_expected_position = 6
		magic_bytes_expected_position = ref_exp_expected_position+2
		ref_exp = samples_out[ref_exp_expected_position].astype(np.float) + 1j * samples_out[ref_exp_expected_position+1].astype(np.float)
		# ref_exp is the reference phasor at sample #4, we need to extrapolate it to the first correct output sample (#6, or two samples later)

		
		if self.last_selector ==  0 or self.last_selector == 1:
			# We have placed two magic bytes in sample 7, so that we can detect loss of synchronization on that data stream:
			magic_bytes = int('1010100010001111', 2) # from aux_data_mux.vhd: 1010_1000_1000_1111
			# magic_bytes is interpreted by python as an unsigned uint16, while samples_out[7] is interpreted as a signed int16
			N_bits = 16
			mask_negative_bit = (1<<(N_bits-1))
			mask_other_bits = mask_negative_bit-1
			magic_bytes = (magic_bytes & mask_other_bits) - (magic_bytes & mask_negative_bit)
			
			

			if samples_out[magic_bytes_expected_position] != magic_bytes:
				print('Comms bug! Sorry about that.')
				print('Loss of synchronization detected on Pipe 0xA1:')
				print('Original read length: %d' % self.Num_samples_read)
				self.logger.warning('Red_Pitaya_GUI{}: Comms bug. Loss of synchronization detected on Pipe 0xA1'.format(self.logger_name))
				
				
				actual_position = magic_bytes_expected_position
				for iter in range(len(samples_out)):
					if samples_out[iter] == magic_bytes:
						actual_position = iter
						print('magic bytes found at position %d' % actual_position)
						break
				
				print('magic bytes (hex) = 0x%x, samples_out[magic_bytes_expected_position] (hex) = 0x%x' % (magic_bytes, samples_out[magic_bytes_expected_position]))
				print('magic bytes (dec) = %d, samples_out[magic_bytes_expected_position] (dec) = %d' % (magic_bytes, samples_out[magic_bytes_expected_position]))
			
		
		# Here we need to know if this was ADC 0 or 1, so that we use the correct DDC reference frequency to extrapolate the phase:
		N_delay_between_ref_exp_and_datastream = 4
		if self.last_selector == 0:
			# ADC 0
			ref_exp = ref_exp * np.exp(-1j*2*np.pi*N_delay_between_ref_exp_and_datastream*(float(self.ddc0_frequency_in_int)/float(2**48)))
			
			# Strip off the samples that were used to pass side information
			samples_out = samples_out[magic_bytes_expected_position+1:]
			

		elif self.last_selector == 1:
			# ADC 1
			ref_exp = ref_exp * np.exp(-1j*2*np.pi*N_delay_between_ref_exp_and_datastream*(float(self.ddc1_frequency_in_int)/float(2**48)))
			
			# Strip off the samples that were used to pass side information
			samples_out = samples_out[magic_bytes_expected_position+1:]
		else:
			# Other (DAC0, DAC1 or DAC2): there is no ref exp in the samples
			ref_exp = 1
			samples_out = samples_out
		# Now ref_exp contains the reference phasor, aligned with the first sample that this function will return
		
		return (samples_out, ref_exp)
			
	def read_ddc_samples_from_DDR2(self):
		if self.bVerbose == True:
			print('read_ddc_samples_from_DDR2')
			
		if self.bCommunicationLogging == True:
			self.log_file.write('read_ddc_samples_from_DDR2()\n')
		data_buffer = self.read_raw_bytes_from_DDR2()
		samples_out = np.frombuffer(data_buffer, dtype=np.int16)
			
		
		# bytes_per_sample = 2
		# data_buffer_reshaped = np.reshape(data_buffer, (-1, bytes_per_sample))
		# convert_2bytes_signed = np.array((2**(0*8), 2**(1*8)), dtype=np.int16)
		# samples_out         = np.dot(data_buffer_reshaped[:, :].astype(np.int16), convert_2bytes_signed)

		# The samples represent instantaneous frequency as: samples_out = diff(phi)/(2*pi*fs) * 2**12, where phi is the phase in radians
		inst_freq = (samples_out.astype(dtype=float))/2**10 * self.fs/4
		# print('Mean frequency error = %f Hz' % np.mean(inst_freq))
		

		return inst_freq
		
	def read_counter_samples_from_DDR2(self):
		if self.bVerbose == True:
			print('read_counter_samples_from_DDR2')
			
		if self.bCommunicationLogging == True:
			self.log_file.write('read_counter_samples_from_DDR2()\n')
		data_buffer = self.read_raw_bytes_from_DDR2()
			
		bytes_per_sample = 2
		data_buffer_reshaped = np.reshape(data_buffer, (-1, bytes_per_sample))
		convert_4bytes_unsigned = np.array((2**(2*8), 2**(3*8), 2**(0*8), 2**(1*8)))
		convert_2bytes_signed = np.array((2**(0*8), 2**(1*8)), dtype=np.int16)
		samples_out         = np.dot(data_buffer_reshaped[:, :].astype(np.int16), convert_2bytes_signed)
		
		
		
		return samples_out
		
	def read_VNA_samples_from_DDR2(self):
		if self.bVerbose == True:
			print('read_VNA_samples_from_DDR2')
			
		if self.bCommunicationLogging == True:
			self.log_file.write('read_VNA_samples_from_DDR2()\n')
		data_buffer = self.read_raw_bytes_from_DDR2()
		
		# Interpret the samples as coming form the system identification VNA:
		# In this format, the DDR contains:
		# INTEGRATOR_REALPART_BITS15_TO_0
		# INTEGRATOR_REALPART_BITS31_TO_16
		# INTEGRATOR_REALPART_BITS47_TO_32
		# INTEGRATOR_REALPART_BITS63_TO_48
		# INTEGRATOR_IMAGPART_BITS15_TO_0
		# INTEGRATOR_IMAGPART_BITS31_TO_16
		# INTEGRATOR_IMAGPART_BITS47_TO_32
		# INTEGRATOR_IMAGPART_BITS63_TO_48
		# INTEGRATION_TIME_BITS15_TO_0
		# INTEGRATION_TIME_BITS31_TO_16
		# Thus each tested frequency will produce 2*64+32 bits (16 bytes).
		bytes_per_frequency_vna = int((2*64+32)/8);
		#repr_vna_all = np.reshape(rep, (-1, bytes_per_frequency_vna))    # note that this gives number_of_frequencies samples
		print('self.number_of_frequencies = %d' % (self.number_of_frequencies))
		print('bytes_per_frequency_vna = %d' % (bytes_per_frequency_vna))
		print('len = %d' % (len(data_buffer)))
		if len(data_buffer) < (self.number_of_frequencies)*bytes_per_frequency_vna:
			# we don't have enough bytes for the whole array. only use the number of frequencies that will fit:
			actual_number_of_frequencies = int(np.floor(len(data_buffer)/bytes_per_frequency_vna))
			self.number_of_frequencies = actual_number_of_frequencies
			
		vna_raw_data = np.reshape(data_buffer[0:(self.number_of_frequencies)*bytes_per_frequency_vna], (self.number_of_frequencies, bytes_per_frequency_vna))    # note that this gives number_of_frequencies samples
		print(vna_raw_data)
		
		vna_real = vna_raw_data[:, 0:8]
		vna_imag = vna_raw_data[:, 8:16]
		vna_integration_time = vna_raw_data[:, 16:20]
		
#        print('Real')
#        print(vna_real)
#        print('Imag')
#        print(vna_imag)
#        print('Integration time')
#        print(vna_integration_time)
		
		# collapse the 8 bytes into 64-bits signed values:
		# I am not sure whether this does the correct job with negative or very large values:
		convert_8bytes_signed = np.array(range(8), dtype=np.int64)
		convert_8bytes_signed = 2**(8*convert_8bytes_signed)
		integrator_real         = np.dot(vna_real[:, :].astype(np.int64), convert_8bytes_signed)
		integrator_imag         = np.dot(vna_imag[:, :].astype(np.int64), convert_8bytes_signed)
		
		convert_4bytes_unsigned = np.array(range(4), dtype=np.uint32)
		convert_4bytes_unsigned = 2**(8*convert_4bytes_unsigned)
		integration_time         = np.dot(vna_integration_time[:, :].astype(np.uint32), convert_4bytes_unsigned)
		
#        print(integration_time)
#        print(convert_4bytes_unsigned)
		
#        print(vna_raw_data)

		
		# The frequency axis can be constructed from knowledge of 
		# fs
		# first_modulation_frequency
		# modulation_frequency_step
		# number_of_frequencies
		frequency_axis = (self.first_modulation_frequency + self.modulation_frequency_step * np.array(range(self.number_of_frequencies), dtype=np.uint64)).astype(np.float64)/2**48*self.fs
		
		# While the overall gain is:
		# That is, a pure loop-back system from the output of the VNA to the input will
		#  give a modulus equal to overall_gain.
		overall_gain = np.array(2.**(15-1) * self.output_gain * float((self.number_of_cycles_integration)), dtype=np.float) # the additionnal divide by two is because cos(x) = 1/2*exp(jx)+1/2*exp(-jx)
		overall_gain = 2.**(15-1) * self.output_gain * integration_time.astype(np.float) # the additionnal divide by two is because cos(x) = 1/2*exp(jx)+1/2*exp(-jx)
#        print(self.number_of_cycles_integration)
#        overall_gain = 1
#        print('TODO: Remove this line! overallgain = 1')
		transfer_function_real = (integrator_real.astype(np.float)) / (overall_gain)
		transfer_function_imag = (integrator_imag.astype(np.float)) / (overall_gain)
		transfer_function_complex = transfer_function_real + 1j * transfer_function_imag
#        phi = np.angle(transfer_function_real + 1j*transfer_function_imag)
#        group_delay = ((-np.diff(phi)+np.pi) % (2*np.pi))-np.pi
#        group_delay = group_delay / np.diff(frequency_axis)/2.0/np.pi


		return (transfer_function_complex, frequency_axis)
	
	def set_dac_offset(self, dac_number, offset):
		if self.bVerbose == True:
			print('set_dac_offset')
			
		if self.bCommunicationLogging == True:
			self.log_file.write('set_dac_offset()\n')
		#print('set_dac_offset(): dac #%d, offset = %d' % (dac_number, offset))
		self.DACs_offset[dac_number] = offset
		self.send_bus_cmd_32bits(self.BUS_ADDR_DAC_offset[dac_number], offset)

	def get_dac_offset(self, dac_number):
		if self.bVerbose == True:
			print('get_dac_offset')

		offset = self.read_RAM_dpll_wrapper(self.BUS_ADDR_DAC_offset[dac_number])
		offset = offset & 0xFFFF
		
		if dac_number < 2:	# DAC 2 is unsigned
			if offset > ((1<<15)-1):
					offset = -(0xFFFF-offset+1)

		self.DACs_offset[dac_number] = offset

		return offset


	##
	## HB, 4/27/2015, Added PWM support on DOUT0
	##
	def set_pwm_settings(self, levels, value, bSendToFPGA = True):
		if self.bVerbose == True:
			print('set_pwm_settings')
		value = int(round(value))
		# Clamp value
		if value > levels:
			value = levels
		if value < 0:
			value = 0
		# Send to FPGA
		if bSendToFPGA == True:
			self.send_bus_cmd_32bits(self.BUS_ADDR_PWM0, value)
	
	def set_dac_limits(self, dac_number, limit_low, limit_high, bSendToFPGA = True):
		if self.bVerbose == True:
			print('set_dac_limits')
			
		if self.bCommunicationLogging == True:
			self.log_file.write('set_dac_limits()\n')
		limit_low = int(limit_low)
		limit_high = int(limit_high)
		
		# print 'set_dac_limits(): dac_number=%d, limit_low=%d, limit_high=%d' % (dac_number, limit_low, limit_high)
		# traceback.print_stack()

		limits_signed = lambda n_bits: (-2**(n_bits-1), 2**(n_bits-1)-1)
		limits_unsigned = lambda n_bits: (0, 2**(n_bits)-1)
		limits_from_dac =  {0: limits_signed(16),
		                    1: limits_signed(16),
		                    2: limits_unsigned(16)}
		# clamp to extremum values:
		if limit_low < limits_from_dac[dac_number][0]:
			limit_low = limits_from_dac[dac_number][0]
		if limit_high > limits_from_dac[dac_number][1]:
			limit_high = limits_from_dac[dac_number][1]

		self.send_bus_cmd(self.BUS_ADDR_dac_limits[dac_number], limit_low, limit_high)
		self.DACs_limit_low[dac_number] = limit_low
		self.DACs_limit_high[dac_number] = limit_high


	def get_dac_limits(self, dac_number):
		if self.bVerbose == True:
			print('get_dac_limits')
		if self.bCommunicationLogging == True:
			self.log_file.write('get_dac_limits()\n')

		# a few helper functions:
		split_32bits_to_2x16bits   = lambda x: ((x & 0xFFFF0000)>>16, (x & 0x0000FFFF))
		interpret_as_16bits_signed = lambda x: (x if x < (1<<15) else -(0xFFFF-x+1))

		limits_register = self.read_RAM_dpll_wrapper(self.BUS_ADDR_dac_limits[dac_number])
		(limit_high, limit_low) = split_32bits_to_2x16bits(limits_register)

		if dac_number == 0 or dac_number == 1:
			limit_high = interpret_as_16bits_signed(limit_high)
			limit_low  = interpret_as_16bits_signed(limit_low)

		self.DACs_limit_low[dac_number]  = limit_low
		self.DACs_limit_high[dac_number] = limit_high
		

	def get_ddc0_ref_freq_from_RAM(self):
		if self.bVerbose == True:
			print('get_ddc0_ref_freq')
			
		# Read FPGA to get the current value

		self.ddc0_frequency_in_int = (self.read_RAM_dpll_wrapper(self.BUS_ADDR_ref_freq0_msbs) << 32) + self.read_RAM_dpll_wrapper(self.BUS_ADDR_ref_freq0_lsbs)

		if self.ddc0_frequency_in_int > ((1<<47)-1):
			self.ddc0_frequency_in_int = -(0xFFFFFFFFFFFF-self.ddc0_frequency_in_int+1)

		frequency_in_hz = float(self.ddc0_frequency_in_int) / 2**48 * self.fs
		return frequency_in_hz

	def get_ddc0_ref_freq(self):
		if self.bVerbose == True:
			print('get_ddc0_ref_freq')
			
		# This only gives the correct answer if either: this object has explicitely ran its set_ddc0_ref_freq() function.
		# or: the default value in the FPGA firmware matches the one in self.frequency_in_int defined as a data member.
		frequency_in_hz = float(self.ddc0_frequency_in_int) / 2**48 * self.fs
		return frequency_in_hz

	def set_ddc0_ref_freq(self, frequency_in_hz):
		if self.bVerbose == True:
			print('set_ddc0_ref_freq')
			
		if self.bCommunicationLogging == True:
			self.log_file.write('set_ddc0_ref_freq()\n')
		
		self.ddc0_frequency_in_int = int(round(2**48 * frequency_in_hz/self.fs))
		self.ddc0_frequency_in_int = self.ddc0_frequency_in_int % (1 << 48) # modulo 2**48
		self.ddc0_frequency_in_hz = self.ddc0_frequency_in_int/2.**48 * self.fs
		frequency_in_int_bits15_to_0 = self.ddc0_frequency_in_int & 0xFFFF
		frequency_in_int_bits31_to_16 = (self.ddc0_frequency_in_int & 0xFFFF0000) >> 16
		frequency_in_int_bits48_to_32 = (self.ddc0_frequency_in_int & 0xFFFF00000000) >> 32
		
#        print('set_ddc0_ref_freq(): frequency_in_hz = %f\n' % frequency_in_hz)
		self.send_bus_cmd(self.BUS_ADDR_ref_freq0_lsbs, frequency_in_int_bits15_to_0, frequency_in_int_bits31_to_16)
		self.send_bus_cmd(self.BUS_ADDR_ref_freq0_msbs, frequency_in_int_bits48_to_32, 0)
		
#        print('set_ddc0_ref_freq(): MSBs = %d, LSBs = %d\n' % (frequency_in_int_bits48_to_32, frequency_in_int_bits31_to_16))
		
	def get_ddc1_ref_freq_from_RAM(self):
		if self.bVerbose == True:
			print('get_ddc1_ref_freq_from_RAM')
		# Read FPGA to get the current value
		self.ddc1_frequency_in_int = (self.read_RAM_dpll_wrapper(self.BUS_ADDR_nominal_ref_freq1_msbs) << 32) + self.read_RAM_dpll_wrapper(self.BUS_ADDR_nominal_ref_freq1_lsbs)

		if self.ddc1_frequency_in_int > ((1<<47)-1):
			self.ddc1_frequency_in_int = -(0xFFFFFFFFFFFF-self.ddc1_frequency_in_int+1)

		frequency_in_hz = float(self.ddc1_frequency_in_int) / 2**48 * self.fs
		return frequency_in_hz

	def get_ddc1_ref_freq(self):
		if self.bVerbose == True:
			print('get_ddc1_ref_freq')
			
		# This only gives the correct answer if either: this object has explicitely ran its set_ddc0_ref_freq() function.
		# or: the default value in the FPGA firmware matches the one in self.frequency_in_int defined as a data member.
		frequency_in_hz = float(self.ddc1_frequency_in_int) / 2**48 * self.fs
		return frequency_in_hz
		
		
	def set_ddc1_ref_freq(self, frequency_in_hz):
		if self.bVerbose == True:
			print('set_ddc1_ref_freq')
			
		if self.bCommunicationLogging == True:
			self.log_file.write('set_ddc1_ref_freq()\n')

		self.ddc1_frequency_in_int = int(round(2**48 * frequency_in_hz/self.fs))
		self.ddc1_frequency_in_int = self.ddc1_frequency_in_int % (1 << 48) # modulo 2**48
		self.ddc1_frequency_in_hz = self.ddc1_frequency_in_int/2.**48 * self.fs
		frequency_in_int_bits15_to_0 = self.ddc1_frequency_in_int & 0xFFFF
		frequency_in_int_bits31_to_16 = (self.ddc1_frequency_in_int & 0xFFFF0000) >> 16
		frequency_in_int_bits48_to_32 = (self.ddc1_frequency_in_int & 0xFFFF00000000) >> 32
		
#        print('set_ddc1_ref_freq(): frequency_in_hz = %f\n' % frequency_in_hz)
		self.send_bus_cmd(self.BUS_ADDR_nominal_ref_freq1_lsbs, frequency_in_int_bits15_to_0, frequency_in_int_bits31_to_16)
		self.send_bus_cmd(self.BUS_ADDR_nominal_ref_freq1_msbs, frequency_in_int_bits48_to_32, 0)
		
		
	def getFreqDiscriminatorGain(self):
		if self.bVerbose == True:
			print('getFreqDiscriminatorGain')
			
		return 2**10/self.fs
		
	##
	## HB, 4/27/2015, Added PWM support on DOUT0
	##
	def convertPWMCountsToVolts(self, standard, levels, counts):
		return np.float(standard)*np.float(counts)/np.float(levels)
	def convertPWMVoltsToCounts(self, standard, levels, volts):
		return int(np.round(np.float(levels)*np.float(volts)/np.float(standard)))
			
	def convertDACCountsToVolts(self, DAC_number, counts):
		if self.bVerbose == True:
			print('convertDACCountsToVolts')

		# Make sure that the counts get treated as floats instead of integers
		# handle both Python scalar and numpy array input:
		if type(counts) is np.ndarray:
			counts = counts.astype(np.float)
		else:
			counts = np.float(counts)
		
		if DAC_number == 0:
			# print('counts = %d, volts = %f, gain = %f' % (counts, np.float(counts)/2.**15. * 1 * self.DAC0_gain, self.DAC0_gain))
			return counts/(2.**15.-1) * 1 * self.DAC0_gain            
		elif DAC_number == 1:
			return counts/(2.**15.-1) * 1 * self.DAC1_gain
		elif DAC_number == 2:
			return_value = counts/(2.**16-1) * self.Vref_DAC2
			return return_value
			
		return 0
		
	def convertDACVoltsToCounts(self, DAC_number, voltage):
		if self.bVerbose == True:
			print('convertDACVoltsToCounts')
			
		return_value = 0
		
		if DAC_number == 0:
			return_value = (float(voltage)/self.DAC0_gain * (2.**15.-1))
			#print('convertDACVoltsToCounts: voltage = %f, DAC0_gain = %f, return_value = %f' % (voltage, self.DAC0_gain, return_value))
		elif DAC_number == 1:
			return_value = (float(voltage)/self.DAC1_gain * (2.**15.-1))
		elif DAC_number == 2:
#            return_value = (float(voltage)/55 * 2.**19.) - (2**19-1)
#            return_value = (float(voltage)/55 * (2.**20.-1)) - (2**19-1)
#            return_value = ((float(voltage)/12./10.) * (2.**20.-1))
			return_value = float(voltage)/(self.Vref_DAC2) * (2**16-1)
			
			
#        if return_value == 0:
#            raise
		return return_value
		
		
	def getDACGainInCountsPerVolts(self, DAC_number):
		if self.bVerbose == True:
			print('getDACGainInCountsPerVolts')
			
		return_value = 0
		
		if DAC_number == 0:
			return_value = (1./self.DAC0_gain * (2.**15.-1))
		elif DAC_number == 1:
			return_value = (1./self.DAC1_gain * (2.**15.-1))
		elif DAC_number == 2:
			return_value = float(1.)/(self.Vref_DAC2) * (2**16-1)

		return return_value
		
	def getDACGainInVoltsPerCounts(self, DAC_number):
		if self.bVerbose == True:
			print('getDACGainInVoltsPerCounts')
			
		return_value = 0
		
		if DAC_number == 0:
			return_value = float(self.DAC0_gain) / (2.**15.-1)
		elif DAC_number == 1:
			return_value = float(self.DAC1_gain / (2.**15.-1))
		elif DAC_number == 2:
			return_value = (self.Vref_DAC2) / (2**16-1)

		return return_value
		
	def convertADCCountsToVolts(self, ADC_number, counts):
		if self.bVerbose == True:
			print('convertADCCountsToVolts')
			
		ADC_gain = 1.
		ADC_bits = 16.
		Volts_max_for_unit_gain = 1. # Nominal value is 1 Volts peak-to-peak (+/- 1 Volts input range)
		
		if ADC_number == 0:
#            print('counts = %d, volts = %f, gain = %f' % (counts, np.float(counts)/2.**15. * 1 * self.DAC0_gain, self.DAC0_gain))
			ADC_gain = float(self.ADC0_gain)
		elif ADC_number == 1:
			ADC_gain = float(self.ADC1_gain)
		
		if type(counts) is np.ndarray:
			# Numpy array:
			return counts.astype(np.float)  /  (2. **(ADC_bits-1)) * Volts_max_for_unit_gain / ADC_gain
		else:
			# Scalar case:
			return np.float(counts)  /  (2. **(ADC_bits-1)) * Volts_max_for_unit_gain / ADC_gain
		
	def convertDDCCountsToHz(self, counts):
		if self.bVerbose == True:
			print('convertDDCCountsToHz')
			
		DDC_bits = 10.
		
		return counts.astype(dtype=np.float)  /  (2. **(DDC_bits)) * self.fs
		
	def setDitherLockInState(self, dac_number, bEnable):
		if self.bVerbose == True:
			print('setDitherLockInState')
			
		self.dither_enable[dac_number] = int(bEnable)
		
		self.setDitherLockInSettings(dac_number)

	def setDitherLockInSettings(self, dac_number):
		if self.bVerbose == True:
			print('setDitherLockInSettings')

	
#		signal bOutputEnable 								: std_logic := '0';
#   	signal modulation_period_divided_by_4_minus_one 	: std_logic_vector(COUNTER_BITS-1 downto 0) := std_logic_vector(to_unsigned(100e6/1e3/4-1, COUNTER_BITS));	-- about 1 kHz
#   	signal modulation_amplitude 						: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(2*2**6, 16));
#   	signal N_periods_integration_minus_one 				: std_logic_vector(COUNTER_BITS-1 downto 0) := std_logic_vector(to_unsigned(100-1, COUNTER_BITS));	-- 100 periods at 1 kHz, to give 10 Hz update rate, or 0.1 sec integration time
#		signal bOutputEnable_vector							: std_logic_vector(0 downto 0);
#	
#            print('self.modulation_period_divided_by_4_minus_one[dac_number] = %d = 2^%f, self.N_periods_integration_minus_one[dac_number] = %d' % (self.modulation_period_divided_by_4_minus_one[dac_number], np.log2(self.modulation_period_divided_by_4_minus_one[dac_number]), self.N_periods_integration_minus_one[dac_number]))
		self.send_bus_cmd_32bits(self.BUS_ADDR_dither_period_divided_by_4_minus_one[dac_number], self.modulation_period_divided_by_4_minus_one[dac_number])
		self.send_bus_cmd_32bits(self.BUS_ADDR_dither_N_periods_minus_one[dac_number], self.N_periods_integration_minus_one[dac_number])
		self.send_bus_cmd_16bits(self.BUS_ADDR_dither_amplitude[dac_number], self.dither_amplitude[dac_number])
#            self.send_bus_cmd_32bits(self.BUS_ADDR_dither_amplitude[dac_number], 2**16*self.dither_amplitude[dac_number]+self.dither_amplitude[dac_number])
#            self.send_bus_cmd(self.BUS_ADDR_dither_amplitude[dac_number], self.dither_amplitude[dac_number], self.dither_amplitude[dac_number])
			
		self.send_bus_cmd_16bits(self.BUS_ADDR_dither_enable[dac_number], self.dither_enable[dac_number])

	def setupDitherLockIn(self, dac_number, modulation_period, N_periods, amplitude, mode_auto):
		if self.bVerbose == True:
			print('setupDitherLockIn')
			

		self.modulation_period_divided_by_4_minus_one[dac_number] = int(round(modulation_period/4-1))
		self.N_periods_integration_minus_one[dac_number] = int(N_periods-1)
		self.dither_amplitude[dac_number] = int(round(amplitude))
		# self.dither_enable[dac_number] = int(bEnable)
		self.dither_mode_auto[dac_number] = int(mode_auto)

		self.setDitherLockInSettings(dac_number)
		self.save_mode_auto(dac_number, self.dither_mode_auto[dac_number])


	def get_Dither_Settings(self, dac_number):
		self.modulation_period_divided_by_4_minus_one[dac_number] 	= self.read_RAM_dpll_wrapper(self.BUS_ADDR_dither_period_divided_by_4_minus_one[dac_number])
		self.N_periods_integration_minus_one[dac_number] 			= self.read_RAM_dpll_wrapper(self.BUS_ADDR_dither_N_periods_minus_one[dac_number])
		self.dither_amplitude[dac_number] 							= self.read_RAM_dpll_wrapper(self.BUS_ADDR_dither_amplitude[dac_number])
		self.dither_enable[dac_number] 								= self.read_RAM_dpll_wrapper(self.BUS_ADDR_dither_enable[dac_number])
		self.dither_mode_auto[dac_number] 							= self.read_RAM_dpll_wrapper(self.BUS_ADDR_dither_mode_auto[dac_number])

		modulation_period = int((self.modulation_period_divided_by_4_minus_one[dac_number]+1)*4)
		N_periods = int(self.N_periods_integration_minus_one[dac_number]+1)
		amplitude = int(self.dither_amplitude[dac_number])


		return (modulation_period, N_periods, amplitude, self.dither_enable[dac_number], self.dither_mode_auto[dac_number])

	def ditherRead(self, N_samples, dac_number=0):
		# print('ditherRead')
			
		# Read N samples from the dither lock-in
		samples = np.zeros(N_samples, dtype=np.complexfloating)

		if dac_number == 0:
			BASE_ADDR_REAL_LSB = self.BUS_ADDR_DITHER0_LOCKIN_REAL_LSB
			BASE_ADDR_REAL_MSB = self.BUS_ADDR_DITHER0_LOCKIN_REAL_MSB
		elif dac_number == 1:
			BASE_ADDR_REAL_LSB = self.BUS_ADDR_DITHER1_LOCKIN_REAL_LSB
			BASE_ADDR_REAL_MSB = self.BUS_ADDR_DITHER1_LOCKIN_REAL_MSB
		elif dac_number == 2:
			# there is no DAC2 anymore
			return samples
		
		# print 'ditherRead------------'
		for k in range(N_samples):

			# results_lsb = self.dev.read_Zynq_register_uint32(BASE_ADDR_REAL_LSB*4)
			# results_msb = self.dev.read_Zynq_register_uint32(BASE_ADDR_REAL_MSB*4)
			# # print 'results_lsb = %d' % results_lsb
			# # print 'results_msb = %d' % results_msb

			# results = np.array((results_lsb, results_msb), np.dtype(np.uint32))
			# results = np.frombuffer(results, np.dtype(np.int64) )
			samples[k] = self.dev.read_Zynq_register_int64(BASE_ADDR_REAL_LSB*4, BASE_ADDR_REAL_MSB*4)

			
		return samples
		
		
	def scaleDitherResultsToHz(self, results, dac_number):
		if self.bVerbose == True:
			print('scaleDitherResultsToHz')
			
		N_samples_integration = 4*(self.modulation_period_divided_by_4_minus_one[dac_number]+1) * (self.N_periods_integration_minus_one[dac_number]+1)
		
		# scaling of the Dither results are DDC counts, summed for N_samples_integration.
		results_in_Hz = self.convertDDCCountsToHz(results)/N_samples_integration
		return results_in_Hz
		
	def scaleDitherResultsToHzPerVolts(self, results, dac_number):
		if self.bVerbose == True:
			print('scaleDitherResultsToHzPerVolts')
			
#        print('type = %s' % type(results))
#        print('shape = %s' % str(results.shape))
		results_in_Hz = self.scaleDitherResultsToHz(results, dac_number)
		dither_amplitude_in_Volts = self.dither_amplitude[dac_number] * self.getDACGainInVoltsPerCounts(dac_number)
		if dither_amplitude_in_Volts == 0.:
			dither_amplitude_in_Volts = 1e-10
			
		results_in_Hz_per_Volts = results_in_Hz/dither_amplitude_in_Volts
		return results_in_Hz_per_Volts


	def set_integrator_settings(self, integrator_number, hold, flip_sign, lock, gain_in_bits):
		if self.bVerbose == True:
			print('set_integrator_settings')
			
		if integrator_number == 1:
		# Register format is:
		# {dac2_integrator1_flipsign, dac2_integrate_frequency, dac2_freq_integrator_gain_left_shift_in_bits, dac2_freq_integrator_gain_right_shift_in_bits}
			address = self.BUS_ADDR_integrator1_settings
		elif integrator_number == 2:
		# Register format is:
		# {dac2_integrator2_flipsign, dac2_integrate_dac1_output, dac2_dac1_integrator_gain_left_shift_in_bits, dac2_dac1_integrator_gain_right_shift_in_bits}
			address = self.BUS_ADDR_integrator2_settings

		if gain_in_bits > 0:
			# Positive gain (in log scale) goes into the MSBs:
			gain_left_shift_in_bits = gain_in_bits
			gain_right_shift_in_bits = 0
		else:
			# Negative gain (in log scale) goes into the LSBs:
			gain_left_shift_in_bits = 0
			gain_right_shift_in_bits = -gain_in_bits
			
		# print('integrator %d, hold = %d, flipsign = %d, lock = %d, gain = %d' % (integrator_number, hold, flip_sign, lock, gain_in_bits))
		self.send_bus_cmd(address, 2**12 * hold + 2**11 * flip_sign + 2**10 * lock + 2**5*gain_left_shift_in_bits + gain_right_shift_in_bits, 0)

	# return type is a tuple: (hold, flip_sign, lock, gain_in_bits)
	def get_integrator_settings(self, integrator_number):
		if self.bVerbose == True:
			print('get_integrator_settings')
		if integrator_number == 1:
		# Register format is:
		# {dac2_integrator1_flipsign, dac2_integrate_frequency, dac2_freq_integrator_gain_left_shift_in_bits, dac2_freq_integrator_gain_right_shift_in_bits}
			address = self.BUS_ADDR_integrator1_settings
		elif integrator_number == 2:
		# Register format is:
		# {dac2_integrator2_flipsign, dac2_integrate_dac1_output, dac2_dac1_integrator_gain_left_shift_in_bits, dac2_dac1_integrator_gain_right_shift_in_bits}
			address = self.BUS_ADDR_integrator2_settings
		data  = self.read_RAM_dpll_wrapper(address)
		integrator_gain_right_shift_in_bits = (data    ) & ((1<<5)-1)
		integrator_gain_left_shift_in_bits  = (data>> 5) & ((1<<5)-1)
		lock                                = (data>>10) & ((1<<1)-1)
		flip_sign                           = (data>>11) & ((1<<1)-1)
		hold                                = (data>>12) & ((1<<1)-1)

		# combine right-shift and left-shift value into positive or negative shift value:
		# first a self-consistency check:
		if (integrator_gain_right_shift_in_bits!=0) and (integrator_gain_left_shift_in_bits!=0):
			print("Warning: Consistency check failed in get_integrator_settings().")
			# arbitrarily decide to pick the low gain value as the correct one:
			integrator_gain_left_shift_in_bits = 0
		# There should always be only one of the left_shift or right_shift that is non-zero
		gain_in_bits = integrator_gain_left_shift_in_bits-integrator_gain_right_shift_in_bits

		return (hold, flip_sign, lock, gain_in_bits)


	def frontend_DDC_processing(self, samples, ref_exp0, input_number):
		if self.bVerbose == True:
			print('frontend_DDC_processing, len(samples) = %d, samples[0] = %d' % (len(samples), samples[0]))
			
		# The signal is from ADC0 or ADC1
		if input_number == 0:
			f_reference = float(self.ddc0_frequency_in_int) / 2**48
		elif input_number == 1:
			f_reference = float(self.ddc1_frequency_in_int) / 2**48
		
		
		ref_exp = (ref_exp0)/np.abs(ref_exp0) * np.exp(-1j*2*np.pi*f_reference*np.array(range(len(samples))))
		complex_baseband = (samples-np.mean(samples)) * ref_exp
		
		# There are two versions of the firmware in use: one uses a 20points boxcar filter,
		# the other one uses a wider bandwidth filter, consisting of a cascade of a 2-pts boxcar, another 2-pts boxcar, and finally a 4-points boxcar.
		if input_number == 0:
			filter_select = self.ddc0_filter_select
			angle_select  = self.ddc0_angle_select
		else:
			filter_select = self.ddc1_filter_select
			angle_select  = self.ddc1_angle_select
			
		
		if filter_select == 0:
			N_filter = 16
			lpf = np.convolve(np.ones(2, dtype=float)/2., np.ones(2, dtype=float)/2.)
			lpf = np.convolve(np.ones(4, dtype=float)/4., lpf)
			
		elif filter_select == 1:
			N_filter = 20
			lpf = np.convolve(np.ones(4, dtype=float)/4., np.ones(16, dtype=float)/16.)
		elif filter_select == 2:
			N_filter = 16+2
			lpf = np.array([4533, 11833, 14589, 7610, -2628, -5400, -350, 3293, 1086, -1867, -1080, 956, 800, -462, -650, 338])/(2.**15-1)
			lpf = np.convolve(np.ones(2, dtype=float)/2., lpf)
#            print(lpf)
		complex_baseband = lfilter(lpf, 1, complex_baseband)[N_filter:]
		return complex_baseband
		

		
		
	def get_frontend_filter_response(self, frequency_axis, input_number):
		if self.bVerbose == True:
			print('get_frontend_filter_response')
			
		if input_number == 0:
			f_reference = float(self.ddc0_frequency_in_int) / 2**48
		elif input_number == 1:
			f_reference = float(self.ddc1_frequency_in_int) / 2**48
			
		f_reference = ((f_reference+0.5) % 1)-0.5  # The modulo converts a frequency above Nyquist to the matching negative frequency
		f_reference = f_reference * self.fs
		
		if input_number == 0:
			filter_select = self.ddc0_filter_select
			angle_select  = self.ddc0_angle_select
		else:
			filter_select = self.ddc1_filter_select
			angle_select  = self.ddc1_angle_select
		
		if filter_select == 0:
			# wideband filter
			spc_filter = np.ones(frequency_axis.shape, dtype=float)
			N_filter = 2
			spc_filter = spc_filter * np.sin(np.pi * (abs(frequency_axis-abs(f_reference))+10)*N_filter/self.fs)/ (np.pi*(abs(frequency_axis-abs(f_reference))+10)*N_filter/self.fs)
			spc_filter = spc_filter * np.sin(np.pi * (abs(frequency_axis-abs(f_reference))+10)*N_filter/self.fs)/ (np.pi*(abs(frequency_axis-abs(f_reference))+10)*N_filter/self.fs)
			N_filter = 4
			spc_filter = spc_filter * np.sin(np.pi * (abs(frequency_axis-abs(f_reference))+10)*N_filter/self.fs)/ (np.pi*(abs(frequency_axis-abs(f_reference))+10)*N_filter/self.fs)
			
			spc_filter = 20*np.log10(np.abs(spc_filter) + 1e-7)
		elif filter_select == 1:
			# narrowband filter
			N_filter = 16
			spc_filter = np.sin(np.pi * (abs(frequency_axis-abs(f_reference))+10)*N_filter/self.fs)/ (np.pi*(abs(frequency_axis-abs(f_reference))+10)*N_filter/self.fs)
			N_filter = 4
			spc_filter = spc_filter * np.sin(np.pi * (abs(frequency_axis-abs(f_reference))+10)*N_filter/self.fs)/ (np.pi*(abs(frequency_axis-abs(f_reference))+10)*N_filter/self.fs)
			
			spc_filter = 20*np.log10(np.abs(spc_filter) + 1e-7)
		elif filter_select == 2:
			# minimum-phase fir filter:
			lpf = np.array([4533, 11833, 14589, 7610, -2628, -5400, -350, 3293, 1086, -1867, -1080, 956, 800, -462, -650, 338])/(2.**15-1)
			lpf = np.convolve(np.ones(2, dtype=float)/2., lpf)
			spc_ref = np.fft.fft(lpf, 2*len(frequency_axis))
			freq_axis_ref = np.linspace(0*self.fs, 1*self.fs, 2*len(frequency_axis))
			spc_filter = np.interp(abs(frequency_axis-abs(f_reference)), freq_axis_ref, np.abs(spc_ref))
			spc_filter = 20*np.log10(np.abs(spc_filter) + 1e-7)
			
		else:
			spc_filter = np.ones(frequency_axis.shape, dtype=float)	# just a placeholoder so we don't crash the next function in the processing chain
			print("Error: invalid filter selector = %d for ddc%d.  This probably indicates a bug while writing or reading this register." % (filter_select, input_number))
			

		return spc_filter
		
	def setCounterMode(self, bTriangular):
		if self.bVerbose == True:
			print('setCounterMode')
			
		# bTriangular = 1 means triangular averaging, bTriangular = 0 means rectangular averaging
		self.send_bus_cmd_16bits(self.BUS_ADDR_triangular_averaging, bTriangular)
		self.bTriangularAveraging = bTriangular

	def getCounterMode(self):
		if self.bVerbose == True:
			print('getCounterMode')

		self.bTriangularAveraging = self.read_RAM_dpll_wrapper(self.BUS_ADDR_triangular_averaging)
		return self.bTriangularAveraging

	def scaleCounterReadingsIntoHz(self, freq_counter_samples, f_ref=None, N_cycles_gate_time=None):
		if self.bVerbose == True:
			print('scaleCounterReadingsIntoHz')

		if f_ref is None:
			f_ref = self.fs
		if N_cycles_gate_time is None:
			N_cycles_gate_time = self.N_CYCLES_GATE_TIME
			
		# Scale the counter values into Hz units:
		# f = data_out * fs / 2^N_INPUT_BITS / conversion_gain
		N_INPUT_BITS = 10
		if self.bTriangularAveraging:
			conversion_gain = N_cycles_gate_time * (N_cycles_gate_time + 1)
		else:
			# Rectangular averaging:
			conversion_gain = N_cycles_gate_time
		try:
			freq_counter_samples = freq_counter_samples.astype(np.float)
		except AttributeError:
			# if freq_counter_samples is not a numpy type, we might get this exception
			freq_counter_samples = float(freq_counter_samples)

		freq_counter_samples = freq_counter_samples * f_ref / 2**(N_INPUT_BITS) / conversion_gain
		return freq_counter_samples


	def new_freq_setting(self):
		# Check if dither is set, then call 
#        setVNA_mode_register(self, trigger_dither, stop_flag, bSquareWave):
		self.new_freq_setting_number = self.new_freq_setting_number + 1
		modulation_frequency_in_hz = ((self.new_freq_setting_number-1)/2) * 0.05 + 0.025

		output_select = 0
		bSquareWave = False
		# half the time we turn the modulation on, half the time we turn it off
		if self.new_freq_setting_number % 2 == 0:
			bEnableDither = True
		else:
			bEnableDither = False
		output_amplitude = int(float(self.DACs_limit_high[output_select] - self.DACs_limit_low[output_select])*float(0.01)/2)
		

		# This is only really to set the dither
		# we don't care about these values:
		input_select = 0
		number_of_frequencies = 8
		System_settling_time = 1e-3
		self.setup_system_identification(input_select, output_select, modulation_frequency_in_hz, modulation_frequency_in_hz, number_of_frequencies, System_settling_time, output_amplitude, 0)
		
		print('new_freq_setting: (output_select, modulation_frequency_in_hz, output_amplitude, bSquareWave, bEnableDither) = %d, %f, %f, %d, %d' % (output_select, modulation_frequency_in_hz, output_amplitude, bSquareWave, bEnableDither))
		
		trigger_dither = bEnableDither
		if bEnableDither == False:
			stop_flag = 1
		else:
			stop_flag = 0
		self.setVNA_mode_register(trigger_dither, stop_flag, bSquareWave)
		print('(trigger_dither, stop_flag, bSquareWave) = %d, %d, %d' % (trigger_dither, stop_flag, bSquareWave))

	def read_dual_mode_counter(self, output_number):
		# fetch data
		# reading at this address samples all frequency counter data at the same time (see registers_read.vhd for details)
		zdtc_samples_number_counter = self.dev.read_Zynq_register_uint32(self.BUS_ADDR_ZERO_DEADTIME_SAMPLES_NUMBER*4)
		increments = zdtc_samples_number_counter - self.last_zdtc_samples_number_counter[output_number]
		if increments != 0:

			# # this is used only for internal testing of the frequency counter's transfer function
			# if output_number == 0:
			#     if zdtc_samples_number_counter-self.last_freq_update == 50 or self.last_freq_update == 0:
			#         self.new_freq_setting()
			#         self.last_freq_update = zdtc_samples_number_counter


			# we have new unread samples
			freq_counter0_sample = self.dev.read_Zynq_register_int64(self.BUS_ADDR_ZERO_DEADTIME_COUNTER0_LSBS*4, self.BUS_ADDR_ZERO_DEADTIME_COUNTER0_MSBS*4)
			freq_counter1_sample = self.dev.read_Zynq_register_int64(self.BUS_ADDR_ZERO_DEADTIME_COUNTER1_LSBS*4, self.BUS_ADDR_ZERO_DEADTIME_COUNTER1_MSBS*4)
			# print("zdtc_samples_number_counter = %d, was %d, read new values" % (zdtc_samples_number_counter, self.last_zdtc_samples_number_counter[output_number]))
			if increments>1 and self.last_zdtc_samples_number_counter[output_number] != 0:
				print("Warning, %d counter sample(s) dropped on counter #%d" % (zdtc_samples_number_counter-self.last_zdtc_samples_number_counter[output_number]-1, output_number))
				self.logger.warning('Red_Pitaya_GUI{}: {} counter sample(s) dropped on counter #{}"'.format(self.logger_name, (zdtc_samples_number_counter-self.last_zdtc_samples_number_counter[output_number]-1),output_number))
		else:
			# we have already read all the counter samples for this output
			freq_counter0_sample = None
			freq_counter1_sample = None
			# print("zdtc_samples_number_counter = %d, was %d, didn't read values" % (zdtc_samples_number_counter, self.last_zdtc_samples_number_counter[output_number]))
		self.last_zdtc_samples_number_counter[output_number] = zdtc_samples_number_counter



		dac0_samples = self.dev.read_Zynq_register_int32(self.BUS_ADDR_DAC0_CURRENT*4)
		dac1_samples = self.dev.read_Zynq_register_int32(self.BUS_ADDR_DAC1_CURRENT*4)
		dac2_samples = self.dev.read_Zynq_register_uint32(self.BUS_ADDR_DAC2_CURRENT*4) #this doesn't seems to work
		if dac2_samples>0xFFFF0000: #greather than 16 bits
			dac2_samples = dac2_samples-0xFFFF0000
		# convert to numpy format:
		dac0_samples = np.array((dac0_samples,))
		dac1_samples = np.array((dac1_samples,))
		dac2_samples = np.array((dac2_samples,))

		# scale to physical units
		if freq_counter0_sample is not None:
			freq_counter0_sample = self.scaleCounterReadingsIntoHz(freq_counter0_sample)
		if freq_counter1_sample is not None:
			freq_counter1_sample = self.scaleCounterReadingsIntoHz(freq_counter1_sample)


		time_axis = None # not currently used anymore
		if output_number == 0:
			return (freq_counter0_sample, time_axis, dac0_samples, dac1_samples, dac2_samples)
		elif output_number == 1:
			return (freq_counter1_sample, time_axis, dac0_samples, dac1_samples, dac2_samples)
		
	def set_ddc_filter(self, adc_number, filter_select, angle_select = 0):
		if self.bVerbose == True:
			print('set_ddc_filter')
			
		
		if adc_number == 0:
			self.ddc0_filter_select = filter_select
			self.ddc0_angle_select = angle_select
		elif adc_number == 1:
			self.ddc1_filter_select = filter_select
			self.ddc1_angle_select = angle_select
			
		self.set_ddc_filter_select_register()
		
	def set_ddc_filter_select_register(self):
		if self.bVerbose == True:
			print('set_ddc_filter_select_register')

			
		# takes the internal states and dumps them to the fpga:
		register_value = self.ddc0_filter_select + (self.ddc1_filter_select<<2) + (self.residuals0_phase_or_freq<<4) + (self.residuals1_phase_or_freq<<5)
		self.send_bus_cmd_16bits(self.BUS_ADDR_ddc_filter_select, register_value)
		#print('set_ddc_filter_select_register: FILTER_SELECT %d' % register_value)
		
		register_value = self.ddc0_angle_select + (self.ddc1_angle_select<<4) 
		self.send_bus_cmd_16bits(self.BUS_ADDR_ddc_angle_select, register_value)
		#print('set_ddc_filter_select_register: ANGLE_SELECT %d' % register_value)
		
	def get_ddc_filter_select(self):
		if self.bVerbose == True:
			print('get_ddc_filter_select')

		data = self.read_RAM_dpll_wrapper(self.BUS_ADDR_ddc_filter_select)
		self.ddc0_filter_select = (data   ) & int('11', 2)
		self.ddc1_filter_select = (data>>2) & int('11', 2)

		return (self.ddc1_filter_select, self.ddc0_filter_select)

	def get_ddc_angle_select(self):
		if self.bVerbose == True:
			print('get_ddc_angle_select')

		data = self.read_RAM_dpll_wrapper(self.BUS_ADDR_ddc_angle_select)
		self.ddc0_angle_select = int(data%(2**4))
		self.ddc1_angle_select = int((data - self.ddc0_angle_select)/(2**4))

		return (self.ddc1_angle_select, self.ddc0_angle_select)
		

	# This mux selects the source of the error signal to the loop filter of channel 2.
	# This makes it possible to select:
	# register_value = 0: the output of DDC2 (the normal, 2 independent channels operation)
	# register_value = 1: the output of DDC1 (allows two different loop filter settings being applied to the same error signal)
	# register_value = 2: the output of the channel 1's loop filter, to allow locking the same beat note with two actuators
	def set_mux_pll2(self, register_value):
		if self.bVerbose == True:
			print('set_mux_pll2')
		self.mux_pll2 = register_value
		self.send_bus_cmd_16bits(self.BUS_ADDR_mux_pll2, register_value)
		
	

		
	# scales the offset of the output tone produced by the VCO right before the ADC.
	# offset = [-1 to 1]
	def set_internal_VCO_offset(self, offset):
		if self.bVerbose == True:
			print('set_internal_VCO_offset')
		self.vco_offset_in_volt = offset
		vco_offset = round(offset*(2**13-1)) #13 bits, because offset is signed
		self.dev.write_Zynq_register_uint32(self.BUS_ADDR_vco_offset, vco_offset)

	def get_internal_VCO_offset(self):
		if self.bVerbose == True:
			print('get_internal_VCO_offset')
		raw = self.dev.read_Zynq_register_uint32(self.BUS_ADDR_vco_offset)   
		if raw > ((1<<13)-1):
			raw = -(0b11111111111111-raw+1) 	#Because the value is consider as an signed integer
		offset = raw/(2**13-1)
		self.vco_offset_in_volt = offset
		return offset



	# scales the output tone produced by the VCO right before the ADC.
	# amplitude = [0 to 1]
	# amplitude = 1 means 1 V peak of output, or 2 Vpeak-peak.
	def set_internal_VCO_amplitude(self, amplitude):
		if self.bVerbose == True:
			print('set_internal_VCO_amplitude')
		self.vco_amplitude_in_volt = amplitude
		vco_amplitude = round(amplitude*(2**15-1)) #15 bits, because amplitude is signed
		self.dev.write_Zynq_register_uint32(self.BUS_ADDR_vco_amplitude, vco_amplitude)

	def get_internal_VCO_amplitude(self):
		if self.bVerbose == True:
			print('get_internal_VCO_amplitude')
		raw = self.dev.read_Zynq_register_uint32(self.BUS_ADDR_vco_amplitude)   
		if raw > ((1<<15)-1):
			raw = -(0xFFFF-raw+1) 	#Because the value is consider as an signed integer
		amplitude = raw/(2**15-1)
		self.vco_amplitude_in_volt = amplitude
		return amplitude

	#This mux selects the source of the VCO frequency and the output DAC to which the VCO is connected
	# register_value = 0 : the VCO is not connected (normal operation)
	# register_value = 1 : the VCO is connected to the DACa
	# register_value = 2 : the VCO is connected to the DACb
	def set_mux_vco(self, data):
		if self.bVerbose == True:
			print('set_mux_vco')

		self.dev.write_Zynq_register_uint32(self.BUS_ADDR_vco_mux, data)
		if data == 0 :
			self.output_vco = [0, 0, 0]
		elif data == 1:
			self.output_vco = [1, 0, 0]
		elif data == 2:
			self.output_vco = [0, 1, 0]

	   
	def get_mux_vco(self):
		if self.bVerbose == True:
			print('get_mux_vco')
		mux_value = self.dev.read_Zynq_register_uint32(self.BUS_ADDR_vco_mux)
		if mux_value == 0 :
			self.output_vco = [0, 0, 0]
		elif mux_value == 1:
			self.output_vco = [1, 0, 0]
		elif mux_value == 2:
			self.output_vco = [0, 1, 0]
		return mux_value

	def read_RAM_dpll_wrapper(self,addr):
		bus_address = (2 << 20) + addr*4
		value = self.dev.read_Zynq_register_uint32(bus_address)
		if value == 4026531839:
			print('Warning! You received the default value when asking for data at address {}.'.format(hex(int(addr))))
			self.logger.warning('Red_Pitaya_GUI{}: Warning! You received the default value when asking for data at address {}"'.format(self.logger_name, hex(int(addr))))
		return value

	def read_RAM_dpll_wrapper_signed(self,addr):
		bus_address = (2 << 20) + addr*4
		value = self.dev.read_Zynq_register_int32(bus_address)
		if value == 4026531839 - 2**32:
			print('Warning! You received the default value when asking for data at address {}.'.format(hex(int(addr))))
			self.logger.warning('Red_Pitaya_GUI{}: Warning! You received the default value when asking for data at address {}"'.format(self.logger_name, hex(int(addr))))
		return value



	def read_pll2_mux(self):
		if self.bVerbose == True:
			print('read_pll2_mux')
		mux_value = self.read_RAM_dpll_wrapper(self.BUS_ADDR_mux_pll2)
		self.mux_pll2 = mux_value
		return mux_value

	def save_openLoop_gain(self, dac_number, value):
		if self.bVerbose == True:
			print('save_openLoop_gain')
		value = int(round(2**32 * value/4))
		self.dev.write_Zynq_register_uint32(self.BUS_ADDR_openLoopGain[dac_number]*4, value)

	def get_openLoop_gain(self, dac_number):
		if self.bVerbose == True:
			print('get_openLoop_gain')
		value = self.read_RAM_dpll_wrapper(self.BUS_ADDR_openLoopGain[dac_number])
		VCO_gain_in_counts_per_counts = value*4/2**32
		return VCO_gain_in_counts_per_counts

	def save_mode_auto(self, dac_number, mode):
		if self.bVerbose == True:
			print('save_mode_auto')
		self.dev.write_Zynq_register_uint32(self.BUS_ADDR_dither_mode_auto[dac_number]*4, mode)

	# def get_mode_auto(self, dac_number):
	# 	if self.bVerbose == True:
	# 		print('get_mode_auto')
	# 	self.dither_mode_auto[dac_number] = self.read_RAM_dpll_wrapper(self.BUS_ADDR_dither_mode_auto[dac_number])
	# 	return self.dither_mode_auto[dac_number]


	def setFan(self, fanState):
		addr = 0x18
		bus_address = (3 << 20) + addr

		self.fanState = fanState

		if fanState:
			data = 0b11000000
		else:
			data = 0b00000000

		self.dev.write_Zynq_register_uint32(bus_address, data)


	def setTestOscillator(self, bEnable=1, bPolarity=1, oscillator_modulus=625, oscillator_modulus_active=62):

		# print("setTestOscillator(): bEnable=%d, bPolarity=%d, oscillator_modulus=%d, oscillator_modulus_active=%d" % (bEnable, bPolarity, oscillator_modulus, oscillator_modulus_active) )

		reg1 = (int(bPolarity)<<25) + (int(bEnable)<<24) + (oscillator_modulus & ((1<<24)-1))
		reg2 = (oscillator_modulus_active & ((1<<24)-1))
		# print("setTestOscillator(): reg1=%d, reg2=%d" % (reg1, reg2) )
		self.send_bus_cmd_32bits(self.BUS_ADDR_TEST_OSC, reg1)
		self.send_bus_cmd_32bits(self.BUS_ADDR_TEST_OSC_DUTY, reg2)


	# clock select register. 0 = internal, 1 = external
	def setClockSelector(self, bExternalClock=0):
		# in the actual register, 1 means internal clock, 0 means external
		reg = int(not bExternalClock)
		print("setClockSelector: bExternalClock=%d. writing 0x%x (decimal %d) to 0x%x" % (bExternalClock, reg, reg, self.clk_sel_base_addr))
		self.dev.write_Zynq_AXI_register_uint32(self.clk_sel_base_addr, reg)

	def read_clk_select(self):
		# in the actual register, 1 means internal clock, 0 means external
		reg = self.dev.read_Zynq_register_32bits(self.clk_sel_base_addr)		
		self.clk_select = (not reg)
		return self.clk_select

	# f_source is the frequency of the selected clock source (200 MHz in internal clock mode, can be whatever is connected to GPIO_P[5] in external clock mode)
	def setADCclockPLL(self, f_source, bExternalClock, CLKFBOUT_MULT, CLKOUT0_DIVIDE):
		DIVCLK_DIVIDE = 1
		VCO_freq = f_source * CLKFBOUT_MULT/DIVCLK_DIVIDE
		print('VCO_freq = %f MHz, valid range is 600-1600 MHz according to the datasheet (DS181)' % (VCO_freq/1e6))

		# From PG065:
		# "You should first write all the required clock configuration registers and then check for the
		# status register. If status register value is 0x1, start the reconfiguration by writing Clock
		# Configuration Register 23 with 0x7. The next write should be 0x2 before the Locked goes
		# High. If the original configuration is needed at any time, then writing this register with value
		# 0x4 and then 0x0 restores the original settings."

		# Clock configuration register 0 (table 4-2 in PG065)
		reg  = (DIVCLK_DIVIDE & ((1<<8)-1)) << 0
		reg |= (CLKFBOUT_MULT & ((1<<8)-1)) << 8
		self.dev.write_Zynq_AXI_register_uint32(self.clkw_base_addr + 0x200, reg)
		# Clock configuration register 2 (table 4-2 in PG065)
		reg = (CLKOUT0_DIVIDE & ((1<<8)-1)) << 0
		self.dev.write_Zynq_AXI_register_uint32(self.clkw_base_addr + 0x208, reg)

		# check status register:
		time_start = time.clock()
		status_reg = 0x0
		while status_reg != 0x1 and time.clock()-time_start < 1.: # 1 sec timeout
			status_reg = self.dev.read_Zynq_AXI_register_uint32(self.clkw_base_addr+0x04)

		if status_reg != 0x1:
			print("Error: timed out waiting for status_reg to become 0x1 (PLL locked)")
			return

		reg_clk_sel_and_reset = int(not bExternalClock) | (1<<1)
		self.dev.write_Zynq_AXI_register_uint32(self.clk_sel_base_addr, reg_clk_sel_and_reset) # assert reset on the incoming ADC clock 
		self.dev.write_Zynq_AXI_register_uint32(self.clkw_base_addr + 0x25C, 0x7)
		self.dev.write_Zynq_AXI_register_uint32(self.clkw_base_addr + 0x25C, 0x2) # this needs to happen before the locked status goes high according to the datasheet.  Not sure what the impact is if we don't honor this requirement

		self.fs = f_source * CLKFBOUT_MULT/CLKOUT0_DIVIDE
		time.sleep(0.1)
		reg_clk_sel_and_reset = int(not bExternalClock) | (0<<1) # de-assert reset on the incoming ADC clock
		self.dev.write_Zynq_AXI_register_uint32(self.clk_sel_base_addr, reg_clk_sel_and_reset) # assert reset on the incoming ADC clock 
		
		self.resetFrontend() # all clocks should now be stable, reset everything else

	# xadc_channel can be [0, 15]
	def readZynqXADC(self, xadc_channel=0):
		###########################################################################
		# Reading the XADC values:
		# See Xilinx document UG480 chapter 2 for conversion factors
		# we use 2**16 instead of 2**12 for the denominator because the codes are "MSB-aligned" in the register (equivalent to a multiplication by 2**4)
		xadc_unipolar_code_to_voltage    = lambda x: x*1./2.**16
		return xadc_unipolar_code_to_voltage(self.dev.read_Zynq_AXI_register_uint32(self.xadc_base_addr+0x240+4*xadc_channel)   )


	# read various power supply voltages on the Zynq using the XADC:
	def readZynqXADCsupply(self):
		###########################################################################
		# Reading the XADC values:
		# See Xilinx document UG480 chapter 2 for conversion factors
		# we use 2**16 instead of 2**12 for the denominator because the codes are "MSB-aligned" in the register (equivalent to a multiplication by 2**4)
		xadc_powersupply_code_to_voltage = lambda x: x*3./2.**16
		Vccint = xadc_powersupply_code_to_voltage(self.dev.read_Zynq_AXI_register_uint32(self.xadc_base_addr+0x204)   )
		Vccaux = xadc_powersupply_code_to_voltage(self.dev.read_Zynq_AXI_register_uint32(self.xadc_base_addr+0x208)   )
		Vbram  = xadc_powersupply_code_to_voltage(self.dev.read_Zynq_AXI_register_uint32(self.xadc_base_addr+0x218)   )
		return (Vccint, Vccaux, Vbram)

	# read the Zynq's current temperature:
	def readZynqTemperature(self):
		###########################################################################
		# Reading the XADC values:
		# See Xilinx document UG480 chapter 2 for conversion factors
		# we use 2**16 instead of 2**12 for the denominator because the codes are "MSB-aligned" in the register (equivalent to a multiplication by 2**4)
		xadc_temperature_code_to_degC    = lambda x: x*503.975/2.**16-273.15
		time_start = time.clock()
		# average 10 readings because otherwise they are quite noisy:
		# this reading loop takes just 2 ms for 10 readings at the moment so there is no real cost
		N_average = 10.
		reg_avg = 0.
		for k in range(int(N_average)):
			reg = self.dev.read_Zynq_AXI_register_uint32(self.xadc_base_addr+0x200)
			reg_avg += float(reg)
			
		reg_avg = float(reg_avg)/N_average
		# print("elapsed = %f" % (time.clock()-time_start))
		ZynqTempInDegC = xadc_temperature_code_to_degC(  reg_avg  )
		return ZynqTempInDegC
		
	def getExtClockFreq(self):
		# see "digital_clock_freq_counter.vhd" for the meaning of each of these registers.
		read_all_regs = lambda : (self.dev.read_Zynq_AXI_register_uint32(self.clk_freq_reg1),
		                          self.dev.read_Zynq_AXI_register_uint32(self.clk_freq_reg2),
		                          self.dev.read_Zynq_AXI_register_uint32(self.clk_freq_reg3))
		data_index = lambda x: (x >> 24)
		iAttempts = 0;
		bSuccess = False
		while iAttempts < 2:
			(reg1, reg2, reg3) = read_all_regs()
			# these three need to match.  If they don't, this means that the data changed in between our three reads.
			# try another time to read all three registers.  It should succeed, since the counter updates only at 1 Hz
			if data_index(reg1) == data_index(reg2) == data_index(reg3):
				bSuccess = True
				break
		    
			iAttempts += 1
		if not bSuccess:
			return np.nan
		freq_64bits = (((reg1 & 0x00FFFFFF) <<  0) + 
		               ((reg2 & 0x00FFFFFF) << 24) + 
		               ((reg3 & 0x0000FFFF) << 48))
		# print("getExtClockFreq(): reg1=0x%08x, reg2=0x%08x, reg3=0x%08x" % (reg1, reg2, reg3))
		# print("getExtClockFreq(): freq_64bits=0x%08x" % (freq_64bits))
		freq_Hz = self.scaleCounterReadingsIntoHz(freq_64bits, f_ref=200e6, N_cycles_gate_time=200e6) # reference frequency in this case is 200 MHz: fclk[3] from the block design
		freq_Hz = freq_Hz * 2**10 # this is because this counter has no fractional bits on its phase measurement, so the gain is effectively 2**FRACT_BITS lower, with FRACT_BITS=10
		# print("getExtClockFreq(): freq_Hz=%e Hz" % freq_Hz)
		return freq_Hz
        
# end class definition
