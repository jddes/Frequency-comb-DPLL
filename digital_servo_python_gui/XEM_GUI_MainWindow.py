"""
XEM6010 Phase-lock box GUI, displays diagnostics on the raw signal, phase noise measurements, and loop filters tuning
by JD Deschenes, October 2013

"""
from __future__ import print_function
import time
from PyQt5 import QtGui, Qt
#import PyQt5.Qwt5 as Qwt
import numpy as np
import math
from scipy.signal import lfilter
from scipy.signal import decimate
from scipy.signal import detrend

# For make_sure_path_exists() and os.rename()
import os
import errno

#from SuperLaserLand_JD2 import SuperLaserLand_JD2
from LoopFiltersUI import LoopFiltersUI
from DisplayVNAWindow import DisplayVNAWindow
from LoopFiltersUI_DAC1_and_DAC2 import LoopFiltersUI_DAC1_and_DAC2
from DisplayDitherSettingsWindow import DisplayDitherSettingsWindow
#from DisplayCrashMonitorWindow import DisplayCrashMonitorWindow
#from ILX_laser_control import ILX_laser_control
#from PyDAQmx_single_1 import NIDAQ_USB
#from NIUSB_DAQ import Instrument
from user_friendly_QLineEdit import user_friendly_QLineEdit

import SpectrumWidget

#import matplotlib.pyplot as plt

import traceback

# stuff for Python 3 port
import pyqtgraph as pg

import RP_PLL # for CommsError
from SocketErrorLogger import logCommsErrorsAndBreakoutOfFunction

import logging

def round_to_N_sig_figs(x, Nsigfigs):
    leading_pos = np.floor(np.log10(np.abs(x)))
    factor = 10**((Nsigfigs-1)-leading_pos)
    return np.round(x * factor)/factor


def smooth(x,window_len=11,window='hanning'):
	"""smooth the data using a window with requested size.
	
	This method is based on the convolution of a scaled window with the signal.
	The signal is prepared by introducing reflected copies of the signal 
	(with the window size) in both ends so that transient parts are minimized
	in the begining and end part of the output signal.
	
	input:
		x: the input signal 
		window_len: the dimension of the smoothing window; should be an odd integer
		window: the type of window from 'flat', 'hanning', 'hamming', 'bartlett', 'blackman'
			flat window will produce a moving average smoothing.

	output:
		the smoothed signal
		
	example:

	t=linspace(-2,2,0.1)
	x=sin(t)+randn(len(t))*0.1
	y=smooth(x)
	
	see also: 
	
	numpy.hanning, numpy.hamming, numpy.bartlett, numpy.blackman, numpy.convolve
	scipy.signal.lfilter
 
	TODO: the window parameter could be the window itself if an array instead of a string
	NOTE: length(output) != length(input), to correct this: return y[(window_len/2-1):-(window_len/2)] instead of just y.
	"""

	if x.ndim != 1:
		raise ValueError("smooth only accepts 1 dimension arrays.")

	if x.size < window_len:
		raise ValueError("Input vector needs to be bigger than window size.")


	if window_len<3:
		return x


	if not window in ['flat', 'hanning', 'hamming', 'bartlett', 'blackman']:
		raise ValueError("Window is on of 'flat', 'hanning', 'hamming', 'bartlett', 'blackman'")


	s=np.r_[x[window_len-1:0:-1],x,x[-1:-window_len:-1]]
	#print(len(s))
	if window == 'flat': #moving average
		w=np.ones(window_len,'d')
	else:
		w=eval('np.'+window+'(window_len)')

	y=np.convolve(w/w.sum(),s,mode='valid')
	return y



class XEM_GUI_MainWindow(QtGui.QWidget):

	display_phase = 0 # used to refresh the phase noise plot only once every N refresh cycles
	VCO_detected_gain_in_Hz_per_Volts = [1, 1, 1]
	bFirstTimeLockCheckBoxClicked = True
		
#    def __init__(self):
#        super(XEM_GUI_MainWindow, self).__init__()
#        
#        self.bDisplayTiming = False # Activate to turn a lot of timing print()s
#        self.output_controls = (True, True, True)
#        self.initUI()
		
	def __init__(self, sl, strTitle, selected_ADC, output_controls, sp, custom_style_sheet, strFGPASerialNumber):
		super(XEM_GUI_MainWindow, self).__init__()
		
		self.strTitle = strTitle
		self.sl = sl
		self.sp = sp    # Holds the system parameters (configuration values)
		self.bDisplayTiming = False # Activate to turn a lot of timing print()s
		self.selected_ADC = selected_ADC
		self.output_controls = output_controls
		self.setObjectName('MainWindow')
		self.setStyleSheet(custom_style_sheet)
		self.strFGPASerialNumber = strFGPASerialNumber

		self.logger = logging.getLogger(__name__)
		self.logger_name = ':XEM_GUI_MainWindow'

		self.timerIDDither = None
		self.timerID = 0

		# For the crash monitor
		self.crash_number = 0
		self.crash_windows = []
		self.crash_windows_opening_times = []
		
		
		self.bAveragePhaseNoise = True
		self.bAveragePhaseNoiseLast = False
		self.N_spc_average = 10.
		
		# For the residuals streaming:
		# Only one window takes care of reading both the CEO and optical residuals
		if self.selected_ADC == 0:
			strFolder = 'c:\\SuperLaserLandLogs\\ResidualsStreaming'
			self.make_sure_path_exists(strFolder)
			self.word_counter = 0
			self.foutput_residuals      = open('%s\\residuals_ceo_%s.bin'       % (strFolder, self.strFGPASerialNumber), 'wb')
			self.foutput_residuals2     = open('%s\\residuals_optical_%s.bin'   % (strFolder, self.strFGPASerialNumber), 'wb')
			self.foutput_residuals_time = open('%s\\residuals_time_%s.bin' % (strFolder, self.strFGPASerialNumber), 'wb', 0)   # the 0 means un-buffered writes
		
		self.initUI()	

	def getValues(self):
		self.bFirstTimeLockCheckBoxClicked = False
		self.getVCOGain()
		self.spectrum.getDACoffset()
		self.getVCOFreq()

		self.qloop_filters[self.selected_ADC].getValues() # We should get qloop_filters.kc before (done in getVCOGain)
		
		self.setLock()

		self.timerIDDither = Qt.QTimer(self)
		self.timerIDDither.timeout.connect(self.timerDitherEvent)
		self.startTimers()
		self.displayDAC()   # This populates the current DAC values with the actual value
		self.qchk_refresh.setChecked(False)
		self.refreshChk_event()

	def pushActualValues(self):
		print("Push actual values of MainWindow, TODO")

	def pushDefaultValues(self):
		# print("XEM_GUI_MainWindow::pushDefaultValues()")
		#For now, equivalent to calling initSL()
		self.loadParameters()
		# Send values to FPGA
		self.setVCOFreq_event()
		self.setVCOGain_event()
		self.chkLockClickedEvent()

		self.timerIDDither = Qt.QTimer(self)
		self.timerIDDither.timeout.connect(self.timerDitherEvent)
		self.startTimers()
		self.displayDAC()   # This populates the current DAC values with the actual value

		# print("XEM_GUI_MainWindow::pushDefaultValues(): after displayDAC")
		if self.output_controls[0] == True:
			self.slowStart100VSwitchingSupply()


	@logCommsErrorsAndBreakoutOfFunction()
	def slowStart100VSwitchingSupply(self):
		# need to set the switching supply to its default values:
		# do a slow start over ~ 100 ms.
		f_switching = 200e3
		Vtarget = 100.
		Vsupply = 30.
		T_slow_start = 100e-3


		target_duty_cycle = (Vtarget-Vsupply)/Vtarget
		oscillator_modulus = int(round(  self.sl.fs/f_switching ))

		print("slowStart100VSwitchingSupply(): starting")
		N_steps = 10
		for k in range(int(N_steps)+1):
			# print("slowStart100VSwitchingSupply(): here")
			current_duty_cycle = float(k)/N_steps * target_duty_cycle
			# print("slowStart100VSwitchingSupply(): here2")
			oscillator_modulus_active = int(round(  oscillator_modulus * current_duty_cycle ))
			# print("slowStart100VSwitchingSupply(): here3")
			self.sl.setTestOscillator(bEnable=1, bPolarity=1, oscillator_modulus=oscillator_modulus, oscillator_modulus_active=oscillator_modulus_active)
			# try:
			# 	self.sl.setTestOscillator(bEnable=1, bPolarity=1, oscillator_modulus=oscillator_modulus, oscillator_modulus_active=oscillator_modulus_active)
			# except RP_PLL.CommsError:
			# 	break
			time.sleep(T_slow_start/N_steps)

		print("slowStart100VSwitchingSupply(): finished")

	def killTimers(self):
		# print("XEM_GUI_MainWindow::killTimers(): %s" % self.strTitle)
		#traceback.print_stack()
		if self.timerIDDither is not None:
			self.timerIDDither.stop()

		if self.qchk_refresh.isChecked():
			self.qchk_refresh.setChecked(False)
			self.refreshChk_event()
		
	def startTimers(self):
		# print("XEM_GUI_MainWindow::startTimers(): %s" % self.strTitle)
		# Need to init timerID
		self.timerID = 0

		# Start the timer which reads the dither:
		if self.timerIDDither is not None:
			self.timerIDDither.start(100)   # 100 ms readout delay, increased to 1000 ms for debugging


	def getVCOGainFromUI(self, output_number):

		try:
			VCO_gain_in_Hz_per_Volts = float(self.qedit_vco_gain[output_number].text())
		except:
			VCO_gain_in_Hz_per_Volts = 1e9

		return VCO_gain_in_Hz_per_Volts

	@logCommsErrorsAndBreakoutOfFunction()
	def setVCOGain_event(self):
		# Update the loop filters gain settings based on the new VCO gains:

		# Also set the scale on the manual output sliders (and the steps)
		# We want the user to be able to easily control the beat frequency with the mousewheel.
		# (mousewheel scroll: 3 small steps or arrow keys: 1 small step)
		# We want each mousewheel step to be about 0.5 MHz,
		# large steps (clicking in the open area of the scrollbar) to be about 5 MHz
		for k in range(3):
			if self.output_controls[k]:
				VCO_gain_in_Hz_per_Volts = self.getVCOGainFromUI(k)

				# getFreqDiscriminatorGain is in DDC Counts/Hz
				# getDACGainInVoltsPerCounts is in V/(DAC Counts)
				VCO_gain_in_counts_per_counts = VCO_gain_in_Hz_per_Volts * self.sl.getFreqDiscriminatorGain() * self.sl.getDACGainInVoltsPerCounts(k) #.sl.getFreqDiscriminatorGain() and self.sl.getDACGainInVoltsPerCounts(k) are constant (different for each k)

				if k == 0 or k == 1:
					self.qloop_filters[k].kc = VCO_gain_in_counts_per_counts
					self.qloop_filters[k].checkFirmwareLimits()
					self.qloop_filters[k].updateFilterSettings()
					self.qloop_filters[k].updateGraph()
				elif k == 2:
					# DAC 2 loop settings are controlled by the same widget as DAC1
					self.qloop_filters[1].kc_dac2 = VCO_gain_in_counts_per_counts
					self.qloop_filters[1].checkFirmwareLimits()
					self.qloop_filters[1].updateFilterSettings()
					self.qloop_filters[1].updateGraph()

				self.sl.save_openLoop_gain(k, VCO_gain_in_counts_per_counts) #Save the value of the open-loop gain in the FPGA to allow reconnection (usefull to read Loop-Filter gain value)
				
				self.spectrum.setSliderStepSize(k, VCO_gain_in_Hz_per_Volts)

		# This function needs the VCO gain to compute the control effort so we have to update it if we have changed.
		self.spectrum.setDACOffset_event()

	@logCommsErrorsAndBreakoutOfFunction()
	def getVCOGain(self):
		if self.selected_ADC == 0:
			dac_list = [0]
		elif self.selected_ADC == 1:
			dac_list = [1, 2]

		for k in dac_list:
			# if self.output_controls[k]:
			VCO_gain_in_counts_per_counts = self.sl.get_openLoop_gain(k)
			# print("k = %d, VCO_gain_in_counts_per_counts=%f" % (k, VCO_gain_in_counts_per_counts))
			VCO_gain_in_Hz_per_Volts = VCO_gain_in_counts_per_counts / (self.sl.getFreqDiscriminatorGain() * self.sl.getDACGainInVoltsPerCounts(k))
			# print("k = %d, VCO_gain_in_Hz_per_Volts=%f" % (k, VCO_gain_in_Hz_per_Volts))
			# prevent divide-by-0 bug:
			if VCO_gain_in_Hz_per_Volts == 0:
				VCO_gain_in_Hz_per_Volts = 1.

			self.qedit_vco_gain[k].blockSignals(True)
			self.qedit_vco_gain[k].setText('{:.1e}'.format(VCO_gain_in_Hz_per_Volts))
			self.qedit_vco_gain[k].blockSignals(False)

			if k == 0 or k == 1:
				self.qloop_filters[k].kc = VCO_gain_in_counts_per_counts
				self.qloop_filters[k].checkFirmwareLimits()
				self.qloop_filters[k].updateGraph()
			elif k == 2:
				# DAC 2 loop settings are controlled by the same widget as DAC1
				self.qloop_filters[1].kc_dac2 = VCO_gain_in_counts_per_counts
				self.qloop_filters[1].checkFirmwareLimits()
				self.qloop_filters[1].updateGraph()


			self.spectrum.setSliderStepSize(k, VCO_gain_in_Hz_per_Volts)

	@logCommsErrorsAndBreakoutOfFunction()
	def setVCOFreq_event(self, checked=False):
		# print("setVCOFreq_event: self.selected_ADC = %d" % self.selected_ADC)
		try:
			frequency_in_hz = float(self.qedit_ref_freq.text())
		except:
			frequency_in_hz = 5e6

			
		# If the VCO has positive sign, we need to put a negative reference frequency to make the
		# total loop sign be negative so that it's stable when we close the loop
		if self.qsign_positive.isChecked():
			frequency_in_hz =-frequency_in_hz
		#print('frequency_in_hz = %e' % frequency_in_hz)
		if self.selected_ADC == 0:
			self.sl.set_ddc0_ref_freq(frequency_in_hz)
		elif self.selected_ADC == 1:
			self.sl.set_ddc1_ref_freq(frequency_in_hz)
		#print('frequency_in_hz = %e (after)' % frequency_in_hz)

	@logCommsErrorsAndBreakoutOfFunction()
	def getVCOFreq(self):
		if self.selected_ADC == 0:
			frequency_in_hz = self.sl.get_ddc0_ref_freq_from_RAM()
		elif self.selected_ADC == 1:
			frequency_in_hz = self.sl.get_ddc1_ref_freq_from_RAM()
		# If the VCO has positive sign, we need to put a negative reference frequency to make the
		# total loop sign be negative so that it's stable when we close the loop
		if frequency_in_hz < 0:
			self.qsign_positive.setChecked(True)
		else:
			self.qsign_negative.setChecked(True)
			
		self.qedit_ref_freq.blockSignals(True)
		self.qedit_ref_freq.setText('%.2e' % abs(frequency_in_hz))
		self.qedit_ref_freq.blockSignals(False)
		
	def refreshChk_event(self):
		if self.qchk_refresh.isChecked():
			# We are doing a not running->running transition
			try:
