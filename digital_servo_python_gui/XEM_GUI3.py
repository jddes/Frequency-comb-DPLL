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

import pdb

import socket

class controller(object):
	"""Main class of the GUI. It contains most of the elements of the GUI, the main_window and the communication class"""
	def __init__(self):
		print("controller::__init__()")
		# Create the object that handles the communication with the FPGA board:
		self.sl = SuperLaserLand_JD_RP(self)
		self.updateDeviceData()

		self.sp = SLLSystemParameters()

		# Start Qt:
		self.app = QtCore.QCoreApplication.instance()
		if self.app is None:
			print("QCoreApplication not running yet. creating.")
			self.bEventLoopWasRunningAlready = False
			self.app = QtWidgets.QApplication(sys.argv)
		else:
			self.bEventLoopWasRunningAlready = True
			print("QCoreApplication already running.")


		self.main()


	def updateDeviceData(self):
		# Hardcoded dictionnary containing the known Red Pitaya
		# TO DO : xml file, user can add RP from the GUI?
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
		strFPGAFirmware=r'red_pitaya_top.bit'
		strCPUFirmware=u'monitor-tcp'
		self.initial_config = initialConfiguration(self.sl.dev, self, self.devices_data, strBroadcastAddress, strFPGAFirmware, strCPUFirmware)
		

	def main(self):

		# Start the User Interface
		bTriggerEvents = False
		bConnectedRP = False
		self.strSelectedSerial = "000000000000"

		bUpdateFPGA = bTriggerEvents
		bSendToFPGA = bTriggerEvents

		
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
		self.xem_gui_mainwindow2 = XEM_GUI_MainWindow(self.sl, custom_shorthand + ': Optical lock', 1, (False, True, False), self.sp, custom_style_sheet, self.strSelectedSerial)
		
		# CEO Lock window
		self.xem_gui_mainwindow = XEM_GUI_MainWindow(self.sl, custom_shorthand + ': CEO lock', 0, (True, False, False), self.sp, custom_style_sheet, self.strSelectedSerial)

		
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
		
		self.main_windows.show()

		
		self.connectionGUI()
		
		# Enter main event loop
		# print("before app.exec_()")
		# self.app.exec_()
		# print("after app.exec_()")
		try:
			print("before app.exec_()")
			self.app.exec_()
			print("after app.exec_()")
		except Exception as e:
			print("XEM_GUI3.py: Exception during app.exec_():")
			print(e)


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


	def pushDefaultValues(self, strSelectedSerial = "000000000000", ip_addr = "192.168.0.150", port=5000):
		self.setCustomStyleSheet(strSelectedSerial)

		if self.sl.dev.valid_socket:
			self.sl.dev.CloseTCPConnection()
			
		self.sl.dev.OpenTCPConnection(ip_addr, port)
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

	def pushActualValues(self, strSelectedSerial, ip_addr = "192.168.0.150", port=5000):
		self.setCustomStyleSheet(strSelectedSerial)

		if self.sl.dev.valid_socket:
			self.sl.dev.CloseTCPConnection()
		self.sl.dev.OpenTCPConnection(ip_addr, port)



		self.xem_gui_mainwindow2.pushActualValues()
		self.xem_gui_mainwindow.pushActualValues()
		self.freq_error_window1.pushValues()
		self.freq_error_window2.pushValues()

	def getActualValues(self, strSelectedSerial, ip_addr = "192.168.0.150", port=5000):
		self.setCustomStyleSheet(strSelectedSerial)
		if self.sl.dev.valid_socket:
			self.sl.dev.CloseTCPConnection()
		self.sl.dev.OpenTCPConnection(ip_addr, port)

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
		except Exception as e:
			print("Error while killing the timers:")
			print(e)

	def startCommunication(self, ip_addr = "192.168.0.150", port=5000):
		self.sl.dev.OpenTCPConnection(ip_addr, port)
		self.xem_gui_mainwindow2.startTimers()
		self.xem_gui_mainwindow.startTimers()
		self.freq_error_window1.startTimers()
		self.freq_error_window2.startTimers()



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
	