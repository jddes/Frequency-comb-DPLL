"""
XEM6010 Phase-lock box GUI, Settings controls for the programmable clock divider and the residuals streaming
by JD Deschenes, October 2013

"""
from __future__ import print_function

import time
from PyQt5 import QtGui, Qt
import numpy as np

import weakref
#from SuperLaserLand_JD2 import SuperLaserLand_JD2
#from DisplayTransferFunctionWindow import DisplayTransferFunctionWindow


class DisplayDividerAndResidualsStreamingSettingsWindow(QtGui.QWidget):
		
	def __init__(self, sl, sp, clk_divider_modulus=67e3, bDividerOn=0, bPulses=0, custom_style_sheet='', custom_shorthand='', bUpdateFPGA = True, bConnectedRP = True):
		super(DisplayDividerAndResidualsStreamingSettingsWindow, self).__init__()
		
		self.clk_divider_modulus = clk_divider_modulus
		self.bDividerOn = bDividerOn
		self.bPulses = bPulses
		
		self.sp = sp
		self.sl = weakref.proxy(sl)
		self.setObjectName('MainWindow')
		self.setStyleSheet(custom_style_sheet)
		self.custom_shorthand = custom_shorthand
		
#        sl.set_clk_divider_settings(bOn=1, bPulses=0, modulus=67e3+1-1)
		
		self.initUI()
		

		
		# This will make the window update the FPGA register
		
		# if bUpdateFPGA == True:
		# 	self.updateClicked()
		# 	self.residualsClicked()

		#bUpdateFPGA = False        # To force connection to an already configure Red Pitaya (for debugging)
		if bConnectedRP:
			if bUpdateFPGA == True:
				self.pushValues()
			else:
				self.getValues()

	def pushValues(self):
		self.ddcClicked()

	def pushDefaultValues(self):
		self.loadParameters()
		self.pushValues()


	def loadParameters(self):
	
		filter_select_1	= int((self.sp.getValue('Filter_select', "DAC1")))

		if filter_select_1 == 0:
			self.qchk_Wideband1.setChecked(True)
		elif filter_select_1 == 1:
			self.qchk_Narrowband1.setChecked(True)
		elif filter_select_1 == 2:
			self.qchk_WidebandFIR1.setChecked(True)

		filter_select_0	= int((self.sp.getValue('Filter_select', "DAC0")))

		if filter_select_0 == 0:
			self.qchk_Wideband0.setChecked(True)
		elif filter_select_0 == 1:
			self.qchk_Narrowband0.setChecked(True)
		elif filter_select_0 == 2:
			self.qchk_WidebandFIR0.setChecked(True)

		
		angle_select_1 	= int((self.sp.getValue('Angle_select', "DAC1")))

		if angle_select_1 == 0:
			self.qchk_cordic1.setChecked(True)
		elif angle_select_1 == 1:
			self.qchk_quadrature_msb1.setChecked(True)
		elif angle_select_1 == 2:
			self.qchk_quadrature_lsb1.setChecked(True)
		elif angle_select_1 == 3:
			self.qchk_inphase_msb1.setChecked(True)
		elif angle_select_1 == 4:
			self.qchk_inphase_lsb1.setChecked(True)

		angle_select_0 	= int((self.sp.getValue('Angle_select', "DAC0")))

		if angle_select_0 == 0:
			self.qchk_cordic0.setChecked(True)
		elif angle_select_0 == 1:
			self.qchk_quadrature_msb0.setChecked(True)
		elif angle_select_0 == 2:
			self.qchk_quadrature_lsb0.setChecked(True)
		elif angle_select_0 == 3:
			self.qchk_inphase_msb0.setChecked(True)
		elif angle_select_0 == 4:
			self.qchk_inphase_lsb0.setChecked(True)

	def getValues(self):
		#Get filter_select(0, 1 or 2) for both adc
		(filter_select_1, filter_select_0) = self.sl.get_ddc_filter_select()
		#Check correspoding radio button
		if filter_select_1 == 0:
			self.qchk_Wideband1.setChecked(True)
		elif filter_select_1 == 1:
			self.qchk_Narrowband1.setChecked(True)
		elif filter_select_1 == 2:
			self.qchk_WidebandFIR1.setChecked(True)

		if filter_select_0 == 0:
			self.qchk_Wideband0.setChecked(True)
		elif filter_select_0 == 1:
			self.qchk_Narrowband0.setChecked(True)
		elif filter_select_0 == 2:
			self.qchk_WidebandFIR0.setChecked(True)

		#Get angle_select (0, 1, 2, 3 or 4) for both adc
		(angle_select_1, angle_select_0) = self.sl.get_ddc_angle_select()
		#Check correspoding radio button
		if angle_select_1 == 0:
			self.qchk_cordic1.setChecked(True)
		elif angle_select_1 == 1:
			self.qchk_quadrature_msb1.setChecked(True)
		elif angle_select_1 == 2:
			self.qchk_quadrature_lsb1.setChecked(True)
		elif angle_select_1 == 3:
			self.qchk_inphase_msb1.setChecked(True)
		elif angle_select_1 == 4:
			self.qchk_inphase_lsb1.setChecked(True)


		if angle_select_0 == 0:
			self.qchk_cordic0.setChecked(True)
		elif angle_select_0 == 1:
			self.qchk_quadrature_msb0.setChecked(True)
		elif angle_select_0 == 2:
			self.qchk_quadrature_lsb0.setChecked(True)
		elif angle_select_0 == 3:
			self.qchk_inphase_msb0.setChecked(True)
		elif angle_select_0 == 4:
			self.qchk_inphase_lsb0.setChecked(True)

	def updateClicked(self):
		# Read user-entered settings:
		(clk_divider_modulus, bDividerOn, bPulses) = self.readSettings()
		if bPulses:
			output_freq = 2*self.sl.fs/(clk_divider_modulus)
		else:
			# square wave mode:
			output_freq = 2*self.sl.fs/(2*(clk_divider_modulus))
			
		# Update display:
		self.qlbl_actual_frequency.setText('%f' % output_freq)
		
		self.sl.set_clk_divider_settings(bDividerOn, bPulses, clk_divider_modulus-1)
		
		
	def readSettings(self):