#            if True:
#                print('self.qedit_timerdelay.text() = %s' % self.qedit_timerdelay.text())
				timer_delay = float(self.qedit_timerdelay.text())
				
			except:
#            else:
				timer_delay = 1000
#            print('Timer delay = %d ms' % timer_delay)
			if self.timerID != 0:
				self.killTimer(self.timerID)
			self.timerID = self.startTimer(int(round(timer_delay)))
			self.timerEvent(0)  # run the event handler once right away, makes the checkbox feel more responsive
#            print('Starting timer')
		else:

			# We are doing a running->not running transition
			if self.timerID != 0:
				self.killTimer(self.timerID)
				self.timerID = 0
#                print('Stopping timer')
			
	def exportData(self):
		# First need to create a unique file name template (with good probability)
		# We simply use the system date and time, and hope that this function doesn't get called twice in a second
		strNameTemplate = time.strftime("data_export\\%m_%d_%Y_%H_%M_%S_")
#        Data to write:
#        self.inst_freq
#        self.freq_noise_psd
#        self.freq_noise_axis
#        self.raw_adc_samples
		
		# Create the subdirectory if it doesn't exist:
		self.make_sure_path_exists('data_export')
		
		# Open files for output, write raw data
#        if True:
		try:
			strCurrentName = strNameTemplate + 'raw_adc_samples.bin'
			f = open(strCurrentName, 'wb')
			f.write(self.raw_adc_samples)
			f.close()
		except:
			pass
		try:
			strCurrentName = strNameTemplate + 'inst_freq.bin'
			f = open(strCurrentName, 'wb')
			f.write(self.inst_freq)
			f.close()
		except:
			pass
		try:
			strCurrentName = strNameTemplate + 'freq_noise_psd.bin'
			f = open(strCurrentName, 'wb')
			f.write(self.freq_noise_psd)
			f.close()
		except:
			pass
		try:
			strCurrentName = strNameTemplate + 'freq_noise_axis.bin'
			f = open(strCurrentName, 'wb')
			f.write(self.freq_noise_axis)
			f.close()
		except:
			pass

		
	def showVNA(self):
		self.vna = DisplayVNAWindow(self.sl)
		

			
	def grabAndExportData(self, bSyncReadOnNextTimeQuantization=True):
		
		start_time = time.perf_counter()
		print('Grabbing and exporting data')
		# Check if another function is currently using the DDR2 logger:
		if self.sl.bDDR2InUse:
			print('grabAndExportData(): DDR2 logger in use, cannot get data from adc')
			return
			
		# Ask which input to use:
		currentSelector, ok = QtGui.QInputDialog.getItem(self, 'Raw data export', 
			'Select the data source:', ('ADC0', 'ADC1', 'DAC0', 'DAC1', 'DAC2'))
		if not ok:
			return
		currentSelector = str(currentSelector)
			
		# Ask how many points:
		N_points_str, ok = QtGui.QInputDialog.getText(self, 'Raw data export', 
			'Enter the number of points desired [1, 32768]:', Qt.QLineEdit.Normal, '32768')
		if not ok:
			return
			
		# Block access to the DDR2 Logger to any other function until we are done:
		self.sl.bDDR2InUse = True

		try:
			N_points = int(float(N_points_str))
		except:
			N_points = 4e3
		
		if N_points < 64:
			N_points = 64
	
		try:
			# Read from selected source
			print("currentSelector = %s" % currentSelector)
			self.sl.setup_write(self.sl.LOGGER_MUX[currentSelector], N_points)
			
			##################################################
			# Synchronize trigger as best as possible to the next multiple of time_quantum seconds:
			if bSyncReadOnNextTimeQuantization:
				time_quantum = 0.01
				time_now = time.time()
				time_target = np.ceil(time_now/time_quantum) * time_quantum
				print('time_now = %f, time_target = %f' % (time_now, time_target))
				
				while time_target > time_now:
					time.sleep(1e-3)
					time_now = time.time()
				
			self.sl.trigger_write()
			if bSyncReadOnNextTimeQuantization:
				print('time_now = %f, time_target = %f' % (time_now, time_target))
			self.sl.wait_for_write()
			(samples_out, ref_exp0) = self.sl.read_adc_samples_from_DDR2()
			samples_out = samples_out.astype(dtype=np.float)/2**15
		except:
			# ADC read failed.
			print('Unhandled exception in ADC read')
