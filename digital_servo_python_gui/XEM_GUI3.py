# -*- coding: utf-8 -*-
"""
Phase-lock box main GUI script,
by JD Deschenes, October 2013
---
-- Ported to Red Pitaya platform - JDD 2017

"""
from __future__ import print_function
import sys
from PyQt5 import QtGui, Qt, QtCore, QtWidgets
import numpy as np


from SuperLaserLand_JD_RP import SuperLaserLand_JD_RP
from XEM_GUI_MainWindow import XEM_GUI_MainWindow
from FreqErrorWindowWithTempControlV2 import FreqErrorWindowWithTempControlV2
from initialConfiguration_RP import initialConfiguration
from SLLSystemParameters import SLLSystemParameters

from DisplayDitherSettingsWindow import DisplayDitherSettingsWindow

from DisplayDividerAndResidualsStreamingSettingsWindow import DisplayDividerAndResidualsStreamingSettingsWindow

from ConfigurationRPSettingsUI import ConfigRPSettingsUI

from devicesData import devicesData

import time



class controller(object):
	"""Main class of the GUI. It contains most of the elements of the GUI, the main_window and the communication class"""
	def __init__(self):
		# Create the object that handles the communication with the FPGA board:
		self.sl = SuperLaserLand_JD_RP(self)
		self.updateDeviceData()

		self.sp = SLLSystemParameters()

		# Start Qt:
		self.app = QtCore.QCoreApplication.instance()
		if self.app is None:
			self.app = QtWidgets.QApplication(sys.argv)


		self.main()


	def updateDeviceData(self):
		# Hardcoded dictionnary containing the known Red Pitaya
		# TO DO : xml file, user can add RP from the GUI?
		self.devices_data = {}
		devices_xml = devicesData("devices_data.xml")
		self.devices_data = devices_xml.updateDictionnary(self.devices_data)

		# Specify the mapping between the MAC addresses (which are used as a form of serial numbers) and the box data
		# self.devices_data = {}
		# self.devices_data['002632f016dc'] = {'color': '#E37405',
		# 					'name': 'Red Pitaya 0',
		# 					'shorthand': 'RP 0',
		# 					'config file': 'system_parameters_RP_1.xml',
		# 					#'port': 60002
		# 					}
							
		# self.devices_data['002632f03cc2'] = {'color': '#811CC9',
		# 					'name': 'RP Comb 1',
		# 					'shorthand': 'RPC 1',
		# 					'config file': 'system_parameters_RP_C1.xml',
		# 					#'port': 60002
		# 					}

		# self.devices_data['002632f03d5b'] = {'color': '#1CC981',
		# 					'name': 'RP Comb 2',
		# 					'shorthand': 'RPC 2',
		# 					'config file': 'system_parameters_RP_C2.xml',
		# 					#'port': 60002
		# 					}
		
	#    serial_to_color_mapping = {}
	#    serial_to_color_mapping['000000054R'] = '#1CC981'
	#    serial_to_color_mapping['000000054S'] = '#811CC9'
	#    # serial_to_color_mapping['124300046U'] = 'blue'
	#    serial_to_color_mapping['12320003SX'] = 'orange'
	#    serial_to_color_mapping['000000054E'] = '#E37405'   # orange high-bandwidth (dark orange)
	#    serial_to_color_mapping['000000054J'] = '#70E7FF'  # blue high-bandwidth (light blue)
	#    serial_to_color_mapping['124300046R'] = '#B572E8'  # purple high-bandwidth (purple)
	#    serial_to_color_mapping['124300046V'] = '#FF0000'
	#    serial_to_color_mapping['124300046S'] = '#0033CC'	


	
	def connectionGUI(self):
		strBroadcastAddress = '192.168.0.255'
		strFPGAFirmware=r'red_pitaya_top_lock_on_trigger.bit'
		strCPUFirmware=u'monitor-tcp'
		self.initial_config = initialConfiguration(self.sl.dev, self, self.devices_data, strBroadcastAddress, strFPGAFirmware, strCPUFirmware)
		
	#    def __init__(self, dev, devices_data={}, strBroadcastAddress="192.168.2.255", strFPGAFirmware='', strCPUFirmware=''):
		
	   # this will remove minimized status 
	   # and restore window with keeping maximized/normal state
		# allowSetForegroundWindow.allowSetForegroundWindow()
		# self.initial_config.setWindowState(self.initial_config.windowState() & ~QtCore.Qt.WindowMinimized | QtCore.Qt.WindowActive)
	#    # this will activate the window
	##    self.initial_config.activateWindow()
	##    self.initial_config.show()
	#  #  self.initial_config.raise_()
	#  #  self.initial_config.show()
	#  
	#    SetWindowPos(self.initial_config.winId(),
	#                    win32con.HWND_TOPMOST, # = always on top. only reliable way to bring it to the front on windows
	#                    0, 0, 0, 0,
	#                    win32con.SWP_NOMOVE | win32con.SWP_NOSIZE | win32con.SWP_SHOWWINDOW)
	#    SetWindowPos(self.initial_config.winId(),
	#                    win32con.HWND_NOTOPMOST, # disable the always on top, but leave window at its top position
	#                    0, 0, 0, 0,
	#                    win32con.SWP_NOMOVE | win32con.SWP_NOSIZE | win32con.SWP_SHOWWINDOW)
	#    self.initial_config.raise_()
	#    self.initial_config.show()
	#    self.initial_config.activateWindow()

		#self.initial_config.setWindowState(self.initial_config.windowState() & ~QtCore.Qt.WindowMinimized | QtCore.Qt.WindowActive)
		# Run the event loop for this window
		#self.app.exec_()
		#self.main()


	def main(self):

		
	############################################## - OLD CODE - ##############################################
	# this opens the connection to the fpga (hard-coded IP address for now)
	#    strList = self.sl.getDeviceList()
		###########################################################################
		# Update the FPGA bitfile and the Zynq monitor-tcp C program
		

		# send new bitfile version
		# try:
	#        self.sl.dev.write_file_on_remote(strFilenameLocal=r'D:\Projects\RedPitaya\fpga\project\redpitaya.runs\impl_1\red_pitaya_top.bit', strFilenameRemote='/opt/red_pitaya_top.bit')
	#        self.sl.dev.write_file_on_remote(strFilenameLocal=r'D:\Projets_Xilinx\RedPitaya\fpga\project\redpitaya.runs\impl_1\red_pitaya_top.bit', strFilenameRemote='/opt/red_pitaya_top.bit')
		#     pass
		# except:
		#     print("warning, could not update fpga bitfile")
		#     pass
		# program FPGA with new bitfile:
	#    self.sl.dev.send_shell_command('cat /opt/red_pitaya_top.bit > /dev/xdevcfg')

	#    time.sleep(3)
	#    
	#    # send new monitor-tcp version
	#    self.sl.dev.write_file_on_remote(strFilenameLocal=u'D:\\Université\\Dropbox\\22_H2015\\Red Pitaya\\monitor-tcp\\monitor-tcp', strFilenameRemote='/opt/monitor-tcp-new')
	#    
	#    # set executable permissions
	#    self.sl.dev.send_shell_command('chmod +x /opt/monitor-tcp-new')
	#    # copy over old file
	#    self.sl.dev.send_shell_command('mv /opt/monitor-tcp-new /opt/monitor-tcp')
	#    
	#    # send reboot command
	#    self.sl.dev.send_reboot_command()
	#    self.sl.dev.sock.shutdown(socket.SHUT_RDWR)
	#    self.sl.dev.sock.close()
	#    
	#    time.sleep(1) # give some time for tcp server to come back up
	##    return
	#    self.sl.getDeviceList() # reconnect
	#    
	#    #self.sl.dev.OpenTCPConnection(self.sl.dev.HOST, self.sl.dev.PORT) # hack to get things working quickly
	##    self.sl.dev.sock.connect((self.sl.dev.HOST, self.sl.dev.PORT))
	#    
	##    return  # for quick debug tests
		
		
		############################################## - OLD CODE - ##############################################
		# Start the User Interface
		
		
		
		bTriggerEvents = False
		bConnectedRP = False
		self.strSelectedSerial = "000000000000"
		
		# if self.initial_config.bOk == False:
		# 	# User clicked cancel. simply close the program:
		# 	return

		# if self.initial_config.qradio_pushValue.isChecked():
		# 	print("Push")
		# 	bTriggerEvents = True
		# 	bConnectedRP = True
		# 	self.loadDefaultValueFromConfigFile(self.initial_config.strSelectedSerial)
		# elif self.initial_config.qradio_existingRP.isChecked():
		# 	print("Reconnection")
		# 	bTriggerEvents = False
		# 	bConnectedRP = True
		# elif self.initial_config.qradio_noRP.isChecked():
		# 	print("No RP")
		# 	bTriggerEvents = False
		# 	bConnectedRP = False


		bUpdateFPGA = bTriggerEvents
		bSendToFPGA = bTriggerEvents


			
		
		# Start the init process (this sets the PLL gain/settings registers and the residuals streaming)
		self.sl.initSubModules()


	   
		###########################################################################
		# Create the object which handles the configuration parameters (DAC offsets, DAC gains, beat frequency modulation range, etc):
		#sp = SLLSystemParameters()
		
			
		
	#    config_window = SLLConfigurationWindow()
	#    config_window.loadParameters(sp)
	#    config_window.hide()
		

		###########################################################################
		# Load all our windows:
		
		# Style sheet which includes the color scheme for each specific box:
		try:
			# custom_style_sheet = ('#MainWindow {color: white; background-color: %s;}' % self.devices_data[self.initial_config.strSelectedSerial]['color'])
			custom_style_sheet = ('#MainWindow {color: white; background-color: %s;}' % self.devices_data[self.strSelectedSerial]['color'])
		except KeyError:
			custom_style_sheet = ''
			
		
		# The shorthand name which gets added to the window names:
		try:
			# custom_shorthand = self.devices_data[self.initial_config.strSelectedSerial]['shorthand']
			custom_shorthand = self.devices_data[self.strSelectedSerial]['shorthand']
		except KeyError:
			custom_shorthand = ''

		# Have to be careful with the modulus setting (double-check with a scope to make sure the output frequency is right)
		# I think the output frequency for the square wave mode is given by:
		# 200 MHz/(2*(modulus+1))
		# While for the pulsed mode (bPulses = 1), the frequency is:
		# 200 MHz/(modulus+1)
	#    sl.set_clk_divider_settings(bOn=1, bPulses=0, modulus=67e3-1)
	#    sl.set_clk_divider_settings(bOn=1, bPulses=0, modulus=67e3+1-1)
		self.divider_settings_window = DisplayDividerAndResidualsStreamingSettingsWindow(self.sl, self.sp, clk_divider_modulus=67e3, bDividerOn=0, bPulses=0, custom_style_sheet=custom_style_sheet, custom_shorthand=custom_shorthand)    
		
		
		# Optical lock window
		# self.xem_gui_mainwindow2 = XEM_GUI_MainWindow(self.sl, custom_shorthand + ': Optical lock', 1, (False, True, False), sp, custom_style_sheet, self.initial_config.strSelectedSerial, bUpdateFPGA = bSendToFPGA, bConnectedRP = bConnectedRP)
		self.xem_gui_mainwindow2 = XEM_GUI_MainWindow(self.sl, custom_shorthand + ': Optical lock', 1, (False, True, False), self.sp, custom_style_sheet, self.strSelectedSerial)
		
		# CEO Lock window
		# self.xem_gui_mainwindow = XEM_GUI_MainWindow(self.sl, custom_shorthand + ': CEO lock', 0, (True, False, False), sp, custom_style_sheet, self.initial_config.strSelectedSerial, bUpdateFPGA = bSendToFPGA, bConnectedRP = bConnectedRP)
		self.xem_gui_mainwindow = XEM_GUI_MainWindow(self.sl, custom_shorthand + ': CEO lock', 0, (True, False, False), self.sp, custom_style_sheet, self.strSelectedSerial)
		
		
	#    ###########################################################################
	#    # For testing the Red Pitaya with the built-in DDS:
	#    
	#    addr_vco = 2
	#    addr_vco_amplitude = 0x0000
	#    addr_vco_freq_msb  = 0x0004
	#    addr_vco_freq_lsb  = 0x0008
	#
	#    vco_amplitude = round(0.01*(2**15-1))
	##   vco_freq_word = np.array([round((15e6/100e6+1./600.)*2.**48)]).astype(np.int64)
	##   # break vco word into msbs and lsbs:
	##   vco_freq_word_msbs = vco_freq_word >> 32
	##   vco_freq_word_lsbs = np.bitwise_and(vco_freq_word, (1<<32)-1)
	#   
	#   # write amplitude
	#    address_uint32 = (addr_vco << 20) + addr_vco_amplitude
	#    data_uint32 = vco_amplitude
	#    self.sl.dev.write_Zynq_register_uint32(address_uint32, data_uint32)
		
		#########################################################  
		# The two frequency counter:
		strOfTime = time.strftime("%m_%d_%Y_%H_%M_%S_")

		try:
			# temp_control_port = self.devices_data[self.initial_config.strSelectedSerial]['port']
			temp_control_port = self.devices_data[self.strSelectedSerial]['port']
		except:
			temp_control_port = 0
		
		
		strNameTemplate = 'data_logging\%s' % strOfTime
		# strNameTemplate = '%s_%s_' % (strNameTemplate, self.initial_config.strSelectedSerial)
		strNameTemplate = '%s_%s_' % (strNameTemplate, self.strSelectedSerial)
		self.freq_error_window1 = FreqErrorWindowWithTempControlV2(self.sl, 'CEO beat in-loop counter', self.sp, 0, strNameTemplate, custom_style_sheet, 0, self.xem_gui_mainwindow)
		self.freq_error_window2 = FreqErrorWindowWithTempControlV2(self.sl, 'Optical beat in-loop counter', self.sp, 1, strNameTemplate, custom_style_sheet, temp_control_port, self.xem_gui_mainwindow2)

		self.counters_window = Qt.QWidget()
		self.counters_window.setObjectName('MainWindow')
		self.counters_window.setStyleSheet(custom_style_sheet)
		vbox = Qt.QVBoxLayout()
		vbox.addWidget(self.freq_error_window1)
		vbox.addWidget(self.freq_error_window2)
		self.counters_window.setLayout(vbox)
		self.counters_window.setWindowTitle(custom_shorthand + ': Frequency counters')
		#self.counters_window.setGeometry(993, 40, 800, 1010)
		#self.counters_window.setGeometry(0, 0, 750, 1000)
		#    self.counters_window.resize(600, 1080-100+30)
		#self.counters_window.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(985, 10))
		#self.counters_window.show()
		
		# Dither windows, this code could be moved to another class/file to help with clutter:
		self.dither_widget0 = DisplayDitherSettingsWindow(self.sl, self.sp, 0, modulation_frequency_in_hz='1e3', output_amplitude='1e-3', integration_time_in_seconds='0.1', bEnableDither=True, custom_style_sheet=custom_style_sheet)
		self.dither_widget1 = DisplayDitherSettingsWindow(self.sl, self.sp, 1, modulation_frequency_in_hz='5.1e3' , output_amplitude='1e-3', integration_time_in_seconds='0.1', bEnableDither=True, custom_style_sheet=custom_style_sheet)
		#dither_widget2 = DisplayDitherSettingsWindow(self.sl, self.sp, 2, modulation_frequency_in_hz='110' , output_amplitude='1e-4', integration_time_in_seconds='0.1', bEnableDither=True, custom_style_sheet=custom_style_sheet)

		self.RP_Settings = ConfigRPSettingsUI(self.sl, self.sp, self, custom_style_sheet=custom_style_sheet, custom_shorthand=custom_shorthand)
		
		self.settings_window = Qt.QWidget()
		self.settings_window.setObjectName('MainWindow')
		self.settings_window.setStyleSheet(custom_style_sheet)
		vbox1 = Qt.QVBoxLayout()
		vbox1.addWidget(self.dither_widget0)
		vbox1.addWidget(self.dither_widget1)
		#vbox1.addWidget(dither_widget2)
		vbox1.addStretch(1)
		vbox2 = Qt.QVBoxLayout()
		vbox2.addWidget(self.RP_Settings)
		vbox2.addWidget(self.divider_settings_window)
		hbox = Qt.QHBoxLayout()
		hbox.addLayout(vbox1)
		hbox.addLayout(vbox2)
		hbox.addStretch(1)
		self.settings_window.setLayout(hbox)
		self.settings_window.setWindowTitle(custom_shorthand + ': Dither controls')
		#self.settings_window.show()
		
	#    ###########################################################################
	#    # For testing out the transfer function window:
	#    frequency_axis = np.logspace(np.log10(10e3), np.log10(2e6), 10e3)
	#    transfer_function = 1/(1 + 1j*frequency_axis/100e3)
	#    window_number = 1
	#    vertical_units = 'V/V'
	#    tf_window1 = DisplayTransferFunctionWindow(frequency_axis, transfer_function, window_number, vertical_units)
	#    
		
	#    # Regroup the two windows into a single one:
		self.main_windows = Qt.QWidget()
		self.main_windows.setObjectName('MainWindow')
		self.main_windows.setStyleSheet(custom_style_sheet)
		

	#    ###########################################################################
	#    # Select clock source
	#    # clock_source = 0: Internal clock at 100 MHz
	#    # clock_source = 1: External clock at 200 MHz on DIN[0]/CLKIN, divided by 2 internally for a system clock still at 100 MHz
	#    if self.initial_config.bSendFirmware:
	#        if self.initial_config.bExternalClock == True:
	#            clock_source = 1
	#            print('External clock mode')
	#        else:
	#            clock_source = 0    
	#            print('Internal clock mode')
	#        self.sl.selectClockSource(clock_source)
	#        # Now we just need to reset the frontend to make sure we start everything in a nice state
	#        self.sl.resetFrontend()
			
		
		tabs = QtGui.QTabWidget()
		# self.xem_gui_mainwindow2.resize(600, 700)
		
		# self.xem_gui_mainwindow.setContentsMargins(0, 0, 0, 0)
		# self.xem_gui_mainwindow.layout().setContentsMargins(0, 0, 0, 0)
		# self.xem_gui_mainwindow2.setContentsMargins(0, 0, 0, 0)
		# self.xem_gui_mainwindow2.layout().setContentsMargins(0, 0, 0, 0)
		# self.counters_window.setContentsMargins(0, 0, 0, 0)
		# self.counters_window.layout().setContentsMargins(0, 0, 0, 0)
		# dither_window.setContentsMargins(0, 0, 0, 0)
		# dither_window.layout().setContentsMargins(0, 0, 0, 0)
		# dfr_timing_gui.setContentsMargins(0, 0, 0, 0)
		# dfr_timing_gui.layout().setContentsMargins(0, 0, 0, 0)
		# self.divider_settings_window.setContentsMargins(0, 0, 0, 0)
		# self.divider_settings_window.layout().setContentsMargins(0, 0, 0, 0)
		
		#tabs.setMaximumSize(1920,1080-100+30)
		
		# self.main_windows.setMaximumSize(600,600)
		# self.xem_gui_mainwindow.setMaximumSize(600,600)
		# self.xem_gui_mainwindow2.setMaximumSize(600,600)
		# self.counters_window.setMaximumSize(600,600)

		# dither_window.setMaximumSize(600,600)
		# dfr_timing_gui.setMaximumSize(600,600)
		# self.divider_settings_window.setMaximumSize(600,600)
		tabs.addTab(self.xem_gui_mainwindow, "CEO Lock")
		tabs.addTab(self.xem_gui_mainwindow2, "Optical Lock")
		tabs.addTab(self.counters_window, "Counters")
		tabs.addTab(self.settings_window, "Settings")
		#FEATURE
		#tabs.addTab(dfr_timing_gui, "DFr trigger generator")
	#    tabs.addTab(self.divider_settings_window, "Filter settings")
		# tabs.setGeometry(0, 0, 750, 1000)
		

		
		box = QtGui.QHBoxLayout()
		box.addWidget(tabs)
		self.main_windows.setLayout(box)
		self.main_windows.setWindowTitle(custom_shorthand)
		#self.main_windows.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(945-300, 0))
		self.main_windows.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(800-300, 0))
		
		self.main_windows.show()

		
		self.connectionGUI()
		
		# Enter main event loop
		#self.app.exec_()
		try:
			self.app.exec_()
		except:
			print("XEM_GUI3.py: Exception during app.exec_()")


	def loadDefaultValueFromConfigFile(self, strSelectedSerial):
		try:
			# custom_config_file = self.devices_data[self.initial_config.strSelectedSerial]['config file']
			custom_config_file = self.devices_data[strSelectedSerial]['config file']
			self.sp.loadFromFile(custom_config_file)
			print('Loaded configuration from %s' % custom_config_file)
		except (KeyError, IOError):
			strFileDefaultConfig = 'system_parameters_RP_Default.xml'
			# print('Warning: Could not parse config file for FPGA serial: %s, loading values from file %s' % (self.initial_config.strSelectedSerial, strFileDefaultConfig))
			# print('Warning: Could not parse config file for FPGA serial: %s, loading values from file %s' % (self.initial_config.strSelectedSerial, strFileDefaultConfig))
			print('Warning: Could not parse config file for FPGA serial: %s, loading values from file %s' % (strSelectedSerial, strFileDefaultConfig))
			custom_config_file = ''
			try:
				self.sp.loadFromFile(strFileDefaultConfig)
				print('Loaded configuration from %s' % strFileDefaultConfig)
			except (KeyError, IOError):
				
				# print('Warning: Could not parse config file "%s" for FPGA serial: %s, falling back on script-defined defaults' % (strFileDefaultConfig, self.initial_config.strSelectedSerial))
				print('Warning: Could not parse config file "%s" for FPGA serial: %s, falling back on script-defined defaults' % (strFileDefaultConfig, strSelectedSerial))
				self.sp.loadDefaults()
		
		# self.sp.loadDefaults()
		# self.sp.saveToFile('system_parameters_current.xml')

		self.sp.sendToFPGA(self.sl, True)


	def setCustomStyleSheet(self, strSelectedSerial):
		# Style sheet which includes the color scheme for each specific box:
		try:
			# custom_style_sheet = ('#MainWindow {color: white; background-color: %s;}' % self.devices_data[self.initial_config.strSelectedSerial]['color'])
			custom_style_sheet = ('#MainWindow {color: white; background-color: %s;}' % self.devices_data[strSelectedSerial]['color'])
		except KeyError:
			custom_style_sheet = ''

		self.divider_settings_window.setStyleSheet(custom_style_sheet)
		self.freq_error_window1.setStyleSheet(custom_style_sheet)
		self.freq_error_window2.setStyleSheet(custom_style_sheet)
		self.xem_gui_mainwindow2.setStyleSheet(custom_style_sheet)
		self.xem_gui_mainwindow.setStyleSheet(custom_style_sheet)
		self.counters_window.setStyleSheet(custom_style_sheet)
		self.dither_widget0.setStyleSheet(custom_style_sheet)
		self.dither_widget1.setStyleSheet(custom_style_sheet)
		self.RP_Settings.setStyleSheet(custom_style_sheet)
		self.settings_window.setStyleSheet(custom_style_sheet)
		self.main_windows.setStyleSheet(custom_style_sheet)


	def pushDefaultValues(self, strSelectedSerial = "000000000000", ip_addr = "192.168.0.150"):
		self.setCustomStyleSheet(strSelectedSerial)

		if self.sl.dev.valid_socket:
			self.sl.dev.CloseTCPConnection()
			
		self.sl.dev.OpenTCPConnection(ip_addr)
		# Now we just need to reset the frontend to make sure we start everything in a nice state
		self.sl.resetFrontend()
		self.loadDefaultValueFromConfigFile(strSelectedSerial)
		
		
		self.xem_gui_mainwindow2.pushDefaultValues()
		self.xem_gui_mainwindow.pushDefaultValues()
		self.freq_error_window1.pushDefaultValues()
		self.freq_error_window2.pushDefaultValues()
		self.RP_Settings.pushDefaultValues()
		self.divider_settings_window.pushDefaultValues()
		self.dither_widget0.pushDefaultValues()
		self.dither_widget1.pushDefaultValues()

	def pushActualValues(self, strSelectedSerial, ip_addr = "192.168.0.150"):
		self.setCustomStyleSheet(strSelectedSerial)

		if self.sl.dev.valid_socket:
			self.sl.dev.CloseTCPConnection()
		self.sl.dev.OpenTCPConnection(ip_addr)



		self.xem_gui_mainwindow2.pushActualValues()
		self.xem_gui_mainwindow.pushActualValues()
		self.freq_error_window1.pushValues()
		self.freq_error_window2.pushValues()

	def getActualValues(self, strSelectedSerial, ip_addr = "192.168.0.150"):
		self.setCustomStyleSheet(strSelectedSerial)
		if self.sl.dev.valid_socket:
			self.sl.dev.CloseTCPConnection()
		self.sl.dev.OpenTCPConnection(ip_addr)

		self.xem_gui_mainwindow2.getValues()
		self.xem_gui_mainwindow.getValues()
		self.freq_error_window1.getValues()
		self.freq_error_window2.getValues()
		self.RP_Settings.getValues()
		self.divider_settings_window.getValues()
		self.dither_widget0.getValues()
		self.dither_widget1.getValues()

	def stopCommunication(self):
		if self.sl.dev.valid_socket:
			self.sl.dev.CloseTCPConnection()
		try:
			self.xem_gui_mainwindow2.killTimers()
			self.xem_gui_mainwindow.killTimers()
			self.freq_error_window1.killTimers()
			self.freq_error_window2.killTimers()
		except:
			print("Error while killing the Timers")

	def startCommunication(self, ip_addr = "192.168.0.150"):
		self.sl.dev.OpenTCPConnection(ip_addr)
		self.xem_gui_mainwindow2.startTimers()
		self.xem_gui_mainwindow.startTimers()
		self.freq_error_window1.startTimers()
		self.freq_error_window2.startTimers()



if __name__ == '__main__':
	controller()
	
	