#        self.clk_divider_modulus = clk_divider_modulus
#        self.bDividerOn = bDividerOn
#        self.bPulses = bPulses
		
		try:
			self.clk_divider_modulus = int(float(self.qedit_modulus.text()))
		except:
			self.clk_divider_modulus = 67e3
			pass
		
		try:
			self.bDividerOn = int(self.qbtn_divider_on.isChecked())
		except:
			self.bDividerOn = 0
			pass
		
		try:
			self.bPulses = int(self.qradio_pulses.isChecked())
		except:
			self.bPulses = 0
			pass

		return (self.clk_divider_modulus, self.bDividerOn, self.bPulses)
		
		
	def readStreamingSettings(self):
		
		try:
			data_delay = int(float(self.qedit_data_delay.text()))
		except:
			data_delay = 1
			pass
		
		try:
			trigger_delay = int(float(self.qedit_trigger_delay.text()))
		except:
			trigger_delay = 1
			pass
		
		try:
			boxcar_size = int(float(self.qedit_boxcar_size.text()))
		except:
			boxcar_size = 2
			pass
		
		return (data_delay, trigger_delay, boxcar_size)

	def residualsClicked(self):
		(data_delay, trigger_delay, boxcar_filter_size) = self.readStreamingSettings()
		rst_residuals_streaming = 0
		self.sl.setResidualsStreamingSettings(data_delay, trigger_delay, boxcar_filter_size, rst_residuals_streaming)
		
		adc_number = 0
		phase_or_freq = int(self.qchk_Modulo0.isChecked())
		self.sl.set_residuals_phase_or_freq(adc_number, phase_or_freq)
		
		adc_number = 1
		phase_or_freq = int(self.qchk_Modulo1.isChecked())
		self.sl.set_residuals_phase_or_freq(adc_number, phase_or_freq)
		

	def ddcClicked(self):
		(data_delay, trigger_delay, boxcar_filter_size) = self.readStreamingSettings()  # Default (1,1,2)
		rst_residuals_streaming = 0
		self.sl.setResidualsStreamingSettings(data_delay, trigger_delay, boxcar_filter_size, rst_residuals_streaming)   # Default (1,1,2,0)
		
		adc_number = 0
		if self.qchk_Wideband0.isChecked():
			filter_select = 0
		elif self.qchk_Narrowband0.isChecked():
			filter_select = 1
		elif self.qchk_WidebandFIR0.isChecked():
			filter_select = 2

		if self.qchk_cordic0.isChecked():
			angle_select = 0
		elif self.qchk_quadrature_msb0.isChecked():
			angle_select = 1
		elif self.qchk_quadrature_lsb0.isChecked():
			angle_select = 2
		elif self.qchk_inphase_msb0.isChecked():
			angle_select = 3
		elif self.qchk_inphase_lsb0.isChecked():
			angle_select = 4
		self.sl.set_ddc_filter(adc_number, filter_select, angle_select)
		
		
		adc_number = 1
		if self.qchk_Wideband1.isChecked():
			filter_select = 0
		elif self.qchk_Narrowband1.isChecked():
			filter_select = 1
		elif self.qchk_WidebandFIR1.isChecked():
			filter_select = 2
		
		if self.qchk_cordic1.isChecked():
			angle_select = 0
		elif self.qchk_quadrature_msb1.isChecked():
			angle_select = 1
		elif self.qchk_quadrature_lsb1.isChecked():
			angle_select = 2
		elif self.qchk_inphase_msb1.isChecked():
			angle_select = 3
		elif self.qchk_inphase_lsb1.isChecked():
			angle_select = 4
		self.sl.set_ddc_filter(adc_number, filter_select, angle_select)
		 
		
	def phaseIncrement(self):
		try:
			phase_increment = float(self.qedit_phaseinc.text())
			phase_increment = int(round(2*self.sl.fs * phase_increment))    # converts from time units to samples
			
			# We need to know the counter modulus so we can convert negative offsets into positive offsets through a modulo operation
			(clk_divider_modulus, bDividerOn, bPulses) = self.readSettings()
			if bPulses:
				clk_divider_actual_modulus = clk_divider_modulus
				# This case is easier:
				phase_increment = phase_increment % clk_divider_actual_modulus
				print('phase increment')
				print(phase_increment)
				self.sl.adjust_clk_divider_phase(phase_increment)
			else:
				# square wave mode:
				# This case is a little bit weird because the counter actually counts half-cycles, so we have to offset the time by steps:
				clk_divider_actual_modulus = clk_divider_modulus
				phase_increment = phase_increment % clk_divider_actual_modulus
				print('phase increment')
				print(phase_increment)
				
				if float(self.qedit_phaseinc.text()) < 0:
					# This puts the correct offset, but also flips the phase
					self.sl.adjust_clk_divider_phase(phase_increment)
					time.sleep(50e-3 + 10*clk_divider_actual_modulus/(2*self.sl.fs))
					# These two extra steps are to adjust the phase:
					first_step = int(round(clk_divider_modulus/2))
					second_step = int(clk_divider_modulus-first_step)
					self.sl.adjust_clk_divider_phase(first_step)
					time.sleep(50e-3 + 10*clk_divider_actual_modulus/(2*self.sl.fs))
					self.sl.adjust_clk_divider_phase(second_step)
				else:
					# This case is easier:
					self.sl.adjust_clk_divider_phase(phase_increment)
				
				
				
			
			phase_increment = phase_increment % clk_divider_actual_modulus
		except:
			phase_increment = 0
			

		
	def initUI(self):


		######################################################################
		# Create the widgets which control the clk divider module:
		# Needs: clk_divider_modulus, bDividerOn, bPulses or Square Wave
		######################################################################
		self.qgroupbox_divider = Qt.QGroupBox('Clk divider settings (Triggers the PRBS generator on DOUT2), enter to accept changes')
		self.qgroupbox_divider.setAutoFillBackground(True)
		
		if self.bPulses:
			output_freq = 2*self.sl.fs/(self.clk_divider_modulus)
		else:
			# square wave mode:
			output_freq = 2*self.sl.fs/(2*(self.clk_divider_modulus))
			
		
		self.qlbl_modulus = Qt.QLabel('Modulus [2, 2^32-1], [samples at 200 MHz]:')
		self.qedit_modulus = Qt.QLineEdit(str(int(self.clk_divider_modulus+1)))
		self.qedit_modulus.editingFinished.connect(self.updateClicked)
		
		self.qlbl_phaseinc = Qt.QLabel('Time increment [-Period, Period], [seconds]:')
		self.qedit_phaseinc = Qt.QLineEdit('0')
