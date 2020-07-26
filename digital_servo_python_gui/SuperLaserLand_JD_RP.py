# -*- coding: utf-8 -*-
"""
XEM6010 Phase-lock box communication interface,
by JD Deschenes, October 2013
Modified January 2016 to interface with the Red Pitaya port of the phase-lock box
Modified June 2020 to interface with Red Pitaya-based phase/frequency meter

"""
from __future__ import print_function
import time     # used for time.sleep()
import numpy as np
from scipy.signal import lfilter
import sys
import traceback
import weakref
import logging

import RP_PLL
import bin_conv
import uart_to_spi_bridge
import adf4351

from common import make_sure_path_exists, tictoc, smooth

class SuperLaserLand_JD_RP:
	# Data members:
	############################################################
	# System parameters:
	fs = 125e6  # adc sampling rate

	# input channels ids start from 1
	num_channels = 4
	channels_list = list(range(1, num_channels+1))

	# dac ids start from 1
	num_dacs = 2
	dacs_list = list(range(1, num_dacs+1))

	############################################################
	# Functions to map addresses below to the correct absolute addresses
	datalogger2absolute = lambda x: x   + RP_PLL.RP_PLL_device.FPGA_BASE_ADDR + (1<<20) # the value 1 is taken from red_pitaya_top.v, from this line: .sys_wen(sys_wen[1]),  used by trigger_write below
	counter2absolute    = lambda x: x*4 + RP_PLL.RP_PLL_device.FPGA_BASE_ADDR # Addresses that are multiplied by four are part of the multichannel_freq_counter_top address space. this is done to avoid any chance of doing a read at a non-four-bytes-aligned address, which crashes the Zynq CPU
	bd2absolute         = lambda x: x   + RP_PLL.RP_PLL_device.FPGA_BASE_ADDR_XADC
	# 
	addr = {
		"trigger_write": datalogger2absolute(0x1004),    # writing anything to this address triggers the write mode in ram_data_logger.vhd; part of a different address space than most other registers

		"mux_selector": counter2absolute(0x0001),
		"DAC_offset1":  counter2absolute(0x0002),
		"DAC_offset2":  counter2absolute(0x0003),
		"DAC_limits1":  counter2absolute(0x0004),
		"DAC_limits1":  counter2absolute(0x0005),

		# DDC frequency settings
		# these are all 64-bits registers, so they also occupy the next adjacent addresses, ie counter2absolute(0x0008), counter2absolute(0x000A), etc
		"ref_freq1": counter2absolute(0x0007),
		"ref_freq2": counter2absolute(0x0009),
		"ref_freq3": counter2absolute(0x000B),
		"ref_freq4": counter2absolute(0x000D),

		# Phase logger registers, implemented in registers_read.vhd
		"phase_logger_start_write":        counter2absolute(0x0041),
		"phase_logger_start_read":         counter2absolute(0x0042),
		"phase_logger_read_start_address": counter2absolute(0x0043),
		"phase_logger_read_data":          counter2absolute(0x0044),
		"phase_logger_write_addr":         counter2absolute(0x0045),
		"phase_logger_n_cycles":           counter2absolute(0x000F), # phase cycles per integration time

		# addresses implemented in the "Board design" 
		# XADC-related
		"xadc_base":   bd2absolute(0x0001_0000),
		"xadc_Vccint": bd2absolute(0x0001_0000 + 0x204),
		"xadc_Vccaux": bd2absolute(0x0001_0000 + 0x208),
		"xadc_Vbram":  bd2absolute(0x0001_0000 + 0x218),
		"xadc_Temp":   bd2absolute(0x0001_0000 + 0x200),

		# Clock configuration registers (table 4-2 in PG065)
		"clkw_reg0":          bd2absolute(0x0002_0000 + 0x200),
		"clkw_reg2":          bd2absolute(0x0002_0000 + 0x208),
		"clkw_status":        bd2absolute(0x0002_0000 + 0x04),
		"clkw_reg23":         bd2absolute(0x0002_0000 + 0x25C),
		# External-clock-related
		"clk_sel_and_reset":  bd2absolute(0x0003_0000),
		"clk_freq_reg1":      bd2absolute(0x0004_0000),
		"clk_freq_reg2":      bd2absolute(0x0004_0008),
		"clk_freq_reg3":      bd2absolute(0x0005_0000),

		"uart_to_spi_bridge": bd2absolute(0x0005_0008),
	}
	for xadc_channel in range(15+1):
		addr["xadc_channel%d" % xadc_channel] = addr["xadc_base"]+0x240+4*xadc_channel

	reg_values     = dict() # this will get populated every time we write a value to the device
	derived_values = dict() # these values get populated as a function of the register values, and are mostly for convenience
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
		self.bDisplayTiming = False

		strNameTemplate = time.strftime("data_logging\\%m_%d_%Y_%H_%M_%S_")
		# Create the subdirectory if it doesn't exist:
		make_sure_path_exists('data_logging')

		self.adf4351 = dict()
		self.adc_volts_per_counts = 1./2**14 * 21.9e-3/13.4e-3 # calibrated on one unit on 2020-07-18 using a known-amplitude tone, turned off 7V supply to put RF amps in high-Z
		self.adc_bits = 14
		self.load_amplitude_calibration()

		if controller is not None:
			self.controller = weakref.proxy(controller)
		else:
			self.controller = None

		self.dev = RP_PLL.RP_PLL_device(self.controller)
		self.phaseReadoutDriver = phaseReadoutDriver(self)
		self.populateEmptyRegValues()

	def populateEmptyRegValues(self):
		for reg_name in self.addr:
			self.reg_values[reg_name] = None

	def write(self, reg_name, data_32bits):
		""" Default register writes are 32 bits """
		self.dev.write_uint32(self.addr[reg_name], int(data_32bits))
		self.reg_values[reg_name] = int(data_32bits)

	def write_64bits(self, reg_name, data_64bits):
		""" This is broken up into two consecutive 32-bits writes,
		with the MSBs written last """
		data_32bits_lower =  data_64bits      & 0xFFFFFFFF
		data_32bits_upper = (data_64bits>>32) & 0xFFFFFFFF
		self.dev.write_uint32(self.addr[reg_name],   int(data_32bits_lower))
		self.dev.write_uint32(self.addr[reg_name]+4, int(data_32bits_upper))
		self.reg_values[reg_name] = int(data_64bits)

	def write_2x_16bits(self, reg_name, data_lsbs, data_msbs):
		reg_value = (int(data_msbs)<<16) + int(data_lsbs)
		self.write(reg_name, reg_value)

	def read(self, reg_name):
		reg_value = self.dev.read_uint32(self.addr[reg_name])
		self.reg_values[reg_name] = reg_value
		return reg_value

	def load_amplitude_calibration(self):
		with open("amplitude_calibration\\input_freq.bin", "rb") as f:
			self.amplitude_cal_freq_axis = np.copy(np.frombuffer(f.read(), np.float))
		with open("amplitude_calibration\\input_amplitude.bin", "rb") as f:
			self.amplitude_cal_input_amplitude = np.copy(np.frombuffer(f.read(), np.float))
		with open("amplitude_calibration\\output_amplitude.bin", "rb") as f:
			self.amplitude_cal_output_amplitude = np.copy(np.frombuffer(f.read(), np.float))

		# fix a few glitchy data points:
		self.amplitude_cal_output_amplitude[924] = self.amplitude_cal_output_amplitude[924+1]
		self.amplitude_cal_output_amplitude[366] = self.amplitude_cal_output_amplitude[366+1]

		self.amplitude_ratio_adc_to_input_dB = self.amplitude_cal_output_amplitude - self.amplitude_cal_input_amplitude

	def scale_factor_adc_to_input(self, input_frequency):
		if input_frequency < np.min(self.amplitude_cal_freq_axis):
			input_frequency = np.min(self.amplitude_cal_freq_axis)
		if input_frequency > np.max(self.amplitude_cal_freq_axis):
			input_frequency = np.max(self.amplitude_cal_freq_axis)

		gain_dB = np.interp(input_frequency, self.amplitude_cal_freq_axis, self.amplitude_ratio_adc_to_input_dB)
		gain_linear = np.sqrt(10.0**(gain_dB/10.0))
		return gain_linear

	def getDataFromLogger(self, selector, Num_samples):
		self.write("mux_selector", selector)
		self.write("trigger_write", 0) # value is ignored here, just the fact that we are writing is sufficient
		time.sleep(2e-3) # max write duration is 2**15/(125e6/6) = 1.6 ms
		data_buffer = self.dev.read_Zynq_buffer_int16(Num_samples)
		buffer_numpy = np.copy(np.frombuffer(data_buffer, dtype=np.int16))
		return buffer_numpy

	def demux_logger_timestamp(self, raw_data_int16):
		""" Send raw logger data to this function to split the timestamp and the actual data out.
		Returns a tuple (timestamp, logger_data) """
		if raw_data_int16 is None:
			return (None, None)
		ts_as_int16 = raw_data_int16[:4]
		ts_as_int64 = np.copy(np.frombuffer(ts_as_int16, dtype=np.int64))
		logger_data = raw_data_int16[4:]
		return (ts_as_int64, logger_data)

	def getADCdata(self, adc_number, N_samples):
		raw_data = self.getDataSafe(self.LOGGER_MUX['ADC%d' % adc_number], int(N_samples))
		(timestamp, logger_data) = self.demux_logger_timestamp(raw_data)
		adc_data_in_volts = self.convertADCCountsToVolts(logger_data)
		return (timestamp, adc_data_in_volts)

	def getIQdata(self, iq_channel, N_samples):
		raw_data = self.getDataSafe(self.LOGGER_MUX['IQ%d' % iq_channel], int(N_samples))
		(timestamp, logger_data) = self.demux_logger_timestamp(raw_data)
		if logger_data is None:
			return (None, None)
		with open("out_raw.bin", "wb") as f:
			f.write(raw_data.tobytes())

		data_real = logger_data[0::2]
		data_imag = logger_data[1::2]
		# make sure real and imag are the same size:
		N_min = min(len(data_real), len(data_imag))
		data_complex = data_real[:N_min] + 1j*data_imag[:N_min]
		data_complex = self.convertIQCountsToVolts(data_complex)
		return (timestamp, data_complex)

	def getDataSafe(self, selector, N_samples):
		tictoc(self)
		try:
			data = self.getDataFromLogger(selector, int(N_samples))
			return data
		except RP_PLL.CommsLoggeableError as e:
			print('RP_PLL.CommsLoggeableError')
			# log exception (TODO)
			# logging.error("Exception occurred", exc_info=True)
			return None

		except RP_PLL.CommsError as e:
			print('RP_PLL.CommsError')
			# do not log exception (because it's simply an obvious follow-up to a previous one, and we don't want to fill up the log with repeated information)
			return None

		finally:
			# Tear-down, whether or not an exception occured: Signal to other functions that they can use the DDR2 logger
			tictoc(self, '')
			pass
	
	def set_dac_offset(self, dac_number, offset):
		""" dac_number can be either 1 or 2 """
		assert dac_number in self.dacs_list
		self.write("DAC_offset" % dac_number, offset)

	def set_ddc_ref_freq(self, frequency_in_hz, channel_id):
		""" channel_id can be either 1, 2, 3 or 4 """
		assert channel_id in self.channels_list
		dds_freq_word = int(round(2**48 * frequency_in_hz/self.fs))
		dds_freq_word = dds_freq_word % (1 << 48) # modulo 2**48
		print("dds_freq_word=", dds_freq_word)
		self.write_64bits("ref_freq%d"%channel_id, dds_freq_word)

	def set_dac_limits(self, dac_number, limit_low, limit_high, bSendToFPGA = True):
		""" Valid DAC numbers are 1 and 2 """
		limit_low = int(limit_low)
		limit_high = int(limit_high)

		limits_signed = lambda n_bits: (-2**(n_bits-1), 2**(n_bits-1)-1)
		limits_unsigned = lambda n_bits: (0, 2**(n_bits)-1)
		limits_from_dac =  {1: limits_signed(16),
							2: limits_signed(16)}
		# clamp to extremum values:
		if limit_low < limits_from_dac[dac_number][0]:
			limit_low = limits_from_dac[dac_number][0]
		if limit_high > limits_from_dac[dac_number][1]:
			limit_high = limits_from_dac[dac_number][1]

		self.write_2x_16bits("DAC_limits%d"%dac_number, limit_low, limit_high)

	def get_ddc_filter(self):
		return np.array([-909, 1718, 4689, 10090, 18371, 29803, 44256, 61034, 78773, 95424, 108353, 114569, 111075, 95319, 65698, 22057, -33908, -98401, -165516, -227493, -275271, -299287, -290477, -241376, -147158, -6537, 177657, 398280, 644147, 900763, 1151462, 1378852, 1566415, 1700080, 1769608, 1769608, 1700080, 1566415, 1378852, 1151462, 900763, 644147, 398280, 177657, -6537, -147158, -241376, -290477, -299287, -275271, -227493, -165516, -98401, -33908, 22057, 65698, 95319, 111075, 114569, 108353, 95424, 78773, 61034, 44256, 29803, 18371, 10090, 4689, 1718, -909])

	def ensure_float(self, x):
		""" Returns the same values as x, but as floating point,
		 unless the input was None, in which case None is returned """
		if type(x) is np.ndarray: # Numpy array ?
			if np.iscomplexobj(x):
				x_float = x.astype(np.complex128)
			else:
				x_float = x.astype(np.float)
		else: # Scalar case:
			x_float = np.float(x)
		return x_float

	def getADCmaxVoltage(self):
		return self.convertADCCountsToVolts((2**(self.adc_bits-1)-1))

	def convertADCCountsToVolts(self, counts):
		if counts is None:
			return None # handle trivial case
		return self.ensure_float(counts) * self.adc_volts_per_counts

	def convertIQCountsToVolts(self, counts):
		if counts is None:
			return None # handle trivial case
		return self.ensure_float(counts) * self.adc_volts_per_counts

	def setADCclockPLL(self, f_source, bExternalClock, CLKFBOUT_MULT, CLKOUT0_DIVIDE):
		""" f_source is the frequency of the selected clock source (200 MHz in internal clock mode, can be whatever is connected to GPIO_P[5] in external clock mode) """
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
		self.write("clkw_reg0", reg)
		# Clock configuration register 2 (table 4-2 in PG065)
		reg = (CLKOUT0_DIVIDE & ((1<<8)-1)) << 0
		self.write("clkw_reg2", reg)

		# check status register:
		time_start = time.clock()
		status_reg = 0x0
		while status_reg != 0x1 and time.clock()-time_start < 1.: # 1 sec timeout
			status_reg = self.read("clkw_status")

		if status_reg != 0x1:
			print("Error: timed out waiting for status_reg to become 0x1 (PLL locked)")
			return

		self.setClkSelectAndReset(bExternalClock, bReset=True) # assert reset on the incoming ADC clock
		self.write("clkw_reg23", 0x7)
		self.write("clkw_reg23", 0x2) # this needs to happen before the locked status goes high according to the datasheet.  Not sure what the impact is if we don't honor this requirement

		self.fs = f_source * CLKFBOUT_MULT/CLKOUT0_DIVIDE
		time.sleep(0.1)
		self.setClkSelectAndReset(bExternalClock, bReset=False) # de-assert reset on the incoming ADC clock

	def setClkSelectAndReset(self, bExternalClock, bReset):
		""" Select external or internal clock source, and also sets the reset """
		reg_clk_sel_and_reset = int(not bExternalClock) | (int(bReset)<<1)
		self.write("clk_sel_and_reset", reg_clk_sel_and_reset)

	# xadc_channel can be [0, 15]
	def readZynqXADC(self, xadc_channel=0):
		###########################################################################
		# Reading the XADC values:
		# See Xilinx document UG480 chapter 2 for conversion factors
		# we use 2**16 instead of 2**12 for the denominator because the codes are "MSB-aligned" in the register (equivalent to a multiplication by 2**4)
		xadc_unipolar_code_to_voltage    = lambda x: x*1./2.**16
		return xadc_unipolar_code_to_voltage(self.read("xadc_channel%d" % xadc_channel))

	# read various power supply voltages on the Zynq using the XADC:
	def readZynqXADCsupply(self):
		###########################################################################
		# Reading the XADC values:
		# See Xilinx document UG480 chapter 2 for conversion factors
		# we use 2**16 instead of 2**12 for the denominator because the codes are "MSB-aligned" in the register (equivalent to a multiplication by 2**4)
		xadc_powersupply_code_to_voltage = lambda x: x*3./2.**16
		Vccint = xadc_powersupply_code_to_voltage(self.read("xadc_Vccint"))
		Vccaux = xadc_powersupply_code_to_voltage(self.read("xadc_Vccaux"))
		Vbram  = xadc_powersupply_code_to_voltage(self.read("xadc_Vbram"))
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
			reg = self.read("xadc_Temp")
			reg_avg += float(reg)
			
		reg_avg = float(reg_avg)/N_average
		# print("elapsed = %f" % (time.clock()-time_start))
		ZynqTempInDegC = xadc_temperature_code_to_degC(  reg_avg  )
		return ZynqTempInDegC
		
	def getExtClockFreq(self):
		# see "digital_clock_freq_counter.vhd" for the meaning of each of these registers.
		read_all_regs = lambda : (self.read("clk_freq_reg1"),
								  self.read("clk_freq_reg2"),
								  self.read("clk_freq_reg3"))
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
		freq_Hz = self.scaleCounterReadingsIntoHz(freq_64bits, N_cycles_gate_time=200e6, f_ref=200e6) # reference frequency in this case is 200 MHz: fclk[3] from the block design
		freq_Hz = freq_Hz * 2**10 # this is because this counter has no fractional bits on its phase measurement, so the gain is effectively 2**FRACT_BITS lower, with FRACT_BITS=10
		# print("getExtClockFreq(): freq_Hz=%e Hz" % freq_Hz)
		return freq_Hz

	def scaleCounterReadingsIntoHz(self, freq_counter_samples, N_cycles_gate_time, f_ref=None):
		if f_ref is None:
			f_ref = self.fs
		# Scale the counter values into Hz units:
		# f = data_out * fs / 2^N_INPUT_BITS / conversion_gain
		N_INPUT_BITS = 10
		conversion_gain = N_cycles_gate_time * (N_cycles_gate_time + 1)
		freq_counter_samples = self.ensure_float(freq_counter_samples) * f_ref / 2**(N_INPUT_BITS) / conversion_gain
		return freq_counter_samples

	def uart_uc_set_enable(self, bEnable):
		reg = int(bool(bEnable)) * (1<<9)
		self.write("uart_to_spi_bridge", reg)

	def uart_write(self, data_uint8):
		reg_func = lambda bEnable, write_strobe, data : (int(bool(bEnable)) * (1<<9)) | (write_strobe<<8) | (data_uint8 & 0xff)
		self.write("uart_to_spi_bridge", reg_func(1, 1, data_uint8))
		self.write("uart_to_spi_bridge", reg_func(1, 0, data_uint8))

	def set_adf4351(self, val):
		self.uart_uc_set_enable(1)
		time.sleep(10e-3) # leave some time for the uC to boot
		for value in val:
			self.uart_write(value)
			time.sleep(1e-3)
		# time.sleep(100e-3) # leave some time for the uC to finish programming the adf4351
		# self.uart_uc_set_enable(0)

	def set_adf4351_freq(self, out_freq=135e6, ref_freq=10e6, pfd_target_freq=10e6, channel=1,
							   LO_pwr='+5dBm', LO_enabled=True):
		""" Channel can be 1, 2, 3 or 4 """
		if not channel in self.adf4351:
			self.adf4351[channel] = adf4351.adf4351()

		chip_select = 2**(channel-1)

		self.adf4351[channel].load_defaults()
		self.adf4351[channel].setup_integer_n(out_freq, ref_freq, pfd_target_freq)
		self.adf4351[channel].set_output_power(LO_pwr)
		if not LO_enabled:
			self.adf4351[channel].turn_off_vco()

		reg_vals = self.adf4351[channel].internal_state_to_reg_vals()
		reg_vals.reverse() # need to write r0 last
		uart_vals = uart_to_spi_bridge.spi_values_to_uart_bytes(reg_vals, chip_select)
		self.set_adf4351(uart_vals)
		print(self.reg_values)
		return self.adf4351[channel]
		