#            del self.sl
#            raise
			
		# Signal to other functions that they can use the DDR2 logger
		self.sl.bDDR2InUse = False
		
		print('Elapsed time (Comm) = %f' % (time.perf_counter()-start_time))
		start_time = time.perf_counter()
		
		# Write the data to disk:
		strNameTemplate = time.strftime("data_export\\%m_%d_%Y_%H_%M_%S_")

		self.make_sure_path_exists('data_export')

		# Open files for output, write raw data
		try:
			strCurrentName = strNameTemplate + self.strFGPASerialNumber +  '_raw_adc_samples.bin'
			f = open(strCurrentName, 'wb')
			f.write(samples_out)
			f.close()
		except:
			pass
		
		print('Elapsed time (write to disk) = %f' % (time.perf_counter()-start_time))
		start_time = time.perf_counter()

	def setLock(self):
		bLock = self.qloop_filters[self.selected_ADC].qchk_lock.isChecked()
		self.qchk_lock.setChecked(bLock)
		if bLock:
			#We are reconnecting to a RP which has a locked loop filter
			self.qchk_lock.setStyleSheet('font-size: 18pt; color: white; background-color: green')            
		else:
			self.qchk_lock.setStyleSheet('font-size: 18pt; color: white; background-color: red')

	@logCommsErrorsAndBreakoutOfFunction()
	def chkLockClickedEvent(self, checked=False):
		bLock = self.qchk_lock.isChecked()
		if bLock:
			# we are doing an unlocked->locked transition.
		
			# We first check if the detected VCO gain seems right:
			if self.sl.dither_enable[self.selected_ADC]:
				# check if gain is OK
				try:
					VCO_gain_in_Hz_per_Volts = float(self.qedit_vco_gain[self.selected_ADC].text())
				except:
					VCO_gain_in_Hz_per_Volts = 1e9
				# First check if sign is right:
				if np.sign(self.VCO_detected_gain_in_Hz_per_Volts[self.selected_ADC]) != np.sign(VCO_gain_in_Hz_per_Volts):
					# Display warning message.
					reply = QtGui.QMessageBox.question(self, 'Warning',
								"The detected VCO gain is negative.  This will most likely make the loop unstable.  This is either caused by trying to lock to an incorrect sideband, or an incorrect setting of the VCO sign in the UI.  Do you want to turn on the lock anyway?",
								QtGui.QMessageBox.Yes | QtGui.QMessageBox.No, QtGui.QMessageBox.No)
					
					if reply == QtGui.QMessageBox.No:
						# Exit early
						self.qchk_lock.setChecked(False)
						return 
					print('Warning about the loop sign ignored.')
				else:
					print('Gain sign OK')
				# Now we check if the magnitude of the entered VCO gain and the detected gain agree within some tolerance:
				if self.VCO_detected_gain_in_Hz_per_Volts[self.selected_ADC]/VCO_gain_in_Hz_per_Volts > 1.5 or self.VCO_detected_gain_in_Hz_per_Volts[self.selected_ADC]/VCO_gain_in_Hz_per_Volts < 1/1.5:
					# Display warning message.
					reply = QtGui.QMessageBox.question(self, 'Warning',
								"The detected VCO gain (%.2e Hz/V) has a significantly different magnitude than the entered value used for designing the controller (%.2e Hz/V).  This may make the loop unstable.  Do you want to turn on the lock anyway?" % (self.VCO_detected_gain_in_Hz_per_Volts[self.selected_ADC], VCO_gain_in_Hz_per_Volts),
								QtGui.QMessageBox.Yes | QtGui.QMessageBox.No, QtGui.QMessageBox.No)
					
					if reply == QtGui.QMessageBox.No:
						# Exit early
						self.qchk_lock.setChecked(False)
						return
					print('Warning about the loop gain ignored.')
				else:
					print('Gain magnitude OK')
					
			# If we get here that means either that all the parameters have passed the checks, or the dither was off.
			# Turn the dither off if the dither mode is automatic:
			if self.selected_ADC == 0:
				if self.sl.dither_mode_auto[0] == 1:
					# automatic mode
					self.sl.setDitherLockInState(0, False)
			else:
				# Optical lock: we have two dithers to take care of:
				if self.sl.dither_mode_auto[1] == 1:
					# automatic mode
					self.sl.setDitherLockInState(1, False)
				# if self.sl.dither_mode_auto[2] == 1:
				#     # automatic mode
				#     self.sl.setDitherLockInState(2, False)
					
			self.logger.info('Red_Pitaya_GUI{}: Lock'.format(self.logger_name))
			self.qchk_lock.setStyleSheet('font-size: 18pt; color: white; background-color: green')            
			# Turn the lock on
			if self.selected_ADC == 0:
				self.qloop_filters[0].qchk_lock.setChecked(True)
				self.qloop_filters[0].updateFilterSettings()

			elif self.selected_ADC == 1:
				# Lock procedure if there is no 3rd DAC on the Red Pitaya:
				# self.qloop_filters[1].qchk_lock.setChecked(True)
				# self.qloop_filters[1].updateFilterSettings()

				
				# There is a different procedure for turning the lock on on the optical loop:
				# first we grab the beat using the DAC2 frequency-locked loop. then we set this integrator to hold
				# and switch to the DAC1 PLL + DAC2 second integrator.
				self.qloop_filters[1].qradio_mode_off.setChecked(False)
				self.qloop_filters[1].qradio_mode_slow.setChecked(True)
				self.qloop_filters[1].qradio_mode_fast.setChecked(False)
				self.qloop_filters[1].qradio_mode_both.setChecked(False)
				self.qloop_filters[1].updateSettings()
				
				# Wait for the integrator to grab on to the beat
				time.sleep(0.2)
				
				# Turn on the full-blown PLL
				self.qloop_filters[1].qradio_mode_off.setChecked(False)
				self.qloop_filters[1].qradio_mode_slow.setChecked(False)
				self.qloop_filters[1].qradio_mode_fast.setChecked(False)
				self.qloop_filters[1].qradio_mode_both.setChecked(True)
				self.qloop_filters[1].updateSettings()
				
		
		else:   # bLock = False
			if not self.sl.output_vco[self.selected_ADC]:


				if not self.bFirstTimeLockCheckBoxClicked:
					# We are doing a locked->unlocked transition
					# 1. Smoothly ramp the manual dac offsets to where the lock has decided to sit:
					# This is to prevent any violent step on the actuator when we turn off the lock:
					# It also prevents mode changes (the laser should stay fairly close to when it was locked.
					if self.selected_ADC == 0:
						# Go and measure the current DAC DC value:
						N_points = 10e3
						self.sl.setup_DAC0_write(N_points)
						self.sl.trigger_write()
						self.sl.wait_for_write()
						(samples_out, ref_exp0) = self.sl.read_adc_samples_from_DDR2()
	#                    print(np.mean(samples_out))
						current_dac_offset_in_counts = np.mean(samples_out)
						kDAC = 0
						
						
					elif self.selected_ADC == 1:
						N_points = 10e3
						self.sl.setup_DAC1_write(N_points)
						self.sl.trigger_write()
						self.sl.wait_for_write()
						(samples_out, ref_exp0) = self.sl.read_adc_samples_from_DDR2()
	#                    print(np.mean(samples_out))
						current_dac_offset_in_counts = np.mean(samples_out)
						kDAC = 1
						
					# Read the current manual offset value:
					current_manual_offset_in_slider_units = float(self.spectrum.q_dac_offset[kDAC].value())
					# Convert the DAC DC offset to the slider units:
					current_dac_offset_in_slider_units = float(current_dac_offset_in_counts - self.sl.DACs_limit_low[kDAC])/float(self.sl.DACs_limit_high[kDAC] - self.sl.DACs_limit_low[kDAC])*1e6
					
					# Set up a ramp with 20 steps:
					desired_ramp = np.linspace(current_manual_offset_in_slider_units, current_dac_offset_in_slider_units, 20)
					# print('ramping from %d to %d in slider units' % (current_manual_offset_in_slider_units, current_dac_offset_in_slider_units))
					
					Total_ramp_time = 0.1
					for k2 in range(len(desired_ramp)):
	#                    print('set slider to %d' % desired_ramp[k2])
						self.spectrum.q_dac_offset[kDAC].setValue(desired_ramp[k2])
						self.spectrum.setDACOffset_event()
						time.sleep(float(Total_ramp_time)/len(desired_ramp))
				
					# 2. turn the lock off
					if self.selected_ADC == 0:
						self.qloop_filters[0].qchk_lock.setChecked(False)
						self.qloop_filters[0].updateFilterSettings()
					elif self.selected_ADC == 1:
						# Unlock procedure for when there is no 3rd DAC on the Red Pitaya
						# self.qloop_filters[1].qchk_lock.setChecked(False)
						# self.qloop_filters[1].updateFilterSettings()

						# There is a different procedure for turning the lock on on the optical loop:
						# first we grab the beat using the DAC2 frequency-locked loop. then we set this integrator to hold
						# and switch to the DAC1 PLL + DAC2 second integrator.
						self.qloop_filters[1].qradio_mode_off.setChecked(True)
						self.qloop_filters[1].qradio_mode_slow.setChecked(False)
						self.qloop_filters[1].qradio_mode_fast.setChecked(False)
						self.qloop_filters[1].qradio_mode_both.setChecked(False)
						self.qloop_filters[1].updateSettings()
					
			else:
				# if the VCO is activated, we don't want to try to estimate the output offset, we just turn off the lock directly
				# 2. turn the lock off
				if self.selected_ADC == 0:
					self.qloop_filters[0].qchk_lock.setChecked(False)
					self.qloop_filters[0].updateFilterSettings()
				elif self.selected_ADC == 1:
					self.qloop_filters[1].qchk_lock.setChecked(False)
					self.qloop_filters[1].updateFilterSettings()
		
			# 3. Turn the dither on if the dither mode is automatic:
			if self.selected_ADC == 0:
				if self.sl.dither_mode_auto[0] == 1:
					# automatic mode
					self.sl.setDitherLockInState(0, True)
			else:
				# Optical lock: we have two dithers to take care of:
				if self.sl.dither_mode_auto[1] == 1:
					# automatic mode
					self.sl.setDitherLockInState(1, True)
				# if self.sl.dither_mode_auto[2] == 1:
				#     # automatic mode
				#     self.sl.setDitherLockInState(2, True)
					
			self.logger.info('Red_Pitaya_GUI{}: Unlock'.format(self.logger_name))
			self.qchk_lock.setStyleSheet('font-size: 18pt; color: white; background-color: red')
			

		self.bFirstTimeLockCheckBoxClicked = False

			
	def initUI(self):
		
#        second_half_offset = 50
		# Change the background color of the main form so that each controls group stand out better
		PalNormal = Qt.QPalette()
		
		# Assign the palette to the main form to read off the 'normal' background color:
		self.setPalette(PalNormal)
		normalBackgroundRGB = PalNormal.color(Qt.QPalette.Background).getRgb()
#        print(normalBackground.getRgb())
		
		# Darken the background of the dialog slightly
		darker_factor = 0.5
		PalDarkerBackground = Qt.QPalette()
		PalDarkerBackground.setColor(Qt.QPalette.Background, Qt.QColor(normalBackgroundRGB[0]*darker_factor, normalBackgroundRGB[1]*darker_factor, normalBackgroundRGB[2]*darker_factor))