#        self.qedit_phaseinc.editingFinished.connect(self.phaseIncrement)
		self.qbtn_phaseinc = Qt.QPushButton('Apply')
		self.qbtn_phaseinc.clicked.connect(self.phaseIncrement)
		
		# Modulation frequency:
		self.qlbl_freq = Qt.QLabel('Actual frequency [Hz]:')
		self.qlbl_actual_frequency = Qt.QLabel(str(output_freq))
#        self.qlbl_actual_frequency.setMaximumWidth(60)
		
		# Sine/Square wave
		self.qradio_pulses = Qt.QRadioButton('5 ns pulses')
		self.qradio_square_wave = Qt.QRadioButton('Square wave')
		self.qsign_group = Qt.QButtonGroup(self)
		self.qsign_group.addButton(self.qradio_pulses)
		self.qsign_group.addButton(self.qradio_square_wave)
		
		self.qradio_pulses.setChecked(bool(self.bPulses))
		self.qradio_square_wave.setChecked(not bool(self.bPulses))
		self.qradio_pulses.clicked.connect(self.updateClicked)
		self.qradio_square_wave.clicked.connect(self.updateClicked)
		
		# On/Off button
		self.qbtn_divider_on = QtGui.QPushButton('Activate output')
		self.qbtn_divider_on.clicked.connect(self.updateClicked)
		self.qbtn_divider_on.setCheckable(True)
		self.qbtn_divider_on.setChecked(bool(self.bDividerOn))
		
		
		# Put all the widgets into a grid layout
		grid = QtGui.QGridLayout()
		
		grid.addWidget(self.qlbl_modulus,               0, 0)
		grid.addWidget(self.qedit_modulus,              0, 1, 1, 2)
		
		grid.addWidget(self.qlbl_phaseinc,              1, 0)
		grid.addWidget(self.qedit_phaseinc,             1, 1)
		grid.addWidget(self.qbtn_phaseinc,              1, 2)
		
		
		grid.addWidget(self.qlbl_freq,                  2, 0)
		grid.addWidget(self.qlbl_actual_frequency,      2, 1, 1, 2)        
		grid.addWidget(self.qradio_pulses,              3, 0)
		grid.addWidget(self.qradio_square_wave,         3, 1, 1, 2)        

		grid.addWidget(self.qbtn_divider_on,            4, 0, 1, 3)
		
		self.qgroupbox_divider.setLayout(grid)
		
		
		######################################################################
		# Create the widgets which control the residuals streaming module:
		# Needs: data_delay, trigger_delay, boxcar_filter_size
		######################################################################
		self.qgroupbox_streaming = Qt.QGroupBox('Residuals streaming settings')
		self.qgroupbox_streaming.setAutoFillBackground(True)
		
		if self.bPulses:
			output_freq = 2*self.sl.fs/(self.clk_divider_modulus)
		else:
			# square wave mode:
			output_freq = 2*self.sl.fs/(2*(self.clk_divider_modulus))
			
		
		self.qlbl_data_delay = Qt.QLabel('Data delay, [samples at 100 MHz]:')
		self.qedit_data_delay = Qt.QLineEdit('1')
		self.qedit_data_delay.textChanged.connect(self.residualsClicked)
		self.qedit_data_delay.setMaximumWidth(60)
		
		self.qlbl_trigger_delay = Qt.QLabel('Trigger delay, [samples at 100 MHz]:')
		self.qedit_trigger_delay = Qt.QLineEdit('1')
		self.qedit_trigger_delay.textChanged.connect(self.residualsClicked)
		self.qedit_trigger_delay.setMaximumWidth(60)
		
		self.qlbl_boxcar_size = Qt.QLabel('Boxcar filter size, [samples at 100 MHz]:')
		self.qedit_boxcar_size = Qt.QLineEdit('10')
		self.qedit_boxcar_size.textChanged.connect(self.residualsClicked)
		self.qedit_boxcar_size.setMaximumWidth(60)

		# Saturated or modulo phase 0:
		self.qlbl_phase0 = Qt.QLabel('Phase residuals 0:')
		self.qchk_Saturation0 = Qt.QRadioButton('Saturation')
		self.qchk_Modulo0 = Qt.QRadioButton('Modulo')
		self.qphase0_group = Qt.QButtonGroup(self)
		self.qphase0_group.addButton(self.qchk_Saturation0)
		self.qphase0_group.addButton(self.qchk_Modulo0)
		
		self.qchk_Saturation0.setChecked(True)
		self.qchk_Modulo0.setChecked(False)
		
		self.qchk_Saturation0.clicked.connect(self.residualsClicked)
		self.qchk_Modulo0.clicked.connect(self.residualsClicked)
		
		# Saturated or modulo phase 1:
		self.qlbl_phase1 = Qt.QLabel('Phase residuals 1:')
		self.qchk_Saturation1 = Qt.QRadioButton('Saturation')
		self.qchk_Modulo1 = Qt.QRadioButton('Modulo')
		self.qphase1_group = Qt.QButtonGroup(self)
		self.qphase1_group.addButton(self.qchk_Saturation1)
		self.qphase1_group.addButton(self.qchk_Modulo1)
		
		self.qchk_Saturation1.setChecked(True)
		self.qchk_Modulo1.setChecked(False)
		
		self.qchk_Saturation1.clicked.connect(self.residualsClicked)
		self.qchk_Modulo1.clicked.connect(self.residualsClicked)
		
		
		
		
		# Put all the widgets into a grid layout
		grid = QtGui.QGridLayout()
		
		grid.addWidget(self.qlbl_data_delay,            0, 0, 1, 1)
		grid.addWidget(self.qedit_data_delay,           0, 1, 1, 2)
		grid.addWidget(self.qlbl_trigger_delay,         1, 0, 1, 1)
		grid.addWidget(self.qedit_trigger_delay,        1, 1, 1, 2)
		grid.addWidget(self.qlbl_boxcar_size,           2, 0, 1, 1)
		grid.addWidget(self.qedit_boxcar_size,          2, 1, 1, 2)
		
		grid.addWidget(self.qlbl_phase0,                3, 0)
		grid.addWidget(self.qchk_Saturation0,           3, 1)
		grid.addWidget(self.qchk_Modulo0,               3, 2)
		
		grid.addWidget(self.qlbl_phase1,                4, 0)
		grid.addWidget(self.qchk_Saturation1,           4, 1)
		grid.addWidget(self.qchk_Modulo1,               4, 2)
		
		self.qgroupbox_streaming.setLayout(grid)        
		
		######################################################################
		# Create the widgets which control the DDC settings
		######################################################################
		self.qgroupbox_ddc = Qt.QGroupBox('DDC settings')
		self.qgroupbox_ddc.setAutoFillBackground(True)

		# Wideband/narrowband DDC0:
		self.qlbl_ddc0 = Qt.QLabel('DDC 0 filter BW:')
		self.qchk_Wideband0 = Qt.QRadioButton('Wideband (25 MHz)')
		self.qchk_Narrowband0 = Qt.QRadioButton('Narrowband (6 MHz)')
		self.qchk_WidebandFIR0 = Qt.QRadioButton('Wideband FIR (50 MHz)')
		self.qddc0_group = Qt.QButtonGroup(self)
		self.qddc0_group.addButton(self.qchk_Wideband0)
		self.qddc0_group.addButton(self.qchk_Narrowband0)
		self.qddc0_group.addButton(self.qchk_WidebandFIR0)
		
		self.qchk_Wideband0.setChecked(True)
		self.qchk_Narrowband0.setChecked(False)
		self.qchk_WidebandFIR0.setChecked(False)
		
		self.qchk_Wideband0.clicked.connect(self.ddcClicked)
		self.qchk_Narrowband0.clicked.connect(self.ddcClicked)
		self.qchk_WidebandFIR0.clicked.connect(self.ddcClicked)
		
		# DDC0 CORDIC or Quadrature
		self.qlbl_ddc0angle = Qt.QLabel('DDC 0 CORDIC or Quadrature:')
		self.qchk_cordic0 = Qt.QRadioButton('CORDIC')
		self.qchk_quadrature_msb0 = Qt.QRadioButton('Quadrature MSB')
		self.qchk_quadrature_lsb0 = Qt.QRadioButton('Quadrature LSB')
		self.qchk_inphase_msb0 = Qt.QRadioButton('In-Phase MSB')
		self.qchk_inphase_lsb0 = Qt.QRadioButton('In-Phase LSB')
		self.qddc0_group = Qt.QButtonGroup(self)
		self.qddc0_group.addButton(self.qchk_cordic0)
		self.qddc0_group.addButton(self.qchk_quadrature_msb0)
		self.qddc0_group.addButton(self.qchk_quadrature_lsb0)
		self.qddc0_group.addButton(self.qchk_inphase_msb0)
		self.qddc0_group.addButton(self.qchk_inphase_lsb0)
		
		self.qchk_cordic0.setChecked(True)
		self.qchk_quadrature_msb0.setChecked(False)
		self.qchk_quadrature_lsb0.setChecked(False)
		
		self.qchk_cordic0.clicked.connect(self.ddcClicked)
		self.qchk_quadrature_msb0.clicked.connect(self.ddcClicked)
		self.qchk_quadrature_lsb0.clicked.connect(self.ddcClicked)
		self.qchk_inphase_msb0.clicked.connect(self.ddcClicked)
		self.qchk_inphase_lsb0.clicked.connect(self.ddcClicked)
		
		# Wideband/narrowband DDC1:
		self.qlbl_ddc1 = Qt.QLabel('DDC 1 filter BW:')
		self.qchk_Wideband1 = Qt.QRadioButton('Wideband (31 MHz)')
		self.qchk_Narrowband1 = Qt.QRadioButton('Narrowband (7.5 MHz)')
		self.qchk_WidebandFIR1 = Qt.QRadioButton('Wideband FIR (62 MHz)')
		self.qddc1_group = Qt.QButtonGroup(self)
		self.qddc1_group.addButton(self.qchk_Wideband1)
		self.qddc1_group.addButton(self.qchk_Narrowband1)
		self.qddc1_group.addButton(self.qchk_WidebandFIR1)
		
		self.qchk_Wideband1.setChecked(True)
		self.qchk_Narrowband1.setChecked(False)
		self.qchk_WidebandFIR1.setChecked(False)
		
		self.qchk_Wideband1.clicked.connect(self.ddcClicked)
		self.qchk_Narrowband1.clicked.connect(self.ddcClicked)
		self.qchk_WidebandFIR1.clicked.connect(self.ddcClicked)
		
		# DDC1 CORDIC or Quadrature
		self.qlbl_ddc1angle = Qt.QLabel('DDC 1 CORDIC or Quadrature:')
		self.qchk_cordic1 = Qt.QRadioButton('CORDIC')
		self.qchk_quadrature_msb1 = Qt.QRadioButton('Quadrature MSB')
		self.qchk_quadrature_lsb1 = Qt.QRadioButton('Quadrature LSB')
		self.qchk_inphase_msb1 = Qt.QRadioButton('In-Phase MSB')
		self.qchk_inphase_lsb1 = Qt.QRadioButton('In-Phase LSB')
		self.qddc1_group = Qt.QButtonGroup(self)
		self.qddc1_group.addButton(self.qchk_cordic1)
		self.qddc1_group.addButton(self.qchk_quadrature_msb1)
		self.qddc1_group.addButton(self.qchk_quadrature_lsb1)
		self.qddc1_group.addButton(self.qchk_inphase_msb1)
		self.qddc1_group.addButton(self.qchk_inphase_lsb1)
		
		self.qchk_cordic1.setChecked(True)
		self.qchk_quadrature_msb1.setChecked(False)
		self.qchk_quadrature_lsb1.setChecked(False)
		
		self.qchk_cordic1.clicked.connect(self.ddcClicked)
		self.qchk_quadrature_msb1.clicked.connect(self.ddcClicked)
		self.qchk_quadrature_lsb1.clicked.connect(self.ddcClicked)
		self.qchk_inphase_msb1.clicked.connect(self.ddcClicked)
		self.qchk_inphase_lsb1.clicked.connect(self.ddcClicked)
		
		
		
		# Put all the widgets into a grid layout
		grid = QtGui.QGridLayout()
		
		
		grid.addWidget(self.qlbl_ddc0,                0, 0)
		grid.addWidget(self.qchk_Wideband0,           0, 1)
		grid.addWidget(self.qchk_Narrowband0,         0, 2)
		grid.addWidget(self.qchk_WidebandFIR0,        0, 3)
		
		#FEATURE
		grid.addWidget(self.qlbl_ddc0angle,           1, 0)
		grid.addWidget(self.qchk_cordic0,             1, 1)
		grid.addWidget(self.qchk_quadrature_msb0,     1, 2)
		grid.addWidget(self.qchk_quadrature_lsb0,     1, 3)
		grid.addWidget(self.qchk_inphase_msb0,        2, 2)
		grid.addWidget(self.qchk_inphase_lsb0,        2, 3)

		grid.addWidget(self.qlbl_ddc1,                3, 0)
		grid.addWidget(self.qchk_Wideband1,           3, 1)
		grid.addWidget(self.qchk_Narrowband1,         3, 2)
		grid.addWidget(self.qchk_WidebandFIR1,        3, 3)
		
		#FEATURE
		grid.addWidget(self.qlbl_ddc1angle,           4, 0)
		grid.addWidget(self.qchk_cordic1,             4, 1)
		grid.addWidget(self.qchk_quadrature_msb1,     4, 2)
		grid.addWidget(self.qchk_quadrature_lsb1,     4, 3)
		grid.addWidget(self.qchk_inphase_msb1,        5, 2)
		grid.addWidget(self.qchk_inphase_lsb1,        5, 3)
		
		self.qgroupbox_ddc.setLayout(grid)        
		
		

		vbox = Qt.QVBoxLayout()
		#FEATURE
		# vbox.addWidget(self.qgroupbox_divider)
		# vbox.addWidget(self.qgroupbox_streaming)
		vbox.addWidget(self.qgroupbox_ddc)
		vbox.addStretch(1)
		self.setLayout(vbox)
		

		# Adjust the size and position of the window
#        self.resize(800, 600)
		self.center()
		self.setWindowTitle(self.custom_shorthand + ': Peripherals settings')    
		#self.show()
		

		
	def center(self):
		
		qr = self.frameGeometry()
		cp = QtGui.QDesktopWidget().availableGeometry().center()
		qr.moveCenter(cp)
#        self.move(qr.topLeft())
#        self.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(50, 50))
		

		
		
		