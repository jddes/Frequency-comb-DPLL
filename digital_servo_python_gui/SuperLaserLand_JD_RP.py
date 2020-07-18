# -*- coding: utf-8 -*-
"""
XEM6010 Phase-lock box communication interface,
by JD Deschenes, October 2013
Modified January 2016 to interface with the Red Pitaya port of the phase-lock box

"""
from __future__ import print_function
import time     # used for time.sleep()
import numpy as np
from scipy.signal import lfilter
import sys
import traceback
import weakref
import logging

from SuperLaserLand2_JD2_PLL import PLL0_module, PLL1_module, PLL2_module
import RP_PLL
import bin_conv
import adf4351_ctrl_through_uart
import adf4351

from common import make_sure_path_exists, tictoc

class SuperLaserLand_JD_RP:
	# Data members:
	############################################################
	# System parameters:
	fs = 125e6  # adc sampling rate
	bDDR2InUse = False  # Each function that uses the DDR2 logger module should make sure that this isn't set before changing any setting
	bCommunicationLogging = False   # Turn On/Off logging of the USB communication with the FPGA box
	bVerbose = False
	
	
	ddc_frequency_in_hz = 4*[25e6]
	ddc_frequency_in_int = 4*[int(round(25e6/100e6 * 2**48))]

	DAC0_gain = 1
	DAC1_gain = 1
	DAC2_gain = 2
	DACs_limit_low = [-2**15, -2**15, 0]
	DACs_limit_high = [2**15-1, 2**15-1, 2**16-1]
	DACs_offset = [2**14, 2**14, -2**15]

	# input channels ids start from 1
	num_channels = 4
	channels_list = list(range(1, num_channels+1))

	# dac ids start from 0
	num_dacs = 2
	dacs_list = list(range(0, num_dacs+1))

	# addresses from the "IP integrator block design" (see address editor)
	# there is also an offset of 0x8000_0000 applied in RP_PLL
	xadc_base_addr    = 0x0001_0000
	clkw_base_addr    = 0x0002_0000
	clk_sel_base_addr = 0x0003_0000
	clk_freq_reg1     = 0x0004_0000
	clk_freq_reg2     = 0x0004_0008
	clk_freq_reg3     = 0x0005_0000
	reg_to_uart       = 0x0005_0008

	############################################################
	BUS_ADDR_MUX_SELECTORS                              = 0x0001
	
	DATA_LOGGER_ZYNQ_INDEX                              = 1  # taken from red_pitaya_top.v, from this line: .sys_wen              (  sys_wen[1]                 ),  // write enable
	BUS_ADDR_TRIG_WRITE                                 = (DATA_LOGGER_ZYNQ_INDEX<<20) + 0x1004    # writing anything to this address triggers the write mode in ram_data_logger.vhd
	# NOTE THAT THIS MODULE (ram_data_logger.vhd) IS IMPLEMENTED OUTSIDE OF DPLL_WRAPPER.V AND THUS IT is part of a different address mapping: this is a direct address offset in the Zynq address space, contrary to most of the other addresses here, which are multiplied by 4 by the conversion layer to avoid breaking 32 bits boundaries
	
	# Addresses for the output DAC offsets:
	BUS_ADDR_DAC_offset                                = [0x0002, 0x0003]
	# DAC limits
	BUS_ADDR_dac_limit                                = (0x0004, 0x0005)
	
	# DDC frequency settings
	BUS_ADDR_ref_freq = [0x0007, 0x0009, 0x000B, 0x000D] # these are all 64-bits registers, so they also occupy the next adjacent addresses, ie 0x8001, 0x8011, etc
	############################################################
	
	############################################################
	# Constants for the input multiplexer going to the DDR2Logger
	LOGGER_MUX = {
		'ADC1':          0,
		'ADC2':          1,
		'IQ1':           2,
		'IQ2':           3,
		'IQ3':           4,
		'IQ4':           5,
		'IN6':           6,           # unused for now
		'IN7':           7,           # unused for now
		'IN8':           8,           # unused for now
		'IN9':           2**4,        # unused for now
		'IN10':          2**4 + 2**3, # unused for now
		}
	############################################################
	
	def __init__(self, controller = None):
		self.logger = logging.getLogger(__name__)
		self.logger_name = ':SuperLaserLand_JD_RP'

		strNameTemplate = time.strftime("data_logging\\%m_%d_%Y_%H_%M_%S_")
		# Create the subdirectory if it doesn't exist:
		make_sure_path_exists('data_logging')

		self.adf4351 = dict()

		if controller is not None:
			self.controller = weakref.proxy(controller)
		else:
			self.controller = None

		self.dev = RP_PLL.RP_PLL_device(self.controller)
		self.phaseReadoutDriver = phaseReadoutDriver(self.dev)
			
	def send_bus_cmd(self, bus_address, data1, data2):
		self.dev.write_Zynq_register_uint32(int(bus_address)*4, (int(data2)<<16) + int(data1))
		
	def send_bus_cmd_16bits(self, bus_address, data_16bits):
		data_lsbs = int(data_16bits) & 0xFFFF
		self.dev.write_Zynq_register_uint32(int(bus_address)*4, data_lsbs)

	def send_bus_cmd_32bits(self, bus_address, data_32bits):
		self.dev.write_Zynq_register_uint32(int(bus_address)*4, int(data_32bits))

	def send_bus_cmd_64bits(self, bus_address_lower, data_64bits):
		data_32bits_lower =  data_64bits      & 0xFFFFFFFF
		data_32bits_upper = (data_64bits>>32) & 0xFFFFFFFF
		self.dev.write_Zynq_register_uint32(int(bus_address_lower  )*4, int(data_32bits_lower))
		self.dev.write_Zynq_register_uint32(int(bus_address_lower+1)*4, int(data_32bits_upper))
		
	def getDataFromLogger(self, selector, Num_samples):
		self.dev.write_Zynq_register_uint32(self.BUS_ADDR_MUX_SELECTORS*4, selector)
		self.dev.write_Zynq_register_uint32(self.BUS_ADDR_TRIG_WRITE, 0) # value is ignored here, just the fact that we are writing is sufficient
		time.sleep(2e-3) # max write duration is 2**15/(125e6/6) = 1.6 ms
		data_buffer = self.dev.read_Zynq_buffer_int16(Num_samples)
		buffer_numpy = np.fromstring(data_buffer, dtype=np.int16)
		return buffer_numpy
	
	def set_dac_offset(self, dac_number, offset):
		""" dac_number can be either 0 or 1 """
		assert dac_number in self.dacs_list
		#print('set_dac_offset(): dac #%d, offset = %d' % (dac_number, offset))
		self.DACs_offset[dac_number] = offset
		self.send_bus_cmd_32bits(self.BUS_ADDR_DAC_offset[dac_number], offset)

	def set_ddc_ref_freq(self, frequency_in_hz, channel_id):
		""" channel_id can be either 1, 2, 3 or 4 """
		assert channel_id in self.channels_list
		dds_freq_word = int(round(2**48 * frequency_in_hz/self.fs))
		dds_freq_word = dds_freq_word % (1 << 48) # modulo 2**48
		print("dds_freq_word(channel%d) = %s/2**48" % (channel_id, dds_freq_word))
		self.send_bus_cmd_64bits(self.BUS_ADDR_ref_freq[channel_id-1], dds_freq_word)
		self.ddc_frequency_in_int[channel_id-1] = dds_freq_word

	def get_dac_offset(self, dac_number):
		offset = self.read_RAM_dpll_wrapper(self.BUS_ADDR_DAC_offset[dac_number])
		offset = offset & 0xFFFF
		
		if dac_number < 2:	# DAC 2 is unsigned
			if offset > ((1<<15)-1):
					offset = -(0xFFFF-offset+1)

		self.DACs_offset[dac_number] = offset

		return offset

	def set_dac_limits(self, dac_number, limit_low, limit_high, bSendToFPGA = True):
			
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
		# Read FPGA to get the current value
		self.ddc0_frequency_in_int = (self.read_RAM_dpll_wrapper(self.BUS_ADDR_ref_freq0_msbs) << 32) + self.read_RAM_dpll_wrapper(self.BUS_ADDR_ref_freq0_lsbs)

		if self.ddc0_frequency_in_int > ((1<<47)-1):
			self.ddc0_frequency_in_int = -(0xFFFFFFFFFFFF-self.ddc0_frequency_in_int+1)

		frequency_in_hz = float(self.ddc0_frequency_in_int) / 2**48 * self.fs
		return frequency_in_hz

	def get_ddc0_ref_freq(self):
			
		# This only gives the correct answer if either: this object has explicitely ran its set_ddc0_ref_freq() function.
		# or: the default value in the FPGA firmware matches the one in self.frequency_in_int defined as a data member.
		frequency_in_hz = float(self.ddc0_frequency_in_int) / 2**48 * self.fs
		return frequency_in_hz

	def get_ddc1_ref_freq_from_RAM(self):
		# Read FPGA to get the current value
		self.ddc1_frequency_in_int = (self.read_RAM_dpll_wrapper(self.BUS_ADDR_ref_freq1_msbs) << 32) + self.read_RAM_dpll_wrapper(self.BUS_ADDR_ref_freq1_lsbs)

		if self.ddc1_frequency_in_int > ((1<<47)-1):
			self.ddc1_frequency_in_int = -(0xFFFFFFFFFFFF-self.ddc1_frequency_in_int+1)

		frequency_in_hz = float(self.ddc1_frequency_in_int) / 2**48 * self.fs
		return frequency_in_hz

	def get_ddc1_ref_freq(self):
		# This only gives the correct answer if either: this object has explicitely ran its set_ddc0_ref_freq() function.
		# or: the default value in the FPGA firmware matches the one in self.frequency_in_int defined as a data member.
		frequency_in_hz = float(self.ddc1_frequency_in_int) / 2**48 * self.fs
		return frequency_in_hz

	def get_ddc_filter(self):
		return np.array([-909, 1718, 4689, 10090, 18371, 29803, 44256, 61034, 78773, 95424, 108353, 114569, 111075, 95319, 65698, 22057, -33908, -98401, -165516, -227493, -275271, -299287, -290477, -241376, -147158, -6537, 177657, 398280, 644147, 900763, 1151462, 1378852, 1566415, 1700080, 1769608, 1769608, 1700080, 1566415, 1378852, 1151462, 900763, 644147, 398280, 177657, -6537, -147158, -241376, -290477, -299287, -275271, -227493, -165516, -98401, -33908, 22057, 65698, 95319, 111075, 114569, 108353, 95424, 78773, 61034, 44256, 29803, 18371, 10090, 4689, 1718, -909])
		
	def getFreqDiscriminatorGain(self):
		return 2**10/self.fs

	def convertADCCountsToVolts(self, ADC_number, counts):
		ADC_gain = 1.
		ADC_bits = 16.
		Volts_max_for_unit_gain = 1. # Nominal value is 1 Volts peak-to-peak (+/- 1 Volts input range)
		
		if type(counts) is np.ndarray: # Numpy array ?
			counts_float = counts.astype(np.float)
		else: # Scalar case:
			counts_float = np.float(counts)
		return counts_float /  (2. **(ADC_bits-1)) * Volts_max_for_unit_gain / ADC_gain
		
	def convertDDCCountsToHz(self, counts):
		DDC_bits = 10.
		return counts.astype(dtype=np.float)  /  (2. **(DDC_bits)) * self.fs

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

	def save_openLoop_gain(self, dac_number, value):
		value = int(round(2**32 * value/4))
		self.dev.write_Zynq_register_uint32(self.BUS_ADDR_openLoopGain[dac_number]*4, value)

	def get_openLoop_gain(self, dac_number):
		value = self.read_RAM_dpll_wrapper(self.BUS_ADDR_openLoopGain[dac_number])
		VCO_gain_in_counts_per_counts = value*4/2**32
		return VCO_gain_in_counts_per_counts

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

	def uart_uc_set_enable(self, bEnable):
		reg = int(bool(bEnable)) * (1<<9)
		self.dev.write_Zynq_AXI_register_uint32(self.reg_to_uart, reg)

	def uart_write(self, data_uint8):
		reg_func = lambda bEnable, write_strobe, data : (int(bool(bEnable)) * (1<<9)) | (write_strobe<<8) | (data_uint8 & 0xff)
		reg = reg_func(1, 1, data_uint8)
		self.dev.write_Zynq_AXI_register_uint32(self.reg_to_uart, reg)
		reg = reg_func(1, 0, data_uint8)
		self.dev.write_Zynq_AXI_register_uint32(self.reg_to_uart, reg)

	def set_adf4351(self, val):
		self.uart_uc_set_enable(1)
		time.sleep(10e-3) # leave some time for the uC to boot
		for value in val:
			self.uart_write(value)
			time.sleep(1e-3)
		# time.sleep(100e-3) # leave some time for the uC to finish programming the adf4351
		# self.uart_uc_set_enable(0)

	def turn_off_adf4351_channel(self, chip_select=1):
		a = adf4351.adf4351()
		a.turn_off_vco()
		reg_vals = a.internal_state_to_reg_vals()
		reg_vals.reverse() # need to write r0 last
		uart_vals = adf4351_ctrl_through_uart.spi_values_to_uart_bytes(reg_vals, chip_select)
		self.set_adf4351(uart_vals)

	def set_adf4351_freq(self, out_freq=135e6, ref_freq=10e6, pfd_target_freq=10e6, channel=1):
		""" Channel can be 1, 2, 3 or 4 """
		if not channel in self.adf4351:
			self.adf4351[channel] = adf4351.adf4351()

		chip_select = 2**(channel-1)

		self.adf4351[channel].setup_integer_n(out_freq, ref_freq, pfd_target_freq)
		reg_vals = self.adf4351[channel].internal_state_to_reg_vals()
		reg_vals.reverse() # need to write r0 last
		uart_vals = adf4351_ctrl_through_uart.spi_values_to_uart_bytes(reg_vals, chip_select)
		self.set_adf4351(uart_vals)
		return self.adf4351[channel]
		