#        PalDarkerBackground.setColor(Qt.QPalette.Background, Qt.QColor(255, 255, 255))
		self.setPalette(PalDarkerBackground)
		self.setAutoFillBackground(True)
				
		
		# PalNormal's color has been changed when we assigned PalDarkerBackground to self - this statement seems very circular but somehow it works
		PalNormal.setColor(Qt.QPalette.Background, PalNormal.color(Qt.QPalette.Background))
		
		######################################################################
		# Settings
		######################################################################
		self.qgroupbox_settings = Qt.QGroupBox('Settings', self)
		
		# Button which exports the data to the disk
		self.qbtn = QtGui.QPushButton('Export PSD data')
		self.qbtn.clicked.connect(self.exportData)
		
		# Button which grabs a single acquisition from the DDR memory and exports the data to the disk
		self.qbtn_grab = QtGui.QPushButton('Export ADC data')
		self.qbtn_grab.clicked.connect(self.grabAndExportData)
		
		# Button which opens the VNA window:
		self.qbtn_VNA = QtGui.QPushButton('Transfer function')
		self.qbtn_VNA.clicked.connect(self.showVNA)
		
		# VCO modulation gain:
		self.qedit_vco_gain = {}
		
		self.qlabel_detected_vco_gain = {}
		if self.selected_ADC == 0:
			# CEO Lock: only one output (DAC0)
			self.qlabel_vco_gain = Qt.QLabel('VCO Gain (DAC0) [Hz/V]:')
			self.qlabel_detected_vco_gain_label = Qt.QLabel('Detected VCO Gain [Hz/V]:')
			
			self.qedit_vco_gain[0] = user_friendly_QLineEdit('1e6')
			self.qedit_vco_gain[0].returnPressed.connect(self.setVCOGain_event)
			self.qedit_vco_gain[0].setMaximumWidth(60)
			
			self.qlabel_detected_vco_gain[0] = Qt.QLabel('0 Hz/V')
			self.qlabel_detected_vco_gain[0].setAlignment(Qt.Qt.AlignHCenter)
			
		else:
			# Optical lock
			self.qlabel_vco_gain = Qt.QLabel('VCO Gains (DAC1, DAC2HV) [Hz/V]:')
			# self.qlabel_vco_gain = Qt.QLabel('VCO Gain (DAC1) [Hz/V]:')
			
			self.qlabel_detected_vco_gain_label = Qt.QLabel('Detected VCO Gain [Hz/V]:')
			
			self.qedit_vco_gain[1] = user_friendly_QLineEdit('1e6')
			self.qedit_vco_gain[1].returnPressed.connect(self.setVCOGain_event)
			self.qedit_vco_gain[1].setMaximumWidth(60)
			
			self.qedit_vco_gain[2] = user_friendly_QLineEdit('1e6')
			self.qedit_vco_gain[2].returnPressed.connect(self.setVCOGain_event)
			self.qedit_vco_gain[2].setMaximumWidth(60)
			
			self.qlabel_detected_vco_gain[1] = Qt.QLabel('0 Hz/V')
			self.qlabel_detected_vco_gain[1].setAlignment(Qt.Qt.AlignHCenter)
			
			self.qlabel_detected_vco_gain[2] = Qt.QLabel('0 Hz/V')
			self.qlabel_detected_vco_gain[2].setAlignment(Qt.Qt.AlignHCenter)

		
		# DDC reference frequency:
		self.qlabel_ref_freq = Qt.QLabel('Reference freq [Hz]:')
		self.qedit_ref_freq = user_friendly_QLineEdit('5e6')
		self.qedit_ref_freq.returnPressed.connect(self.setVCOFreq_event)
		self.qedit_ref_freq.setMaximumWidth(60)
		
		
		# Main button for turning the locks on/off:
		self.qchk_lock = Qt.QCheckBox('Lock')
		self.qchk_lock.setStyleSheet('')
		self.qchk_lock.setStyleSheet('font-size: 18pt; color: white; background-color: red')
#        self.qchk_lock.setStyleSheet('font-size: 18pt; color: white; background-color: green')
		self.qchk_lock.clicked.connect(self.chkLockClickedEvent)
		self.qchk_lock.setChecked(False)
				
		# VCO sign:
		self.qsign_positive = Qt.QRadioButton('VCO sign +')
		self.qsign_negative = Qt.QRadioButton('VCO sign -')
		self.qsign_group = Qt.QButtonGroup(self)
		self.qsign_group.addButton(self.qsign_positive)
		self.qsign_group.addButton(self.qsign_negative)
		
		self.qsign_positive.setChecked(True)
		self.qsign_negative.setChecked(False)
		self.qsign_positive.clicked.connect(self.setVCOFreq_event)
		self.qsign_negative.clicked.connect(self.setVCOFreq_event)
		
		
		# Create widgets to indicate performance
		self.last_refresh = time.perf_counter()
		self.qlabel_refreshrate_display = Qt.QLabel('Actual delay:')
		self.qlabel_refreshrate = Qt.QLabel('1000 ms')
#        self.qlabel_refreshrate.resize(self.qlabel_refreshrate.sizeHint())
		

		self.qlabel_timerdelay = Qt.QLabel('Refresh delay [ms]:')
		self.qedit_timerdelay = user_friendly_QLineEdit('33')
		self.qedit_timerdelay.returnPressed.connect(self.refreshChk_event)
		self.qedit_timerdelay.setMaximumWidth(60)
		
		self.qchk_refresh = Qt.QCheckBox('Auto-refresh')
		self.qchk_refresh.clicked.connect(self.refreshChk_event)
		

		
		
		# Status reporting:
		if self.selected_ADC == 0:
			self.qlbl_status1 = Qt.QLabel('Status: Idle')
		elif self.selected_ADC == 1:
			self.qlbl_status1 = Qt.QLabel('Status: Idle')
			self.qlbl_status2 = Qt.QLabel('Status: Idle')
		
		
		# Put all the widgets into a grid layout
		grid = QtGui.QGridLayout()
		grid.setHorizontalSpacing(10)
		grid.setVerticalSpacing(1)
		
		# 3 rows, XX columns
		grid.addWidget(self.qbtn,                       0, 0)
		grid.addWidget(self.qbtn_VNA,                   1, 0)
		grid.addWidget(self.qbtn_grab,                  2, 0)
		
		grid.addWidget(self.qchk_refresh,               0, 1)
		grid.addWidget(self.qlabel_timerdelay,          1, 1)
		grid.addWidget(self.qedit_timerdelay,           1, 2)
		
		grid.addWidget(self.qlabel_refreshrate_display, 2, 1)
		grid.addWidget(self.qlabel_refreshrate,         2, 2)
		

		
#        grid.addWidget(self.qlabel_bytes_skip,          0, 3)
#        grid.addWidget(self.qedit_bytes_skip,           0, 4)
		grid.addWidget(self.qchk_lock,                  0, 3, 1, 2)
		grid.addWidget(self.qlabel_ref_freq,            1, 3)
		grid.addWidget(self.qedit_ref_freq,             1, 4)
		
		# # both PLLs need to receive a threshold for the residuals.
		# # See tooltip for info
		# grid.addWidget(self.qlabel_crash_threshold,     2, 3)
		# grid.addWidget(self.qedit_crash_threshold,      2, 4)
		

		
		
		# only the first PLL has a crash monitor module in the current firmware:
		if self.selected_ADC == 0:
			pass
			#FEATURE
			#grid.addWidget(self.qlabel_crash_threshold_freq,     2, 5)
			#grid.addWidget(self.qedit_crash_threshold_freq,      2, 6)
			#grid.addWidget(self.qchk_crash_monitor,         2, 7)

		
		
		# We put a sub-grid in the grid
		# we put the VCO controls in the sub-grid, this way the outer grid stays the same size regardless of the number of elements
		grid2 = Qt.QGridLayout()   
		grid2.setHorizontalSpacing(10)
		grid2.setVerticalSpacing(10)
		
		if self.selected_ADC == 0:
			# CEO Lock: only one output (DAC0)
			grid2.addWidget(self.qlabel_vco_gain,                           0, 0)
			grid2.addWidget(self.qlabel_detected_vco_gain_label,            1, 0)
			
			grid2.addWidget(self.qedit_vco_gain[0],                         0, 1)
			grid2.addWidget(self.qlabel_detected_vco_gain[0],               1, 1)
		
			
		else:
			# Optical lock: two outputs (DAC1 and DAC2)
			grid2.addWidget(self.qlabel_vco_gain,                           0, 0)
			grid2.addWidget(self.qlabel_detected_vco_gain_label,            1, 0)
			
			grid2.addWidget(self.qedit_vco_gain[1],                         0, 1)
			grid2.addWidget(self.qlabel_detected_vco_gain[1],               1, 1)
			
			grid2.addWidget(self.qedit_vco_gain[2],                         0, 2)
			# grid2.addWidget(self.qlabel_detected_vco_gain[2],               1, 2)
		
		grid.addLayout(grid2, 0, 5, 2, 2)        
		grid.addWidget(self.qsign_positive,             0, 7)
		grid.addWidget(self.qsign_negative,             1, 7)
		

		
		grid.addWidget(Qt.QLabel(),                     0, 9, 1, 1)
		grid.setColumnStretch(9, 1)
		
		self.qgroupbox_settings.setLayout(grid)    
		self.qgroupbox_settings.setPalette(PalNormal)
		self.qgroupbox_settings.setAutoFillBackground(True)
		
        ######################################################################
        # Spectrum analyzer/Diagnostics
        ######################################################################
		self.spectrum = SpectrumWidget.SpectrumWidget(self, self.selected_ADC, self.output_controls, self.sl, PalNormal)
		
		######################################################################
		# Create the controls for the loop filters
		######################################################################
		self.qgroupbox_loop_filters = Qt.QGroupBox('Loop filters', self)
		
		hbox = Qt.QHBoxLayout()
		self.qloop_filters = {}
		
		for k in range(3):
			if self.output_controls[k] == True:
				if k == 0:
	#                print('XEM_GUI_MainWindow(): About to call LoopFiltersUI()')
					self.qloop_filters[k] = LoopFiltersUI(self.sl, k, bDisplayLockChkBox=False)

					
					hbox.addWidget(self.qloop_filters[k])
					#self.qloop_filters[k].show()
				
				elif k == 1:
					self.qloop_filters[k] = LoopFiltersUI_DAC1_and_DAC2(self.sl, k, self.sl.pll[k])
					hbox.addWidget(self.qloop_filters[k])
					self.qloop_filters[k].show()
					
		
		
		self.qgroupbox_loop_filters.setLayout(hbox)
		
