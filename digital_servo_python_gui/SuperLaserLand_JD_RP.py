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
import pprint

import RP_PLL
import bin_conv
import uart_to_spi_bridge
import adf4351
import rationals
import zynq_mmcm

from common import make_sure_path_exists, tictoc, smooth, bitmask

class SuperLaserLand_JD_RP:
    # Data members:
    ############################################################
    # System parameters:
    fs = 125e6  # default adc sampling rate
    fs_dds = 1e9 # default dds sampling rate (1 GHz nominal)

    # input channels ids start from 1
    num_channels = 4
    channels_list = list(range(1, num_channels+1))

    # dac ids start from 1
    num_dacs = 2
    dacs_list = list(range(1, num_dacs+1))

    ############################################################
    # Functions to map addresses below to the correct absolute addresses
    # There are three separate address spaces
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

        # DDS settings
        "manual_offset_dds1": counter2absolute(0x0010),
        "manual_offset_dds2": counter2absolute(0x0012),
        "manual_offset_dds3": counter2absolute(0x0014),
        "manual_offset_dds4": counter2absolute(0x0016),

        "dds1_limits": counter2absolute(0x0018),
        "dds2_limits": counter2absolute(0x0019),
        "dds3_limits": counter2absolute(0x001A),
        "dds4_limits": counter2absolute(0x001B),

        # PI settings
        "PI_n_cycles":       counter2absolute(0x0003), # extra decimation ratio from IQ data rate to DDS data rate
        "PI_enables":        counter2absolute(0x001C),
        "PI_fine_gains":     counter2absolute(0x001D),
        "PI_coarse_P_gains": counter2absolute(0x001E),
        "PI_coarse_I_gains": counter2absolute(0x001F),

        "AD9912_SPI1":        counter2absolute(0x0020),
        "AD9912_SPI2":        counter2absolute(0x0021),
        "AD9912_SPI3":        counter2absolute(0x0022),
        "AD9912_SPI4":        counter2absolute(0x0023),

        "DDS_SPI_enables":    counter2absolute(0x0024),

        # frequency ramp settings:
        "ramp_resets": counter2absolute(0x0025),
        "ramp_slope1": counter2absolute(0x0026),
        "ramp_slope2": counter2absolute(0x0028),
        "ramp_slope3": counter2absolute(0x0030),
        "ramp_slope4": counter2absolute(0x0032),

        # Dither modules
        # from PI_4ch.vhd: "constant DITHER_BASE_ADDRESS : addresses_type := (16#100#, 16#110#, 16#120#, 16#130#);"
        "Dither1_enable":    counter2absolute(0x100 + 0),
        "Dither1_period":    counter2absolute(0x100 + 1),
        "Dither1_N_periods": counter2absolute(0x100 + 2),
        "Dither1_amplitude": counter2absolute(0x100 + 3),

        "Dither2_enable":    counter2absolute(0x110 + 0),
        "Dither2_period":    counter2absolute(0x110 + 1),
        "Dither2_N_periods": counter2absolute(0x110 + 2),
        "Dither2_amplitude": counter2absolute(0x110 + 3),

        "Dither3_enable":    counter2absolute(0x120 + 0),
        "Dither3_period":    counter2absolute(0x120 + 1),
        "Dither3_N_periods": counter2absolute(0x120 + 2),
        "Dither3_amplitude": counter2absolute(0x120 + 3),

        "Dither4_enable":    counter2absolute(0x130 + 0),
        "Dither4_period":    counter2absolute(0x130 + 1),
        "Dither4_N_periods": counter2absolute(0x130 + 2),
        "Dither4_amplitude": counter2absolute(0x130 + 3),

        # Phase logger registers, implemented in registers_read.vhd
        "phase_logger_start_write":        counter2absolute(0x0041),
        "phase_logger_start_read":         counter2absolute(0x0042),
        "phase_logger_read_start_address": counter2absolute(0x0043),
        "phase_logger_read_data":          counter2absolute(0x0044),
        "phase_logger_write_addr":         counter2absolute(0x0045),
        "phase_logger_n_cycles":           counter2absolute(0x0002), # phase cycles per integration time

        "ext_clk_status":                  counter2absolute(0x0046),


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
        'DDS1':          6,
        'DDS2':          7,
        'DDS3':          8,
        'DDS4':          2**4,
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

        self.user_inputs = dict()

        self.adf4351 = dict()
        self.adc_volts_per_counts = 1./2**14 * 21.9e-3/13.4e-3 # calibrated on one unit on 2020-07-18 using a known-amplitude tone, turned off 7V supply to put RF amps in high-Z
        self.adc_bits = 14
        LOG2_PI_ERROR_DIVIDE = 4  # generic value from PI_error_preconditionning.vhd
        self.phase_bits = 14 - LOG2_PI_ERROR_DIVIDE
        self.dds_bits = 48

        self.LPF_DECIM = 6 # decimation ratio done by fir_lpf_decim_by_6
        self.dds_spi_clk_div = 4 # must be equal to "clk_div" from red_pitaya_top.v
        self.dds_spi_bits_per_transaction = 100 # approximate number of bits in each SPI transfer to the DDS chip. must be an overestimate
        # decimation between arctan and PI to DDS.
        # must satisfy constraint: self.fs/(self.LPF_DECIM*self.PI_n_cycles) < self.fs/(self.dds_spi_bits_per_transaction*self.dds_spi_clk_div)
        # reduces to: self.LPF_DECIM*self.PI_n_cycles > self.dds_spi_bits_per_transaction*self.dds_spi_clk_div
        self.PI_n_cycles = int(np.ceil(self.dds_spi_bits_per_transaction*self.dds_spi_clk_div/self.LPF_DECIM))
        # print(f"self.PI_n_cycles={self.PI_n_cycles}")

        self.R_LO3 = dict()
        for channel_id in self.channels_list:
            self.R_LO3[channel_id] = rationals.RationalNumber(0, 1) # this will get filled in once we know all the required values
        self.load_amplitude_calibration()

        if controller is not None:
            self.controller = weakref.proxy(controller)
        else:
            self.controller = None

        self.dev = RP_PLL.RP_PLL_device(self.controller)
        self.phaseReadoutDriver = phaseReadoutDriver(self)
        self.populateEmptyRegValues()

    def fs_PI(self):
        """ Returns the PI's sampling rate,
        which is also the DDS's frequency word sampling rate
        (not to be confused by the DDS output clock rate) """
        return self.fs/self.PI_n_cycles/self.LPF_DECIM

    def populateEmptyRegValues(self):
        for reg_name in self.addr:
            self.reg_values[reg_name] = None

    def write(self, reg_name, data_32bits):
        """ Default register writes are 32 bits """
        self.dev.write_uint32(self.addr[reg_name], int(data_32bits))
        self.reg_values[reg_name] = int(data_32bits)

    def write_repeat(self, reg_name, values_32bits, iSleepUs=0):
        """ Write multiple consecutive values to a single address.
        values_32bits must be an iterable """
        self.dev.write_repeat_uint32(self.addr[reg_name], values_32bits, iSleepUs)
        self.reg_values[reg_name] = int(values_32bits[-1])

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
            self.amplitude_cal_freq_axis = np.copy(np.frombuffer(f.read(), float))
        with open("amplitude_calibration\\input_amplitude.bin", "rb") as f:
            self.amplitude_cal_input_amplitude = np.copy(np.frombuffer(f.read(), float))
        with open("amplitude_calibration\\output_amplitude.bin", "rb") as f:
            self.amplitude_cal_output_amplitude = np.copy(np.frombuffer(f.read(), float))

        # fix a few glitchy data points:
        self.amplitude_cal_output_amplitude[670-1] = self.amplitude_cal_output_amplitude[670-1+1]
        self.amplitude_cal_output_amplitude[584-1] = self.amplitude_cal_output_amplitude[584-1+1]

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
        ts_as_int64 = ts_as_int64[0]
        logger_data = raw_data_int16[4:]
        return (ts_as_int64, logger_data)

    def demux_IQ_data(self, logger_data):
        data_real = logger_data[0::2]
        data_imag = logger_data[1::2]
        # make sure real and imag are the same size:
        N_min = min(len(data_real), len(data_imag))
        data_complex = data_real[:N_min] + 1j*data_imag[:N_min]
        data_complex = self.convertIQCountsToVolts(data_complex)
        return data_complex

    def demux_DDS_data(self, logger_data):
        logger_data = logger_data[:3*(len(logger_data)//3)]
        logger_data.dtype = np.uint16
        data_counts = logger_data[0::2].astype(np.int64)
        data_counts |= logger_data[1::2].astype(np.int64)
        data_counts |= logger_data[2::2].astype(np.int64)
        data_counts = data_counts & bitmask(47) - (data_counts & (1<<47)) # sign-extend from 48 bits to 64
        data_Hz = float(data_counts) / 2**48 * self.fs_dds
        return data_Hz

    def getDDSdata(self, channel_id, N_samples):
        raw_data = self.getDataSafe(self.LOGGER_MUX['DDS%d' % channel_id], int(N_samples))
        (timestamp, logger_data) = self.demux_logger_timestamp(raw_data)
        dds_value_in_Hz = self.demux_DDS_data(logger_data)
        return (timestamp, dds_value_in_Hz)

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

        data_complex = self.demux_IQ_data(logger_data)

        LO3_phase_radians = self.phaseReadoutDriver.get3rdLOPhaseRadians(timestamp, self.R_LO3[iq_channel], iq_channel)
        data_complex = data_complex * np.exp(-1j*LO3_phase_radians)

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

    def set_ddc_ref_freq(self, channel_id, frequency_in_hz):
        """ channel_id can be either 1, 2, 3 or 4 """
        assert channel_id in self.channels_list
        self.user_inputs["ddc_ref_freq%d_hz" % channel_id] = frequency_in_hz
        dds_freq_word = self.dds_freq_to_word(frequency_in_hz, self.fs)
        # print("dds_freq_word=",dds_freq_word)
        self.write_64bits("ref_freq%d"%channel_id, dds_freq_word)

        self.R_LO3[channel_id] = self.phaseReadoutDriver.compute3rdLOFreq(channel_id)

    def set_dds_offset_freq(self, channel_id, frequency_in_hz):
        """ channel_id can be either 1, 2, 3 or 4 """
        assert channel_id in self.channels_list
        self.user_inputs["dds_ref_freq%d_hz" % channel_id] = frequency_in_hz
        dds_freq_word = self.dds_freq_to_word(frequency_in_hz, self.fs_dds)
        # print("dds_target_freq = %f Hz, dds_freq_ratio = %f, word=0x%x" % (dds_freq_word/2**48*self.fs_dds, dds_freq_word/2**48, dds_freq_word))
        self.write_64bits("manual_offset_dds%d"%channel_id, dds_freq_word)

    def dds_freq_to_word(self, frequency_in_hz, ref_freq):
        dds_freq_word = int(round(2**(48) * frequency_in_hz/ref_freq))
        dds_freq_word = dds_freq_word % (1 << 48) # modulo 2**48
        return dds_freq_word

    def set_dds_limits(self, channel_id, limit_low_hz, limit_high_hz):
        """ Valid channel_id's are 1, 2, 3, 4 """
        assert channel_id in self.channels_list

        # Limit registers are only 2x16 bits, and are each multiplied by 2**32 in the fpga
        limit_low = self.dds_freq_to_word(limit_low_hz, self.fs_dds)//2**32
        limit_high = self.dds_freq_to_word(limit_high_hz, self.fs_dds)//2**32

        self.write_2x_16bits("dds%d_limits"%channel_id, limit_low, limit_high)

    def set_dds_unlimited(self, channel_id):
        """ Removes all limiting from the given channel id """
        self.write_2x_16bits("dds%d_limits"%channel_id, -2**(16-1), 2**(16-1)-1)
        # self.write_2x_16bits("dds%d_limits"%channel_id, 0, 2**(16-1)-1)

    def get_ddc_filter(self):
        """ Returns the filter implemented in fir_lpf_decim_by_6 """
        return np.array([-909, 1718, 4689, 10090, 18371, 29803, 44256, 61034, 78773, 95424, 108353, 114569, 111075, 95319, 65698, 22057, -33908, -98401, -165516, -227493, -275271, -299287, -290477, -241376, -147158, -6537, 177657, 398280, 644147, 900763, 1151462, 1378852, 1566415, 1700080, 1769608, 1769608, 1700080, 1566415, 1378852, 1151462, 900763, 644147, 398280, 177657, -6537, -147158, -241376, -290477, -299287, -275271, -227493, -165516, -98401, -33908, 22057, 65698, 95319, 111075, 114569, 108353, 95424, 78773, 61034, 44256, 29803, 18371, 10090, 4689, 1718, -909])

    def ensure_float(self, x):
        """ Returns the same values as x, but as floating point,
         unless the input was None, in which case None is returned """
        if type(x) is np.ndarray: # Numpy array ?
            if np.iscomplexobj(x):
                x_float = x.astype(np.complex128)
            else:
                x_float = x.astype(float)
        else: # Scalar case:
            x_float = float(x)
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

    def setADCclockPLL(self, f_ref, bExternalClock):
        """ Computes and commits closest integer-N solution for the ADC clock.
        In internal clock mode, f_ref is ignored (overriden by the 200 MHz internal clock) """
        self.user_inputs["bExternalClock"] = bExternalClock
        if bExternalClock:
            (M, N) = zynq_mmcm.get_integer_N_solution(f_ref, f_target_adc=125e6)
            self.user_inputs["adc_f_ref_hz"]   = f_ref
            self.user_inputs["CLKFBOUT_MULT"]  = M
            self.user_inputs["CLKOUT0_DIVIDE"] = N
            self._setADCclockPLL()
        else:
            # we are not even using the MMCM
            self.user_inputs["adc_f_ref_hz"]   = 125e6
            self.user_inputs["CLKFBOUT_MULT"]  = 1
            self.user_inputs["CLKOUT0_DIVIDE"] = 1
            self._setClkSelectAndReset(False, bExternalClock)
        self.fs = self.user_inputs["adc_f_ref_hz"] * self.user_inputs["CLKFBOUT_MULT"]/self.user_inputs["CLKOUT0_DIVIDE"]

    def _setADCclockPLL(self):
        """ f_ref is the frequency of the clock connected to GPIO_P[5] in external clock mode """

        self._setClkSelectAndReset(False, False) # Switch to internal clock while we reset the external clock's MMCM
        # From PG065:
        # "You should first write all the required clock configuration registers and then check for the
        # status register. If status register value is 0x1, start the reconfiguration by writing Clock
        # Configuration Register 23 with 0x7. The next write should be 0x2 before the Locked goes
        # High. If the original configuration is needed at any time, then writing this register with value
        # 0x4 and then 0x0 restores the original settings."

        # Clock configuration register 0 (table 4-2 in PG065)
        DIVCLK_DIVIDE = 1
        reg  = (DIVCLK_DIVIDE & ((1<<8)-1)) << 0
        reg |= (self.user_inputs["CLKFBOUT_MULT"] & ((1<<8)-1)) << 8
        self.write("clkw_reg0", reg)
        # Clock configuration register 2 (table 4-2 in PG065)
        reg = (self.user_inputs["CLKOUT0_DIVIDE"] & ((1<<8)-1)) << 0
        self.write("clkw_reg2", reg)

        # check status register:
        if not self._waitForReg("clkw_status", 0x1, timeout=1.0):
            print("Error: timed out waiting for status_reg to become 0x1 (PLL locked)")
            return

        self._setClkSelectAndReset(True, False) # assert reset on the incoming ADC clock
        self.write("clkw_reg23", 0x7)
        self.write("clkw_reg23", 0x2) # this needs to happen before the locked status goes high according to the datasheet.  Not sure what the impact is if we don't honor this requirement

        # time.sleep(0.1)
        self._setClkSelectAndReset(False, False) # de-assert reset on the incoming ADC clock
        time.sleep(0.1)
        self._setClkSelectAndReset(False, self.user_inputs["bExternalClock"]) # Switch to external clock now that the MMCM should be stable

    def _waitForReg(self, reg_name, desired_value, timeout=1.):
        """ Read a register in a loop, until it either becomes a desired value or we hit a timeout.
        Returns True if the register reached the desired value, False if we timed out """
        time_start = time.perf_counter()
        reg_value = self.read(reg_name)
        while reg_value != desired_value and time.perf_counter()-time_start < timeout: # read in a loop until we timeout
            reg_value = self.read(reg_name)
            time.sleep(1e-3)
        return reg_value == desired_value

    def _setClkSelectAndReset(self, bReset, bExternalClock):
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
        time_start = time.perf_counter()
        # average 10 readings because otherwise they are quite noisy:
        # this reading loop takes just 2 ms for 10 readings at the moment so there is no real cost
        N_average = 10.
        reg_avg = 0.
        for k in range(int(N_average)):
            reg = self.read("xadc_Temp")
            reg_avg += float(reg)
            
        reg_avg = float(reg_avg)/N_average
        # print("elapsed = %f" % (time.perf_counter()-time_start))
        ZynqTempInDegC = xadc_temperature_code_to_degC(  reg_avg  )
        return ZynqTempInDegC
        
    def getExtClockFreq(self):
        # see "digital_clock_freq_counter.vhd" for the meaning of each of these registers.
        data_index = lambda x: (x >> 24)
        bSuccess = False
        for iAttempts in range(2):
            reg1 = self.read("clk_freq_reg1")
            reg2 = self.read("clk_freq_reg2")
            reg3 = self.read("clk_freq_reg3")
            # these three need to match.  If they don't, this means that the data changed in between our three reads.
            # try another time to read all three registers.  It should succeed, since the counter updates only at 1 Hz
            if data_index(reg1) == data_index(reg2) == data_index(reg3):
                bSuccess = True
                break
        if not bSuccess:
            return np.nan
        freq_64bits = (((reg1 & 0x00FFFFFF) <<  0) + 
                       ((reg2 & 0x00FFFFFF) << 24) + 
                       ((reg3 & 0x0000FFFF) << 48))
        freq_Hz = self.scaleCounterReadingsIntoHz(freq_64bits, N_cycles_gate_time=200e6, f_ref=200e6) # reference frequency in this case is 200 MHz: fclk[3] from the block design
        freq_Hz = freq_Hz * 2**10 # this is because this counter has no fractional bits on its phase measurement, so the gain is effectively 2**FRACT_BITS lower, with FRACT_BITS=10
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

    def getClkStatus(self):
        """ Returns four boolean flags:
        (loss_of_clk_detected, clk_ext_good, clk_int_or_ext_actual, clk_int_or_ext_desired)
        loss_of_clk_detected is True if the user set external clock mode, but the system fell back to internal clock mode
        at any point since the last reading of this flag.
        clk_int_or_ext_desired = True means internal clock
        clk_int_or_ext_actual = True means internal clock
        """
        reg_value = self.read("ext_clk_status")
        loss_of_clk_detected   = bool((reg_value>>3) & 0x1)
        clk_ext_good           = bool((reg_value>>2) & 0x1)
        clk_int_or_ext_actual  = bool((reg_value>>1) & 0x1)
        clk_int_or_ext_desired = bool((reg_value>>0) & 0x1)
        return (loss_of_clk_detected, clk_ext_good, clk_int_or_ext_actual, clk_int_or_ext_desired)

    def uart_uc_set_enable(self, bEnable):
        reg = int(bool(bEnable)) * (1<<9)
        self.write("uart_to_spi_bridge", reg)

    def uart_write(self, data_uint8):
        reg_func = lambda bEnable, write_strobe, data : (int(bool(bEnable)) * (1<<9)) | (write_strobe<<8) | (data & 0xff)
        self.write("uart_to_spi_bridge", reg_func(1, 1, data_uint8))
        self.write("uart_to_spi_bridge", reg_func(1, 0, data_uint8))

    def uart_write_multiple(self, data_uint8):
        reg_func = lambda bEnable, write_strobe, data : (int(bool(bEnable)) * (1<<9)) | (write_strobe<<8) | (data & 0xff)
        data_out = []
        for data in data_uint8:
            data_out.append(reg_func(1, 1, data))
            data_out.append(reg_func(1, 0, data))
        self.write_repeat("uart_to_spi_bridge", data_out, iSleepUs=100)

    def set_adf4351(self, val):
        # self.bDisplayTiming = True
        tictoc(self)
        self.uart_uc_set_enable(1)
        # time.sleep(200e-3) # leave some time for the uC to boot. not needed anymore since I am setting the uC power on by default in the fpga code
        self.uart_write_multiple(val)
        tictoc(self, 'writing %d values' % len(val))
        self.bDisplayTiming = False

    def set_expected_freq(self, channel_id, expected_freq_str, ref_freq_str, mode="counter"):
        """ Must be called before set_adf4351_freq(), provides required information for
        the 3rd LO applied when reading out the phase """
        self.user_inputs["expected_freq_str_ch%d" % channel_id] = expected_freq_str
        self.user_inputs["mode_ch%d" % channel_id] = mode
        self.user_inputs["ref_freq_MHz_str"] = ref_freq_str

    def set_adf4351_freq(self, out_freq=135e6, ref_freq=10e6, pfd_target_freq=10e6, channel=1,
                               LO_pwr='+5dBm', LO_enabled=True):
        """ Channel can be 1, 2, 3 or 4 """
        # self.bDisplayTiming = True
        tictoc(self)
        self.user_inputs["out_freq_ch%d"        % channel] = out_freq
        self.user_inputs["ref_freq_ch%d"        % channel] = ref_freq
        self.user_inputs["pfd_target_freq_ch%d" % channel] = pfd_target_freq
        self.user_inputs["LO_pwr_ch%d"          % channel] = LO_pwr
        self.user_inputs["LO_enabled_ch%d"      % channel] = LO_enabled

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
        # print(self.reg_values)
        tictoc(self, '')
        self.bDisplayTiming = False
        return self.adf4351[channel]

    def get_adf4351_settings(self, channel):
        """ Returns a tuple containing the numerator and denominator of the synthesized frequency ratio:
        f_LO = f_ref * num/denom.
        Output is valid only if we have pushed to the adf4351 while connected """
        D = 2**self.adf4351[channel].reg["RF_DIVIDER_SEL"]
        INT = self.adf4351[channel].reg["INT"]
        R = self.adf4351[channel].reg["R"]
        num = INT
        denom = D*R
        return (num, denom)

    def KiForKp(self, Kp_coarse, target_BW):
        """ Returns the value of the coarse part of Ki for a given value of Kp,
        sets the crossover between the integrator and proportional
        to roughly 1/10th of the loop's unity gain frequency """
        target_crossover_freq = target_BW/10
        Ki_coarse = Kp_coarse * 2 * np.pi * target_crossover_freq/self.fs_PI()
        Ki_coarse = 2**int(round(np.log2(Ki_coarse)))
        if Ki_coarse < 1:
            print("Warning, clamping coarse I gain to 1 (was %e). this may cause loop instability" % Ki_coarse)
            Ki_coarse = 1
        return Ki_coarse

    def setup_controller(self, channel_id, nominal_output_freq, target_BW, loop_sign, bLock):
        """ Sets all required values for one controller channel.
        Doesn't actually commit to device: this happens all at once for all four channels
        when calling commit_controller_settings() """
        self.user_inputs["target_BW_ch%d"%channel_id] = target_BW
        (gain_combined, gain_fine, gain_coarse) = self.getKpForBW(target_BW)
        self.user_inputs["Kp_fine_ch%d"%channel_id] = gain_fine * loop_sign
        self.user_inputs["Kp_coarse_ch%d"%channel_id] = gain_coarse
        self.user_inputs["Ki_coarse_ch%d"%channel_id] = self.KiForKp(gain_coarse, target_BW)
        self.user_inputs["actual_BW_ch%d"%channel_id] = self.getClosedLoopBW(gain_combined)
        self.user_inputs["nominal_output_freq_ch%d"%channel_id] = nominal_output_freq

        self.updateLockState(channel_id, bLock)

    def setDDSclockPLL(self, ref_clk_Hz):
        target_fs = 1e9
        if ref_clk_Hz < 1e9/66:
            # have to use the SYSCLK PLL Doubler to reach 1 GHz
            # ratio can only be 8 to 132, multiples of 8
            all_ratios = np.arange(8, 132+1, 8)
            doubler_ratio = 2
            doubler_enable = 1
        else:
            # ratio can only be 4 to 66, multiples of 2
            all_ratios = np.arange(4, 66+1, 2)
            doubler_ratio = 1
            doubler_enable = 0

        fs_ddc = all_ratios*ref_clk_Hz
        invalid_ratios = np.nonzero(fs_ddc > target_fs)
        fs_ddc     = np.delete(fs_ddc, invalid_ratios)
        all_ratios = np.delete(all_ratios, invalid_ratios)
        closest_ind = np.argmin(np.abs(fs_ddc-target_fs))
        chosen_ratio = all_ratios[closest_ind]
        self.user_inputs["dds_fs_over_ref_clk"] = chosen_ratio

        ad9912_addr_n_divider = 0x20
        ad9912_addr_pll_parameters = 0x22
        reg_n_divider = int(chosen_ratio/2/doubler_ratio-2)
        reg_pll_parameters = (1<<7) | (doubler_enable<<3)

        for channel_id in self.channels_list:
            # self.setAD9912powerState(channel_id, True)
            self.write_AD9912_SPI(channel_id, ad9912_addr_n_divider, reg_n_divider)
            self.write_AD9912_SPI(channel_id, ad9912_addr_pll_parameters, reg_pll_parameters)

        self.fs_dds = ref_clk_Hz * chosen_ratio
        print("setDDSclockPLL(): chosen_ratio = %d, fs_ddc = %f MHz, doubler=%d" % (chosen_ratio, self.fs_dds/1e6, doubler_enable))

    def setAD9912powerState(self, channel_id, bPowerOn):
        """ Powers down or up the AD9912 chips using the "power down" register """
        # This powers down the AD9912 themselves
        ad9912_addr_power_down = 0x10
        reg_pd_value = (1<<7) # power down HSTL output driver, since we never use it
        if bPowerOn == False:
            reg_pd_value |= (1<<7) | (1<<1) # also set full power down bit
        self.write_AD9912_SPI(channel_id, ad9912_addr_power_down, reg_pd_value)

    def updateLockState(self, channel_id, bLock):
        """ Update the lock state for a single channel, without committing.
        setup_controller() must have been called prior to using this function """
        self.user_inputs["Kp_enable_ch%d"%channel_id] = bLock
        self.user_inputs["Ki_enable_ch%d"%channel_id] = bLock
        
    def commit_controller_settings(self, channel_id=None):
        """ Commits controller settings for a given channel, or for all channels if channel_id=None.
        Each channel must have been set up previously using setup_controller() """
        if channel_id is None:
            channels_to_update = self.channels_list
        else:
            channels_to_update = [channel_id]
        N_bits_coarse_gain = 6
        N_bits_fine_gain = 4

        fine_gain_reg     = 0
        coarse_P_gain_reg = 0
        coarse_I_gain_reg = 0
        PI_enables_reg    = 0
        for channel_id in channels_to_update:
            fine_gain = self.user_inputs["Kp_fine_ch%d"%channel_id]
            fine_gain_reg |= (fine_gain & bitmask(N_bits_fine_gain)) << (N_bits_fine_gain*(channel_id-1))

            coarse_P_gain = int(np.log2(self.user_inputs["Kp_coarse_ch%d"%channel_id]))
            coarse_P_gain_reg |= (coarse_P_gain & bitmask(N_bits_coarse_gain)) << (N_bits_coarse_gain*(channel_id-1))

            coarse_I_gain = int(np.log2(self.user_inputs["Ki_coarse_ch%d"%channel_id]))
            coarse_I_gain_reg |= (coarse_I_gain & bitmask(N_bits_coarse_gain)) << (N_bits_coarse_gain*(channel_id-1))

            PI_enables_reg |= self.user_inputs["Kp_enable_ch%d"%channel_id] << (channel_id-1)

            actuator_range = 10e6
            nominal_freq = self.user_inputs["nominal_output_freq_ch%d"%channel_id]
            self.set_dds_limits(channel_id, nominal_freq-actuator_range/2, nominal_freq+actuator_range/2)
            self.set_dds_offset_freq(channel_id, nominal_freq)

        # turn the lock on without integrator briefly, to allow the error to converge to 0
        self.write("PI_fine_gains", fine_gain_reg)
        self.write("PI_coarse_P_gains", coarse_P_gain_reg)
        self.write("PI_coarse_I_gains", coarse_I_gain_reg)
        self.write("PI_enables", PI_enables_reg)
        time.sleep(10e-3)

        # now turn on the integrators:
        for channel_id in channels_to_update:
            PI_enables_reg |= self.user_inputs["Ki_enable_ch%d"%channel_id] << (channel_id-1+len(self.channels_list))
        self.write("PI_enables", PI_enables_reg)

        self.write("PI_n_cycles", self.PI_n_cycles)

    def getAllPossiblePgains(self):
        """ Returns a numpy array with all available values of the proportional gain,
        in units of Hz/rad.
        Returns only positive values, but the gain can have the same magnitude, but negative """
        gain_fine, gain_coarse = np.meshgrid(np.arange(1, 8, dtype=np.int64), 2**np.arange(0, 48, dtype=np.int64))
        gain_fine     = gain_fine.flatten()
        gain_coarse   = gain_coarse.flatten()
        gain_combined = gain_fine * gain_coarse * self.PI_n_cycles
        _, indices = np.unique(gain_combined, return_index=True)
        gain_fine     = gain_fine[indices]
        gain_coarse   = gain_coarse[indices]
        gain_combined = gain_combined[indices]

        return (gain_combined, gain_fine, gain_coarse)

    def getClosedLoopBW(self, Kp):
        """ Returns the predicted closed-loop BW for a given gain. 
        Kp can be a numpy array, in which case the return value will also
        be a numpy array. """
        return 2**(self.phase_bits - self.dds_bits)/(2*np.pi) * Kp * self.fs_dds

    def getKpForBW(self, target_BW):
        """ Returns the value of Kp that will give the closest to the requested BW.
        The value of Kp is returned as a tuple: (gain_combined, gain_fine, gain_coarse) """
        (gain_combined, gain_fine, gain_coarse) = self.getAllPossiblePgains()
        BW_all = self.getClosedLoopBW(gain_combined)
        best_index = np.argmin(np.abs(BW_all-target_BW))
        gain_fine     = gain_fine[best_index]
        gain_coarse   = gain_coarse[best_index]
        gain_combined = gain_combined[best_index]
        return (gain_combined, gain_fine, gain_coarse)

    def getHardwareDescription(self):
        """ Returns a dictionary with various flags describing the hardware on the connected device """
        d = dict()
        f = self.dev.read_file_from_remote("/opt/hardware.txt")
        f = f.decode('ascii')
        # f = "has_dds=1\nhas_mixer_board=1\n" # for testing
        for line in f.split('\n'):
            if line == '':
                continue
            key, value = line.split('=')
            d[key] = bool(int(value))

        f = self.dev.read_file_from_remote("/opt/macaddress.txt")
        f = f.decode('ascii')
        if f == '':
            self.dev.send_shell_command('ifconfig | grep eth0 > /opt/macaddress.txt')
            time.sleep(0.1)
            f = self.dev.read_file_from_remote("/opt/macaddress.txt")
            f = f.decode('ascii')

        mac_token = 'HWaddr '
        ind = f.find(mac_token)
        if ind != -1:
            d["mac"] = f[ind+len(mac_token):].strip()
        return d

    def sendHardwareDescription(self, bHasMixerBoard=False, bHasDDS=False):
        """ Creates a file that describes various add-ons to the RP,
        and sends it to the currently-connected device.
        To be used only once when upgrading a given RP """
        description = "has_mixer_board=%d\n" % int(bool(bHasMixerBoard))
        description += "has_dds=%d\n" % int(bool(bHasDDS))
        file_data = description.encode('ascii')
        self.dev.write_file_on_remote("", strFilenameRemote="/opt/hardware.txt", file_data=file_data)

    def write_AD9912_SPI(self, channel_id, reg_addr, reg_value):
        reg_combined = reg_value & bitmask(8)
        reg_combined |= (reg_addr & bitmask(13)) << 8
        # print("write_AD9912_SPI(): id=%d, reg_addr=0x%x, reg_value=0x%x, reg_combined=0x%x" % (channel_id, reg_addr, reg_value, reg_combined))
        self.write("AD9912_SPI%d" % channel_id, reg_combined)
        time.sleep(1e-3)

    def getAD9912currentForWord(self, current_word):
        """ Returns the value of the DDS DAC's fullscale current, in Amperes,
        for a given value of the current tuning word (10 bits) """
        # equations from the AD9912 datasheet
        I_DAC_ref = 1.2/10e3 # Rset = 10 kOhms on the DDS board, as recommended per the datasheet
        I_DAC_fullscale = I_DAC_ref * (72 + 192*current_word/1024)
        return I_DAC_fullscale

    def getAD9912outputPower(self, current_word):
        """ Returns the output power in Watts into a 50 ohms load.
        Calculation is not trivial due to the presence of the transformer
        which coherently combines the two DAC outputs """
        I_DAC_fullscale = self.getAD9912currentForWord(current_word)
        I_peak = I_DAC_fullscale/2
        I_load = 2/3 * I_peak
        R_load = 50
        P_nominal = R_load * I_load**2/2
        extra_loss = 0.5 # loss in dB between actual power and nominal
        P_actual = P_nominal * 10**(-extra_loss/10)
        return P_actual

    def setAD9912current(self, channel_id, current_word):
        """ Sets the reference current for the DDS DAC.
        current_word is a 10 bits word, where 0 corresponds to 8.6 mA and 1023 corresponds to 31.7 mA.
        The default value is 20 mA (current_word=512) """
        ad9912_addr_lsb = 0x40B
        reg_lsbs =  current_word     & bitmask(8)
        reg_msbs = (current_word>>8) & bitmask(2)
        self.write_AD9912_SPI(channel_id, ad9912_addr_lsb,   reg_lsbs)
        self.write_AD9912_SPI(channel_id, ad9912_addr_lsb+1, reg_msbs)

    def setAD9912enable(self, DDS_SPI_enables):
        """ Enables or disables various SPI signals going to the AD9912.
        This is mostly a low-level debugging feature, and should not be used
        unless you have some idea of how the board is wired up.
        DDS_enables must be a dictionary containing a boolean entry for each signal,
        True meaning to enable this signal, False meaning to disable it """
        reg_val =  int(bool(DDS_SPI_enables["freq_updates"]))
        DDS_SPI_enables_names = ["DIO0_P_SDIO2",
                                 "DIO0_N_SDIO1",
                                 "DIO1_P_CSB",
                                 "DIO1_N_SCLK_P",
                                 "DIO2_P_SCLK_P",
                                 "DIO2_N_SCLK_N",
                                 "DIO4_P_SDIO3",
                                 "DIO4_N_CSB",
                                 "DIO6_P_SCLK_P",
                                 "DIO6_N_SCLK_N",
                                 "DIO7_P_SDIO4",
                                 "DIO7_N_CSB"]
        for ind, key in enumerate(DDS_SPI_enables_names):
            bit_number = ind+1
            reg_val |= int(bool(DDS_SPI_enables[key])) << bit_number
        # print("DDS_SPI_enables = ", bin(reg_val))
        self.write("DDS_SPI_enables", reg_val)

        return

    def setupDither(self, channel_id, integration_time_in_seconds, modulation_frequency_in_hz, output_amplitude_normalized, bEnableDither):
        """ output_amplitude_normalized is between 0 and 1, normalized to the DDS clock rate,
        ie output_amplitude_normalized=1 means 1 GHz peak-peak of dither """

        modulation_period = round(self.fs/modulation_frequency_in_hz)
        integration_time_in_samples = integration_time_in_seconds*self.fs
        N_periods = np.ceil(integration_time_in_samples/modulation_period)

        modulation_period_divided_by_4_minus_one = int(round(modulation_period/4-1))
        N_periods_integration_minus_one = int(N_periods-1)
        amplitude = int(round(output_amplitude_normalized * 2 * (2**32-1) * self.fs_dds)) # not sure why there needs to be an extra factor of 2 here compared to what I would calculate

        self.write("Dither%d_period"%channel_id, modulation_period_divided_by_4_minus_one)
        self.write("Dither%d_N_periods"%channel_id, N_periods_integration_minus_one)
        self.write("Dither%d_amplitude"%channel_id, amplitude)
        self.write("Dither%d_enable"%channel_id, bEnableDither)

    def setupRamps(self, reset_ramps_list, ramp_rates_in_Hz_per_second):
        """ reset_ramps_list must be an iterable with four boolean elements,
        where True means to disable the ramp for that channel,
        ramp_rates_in_Hz_per_second must by a four-element iterable of desired ramp rates. """
        # frequency ramp settings:
        reset_ramps = 0
        for ind, rst in enumerate(reset_ramps_list):
            reset_ramps += int(bool(rst)) * 2**ind
        # print(f"reset_ramps_list={reset_ramps_list}, reset_ramps={reset_ramps}")
        self.write("ramp_resets", reset_ramps)
        
        for index, rate in enumerate(ramp_rates_in_Hz_per_second):
            self.setupRampSingle(index+1, rate)

    def setupRampSingle(self, index, rate_in_Hz_per_second):
        # print(f"ramp_slope{index}: {rate_in_Hz_per_second} Hz/sec, {self.ramp_rate_to_code(rate_in_Hz_per_second)} in fpga units")
        self.write_64bits(f"ramp_slope{index}", self.ramp_rate_to_code(rate_in_Hz_per_second))

    def ramp_rate_to_code(self, rate_in_Hz_per_second):
        """ convert a freq ramp rate in Hz/sec to
        the DDC increment integer per clk-enabled cycle. """
        # constant from ddc_mixer.vhd:
        FREQ_WIDTH = 48
        # constant from linear_ramp_gen.vhd:
        RIGHT_SHIFT = 23
        # print(self.fs_PI())
        # print(self.fs)
        return int(np.round(2**(FREQ_WIDTH+RIGHT_SHIFT)
                            *rate_in_Hz_per_second/self.fs_PI()/self.fs))


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
        self.LPF_DECIM = self.sl.LPF_DECIM # decimation ratio done by fir_lpf_decim_by_6
        self.fs_nominal = 125e6 # just used once to set output rate, will NOT be updated later
        self.nominal_output_rate = 100 # this is the target, the actual rate will be a bit off, since that doesn't yield an integer number of cycles
        self.n_bits_phase = 14 # fractional bits on the arctan extraction inside the fpga
        self.last_phi_int64   = {k: np.int64(0) for k in self.sl.channels_list} # holds the value of the most recent raw phase (without offset)
        self.phi_offset_int64 = {k: np.int64(0) for k in self.sl.channels_list} # holds the value of the phase when the user presses "reset phase"

    def write(self, reg_name, value):
        self.sl.write(reg_name, value)

    def read(self, reg_name):
        return self.sl.read(reg_name)

    def startLogging(self):
        """ This needs to be triggered only once, but there is no arm in doing it multiple times """
        self.write("phase_logger_start_write", 0)
        self.write("phase_logger_start_write", 1) # starts the data recording
        self.setOutputRate(self.nominal_output_rate)

    def setOutputRate(self, desired_rate):
        """ Sets the integration time for each phase point, based on the desired rate in Hz.
        Actual rate will be very slightly different due to the period being quantized to an integer.
        Subject to limitations from polling rates and max readout rates which have not been fully explored
        outside of the design 100 Hz rate. Explore at your own risk! """
        self.nominal_output_rate = desired_rate
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
        return (int(current_chunk_id)-1 - int(self.last_chunk_id)) % int(self.number_of_chunks)

    def _peakLatestChunk(self):
        """ Read the most recent available chunk, but don't update the read pointer for subsequent read. """
        latest_chunk_id = self._getLatestChunkIndex()
        latest_chunk_data = self._readDataChunks(latest_chunk_id, number_of_chunks=1, bUpdateReadPointer=False)
        self.apply3rdLO(latest_chunk_data)
        return latest_chunk_data

    def peakLatestPhases(self):
        """ Returns a dict with the latest phase offset value for each channel.
        Units are cycles, dict keys are the channel IDs 1 through 4 """
        result = dict()
        data = self._peakLatestChunk()
        for channel_id in self.sl.channels_list:
            phi = data['phi%d' % channel_id]
            self.last_phi_int64[channel_id] = phi # for phase reset feature
            phi = phi.astype(float)
            phi = phi[0]/2**self.n_bits_phase
            phi = phi/self.sl.reg_values["phase_logger_n_cycles"]
            # phi is now in cycles
            result[channel_id] = phi
        return result

    def resetChannelPhase(self, channel_id):
        """ Called when the user wants to reset a channels' phase.
        Implemented by saving the last observed phase value via the peakLatestPhases feature,
        and merely subtracting off this offset """
        self.phi_offset_int64[channel_id] += self.last_phi_int64[channel_id]

    def apply3rdLO(self, data):
        """ Removes an additional phase ramp from the data measured by the fpga.
        This takes into account the finite resolution that we have in setting the various
        LO frequencies in the chain compared to what is requested by the user.
        Also handles the manual phase reset that can be requested by the user """
        for pt_index in range(len(data)):
            timestamp = data['timestamp'][pt_index]
            for channel_id in self.sl.channels_list:
                LO3_phase_int = self.get3rdLOPhaseInt(timestamp, self.sl.R_LO3[channel_id], channel_id)
                data['phi%d' % channel_id][pt_index] -= LO3_phase_int

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
        #   f.write(data.tobytes())

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

    def readData(self, N_blocksize=None):
        """ This should be called periodically in normal operation.
        If N_blocksize=None, it reads all available data and returns it.
        Returns None if there is no data
        If N_blocksize != None, it returns None
        unless there are at least N_blocksize data chunks,
        in which case it reads exactly N_blocksize chunks """
        chunksAvailable = self._chunksAvailable()
        if N_blocksize is None:
            if chunksAvailable == 0:
                return None
            else:
                number_of_chunks = chunksAvailable
        else:
            if chunksAvailable >= N_blocksize:
                number_of_chunks = N_blocksize
            else:
                return None
        # print("readData(): reading the %d chunks available" % chunksAvailable)
        data = self._readDataChunks(first_chunk_id=self.last_chunk_id+1,
                                    number_of_chunks = number_of_chunks)
        self.apply3rdLO(data)
        return data

    def compute3rdLOFreq(self, channel_id):
        """ Computes the exact LO frequency as a rational fraction of the ADC clock rate
        for a 3rd frequency shifting operation, which will bring the net
        frequency shift from input to saved data equal to the exact desired shift.
        This is necessary because of the finite possibilities for LO choices upstream """
        # self.bDisplayTiming = True
        if self.sl.user_inputs["mode_ch%d" % channel_id] != "counter":
            R_LO3 = rationals.RationalNumber(0, 1) # disable 3rd LO, in order for the streamed phase to be exactly equal to the phase inside the FPGA
            return R_LO3
        tictoc(self)
        # print(self.sl.user_inputs)
        if self.sl.user_inputs["bExternalClock"]: # normal mode: ADC is phase-locked to external ref
            # this is exact
            R_ADC = rationals.RationalNumber(self.sl.user_inputs["CLKFBOUT_MULT"], self.sl.user_inputs["CLKOUT0_DIVIDE"])
        else: # test mode: ADC is phase-locked to internal ref
            # this is not exact, since the physical frequencies aren't exactly known anyway
            pprint.pprint(self.sl.user_inputs)
            R_adc_ref_vs_ext_ref = rationals.RationalNumber(self.sl.user_inputs["adc_f_ref_hz"], self.sl.user_inputs["ref_freq_ch%d" % channel_id])
            R_ADC = rationals.RationalNumber(self.sl.user_inputs["CLKFBOUT_MULT"], self.sl.user_inputs["CLKOUT0_DIVIDE"])
            R_ADC = R_ADC * R_adc_ref_vs_ext_ref
        one_over_R_ADC = rationals.RationalNumber(R_ADC.denom, R_ADC.num)
        (LO1_num, LO1_denom) = self.sl.get_adf4351_settings(channel_id)
        R_LO1 = rationals.RationalNumber(LO1_num, LO1_denom)
        k_DDS = self.sl.reg_values["ref_freq%d" % channel_id]
        denom_DDS = rationals.FactoredInteger(2**48, 48*[2]) # provide the factorized number directly to avoid computing it each time (not sure if that matters overall, but it's easy to do
        R_DDS = rationals.RationalNumber(k_DDS, denom_DDS)
        R_LO2 = R_ADC * R_DDS

        F_in = rationals.RationalNumber(from_string = self.sl.user_inputs["expected_freq_str_ch%d" % channel_id], scale_factor=int(1e6))
        F_ref = rationals.RationalNumber(from_string = self.sl.user_inputs["ref_freq_MHz_str"], scale_factor=int(1e6))
        one_over_F_ref = rationals.RationalNumber(F_ref.denom, F_ref.num)
        R_in = F_in * one_over_F_ref

        R_LO3 = (abs(R_in - R_LO1) - R_LO2) * one_over_R_ADC
        # print("R_in=", R_in)
        # print("R_ADC=", R_ADC)
        # print("R_LO1=", R_LO1)
        # print("k_DDS=", k_DDS)
        # print("R_DDS=", R_DDS)
        # print("R_LO2=", R_LO2)
        # print("R_LO3=", R_LO3)
        tictoc(self, '')
        self.bDisplayTiming = False
        return R_LO3

    def get3rdLOPhaseRadians(self, timestamp, R_LO3, channel_id):
        """ Returns the value of the 3rd LO phase at a given ADC timestamp.
        Phase is returned in radians, modulo 2*pi.
        This phase does NOT contain the phase offset for manual phase reset """
        gain = int(2**int(self.n_bits_phase) * int(self.sl.reg_values["phase_logger_n_cycles"]))

        ts_times_num = int(timestamp) * R_LO3.num.x
        ts_times_num = ts_times_num % R_LO3.denom.x # this will maintain numerical accuracy despite the float() conversion
        phase_radians = 2*np.pi * float(ts_times_num) / R_LO3.denom.x

        return phase_radians

    def get3rdLOPhaseInt(self, timestamp, R_LO3, channel_id):
        """ Returns the value of the 3rd LO phase at a given ADC timestamp.
        Phase is returned in integer units of unwrapped phase produced by the phase readout.
        timestamp can either be a numpy array of int64 values, or a scalar int.
        This phase DOES contain the phase offset for manual phase reset """
        gain = int(2**int(self.n_bits_phase) * int(self.sl.reg_values["phase_logger_n_cycles"]))
        inner_func = lambda ts : (gain * int(ts) * R_LO3.num.x) // R_LO3.denom.x
        if isinstance(timestamp, np.ndarray):
            phase_int = np.zeros(timestamp.shape, dtype=np.int64)
            for ts in timestamp:
                phase_int[k] = inner_func(timestamp)
        else:
            # scalar case
            phase_int = inner_func(timestamp)
        # phase reset feature:
        phase_int += self.phi_offset_int64[channel_id]
        return phase_int

# end class definition

if __name__ == '__main__':
    sl = SuperLaserLand_JD_RP()
    sl.dev.OpenTCPConnection("192.168.2.34")
    sl.uart_uc_set_enable(0)
    ref_freq = 25e6 # frequency connected to clk_in
    time.sleep(0.1)
    sl.set_adf4351_freq(out_freq=40e6+15e6, ref_freq=ref_freq, channel=1)
    time.sleep(0.1)
    sl.set_adf4351_freq(out_freq=50e6-10e6, ref_freq=ref_freq, channel=2)
    time.sleep(0.1)
    time.sleep(0.1)
    # sl.turn_off_adf4351_channel(channel=1)
    # sl.turn_off_adf4351_channel(channel=2)
    # sl.turn_off_adf4351_channel(channel=4)
    # sl.turn_off_adf4351_channel(channel=8)

    time.sleep(0.1)
    sl.set_adf4351_freq(out_freq=60e6+15e6, ref_freq=ref_freq, channel=4)
    # time.sleep(0.1)
    sl.set_adf4351_freq(out_freq=1000e6+40e6, ref_freq=ref_freq, channel=8)
    time.sleep(0.1)
    # sl.set_adf4351_freq(out_freq=45e6, channel=4)
    # sl.set_adf4351_freq(out_freq=101e6, channel=8)

    readout = phaseReadoutDriver(sl.dev)
    readout.startLogging()
    time.sleep(1)
    data = readout.readData()
    print(data)


    # sl.set_adf4351_freq(out_freq=130e6, channel=1+2+4+8)
    # sl.set_adf4351_freq(out_freq=170e6+40e6, channel=8)