class phaseReadoutDriver():
	def __init__(self, dev):
		""" dev must be a RP_PLL.RP_PLL_device() instance """
		self.dev = dev
		# constants, etc
		self.bDisplayTiming = False
		self.ADDRESS_WIDTH = 13 # constant from registers_read.vhd, must match
		self.ram_size = 2**self.ADDRESS_WIDTH
		self.sync_bytes = 0xABCD12340A0B0C0D # from mux_phase_to_logger.vhd
		self.data_dtype = np.dtype([
							('sync_bytes', np.uint64),
							('timestamp',  np.uint64),
							('phi1',       np.int64),
							('phi2',       np.int64),
							('phi3',       np.int64),
							('phi4',       np.int64),
							])
		self.bytes_per_word = 4 # 32-bits words at readout
		self.words_per_chunk = int(self.data_dtype.itemsize/self.bytes_per_word)
		self.number_of_chunks = int(np.floor(self.ram_size/self.words_per_chunk))

		# create member variables that will hold internal state
		self.last_chunk_id = -1
		self.first_read = True
		self.read_counter = 0
		self.LPF_DECIM = 6 # decimation ratio done by fir_lpf_decim_by_6
		self.fs_nominal = 125e6 # just used once to set output rate, will NOT be updated later
		self.nominal_output_rate = 100 # this is the target, the actual rate will be a bit off, since that doesn't yield an integer number of cycles

		self.addr = dict()
		# *4 here is to translate from Zynq addresses to addresses used inside multichannel_freq_counter_top.vhd
		self.addr["start_write"]        = 4*0x0041
		self.addr["start_read"]         = 4*0x0042
		self.addr["read_start_address"] = 4*0x0043
		self.addr["read_data"]          = 4*0x0044
		self.addr["write_addr"]         = 4*0x0045
		self.addr["n_cycles"]           = 4*0xF # phase cycles per integration time

	def startLogging(self):
		""" This needs to be triggered only once, but there is no arm in doing it multiple times """
		self.dev.write_Zynq_register_uint32(self.addr["start_write"], 0)
		self.dev.write_Zynq_register_uint32(self.addr["start_write"], 1) # starts the data recording
		self.dev.write_Zynq_register_uint32(self.addr["n_cycles"], round(self.fs_nominal/self.LPF_DECIM/self.nominal_output_rate))

	def _chunksAvailable(self):
		""" Returns the number of new data chunks available since last read """
		write_addr = self.dev.read_Zynq_register_uint32(self.addr["write_addr"])
		current_chunk_id = np.floor(write_addr/self.words_per_chunk)
		return (current_chunk_id-1 - self.last_chunk_id) % self.number_of_chunks

	def _readDataChunks(self, first_chunk_id, number_of_chunks):
		self.dev.write_Zynq_register_uint32(self.addr["read_start_address"], 0) # sets the read pointer to the first point
		self.dev.write_Zynq_register_uint32(self.addr["start_read"], 1) # causes the fpga to load the read_start_address value
		self.dev.write_Zynq_register_uint32(self.addr["start_read"], 0)
		# currently: read the whole ram everytime, since it only takes 4 ms anyway...
		words_to_read = self.number_of_chunks * self.words_per_chunk
		tictoc(self)
		data = self.dev.read_repeat(self.addr["read_data"], words_to_read)
		data = np.fromstring(data, dtype=np.uint32)
		tictoc(self, "read %d words" % (len(data)))

		self.read_counter += 1
		data.dtype = self.data_dtype

		# only return requested data
		used_chunks = first_chunk_id + np.arange(number_of_chunks, dtype=np.uint32)
		used_chunks = used_chunks % self.number_of_chunks # modulo addressing
		# print("used chunks = %s" % used_chunks)
		self.last_chunk_id = used_chunks[-1]
		data_all = np.copy(data) # for debugging
		data = data[used_chunks]

		# with open("out_data%d.bin" % self.read_counter, "wb") as f:
		# 	f.write(data.tobytes())

		# Sanity-checks on the data:
		self._validate_sync_bytes(data, data_all)
		return data

	def _validate_sync_bytes(self, data, data_all):
		""" Checks that every received data chunks contain the expected sync bytes
		as the first word.
		Outputs debugging data if it didn't match """
		# # for the first read, we ignore this check since there is a trivial condition
		# # where this check fails if the buffer hasn't been filled completely once
		# if self.first_read:
		#     self.first_read = False
		#     return

		if np.any(data["sync_bytes"] != self.sync_bytes):
			print("warning, data is desynced. Check contents of out_desynced.bin for debugging")
			with open("out_desynced.bin", "wb") as f:
				f.write(data_all.tobytes())

	def readData(self):
		""" This should be called periodically in normal operation.
		Reads any available data and returns it.
		Returns None if there is no data otherwise """
		chunksAvailable = self._chunksAvailable()
		if chunksAvailable == 0:
			return None
		# print("readData(): reading the %d chunks available" % chunksAvailable)
		return self._readDataChunks(first_chunk_id=self.last_chunk_id+1,
									number_of_chunks = chunksAvailable)