#        self.qgroupbox_loop_filters.setLayout(grid)
		self.qgroupbox_loop_filters.setPalette(PalNormal)
		self.qgroupbox_loop_filters.setAutoFillBackground(True)
		
		######################################################################
		# Phase noise analysis
		######################################################################
		self.qgroupbox_phasenoise = Qt.QGroupBox('Phase noise (all computed from DDC output)', self)
		
		# Selector for the plot type (phase or freq noise)
#        self.qlabel_ddc_plot_select = Qt.QLabel('Plot type:')
		self.qcombo_ddc_plot = Qt.QComboBox()
		self.qcombo_ddc_plot.addItem('Freq')
		self.qcombo_ddc_plot.addItem('Phase')
		self.qcombo_ddc_plot.addItem('Freq: time domain')
		self.qcombo_ddc_plot.addItem('Phase: time domain')
		self.qcombo_ddc_plot.setCurrentIndex(1)
		
		# Create widgets to set the number of points for the DDC graphs:
		self.qlabel_ddc_rbw = Qt.QLabel('RBW: 100 kHz; Points:')
		self.qedit_ddc_length = Qt.QLineEdit('32.768e3') # this used to be 3e5 in the Dave Leibrant box version, but was changed to 16e3 due to RedPitaya memory limitations
		self.qedit_ddc_length.setMaximumWidth(60)
		
		# Create widgets to set the higher frequency of the integration:        
		self.qlabel_cumul_integral = Qt.QLabel('Integration\nlimit [Hz]:')
		self.qedit_cumul_integral = Qt.QLineEdit('5e6')
		self.qedit_cumul_integral.setMaximumWidth(60)
		
		# Display mean frequency error:
		self.qlbl_mean_freq_error = Qt.QLabel('Mean freq error = 0 MHz')
		
		# Checkbox to enable faster updates of the phase noise plot:
		self.qchk_phase_noise_fast_updates = Qt.QCheckBox('Faster updates')
		self.qchk_phase_noise_fast_updates.setChecked(False)
		
		# X and Y limits for the plot:
		self.qlbl_xlims = Qt.QLabel('Xmin, Xmax')
		self.qedit_xlims = Qt.QLineEdit('3e3, 5e6')
		self.qedit_xlims.setMaximumWidth(60)
		self.qlbl_ylims = Qt.QLabel('Ymin, Ymax')
		self.qedit_ylims = Qt.QLineEdit('-100, -30')
		self.qedit_ylims.setMaximumWidth(60)
		
		# Averaging controls: # Averages (1=off)
		self.qlbl_spc_averaging = Qt.QLabel('# Averages\n(1=off)')
		self.qedit_spc_averaging = Qt.QLineEdit('1')
		self.qedit_spc_averaging.setMaximumWidth(60)

		# Create the frequency domain plot for the DDC0
		self.qplt_DDC0_spc = pg.PlotWidget()
		self.qplt_DDC0_spc.setTitle('Freq noise PSD')
		#self.qplt_DDC0_spc.setCanvasBackground(Qt.Qt.white)
		#self.qplt_DDC0_spc.setAxisScaleEngine(Qwt.QwtPlot.xBottom, Qwt.QwtLog10ScaleEngine())
		self.qplt_DDC0_spc.getPlotItem().setLogMode(x=True)
		self.qplt_DDC0_spc.setYRange(-60, 60)
		
		#self.qplt_DDC0_spc.enableAxis(Qwt.QwtPlot.yRight)
		self.qplt_DDC0_spc.setLabel('bottom', 'Frequency [Hz]')
		self.qplt_DDC0_spc.setLabel('left', 'PSD [dB Hz^2/Hz]')
		#self.qplt_DDC0_spc.setLabel('right', 'Phase [rad]')

		# create the right-side axis:
		p1 = self.qplt_DDC0_spc.getPlotItem()
		self.qplt_DDC0_spc_right_viewbox = pg.ViewBox()
		#self.qplt_DDC0_spc_right_viewbox.setLogMode(x=True)
		p1.showAxis('right')
		p1.scene().addItem(self.qplt_DDC0_spc_right_viewbox)
		p1.getAxis('right').linkToView(self.qplt_DDC0_spc_right_viewbox)
		self.qplt_DDC0_spc_right_viewbox.setXLink(p1)
		p1.getAxis('right').setLabel('Phase [rad]')

		self.updatePhaseNoiseViews()
		p1.vb.sigResized.connect(self.updatePhaseNoiseViews)

		
		self.qplt_DDC0_spc.showGrid(x=True, y=True)
		#plot_grid = Qwt.QwtPlotGrid()
		#plot_grid.setMajPen(Qt.QPen(Qt.Qt.black, 0, Qt.Qt.DotLine))
		#plot_grid.attach(self.qplt_DDC0_spc)
		
		# Create the curve in the plot
		self.curve_DDC0_spc = self.qplt_DDC0_spc.getPlotItem().plot(title='Phase noise PSD', pen='b')
		#self.curve_DDC0_spc.attach(self.qplt_DDC0_spc)
		#self.curve_DDC0_spc.setPen(Qt.QPen(Qt.Qt.blue))
		
		

		#self.curve_DDC0_cumul_phase = pg.PlotCurveItem(pen='g')
		self.curve_DDC0_cumul_phase = pg.PlotDataItem(pen='k')
		self.curve_DDC0_cumul_phase.setLogMode(True, False)
		self.qplt_DDC0_spc_right_viewbox.addItem(self.curve_DDC0_cumul_phase)

		#self.curve_DDC0_cumul_phase = self.qplt_DDC0_spc_right_viewbox.getPlotItem().plot(pen='k')
		#self.curve_DDC0_cumul_phase.attach(self.qplt_DDC0_spc)
		#self.curve_DDC0_cumul_phase.setPen(Qt.QPen(Qt.Qt.black))
		# self.curve_DDC0_cumul_phase.setYAxis(Qwt.QwtPlot.yRight)
		
		self.curve_DDC0_spc_avg = self.qplt_DDC0_spc.getPlotItem().plot(pen='g')
		#self.curve_DDC0_spc_avg.attach(self.qplt_DDC0_spc)
		#self.curve_DDC0_spc_avg.setPen(Qt.QPen(Qt.Qt.darkGreen))
			


		# Put all the widgets into a grid layout
		grid = Qt.QGridLayout()
#        grid.addWidget(self.qlabel_ddc_plot_select, 0, 0)
		grid.addWidget(self.qcombo_ddc_plot, 0, 0, 1, 2)
		grid.addWidget(self.qlabel_ddc_rbw, 1, 0)
		grid.addWidget(self.qedit_ddc_length, 1, 1)
		grid.addWidget(self.qlabel_cumul_integral, 2, 0)
		grid.addWidget(self.qedit_cumul_integral, 2, 1)

		grid.addWidget(self.qlbl_xlims, 3, 0, 1, 1)
		grid.addWidget(self.qedit_xlims, 3, 1, 1, 1)
		grid.addWidget(self.qlbl_ylims, 4, 0, 1, 1)
		grid.addWidget(self.qedit_ylims, 4, 1, 1, 1)

		grid.addWidget(self.qlbl_spc_averaging, 5, 0, 1, 1)
		grid.addWidget(self.qedit_spc_averaging, 5, 1, 1, 1)
		
		
		
		grid.addWidget(self.qchk_phase_noise_fast_updates, 6, 0, 1, 2)
		grid.addWidget(self.qlbl_mean_freq_error, 7, 0, 1, 2)
		
		grid.addWidget(Qt.QLabel(''), 8, 0)
		
		
		grid.addWidget(self.qplt_DDC0_spc, 0, 2, 9, 1)
		grid.setRowStretch(7, 1)
		grid.setColumnStretch(2, 1)
		
		
		self.qgroupbox_phasenoise.setLayout(grid)
		self.qgroupbox_phasenoise.setPalette(PalNormal)
		self.qgroupbox_phasenoise.setAutoFillBackground(True)        

		######################################################################
		# Layout for the whole form:
		######################################################################
		grid = Qt.QGridLayout()
		grid.setSpacing(10)
		
		grid.addWidget(self.qgroupbox_settings,          0, 0, 1, 0)
		grid.addWidget(self.spectrum,                    1, 0, 1, 0)
		grid.addWidget(self.qgroupbox_phasenoise,        2, 0, 1, 1)
		grid.addWidget(self.qgroupbox_loop_filters,      3, 0, 1, 1)
#        grid.setRowStretch(2, 1)
		
		self.setLayout(grid)
		
		
		# Adjust the size and position of the window
#        self.resize(940, 1080-100+30)
#        self.center()
		#self.setGeometry(18, 40, 950, 1010)
		#self.setGeometry(0, 0, 750, 1000)
		self.setWindowTitle(self.strTitle)  
		#self.show()
		
#    def resizeEvent(self, event):
#        print('resizeEvent')
#        print(self.geometry())

	## Handle view resizing for the phase noise plot (since we need to manual link the left and right side axes)
	def updatePhaseNoiseViews(self):
		## view has resized; update auxiliary views to match
		p1 = self.qplt_DDC0_spc.getPlotItem()

		self.qplt_DDC0_spc_right_viewbox.setGeometry(p1.vb.sceneBoundingRect())
		
		## need to re-update linked axes since this was called
		## incorrectly while views had different shapes.
		## (probably this should be handled in ViewBox.resizeEvent)
		self.qplt_DDC0_spc_right_viewbox.linkedViewChanged(p1.vb, self.qplt_DDC0_spc_right_viewbox.XAxis)


		
	def loadParameters(self):                                             

		# Update the values in the UI to reflect the internal values:

		# Get values from xml file
		for k in range(3):
			if self.output_controls[k] == True:
#                print('XEM_GUI_MainWindow(): About to call loadParameters()')
				if k < 2: # For qloop_filter 0 and 1
					# print('before calling self.qloop_filters[k].loadParameters(self.sp)')
					self.qloop_filters[k].loadParameters(self.sp)                               # Get values from xml file for loop_filters
					# print('after calling self.qloop_filters[k].loadParameters(self.sp)')
					# self.qchk_lock.setChecked(self.qloop_filters[k].qchk_lock.isChecked()) # update the qchk_lock in this widget with the value loaded from sp
					# print('after calling setChecked')

				# Get dac gain from the system parameters object and set it in the UI:
				# print('before calling self.sp.getValue(''VCO_gain'', strDAC)')
				strDAC = 'DAC{:01d}'.format(k)
				str_VCO_gain = (self.sp.getValue('VCO_gain', strDAC))
				# print('before calling self.qedit_vco_gain[k].setText(str_VCO_gain)')
				self.qedit_vco_gain[k].blockSignals(True)
				self.qedit_vco_gain[k].setText(str_VCO_gain)
				self.qedit_vco_gain[k].blockSignals(False)
				# print('after calling self.qedit_vco_gain[k].setText(str_VCO_gain)')
				
				# Output offsets values:
				output_offset_in_volts = float(self.sp.getValue('Output_offset_in_volts', strDAC))

				# Scale this to the correct units for the output offset slider:
				min_output_in_volts = float(self.sp.getValue('Output_limits_low', strDAC))
				max_output_in_volts = float(self.sp.getValue('Output_limits_high', strDAC))
				slider_units = (output_offset_in_volts - min_output_in_volts)/(max_output_in_volts-min_output_in_volts) * 1e6
				# print('calling dac offset slider setValue()')
				# self.q_dac_offset[k].blockSignals(True)
				# self.q_dac_offset[k].setValue(slider_units)
				# self.q_dac_offset[k].blockSignals(False)
				self.spectrum.setDacOffset(k, slider_units)
				# print('done calling dac offset slider setValue()')
				

		# Get ddc reference frequency from the system parameters object and set it in the UI:
		strDDC = 'DDC{:01d}'.format(self.selected_ADC)
		str_ref_freq = (self.sp.getValue('Reference_frequency', strDDC))
		self.qedit_ref_freq.setText(str_ref_freq)
		self.qedit_ref_freq.reset_my_color()
			
		# print('done loadParameters()')
		return
		
	def center(self):
		
		qr = self.frameGeometry()
		cp = QtGui.QDesktopWidget().availableGeometry().center()
		qr.moveCenter(cp)
#        self.move(qr.topLeft())
		self.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(10, 10))
		

		
	def initSL(self):
		# Old function to start the GUI communication
#        self.sl = SuperLaserLand_JD2()
#        self.sl.open()
		print("initSL()")

		self.loadParameters()
		
		bUpdateFPGA = True
		# Send values to FPGA
		if bUpdateFPGA == True:
			self.setVCOFreq_event()
			self.setVCOGain_event()
			self.chkLockClickedEvent()
			if self.output_controls[0] == True:
				self.setPWM0_event()

#        self.setFLL0_event()
#        self.setPLL0_event()
		
		
#        self.timerID = self.startTimer(500 * 1/1)
		self.timerID = 0
		self.qchk_refresh.setChecked(False) # Set this to True to have the auto-refresh active when running the GUI, or to False to wait for the user to check the box
		self.refreshChk_event()    
		
		# Start the timer which reads the dither:
#        self.timerIDDither = Qt
		self.timerIDDither = Qt.QTimer(self)
		self.timerIDDither.timeout.connect(self.timerDitherEvent)
		self.timerIDDither.start(100)   # 100 ms readout delay, increased to 1000 ms for debugging
		# print "Warning! Increased self.timerIDDither.start(100) to 3000 for debugging."
#        self.timerDitherEvent()
	
#        self.grabAndDisplayADC()
#        self.displayDDC()
	
		self.displayDAC()   # This populates the current DAC values with the actual value
#        self.timerEvent(0)  # run the event handler once right away, to populate the rest of the window

		print("initSL() done")
		
	def closeEvent(self, event):
		# from http://stackoverflow.com/questions/1414781/prompt-on-exit-in-pyqt-application
#        quit_msg = "Are you sure you want to exit the program?"
#        reply = QtGui.QMessageBox.question(self, 'Message', 
#                         quit_msg, QtGui.QMessageBox.Yes, QtGui.QMessageBox.No)
#        
#        print(event)
#        
#        if reply == QtGui.QMessageBox.Yes:
#            event.accept()
#            app = Qt.QApplication.instance()
#            app.closeAllWindows()
##            app.
#        else:
#            event.ignore()
		return
		
	@logCommsErrorsAndBreakoutOfFunction()
	def timerDitherEvent(self):
		# print('timerDitherEvent')

		# Check if the sl object exists: otherwise this timer will keep throwing exceptions, filling up the console messages
		# and preventing us form seeing the real cause
		if not hasattr(self, 'sl'):
			print('SL object does not exist anymore. disabling timer in timerDitherEvent')
			self.timerIDDither.stop()
			return

	
		start_time = time.perf_counter()
		for k in range(2): #There is no dither for the 2nd DAC
			if self.output_controls[k]:
				if self.sl.dither_enable[k] == False:
					if k != 2: # DAC2 currently does not have dither
						self.qlabel_detected_vco_gain[k].setText('off')
						self.qlabel_detected_vco_gain[k].setStyleSheet("color: white; background-color: black")
					
				else:
					samples = self.sl.ditherRead(2, k)
					# There is an implicit (-) sign because the DDC has to shift the frequency to 0.
					# This means that the detected gain will be positive when the VCO sign checkbox is correctly tuned
					samples = -samples
					samples = np.mean(samples)
					# np.mean() returns a numpy.float, but the conversions functions expect an ndarray
					samples = np.ndarray((1,), dtype=np.float, buffer=samples)

					# TODO: fancier things with the real and imaginary part, to try to detect invalid readings?  Is this necessary?
					# TODO: Compare many different readings to try to sort out any incorrect ones?
					VCO_detected_gain_in_Hz_per_Volts = self.sl.scaleDitherResultsToHzPerVolts(samples, k)
					self.VCO_detected_gain_in_Hz_per_Volts[k] = VCO_detected_gain_in_Hz_per_Volts
					self.qlabel_detected_vco_gain[k].setText('%.1e' % VCO_detected_gain_in_Hz_per_Volts)
					elapsed_time = time.perf_counter() - start_time
	#                print('Elapsed time (timerDitherEvent) = %f ms' % (1000*elapsed_time))
					
					# If the detected gain is negative, the loop will be unstable when closed, so we switch to a red background so that the user can flip the sign
					if VCO_detected_gain_in_Hz_per_Volts > 0:
#                        self.qedit_fi.setStyleSheet("background-color: %s" % Qt.QColor(Qt.Qt.white).name())
						self.qlabel_detected_vco_gain[k].setStyleSheet("color: white; background-color: green")
					else:
						# red background