class phaseReadoutDriver():
	def __init__(self, sl):
		""" sl must be a SuperLaserLand_JD_RP() instance """
		self.sl = sl
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
		self.n_bits_phase = 14 # fractional bits on the arctan extraction inside the fpga

	def write(self, reg_name, value):
		self.sl.write(reg_name, value)

	def read(self, reg_name):
		return self.sl.read(reg_name)

	def startLogging(self):
		""" This needs to be triggered only once, but there is no arm in doing it multiple times """
		self.write("phase_logger_start_write", 0)
		self.write("phase_logger_start_write", 1) # starts the data recording
		self.n_cycles = round(self.fs_nominal/self.LPF_DECIM/self.nominal_output_rate)
		self.write("phase_logger_n_cycles", self.n_cycles)

	def _getInProgressChunkIndex(self):
		""" Returns the index of the chunk currently being written to """
		write_addr = self.read("phase_logger_write_addr")
		current_chunk_id = int(np.floor(write_addr/self.words_per_chunk))
		return current_chunk_id

	def _getLatestChunkIndex(self):
		""" Returns the index of the most recent available chunk """
		current_chunk_id = self._getInProgressChunkIndex()
		return (current_chunk_id-1) % self.number_of_chunks

	def _chunksAvailable(self):
		""" Returns the number of new data chunks available since last read """
		current_chunk_id = self._getInProgressChunkIndex()
		return (current_chunk_id-1 - self.last_chunk_id) % self.number_of_chunks

	def peakLatestChunk(self):
		""" Read the most recent available chunk, but don't update the read pointer for subsequent read. """
		latest_chunk_id = self._getLatestChunkIndex()
		return self._readDataChunks(latest_chunk_id, number_of_chunks=1, bUpdateReadPointer=False)

	def _readDataChunks(self, first_chunk_id, number_of_chunks, bUpdateReadPointer=True):
		self.write("phase_logger_read_start_address", 0) # sets the read pointer to the first point
		self.write("phase_logger_start_read", 1) # causes the fpga to load the read_start_address value
		self.write("phase_logger_start_read", 0)
		# currently: read the whole ram everytime, since it only takes 4 ms anyway...
		words_to_read = self.number_of_chunks * self.words_per_chunk
		tictoc(self)
		data = self.sl.dev.read_repeat(self.sl.addr["phase_logger_read_data"], words_to_read)
		data = np.copy(np.frombuffer(data, dtype=np.uint32))
		tictoc(self, "read %d words" % (len(data)))

		self.read_counter += 1
		data.dtype = self.data_dtype

		# only return requested data
		used_chunks = first_chunk_id + np.arange(number_of_chunks, dtype=np.uint32)
		used_chunks = used_chunks % self.number_of_chunks # modulo addressing
		# print("used chunks = %s" % used_chunks)
		if bUpdateReadPointer:
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