# end class definition

if __name__ == '__main__':
	sl = SuperLaserLand_JD_RP()
	sl.dev.OpenTCPConnection("192.168.2.34")
	sl.uart_uc_set_enable(1)
	ref_freq = 25e6 # frequency connected to clk_in
	time.sleep(0.1)
	sl.set_adf4351_freq(out_freq=40e6+15e6, ref_freq=ref_freq, chip_select=1)
	time.sleep(0.1)
	sl.set_adf4351_freq(out_freq=50e6-10e6, ref_freq=ref_freq, chip_select=2)
	time.sleep(0.1)
	time.sleep(0.1)
	# sl.turn_off_adf4351_channel(chip_select=1)
	# sl.turn_off_adf4351_channel(chip_select=2)
	# sl.turn_off_adf4351_channel(chip_select=4)
	# sl.turn_off_adf4351_channel(chip_select=8)

	time.sleep(0.1)
	sl.set_adf4351_freq(out_freq=60e6+15e6, ref_freq=ref_freq, chip_select=4)
	# time.sleep(0.1)
	sl.set_adf4351_freq(out_freq=1000e6+40e6, ref_freq=ref_freq, chip_select=8)
	time.sleep(0.1)
	# sl.set_adf4351_freq(out_freq=45e6, chip_select=4)
	# sl.set_adf4351_freq(out_freq=101e6, chip_select=8)

	readout = phaseReadoutDriver(sl.dev)
	readout.startLogging()
	time.sleep(1)
	data = readout.readData()
	print(data)


	# sl.set_adf4351_freq(out_freq=130e6, chip_select=1+2+4+8)
	# sl.set_adf4351_freq(out_freq=170e6+40e6, chip_select=8)