#                        self.qlabel_detected_vco_gain[k].setStyleSheet("color: white; background-color: %s" % Qt.QColor(Qt.Qt.red).name())
						self.qlabel_detected_vco_gain[k].setStyleSheet("color: white; background-color: red")
		
	@logCommsErrorsAndBreakoutOfFunction()
	def timerEvent(self, e):
		# print 'timerEvent : %.3f sec' % (time.perf_counter())

		# Check if the sl object exists: otherwise this timer will keep throwing exceptions, filling up the console messages
		# and preventing us form seeing the real cause.  We let only one exception go through and then disable 
		try:
			# Read out residuals and dump to disk:
			if self.selected_ADC == 0:
				pass
					
			# Handle the LEDs display
			ret = self.sl.readLEDs()
			if ret is not None:
				(LED_G0, LED_R0, LED_G1, LED_R1, LED_G2, LED_R2) = ret
				# print ('%d, %d, %d, %d, %d, %d' % (LED_G0, LED_R0, LED_G1, LED_R1, LED_G2, LED_R2))


			# if self.selected_ADC == 0:
			# 	# if self.qchk_crash_monitor.isChecked():
			# 	# 	self.checkCrash()
				
			# 	# LEDs for CEO lock:
			# 	if LED_G0 and (not LED_R0):
			# 		# status is locked
			# 		self.qlbl_status1.setText('Status: Locked')
			# 		self.qlbl_status1.setStyleSheet('color: white; background-color: green')
			# 	elif LED_G0 and LED_R0:
			# 		# Status is railed
			# 		self.qlbl_status1.setText('Status: Railed')
			# 		self.qlbl_status1.setStyleSheet('color: white; background-color: orange')
			# 	elif (not LED_G0) and LED_R0:
			# 		# Residuals above threshold
			# 		self.qlbl_status1.setText('Status: Residuals > threshold')
			# 		self.qlbl_status1.setStyleSheet('color: white; background-color: red')
			# 	elif (not LED_G0) and (not LED_R0):
			# 		# Idle
			# 		self.qlbl_status1.setText('Status: Idle')
			# 		self.qlbl_status1.setStyleSheet('')
				
			# elif self.selected_ADC == 1:
			# 	# LEDs for Optical lock
			# 	if LED_G1 and (not LED_R1):
			# 		# status is locked
			# 		self.qlbl_status1.setText('Status: Locked')
			# 		self.qlbl_status1.setStyleSheet('color: white; background-color: green')
			# 	elif LED_G1 and LED_R1:
			# 		# Status is railed
			# 		self.qlbl_status1.setText('Status: Railed')
			# 		self.qlbl_status1.setStyleSheet('color: white; background-color: orange')
			# 	elif (not LED_G1) and LED_R1:
			# 		# Residuals above threshold
			# 		self.qlbl_status1.setText('Status: Residuals above threshold')
			# 		self.qlbl_status1.setStyleSheet('color: white; background-color: red')
			# 	elif (not LED_G1) and (not LED_R1):
			# 		# Idle
			# 		self.qlbl_status1.setText('Status: Idle')
			# 		self.qlbl_status1.setStyleSheet('')
					
			# 	# LEDs for slow PZT output:
			# 	if LED_G2 and (not LED_R2):
			# 		# status is locked
			# 		self.qlbl_status2.setText('Status: Locked')
			# 		self.qlbl_status2.setStyleSheet('color: white; background-color: green')
			# 	elif LED_G2 and LED_R2:
			# 		# Status is railed
			# 		self.qlbl_status2.setText('Status: Railed')
			# 		self.qlbl_status2.setStyleSheet('color: white; background-color: orange')
			# 	elif (not LED_G2) and LED_R2:
			# 		# Residuals above threshold
			# 		self.qlbl_status2.setText('Status: Residuals above threshold')
			# 		self.qlbl_status2.setStyleSheet('color: white; background-color: red')
			# 	elif (not LED_G2) and (not LED_R2):
			# 		# Idle
			# 		self.qlbl_status2.setText('Status: Idle')
			# 		self.qlbl_status2.setStyleSheet('')
		
			if self.qchk_refresh.isChecked():
				self.grabAndDisplayADC()
				self.displayDAC()
				
				if self.display_phase == 0 or self.qchk_phase_noise_fast_updates.isChecked():
					self.displayDDC()
			
			self.display_phase = self.display_phase + 1
			if self.display_phase > 5:
				self.display_phase = 0
			
		except:
			print('SL object does not exist anymore. disabling timer in timerEvent')
			self.killTimer(self.timerID)
			self.timerID = 0
			self.qchk_refresh.setChecked(False)
			raise
		
		self.qlabel_refreshrate.setText('%.0f ms' % (1000*(time.perf_counter() - self.last_refresh)))
		self.last_refresh = time.perf_counter()

	# timerEvent()
	def displayDAC(self):
		
		# Check if another function is currently using the DDR2 logger:
		if self.sl.bDDR2InUse:
			print('displayDAC(): DDR2 logger in use, cannot get data from dac')
			return  
		
		# For now: we grab the smallest chunk of points from the output (so as to not use too much time to refresh)
		# and display the current average:
		for k in range(3):
			if self.output_controls[k]:
				# Read from DAC #k
				start_time = time.perf_counter()
			
				(samples_out, ref_exp0) = self.getADCdata(input_select="DAC%d" % k, N_samples=256)
				if samples_out is None:
					return
				elapsed_time = time.perf_counter() - start_time
				if self.bDisplayTiming == True:
					print('Elapsed time (read dac values) = %f ms' % (1000*elapsed_time))
				samples_out = samples_out.astype(dtype=np.float)

				VCO_gain_in_Hz_per_Volts = self.getVCOGainFromUI(k)
					
				# Update the display:           
				# For the USB bug, compute the mean from the last points     
				current_output_in_volts = self.sl.convertDACCountsToVolts(k, np.mean(samples_out[128:256]))
				current_output_in_hz = current_output_in_volts * VCO_gain_in_Hz_per_Volts
				self.spectrum.qthermo_dac_current[k].setValue(current_output_in_volts)
				self.spectrum.qlabel_dac_current_value[k].setText('{:.4f} V\n{:.0f} MHz'.format(current_output_in_volts, current_output_in_hz/1e6))
				
				elapsed_time = time.perf_counter() - start_time
				if self.bDisplayTiming == True:
					print('Elapsed time (displayDAC total) = %f ms' % (1000*elapsed_time))
			

	def displayDDC(self):
		# self.bDisplayTiming = True
		
		# Read from DDC0
		try:
			try:
				N_points = int(float(self.qedit_ddc_length.text()))
			except:
				N_points = 100e3
			if N_points < 64:
				N_points = 64
				
			start_time = time.perf_counter()


			# if self.selected_ADC == 0:
			# 	self.sl.setup_DDC0_write(N_points)
			# elif self.selected_ADC == 1:
			# 	self.sl.setup_DDC1_write(N_points)
			# self.sl.trigger_write()
			# self.sl.wait_for_write()
			# if self.bDisplayTiming == True:
			# 	print('Elapsed time (setup write) = %f' % (time.perf_counter()-start_time))
			# start_time = time.perf_counter()
			# inst_freq = self.sl.read_ddc_samples_from_DDR2()

			inst_freq = self.getADCdata(input_select='DDC%d' % self.selected_ADC, N_samples=N_points, bReadAsDDC=True)
			if inst_freq is None:
				return

			self.inst_freq = inst_freq
			
			if self.bDisplayTiming == True:
				print('Elapsed time (communication) = %f' % (time.perf_counter()-start_time))

			
#            print('mean freq error = %f MHz, raw code = %f' % (np.mean(inst_freq)/1e6, np.mean(inst_freq)*2**10 / self.sl.fs*4))
			self.qlbl_mean_freq_error.setText('Freq error: %.2f MHz' % (np.mean(inst_freq)/1e6))
			
			# Compute the spectrum:
			# We first perform decimation on the data since we don't have useful information above the cut-off frequency anyway:
			start_time = time.perf_counter()
			N_decimation = 10
			fs_new = self.sl.fs/N_decimation
			#inst_freq_decimated = decimate(inst_freq, N_decimation, zero_phase=False)
			inst_freq_decimated = decimate(detrend(inst_freq), N_decimation, zero_phase=False)
			
#            inst_freq_decimated = inst_freq
#            fs_new = self.sl.fs
			
			# For debugging: we want to check
#            inst_freq_decimated = np.random.randn(100e3)
#            print('Data std dev = %f Hz' % np.std(inst_freq_decimated))
#            print('Data variance = %f Hz^2' % np.var(inst_freq_decimated))
			if self.bDisplayTiming == True:
				print('Elapsed time (decimation) = %f' % (time.perf_counter()-start_time))
			start_time = time.perf_counter()
			
			# Compute the spectrum of the decimated signal:
			start_time = time.perf_counter()
			N_fft = 2**(int(np.ceil(np.log2(len(inst_freq_decimated)))))
			frequency_axis = np.linspace(0, (N_fft-1)/float(N_fft)*fs_new, N_fft)
			last_index_shown = int(np.round(len(frequency_axis)/2))
			window_function = np.blackman(len(inst_freq_decimated))
			window_NEB = np.sum((window_function/np.sum(window_function))**2) * fs_new;
#            print('window_NEB = %f Hz' % window_NEB)
			
			spc = np.fft.fft(inst_freq_decimated * window_function, N_fft)
			spc = np.real(spc*np.conj(spc))/(sum(window_function)**2) # Spectrum is now scaled in power (Hz^2 per bin)
			# Scale the spectrum to be a single-sided power spectral density in Hz^2/Hz:
			spc[1:last_index_shown] = 2*spc[1:last_index_shown] / window_NEB

#            # Compute the running average:
			# Compute spectrum averaging with exponential smoothing (simple first-order IIR filter)
			try:
				n_spc_avg = int(round(float(self.qedit_spc_averaging.text())))
				if n_spc_avg > 1.:
					self.bAveragePhaseNoise = True
					self.N_spc_average = n_spc_avg
				else:
					self.bAveragePhaseNoise = False
					self.N_spc_average = 1.
			except:
				n_spc_avg = 1.
				self.bAveragePhaseNoise = False
				
			if self.bAveragePhaseNoise:
#                print('self.N_spc_average = %d' % self.N_spc_average)
				filter_alpha = np.exp(-1./self.N_spc_average)
				try:
					# if this is not the first time we are called with averaging enabled, we run the filter:
					if self.bAveragePhaseNoiseLast:
						self.spc_running_sum = filter_alpha * self.spc_running_sum +  + (1-filter_alpha)*spc
					else:
						# this is the first time that we are called with averaging enabled, so we reset the current state
						self.spc_running_sum = spc
				except:
					# This is the first time that we are called:
					self.spc_running_sum = spc

				
			self.bAveragePhaseNoiseLast = self.bAveragePhaseNoise
			
#            print('Freq noise PSD: %e Hz^2/Hz' % (np.mean(spc[1:last_index_shown])))
			self.freq_noise_psd = spc[1:last_index_shown]
			self.freq_noise_axis = frequency_axis[1:last_index_shown]
			
#            spc = np.abs(spc)
			
			if self.bDisplayTiming == True:
				print('Elapsed time (FFT) = %f' % (time.perf_counter()-start_time))
				
				
			try:
				f_limits = self.qedit_xlims.text()
				f_limits = f_limits.split(',')
				f_limits = (float(f_limits[0]), float(f_limits[1]))
			except:
				f_limits = (frequency_axis[1], frequency_axis[last_index_shown])
				
			try:
				y_limits = self.qedit_ylims.text()
				y_limits = y_limits.split(',')
				y_limits = (float(y_limits[0]), float(y_limits[1]))
			except:
				y_limits = (-140, 60)
			
			# Update the graph
			if self.qcombo_ddc_plot.currentIndex() == 0:
				# Display the frequency noise
				spc = 10*np.log10(spc + 1e-20)
				self.curve_DDC0_spc.setData(frequency_axis[1:last_index_shown], spc[1:last_index_shown])
				if self.bAveragePhaseNoise:
					self.curve_DDC0_spc_avg.setData(frequency_axis[1:last_index_shown], 10*np.log10(self.spc_running_sum[1:last_index_shown] + 1e-20))
					self.curve_DDC0_spc_avg.setVisible(True)
				else:
					self.curve_DDC0_spc_avg.setVisible(False)
				self.qplt_DDC0_spc.setTitle('Freq noise PSD')
				self.qplt_DDC0_spc.setLabel('left', 'PSD [dB Hz^2/Hz]')
				self.qplt_DDC0_spc.setYRange(y_limits[0], y_limits[1])
