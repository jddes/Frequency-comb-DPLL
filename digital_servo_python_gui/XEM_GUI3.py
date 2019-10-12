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

import ctypes # for the icons


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

import pdb
import traceback

import socket
from RP_PLL import CommsLoggeableError

import logging, logging.handlers
SYSLOG_IP = '127.0.0.1' #To log on this computer
# SYSLOG_IP = '10.248.174.184'
SYSLOG_PORT = 514
logging.basicConfig(level=logging.INFO)

#sys._excepthook = sys.excepthook
#def exception_hook(exctype, value, traceback):
#	print("exception_hook(): type = %s, value = %s" % (exctype, value))
#	
#	sys._excepthook(exctype, value, traceback)
#	sys.exit(1)
#sys.excepthook = exception_hook



class controller(object):
	"""Main class of the GUI. It contains most of the elements of the GUI, the main_window and the communication class"""
	def __init__(self, bManualStartupForTests=False):
		self.logger = logging.getLogger()
		self.logger.addHandler(logging.handlers.SysLogHandler(address = (SYSLOG_IP,SYSLOG_PORT)))
		self.logger_name = '' #To be replaced with FPGA's shorthand

		# Create the object that handles the communication with the FPGA board:
		self.sl = SuperLaserLand_JD_RP(self)
		self.updateDeviceData()

		self.sp = SLLSystemParameters()


		self.reconnection_attempts = 0
		self.timerReconnect = None

		# Start Qt:
		self.app = QtCore.QCoreApplication.instance()
		if self.app is None:
			print("QCoreApplication not running yet. creating.")
			self.bEventLoopWasRunningAlready = False
			self.app = QtWidgets.QApplication(sys.argv)
		else:
			self.bEventLoopWasRunningAlready = True
			print("QCoreApplication already running.")

		self.initUI()

		if bManualStartupForTests==False:
			self.runEventLoop()

	def updateDeviceData(self):
		# xml file containing the known Red Pitaya's and their MAC addresses, UI color and shorthand name
		self.devices_data = {}
		devices_xml = devicesData("devices_data.xml")
		self.devices_data = devices_xml.updateDictionnary(self.devices_data)


	def findMostLikelyLANBroadcastIPAddress(self):
		# list all possible IPv4 addresses and choose the most likely candidate for the subnet on which the red pitaya is
		# heuristics used:
		#   -prefer if the address starts with 192.168
		#   -choose the subnet that has the lowest third byte: eg if there are both 192.168.1.10 and 192.168.2.10, chooose 129.168.1.10 as the correct one
		addrCandidate = '192.168.0.255'

		try:
			listAddr = socket.getaddrinfo(socket.gethostname(), None)
			min_third_byte = 255

			for addr_tuple in listAddr:
				(family, _, _, _, sockaddr) = addr_tuple
				if family == socket.AF_INET:
					# this is IPv4
					print('IP candidate: %s' % sockaddr[0])
					third_byte = int(sockaddr[0].split('.')[2])
					if third_byte <= min_third_byte:
						min_third_byte = third_byte
						addrCandidate = sockaddr[0]
			print('Chosen local IP: %s' % addrCandidate)

		except:
			print("findMostLikelyLANBroadcastIPAddress():Exception trying to find correct broadcast automatically.")
			#pass

		# Take this machine's IP address and transform into broadcast address for the whole subnet (change last byte to 255)
		addrSplit = addrCandidate.split('.')
		addrSplit[3] = '255'
		strBroadCastAddress = '.'.join(addrSplit)

		print('Chosen broadcast IP: %s' % strBroadCastAddress)

		return strBroadCastAddress

	
	def connectionGUI(self):
		
		strBroadcastAddress = self.findMostLikelyLANBroadcastIPAddress()
		#strBroadcastAddress = "192.168.0.255"
		strFPGAFirmware=r'red_pitaya_top_extint_clk.bit'
		strCPUFirmware=u'monitor-tcp'
		self.initial_config = initialConfiguration(self.sl.dev, self, self.devices_data, strBroadcastAddress, strFPGAFirmware, strCPUFirmware)
		

	def initUI(self):

		# Start the User Interface
		self.strSelectedSerial = "000000000000"
		
		# Start the init process (this sets the PLL gain/settings registers and the residuals streaming)
		self.sl.initSubModules()


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

		self.divider_settings_window = DisplayDividerAndResidualsStreamingSettingsWindow(self.sl, self.sp, clk_divider_modulus=67e3, bDividerOn=0, bPulses=0, custom_style_sheet=custom_style_sheet, custom_shorthand=custom_shorthand)    
		
		# Optical lock window
		self.xem_gui_mainwindow2 = XEM_GUI_MainWindow(self.sl, custom_shorthand + ': Optical lock', 1, (False, True, True), self.sp, custom_style_sheet, self.strSelectedSerial)
		
		# CEO Lock window
		self.xem_gui_mainwindow = XEM_GUI_MainWindow(self.sl, custom_shorthand + ': CEO lock', 0, (True, False, False), self.sp, custom_style_sheet, self.strSelectedSerial)

		
		#########################################################  
		# The two frequency counter:
		strOfTime = time.strftime("%m_%d_%Y_%H_%M_%S_")

		
		temp_control_port = 0
		
		
		strNameTemplate = 'data_logging\\%s' % strOfTime
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
		
	#    # Regroup the two windows into a single one:
		self.main_windows = Qt.QWidget()
		self.main_windows.setObjectName('MainWindow')
		self.main_windows.setStyleSheet(custom_style_sheet)
		
		
		tabs = QtGui.QTabWidget()

		tabs.addTab(self.xem_gui_mainwindow, "CEO Lock")
		tabs.addTab(self.xem_gui_mainwindow2, "Optical Lock")
		tabs.addTab(self.counters_window, "Counters")
		tabs.addTab(self.settings_window, "Settings")
		box = QtGui.QHBoxLayout()
		box.addWidget(tabs)
		self.main_windows.setLayout(box)
		self.main_windows.setWindowTitle(custom_shorthand)
		#self.main_windows.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(945-300, 0))
		self.main_windows.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(800-300, 0))
		
		
		APPID = u'TITLE'
		ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(APPID)

		app_icon = QtGui.QIcon()
		app_icon.addFile('icons/red_pitaya.png', QtCore.QSize(32,32))
		self.app.setWindowIcon(app_icon)

		self.main_windows.show()

		self.connectionGUI()

	def runEventLoop(self):
		# Main event loop
		try:
			self.app.exec_()
		except Exception as e:
			print("XEM_GUI3.py: Exception during app.exec_():")
			self.logger.error('Red_Pitaya_GUI{}: Exception during app.exec_():{}'.format(self.logger_name, e))
			print(e)

	def loadDefaultValueFromConfigFile(self, strSelectedSerial, bSendToFPGA = True):
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
				self.sp.populateDefaults()
		
		# self.sp.loadDefaults()
		# self.sp.saveToFile('system_parameters_current.xml')

		self.sp.sendToFPGA(self.sl, bSendToFPGA)

	def setCustomShorthand(self, strSelectedSerial):
		# The shorthand name which gets added to the window names:
		try:
			# custom_shorthand = self.devices_data[self.initial_config.strSelectedSerial]['shorthand']
			custom_shorthand = self.devices_data[strSelectedSerial]['shorthand']
		except KeyError:
			custom_shorthand = ''
			self.logger_name = ''

		self.main_windows.setWindowTitle(custom_shorthand)
		self.xem_gui_mainwindow2.strTitle = custom_shorthand + ': Optical lock'
		self.xem_gui_mainwindow.strTitle = custom_shorthand + ': CEO lock'
		self.counters_window.strTitle = custom_shorthand + ': Frequency counters'

		self.xem_gui_mainwindow2.logger_name = ':' + custom_shorthand + ':Optical lock'
		self.xem_gui_mainwindow.logger_name = ':' + custom_shorthand + ':CEO lock'
		self.freq_error_window1.logger_name = ':' + custom_shorthand + ': Frequency counters'
		self.freq_error_window2.logger_name = ':' + custom_shorthand + ': Frequency counters'
		
	def setCustomStyleSheet(self, strSelectedSerial):
		# Style sheet which includes the color scheme for each specific box:
		try:
			# custom_style_sheet = ('#MainWindow {color: white; background-color: %s;}' % self.devices_data[self.initial_config.strSelectedSerial]['color'])
			custom_style_sheet = ('#MainWindow {color: white; background-color: %s;}' % self.devices_data[strSelectedSerial]['color'])
		except KeyError:
			custom_style_sheet = ''

		target_windows = [
			self.divider_settings_window,
			self.freq_error_window1,
			self.freq_error_window2,
			self.xem_gui_mainwindow2,
			self.xem_gui_mainwindow,
			self.counters_window,
			self.dither_widget0,
			self.dither_widget1,
			self.RP_Settings,
			self.settings_window,
			self.main_windows
			]

		for window in target_windows:
			window.setStyleSheet(custom_style_sheet)

	def setTemperatureControlPort(self, strSelectedSerial):
		try:
			port_number = self.devices_data[strSelectedSerial]['port_temp']
		except Exception:
			port_number = 0
			self.logger.warning('Red_Pitaya_GUI{}: Could not get temperature control port'.format(self.logger_name))

		self.freq_error_window2.port_number = int(port_number)

	def pushDefaultValues(self, strSelectedSerial = "000000000000", ip_addr = "192.168.0.150", port=5000):
		self.strSelectedSerial = strSelectedSerial
		self.ip_addr           = ip_addr
		self.port              = port

		self.setCustomStyleSheet(strSelectedSerial)
		self.setCustomShorthand(strSelectedSerial)

		self.logger.info('Red_Pitaya_GUI{}: Pushing default values from xml file'.format(self.logger_name))
		if self.sl.dev.valid_socket:
			self.sl.dev.CloseTCPConnection()
			
		self.sl.dev.OpenTCPConnection(ip_addr, port)
		if not self.sl.dev.valid_socket:
			self.logger.error('Connection to host %s, port %s failed.' % (ip_addr, port))
			return
		# Now we just need to reset the frontend to make sure we start everything in a nice state
		self.sl.resetFrontend()

		self.loadDefaultValueFromConfigFile(strSelectedSerial, True)
		
		target_windows = [
			self.xem_gui_mainwindow2,
			self.xem_gui_mainwindow,
			self.freq_error_window1,
			self.freq_error_window2,
			self.RP_Settings,
			self.divider_settings_window,
			self.dither_widget0,
			self.dither_widget1,
		]

		for window in target_windows:
			window.pushDefaultValues()
		

		self.setTemperatureControlPort(strSelectedSerial)

	def getActualValues(self, strSelectedSerial, ip_addr = "192.168.0.150", port=5000):

		if self.sl.dev.valid_socket:
			self.sl.dev.CloseTCPConnection()

		self.sl.dev.OpenTCPConnection(ip_addr, port)
		if self.sl.dev.valid_socket == False:
			logging.error('Connection failed.')
			return

		self.logger.info('Red_Pitaya_GUI{}: Updating GUI from FPGA'.format(self.logger_name))

		self.strSelectedSerial = strSelectedSerial
		self.ip_addr           = ip_addr
		self.port              = port

		print("getActualValues: strSelectedSerial = %s" % strSelectedSerial)
		# pdb.set_trace()
		self.setCustomStyleSheet(strSelectedSerial)
		self.setCustomShorthand(strSelectedSerial)

		self.loadDefaultValueFromConfigFile(strSelectedSerial, False) #read xml file to update some values. False means not updating the FPGA

		target_windows = [
			self.xem_gui_mainwindow2,
			self.xem_gui_mainwindow,
			self.freq_error_window1,
			self.freq_error_window2,
			self.RP_Settings,
			self.divider_settings_window,
			self.dither_widget0,
			self.dither_widget1,
		]

		for window in target_windows:
			window.getValues()

		self.setTemperatureControlPort(strSelectedSerial)

	def pushActualValues(self, strSelectedSerial, ip_addr = "192.168.0.150", port=5000):
		self.strSelectedSerial = strSelectedSerial
		self.ip_addr           = ip_addr
		self.port              = port

		self.setCustomStyleSheet(strSelectedSerial)
		self.setCustomShorthand(strSelectedSerial)

		self.logger.info('Red_Pitaya_GUI{}: Pushing actual values from GUI'.format(self.logger_name))

		if self.sl.dev.valid_socket:
			self.sl.dev.CloseTCPConnection()
		self.sl.dev.OpenTCPConnection(ip_addr, port)

		target_windows = [
			self.xem_gui_mainwindow2,
			self.xem_gui_mainwindow,
			self.freq_error_window1,
			self.freq_error_window2,
		]

		for window in target_windows:
			window.pushActualValues()


		self.setTemperatureControlPort(strSelectedSerial)

	def stopCommunication(self):

		self.logger.info('Red_Pitaya_GUI{}: Closing connection'.format(self.logger_name))

		if self.timerReconnect is not None:
			self.timerReconnect = None

		self.sl.dev.CloseTCPConnection()

		try:
			self.xem_gui_mainwindow2.killTimers()
			self.xem_gui_mainwindow.killTimers()
			self.freq_error_window1.killTimers()
			self.freq_error_window2.killTimers()
			self.RP_Settings.killTimers()
		except Exception as e:
			print("Error while killing the timers:")
			print(e)

	def socketErrorEvent(self, e):
		print("XEM_GUI3.py:Controller::socketErrorEvent()")
		# this gets called by the socket-using functions in RP_PLL
		# in the event of a socket exception, while we thought we had a valid connection
		# The right things to do in this case is to:
		# -drop the current socket (because the data stream is left in an uncertain state)
		# -start a reconnection timer that will attempt to reconnect automatically
		# -raise a CommsLoggeableError

		# check if we need to start the reconnection attempt timer:
		if self.timerReconnect is None:
			# disconnect from socket, and start reconnection timer:
			self.stopCommunication()

			print("TCP connection lost. Starting reconnection timer")
			self.timerReconnect = QtCore.QTimer()
			self.reconnection_attempts = 0
			self.timerReconnect.timeout.connect(self.reconnectionAttempt)
			self.timerReconnect.start(3000) # 3000 ms update period (needs to be longer than the delay...)

			raise CommsLoggeableError

		# target_windows = [
		# 	self.xem_gui_mainwindow2,
		# 	self.xem_gui_mainwindow,
		# 	self.freq_error_window1,
		# 	self.freq_error_window2,
		# 	self.RP_Settings
		# ]
		# print("startCommunication")

	def reconnectionAttempt(self):
		self.reconnection_attempts += 1
		# print("TCP connection lost. Attempting to reconnect %d." % (self.reconnection_attempts))

		try:
			self.getActualValues(self.strSelectedSerial, self.ip_addr, self.port)
		except:
			print("Reconnection attempt #%d failed." % self.reconnection_attempts)
			self.logger.error(traceback.format_exc())

		if self.sl.dev.valid_socket:
			# success!
			self.timerReconnect.stop()
			self.timerReconnect = None
			return

		if self.reconnection_attempts == 10:
			# switch to a longer timer between reconnection attempt:
			print("%d failed reconnection attempts. Switching to 10 secs between attempts." % self.reconnection_attempts)
			self.timerReconnect.stop()
			self.timerReconnect.start(10000) # 10 seconds update period

if __name__ == '__main__':
	# pbd.run('controller()')
	print("main: about to create controller instance")
	controller_obj = controller()
	# This code here is to handle weird interaction between IPython's event handler:
	# Depending on the setting for the graphical backend in Spyder (Tools/Preferences/IPython Console/Graphics/Backend = (Automatic or Inline),
	# the Qt event loop might be already running, so the proper way to teardown our application,
	# for example to enable re-using the same console to run another instance afterwards,
	# is different.
	if controller_obj.bEventLoopWasRunningAlready == False:
		controller_obj.stopCommunication()
		del controller_obj
	