#                self.qplt_DDC0_spc.setAxisScale(Qwt.QwtPlot.xBottom, frequency_axis[1], frequency_axis[last_index_shown])
				self.qplt_DDC0_spc.getPlotItem().setLogMode(x=True)
				self.qplt_DDC0_spc.setXRange(np.log10(f_limits[0]), np.log10(f_limits[1]))
				# self.qplt_DDC0_spc.setAxisScaleEngine(Qwt.QwtPlot.xBottom, Qwt.QwtLog10ScaleEngine())
				self.qplt_DDC0_spc.setLabel('bottom', 'Frequency [Hz]')
				self.curve_DDC0_cumul_phase.setVisible(False)
			elif self.qcombo_ddc_plot.currentIndex() == 1:
				# Compute the phase noise time-domain standard deviation:
				phasenoise_stddev = np.std(np.cumsum(inst_freq*2*np.pi/self.sl.fs))
				# Display the phase noise (equal to 1/f^2 times the frequency noise PSD)
				self.curve_DDC0_spc.setData(frequency_axis[1:last_index_shown], 10*np.log10(spc[1:last_index_shown] + 1e-20) - 20*np.log10(frequency_axis[1:last_index_shown]))
				if self.bAveragePhaseNoise:
					self.curve_DDC0_spc_avg.setData(frequency_axis[1:last_index_shown], 10*np.log10(self.spc_running_sum[1:last_index_shown] + 1e-20) - 20*np.log10(frequency_axis[1:last_index_shown]))
					self.curve_DDC0_spc_avg.setVisible(True)
				else:
					self.curve_DDC0_spc_avg.setVisible(False)
				self.qplt_DDC0_spc.setXRange(f_limits[0], f_limits[1])
				self.qplt_DDC0_spc.setTitle('Phase noise PSD, std dev = %.2f radrms' % phasenoise_stddev)
				self.qplt_DDC0_spc.setLabel('left', 'PSD [dBc/Hz]')
				self.qplt_DDC0_spc.setYRange(y_limits[0], y_limits[1])
				#self.qplt_DDC0_spc.setAxisScaleEngine(Qwt.QwtPlot.xBottom, Qwt.QwtLog10ScaleEngine())
				self.qplt_DDC0_spc.getPlotItem().setLogMode(x=True)
				
				self.qplt_DDC0_spc.setXRange(np.log10(f_limits[0]), np.log10(f_limits[1]*5./6.0))   # the scaling is because the widget doesn't seem to use the exact values that we pass...
				self.qplt_DDC0_spc.setLabel('bottom', 'Frequency [Hz]')

				# Display the cumulative integral of the phase noise:
				# Select desired frequency range:
				try:
					integration_higher_bound = float(self.qedit_cumul_integral.text())
				except:
					integration_higher_bound = 1e6
				if integration_higher_bound > fs_new/2:
					integration_higher_bound = fs_new/2
				if integration_higher_bound <= 2/len(spc)*fs_new:
					integration_higher_bound = 2/len(spc)*fs_new
				integration_higher_index = int(round(integration_higher_bound/fs_new*len(spc)))
#                print('integration up to %d out of %d' % (integration_higher_index, len(spc)))
				frequency_axis_integral = frequency_axis[1:integration_higher_index]
				
				# Integrate the phase noise PSD, from the highest frequency to the lowest
				phase_psd = spc[1:integration_higher_index] / frequency_axis_integral**2
				cumul_int = np.flipud(np.cumsum(np.flipud(phase_psd))) * np.mean(np.diff(frequency_axis_integral))
#                print((cumul_int).shape)
#                cumul_int = 0*cumul_int + 10
#                print((cumul_int).shape)
				
				# Show results
				self.curve_DDC0_cumul_phase.setData(frequency_axis_integral, np.sqrt(cumul_int))
				self.curve_DDC0_cumul_phase.setVisible(True)
				#self.qplt_DDC0_spc_right_viewbox.setYRange(0, 2*2*np.pi)
				#self.qplt_DDC0_spc_right_viewbox.setXRange(0, 2*2*np.pi)
#                self.qplt_DDC0_spc.setAxisScale(Qwt.QwtPlot.xBottom, frequency_axis[1], frequency_axis[last_index_shown])

#                self.qplt_DDC0_spc.setAxisScale(Qwt.QwtPlot.yRight, 0, 2*2*np.pi)
				
			 
			elif self.qcombo_ddc_plot.currentIndex() == 2:
				# Display the raw, time-domain instantaneous frequency output by the DDC block, mostly for debugging:
				
				time_axis = np.arange(0, len(inst_freq))/self.sl.fs
				
				self.curve_DDC0_spc.setData(time_axis, inst_freq)
				self.curve_DDC0_spc_avg.setVisible(False)
				self.curve_DDC0_cumul_phase.setVisible(False)
				self.qplt_DDC0_spc.setTitle('Instantaneous frequency error, std dev = %.1f kHz' % (np.std(inst_freq_decimated)/1e3))
				self.qplt_DDC0_spc.setLabel('left', 'Freq [Hz]')
				self.qplt_DDC0_spc.setLabel('bottom', 'Time [s]')
#                self.qplt_DDC0_spc.setAxisScale(Qwt.QwtPlot.yLeft, -self.sl.fs/2, self.sl.fs/2)
				self.qplt_DDC0_spc.setYRange(np.min(inst_freq), np.max(inst_freq))
				#self.qplt_DDC0_spc.setAxisScaleEngine(Qwt.QwtPlot.xBottom, Qwt.QwtLinearScaleEngine())
				self.qplt_DDC0_spc.getPlotItem().setLogMode(x=False)
				self.qplt_DDC0_spc.setXRange(time_axis[0], time_axis[-1])
				 
			elif self.qcombo_ddc_plot.currentIndex() == 3:
				# Display the time-domain instantaneous phase output by the DDC block (computed by integrating the frequency), mostly for debugging:
				
				time_axis = np.arange(0, len(inst_freq))/self.sl.fs
				inst_phase = np.cumsum(inst_freq*2*np.pi/self.sl.fs)
				
				
				
				# Compute the phase noise time-domain standard deviation:
				phasenoise_stddev = np.std(inst_phase)
				
				self.curve_DDC0_spc.setData(time_axis, inst_phase)
				self.curve_DDC0_spc_avg.setVisible(False)
				self.curve_DDC0_cumul_phase.setVisible(False)
				self.qplt_DDC0_spc.setTitle('Instantaneous phase error, std dev = %.2f radrms' % phasenoise_stddev)
				self.qplt_DDC0_spc.setLabel('left', 'Phase [rad]')
				self.qplt_DDC0_spc.setLabel('bottom', 'Time [s]')
#                self.qplt_DDC0_spc.setAxisScale(Qwt.QwtPlot.yLeft, -self.sl.fs/2, self.sl.fs/2)
				self.qplt_DDC0_spc.setYRange(np.min(inst_phase), np.max(inst_phase))
				#self.qplt_DDC0_spc.setAxisScaleEngine(Qwt.QwtPlot.xBottom, Qwt.QwtLinearScaleEngine())
				self.qplt_DDC0_spc.getPlotItem().setLogMode(x=False)
				self.qplt_DDC0_spc.setXRange(time_axis[0], time_axis[-1])
#                self.qplt_DDC0_spc.setAxisScale(Qwt.QwtPlot.yLeft, -3.14, 3.14)
#                print "debug warning: phase noise plot scaled to +/- pi"
			 
#            # Display the un-decimated spectrum:
#            frequency_axis = np.linspace(0, (len(inst_freq)-1)/float(len(inst_freq))*(self.sl.fs), len(inst_freq))
#            last_index_shown = np.round(len(frequency_axis)/2)
#            window_function = np.blackman(len(inst_freq))
#            spc = np.abs(np.fft.fft((inst_freq-np.mean(inst_freq)) * window_function))/(sum(window_function)/2)
#            spc = 20*np.log10(np.abs(spc) + 1e-7)
#            self.curve_DDC0_spc.setData(frequency_axis[1:last_index_shown], spc[1:last_index_shown])

			# Refresh the display:
			
			self.qplt_DDC0_spc.replot()
			

			if window_NEB > 1e6:
				self.qlabel_ddc_rbw.setText('RBW: %.1f MHz; Points:' % (round(window_NEB*1e5)/1e5/1e6))
			elif window_NEB > 1e3:
				self.qlabel_ddc_rbw.setText('RBW: %.1f kHz; Points:' % (round(window_NEB*1e2)/1e2/1e3))
			else:
				self.qlabel_ddc_rbw.setText('RBW: %.0f Hz; Points:' % (round(window_NEB)))
		
			
			
		except:

			del self.sl
			print('Unhandled exception')
			raise
#        pause(1/10.)

		self.bDisplayTiming = False


	def grabAndDisplayADC(self):
		(input_select, plot_type, N_samples) = self.spectrum.getGUIsettingsForADCdata()
		# print("input_select = %s" % input_select)
		# Grab data from the FPGA:
		start_time = time.perf_counter()
		(samples_out, ref_exp0) = self.getADCdata(input_select, N_samples)
		if (samples_out is None) or (ref_exp0 is None):
			return
		self.raw_adc_samples = samples_out.astype(dtype=np.float)

		self.spectrum.plotADCdata(input_select, plot_type, samples_out, ref_exp0)

		# Update the scale which indicates the ADC fill ratio in numbers of bits:
		self.spectrum.updateScaleDisplays(samples_out)


	def getADCdata(self, input_select, N_samples, bReadAsDDC=False):
		if bReadAsDDC:
			empty_return_value = None
		else:
			empty_return_value = (None, None)
		start_time = time.perf_counter()
		
		# Check if another function is currently using the DDR2 logger:
		if self.sl.bDDR2InUse:
			print('grabAndDisplayADC(): DDR2 logger in use, cannot get data from adc')
			return empty_return_value
		# Block access to the DDR2 Logger to any other function until we are done:
		self.sl.bDDR2InUse = True

		time_start = time.perf_counter()
		try:
			# Read from selected source
			self.sl.setup_write(self.sl.LOGGER_MUX[input_select], N_samples)
			self.sl.trigger_write()
			self.sl.wait_for_write()
			if bReadAsDDC == False:
				# read from ADC:
				(samples_out, ref_exp0) = self.sl.read_adc_samples_from_DDR2()
			else:
				# read from DDC:
				samples_out = self.sl.read_ddc_samples_from_DDR2()
				return samples_out

			max_abs = np.max(np.abs(samples_out))

			samples_out = samples_out.astype(dtype=np.float)
			self.raw_adc_samples = samples_out
				

		except RP_PLL.CommsLoggeableError as e:
			# log exception
			logging.error("Exception occurred", exc_info=True)
			return empty_return_value

		except RP_PLL.CommsError as e:
			# do not log exception (because it's simply an obvious follow-up to a previous one, and we don't want to fill up the log with repeated information)
			return empty_return_value

		finally:
			# Tear-down, whether or not an exception occured: Signal to other functions that they can use the DDR2 logger
			self.sl.bDDR2InUse = False
		
		if self.bDisplayTiming == True:
			print('Elapsed time (Comm) = %f' % (time.perf_counter()-start_time))

		# A little bit of data validation:
		if input_select in ['ADC0', 'ADC1']:
			if np.real(ref_exp0) == 0 and np.imag(ref_exp0) == 0:
				print('getADCdata(): Invalid complex exponential. Probably because of a version mismatch between the RP firmware and Python GUI.')
				return empty_return_value
		else:
			ref_exp0 = 1.0
		return (samples_out, ref_exp0)




	# From: http://stackoverflow.com/questions/273192/create-directory-if-it-doesnt-exist-for-file-write
	def make_sure_path_exists(self, path):
		try:
			os.makedirs(path)
		except OSError as exception:
			if exception.errno != errno.EEXIST:
				raise
