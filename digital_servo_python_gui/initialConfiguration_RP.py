# -*- coding: utf-8 -*-
"""
Created on Fri Aug 26 00:26:50 2016

@author: JD
"""
from __future__ import print_function

import sys
from PyQt5 import QtGui, Qt, QtCore, QtWidgets
#import numpy as np
import UDPRedPitayaDiscovery

import time

from RP_PLL import RP_PLL_device # needed to update FPGA firmware and CPU (Zynq) software
import socket
import weakref

import pdb

import logging

class initialConfiguration(QtWidgets.QDialog):
	

		
	def __init__(self, dev, controller, devices_data={}, strBroadcastAddress="192.168.2.255", strFPGAFirmware='', strCPUFirmware=''):
		super(initialConfiguration, self).__init__()
		
		self.logger = logging.getLogger(__name__)
		self.logger_name = ':initialConfiguration'
		# copy init parameters to member variables
		self.dev = dev
		self.strBroadcastAddress = strBroadcastAddress
		self.strFPGAFirmware = strFPGAFirmware
		self.strCPUFirmware = strCPUFirmware
		self.devices_data = devices_data
		
		# we gather all RP data (IP, MAC, item index) tuples in this list:
		self.strSerialList = []
		
		
		# these are used as a form of "return values" of this dialog:
		self.bOk = False
		self.bSendDefaultValues = False
		self.strSelectedMAC = ''
		self.strSelectedIP = ''
		
		if controller is not None:
			self.controller = weakref.proxy(controller)

		# create the UDP discovery object:
		self.udp_discovery = UDPRedPitayaDiscovery.UDPRedPitayaDiscovery(self.strBroadcastAddress)
		self.reset_list_and_send_broadcast()
		self.timerID = self.startTimer(int(100))
		
#        print 'before check_answers'
#        (strIP, strMAC) = self.udp_discovery.check_answers()
#        print 'after check_answers'
		self.initUI()
		
		

	def initUI(self):
		# init the UI
		self.qlabel_serial = Qt.QLabel('Connected FPGAs')
		self.qlabel_broadcast = Qt.QLabel('UDP Broadcast address')
		self.qlabel_firmware = Qt.QLabel('FPGA Firmware file')
		self.qlabel_software = Qt.QLabel('CPU Software file')
		self.qcombo_serial = Qt.QComboBox()
		self.qcombo_serial.setMinimumContentsLength(100)    # I can't figure out how to make it scale correctly with content so we'll make it big enough...
		self.qcombo_serial.setSizeAdjustPolicy(Qt.QComboBox.AdjustToMinimumContentsLength)
		
		self.qedit_broadcast = Qt.QLineEdit(self.strBroadcastAddress)
		self.qedit_firmware = Qt.QLineEdit(self.strFPGAFirmware)
		self.qedit_software = Qt.QLineEdit(self.strCPUFirmware)
		
		self.qbtn_send_broadcast = Qt.QPushButton('Broadcast discovery packet')
		self.qbtn_reprogram_fpga = Qt.QPushButton('Update FPGA firmware')
		self.qbtn_reprogram_cpu = Qt.QPushButton('Update CPU software')
		self.qbtn_send_broadcast.clicked.connect(self.reset_list_and_send_broadcast)
		self.qbtn_reprogram_fpga.clicked.connect(self.programFPGAClicked)
		self.qbtn_reprogram_cpu.clicked.connect(self.programCPUClicked)
		
		self.qradio_reprogram = Qt.QRadioButton('Send default values')
		self.qradio_noreprogram = Qt.QRadioButton('Connect to an already running box')
		self.qradio_reprogram.setChecked(True)
		
		self.qradio_noreprogram.setDisabled(True)
		
		btn_group = Qt.QButtonGroup(self)
		btn_group.addButton(self.qradio_reprogram)
		btn_group.setId(self.qradio_reprogram, 0)
		btn_group.addButton(self.qradio_noreprogram)
		btn_group.setId(self.qradio_noreprogram, 1)

		# btn_group2 = Qt.QButtonGroup(self)
		# btn_group2.addButton(self.qradio_usefromlist)
		# btn_group2.setId(self.qradio_usefromlist, 0)
		# btn_group2.addButton(self.qradio_usefromtextbox)
		# btn_group2.setId(self.qradio_usefromtextbox, 1)


		
		self.qbtn_yes = Qt.QPushButton('OK')
		self.qbtn_no = Qt.QPushButton('Cancel')
	
		self.qbtn_yes.clicked.connect(self.okClicked)
		self.qbtn_no.clicked.connect(self.cancelClicked)
		
		
		self.qgroupbox_IP_addr = Qt.QGroupBox('IP Address')
		gridIP = Qt.QGridLayout()



		self.qradio_usefromlist = Qt.QRadioButton('Use listed')
		self.qradio_usefromtextbox = Qt.QRadioButton('Use manual entry')
		self.qradio_usefromtextbox.setChecked(False)
		self.qradio_usefromlist.setChecked(True)

		self.qlabel_manual_entry = Qt.QLabel('Manual IP entry')
		self.qedit_manual_entry = Qt.QLineEdit('192.168.0.150')

		self.qlabel_host_port = Qt.QLabel('Host Port')
		self.qedit_host_port = Qt.QLineEdit('5000')


		gridIP.addWidget(self.qradio_usefromtextbox, 0, 0)
		gridIP.addWidget(self.qlabel_manual_entry, 0, 1)
		gridIP.addWidget(self.qedit_manual_entry, 0, 2)

		gridIP.addWidget(self.qlabel_host_port, 0, 3)
		gridIP.addWidget(self.qedit_host_port, 0, 4)

	

		gridIP.addWidget(self.qradio_usefromlist, 1, 0)
		gridIP.addWidget(self.qlabel_serial, 1, 1)
		gridIP.addWidget(self.qcombo_serial, 1, 2)

		gridIP.addWidget(self.qbtn_send_broadcast, 2, 0)
		gridIP.addWidget(self.qlabel_broadcast, 2, 1)
		gridIP.addWidget(self.qedit_broadcast, 2, 2)

		self.qgroupbox_IP_addr.setLayout(gridIP)
		

		self.qgroupbox_connection = Qt.QGroupBox('Red Pitaya Connection')
		gridConnection = Qt.QGridLayout()

		self.qradio_pushValue = Qt.QRadioButton('Push default values to Red Pitaya')
		self.qradio_existingRP = Qt.QRadioButton('Reconnect to an already running Red Pitaya')
		self.qradio_noRP = Qt.QRadioButton('Open the GUI without any Red Pitaya')
		self.qradio_existingRP.setChecked(True)

		gridConnection.addWidget(self.qradio_pushValue,		0, 0)
		gridConnection.addWidget(self.qradio_existingRP, 	0, 1)
		gridConnection.addWidget(self.qradio_noRP, 			0, 2)

		self.qgroupbox_connection.setLayout(gridConnection)

#        btn_group2 = Qt.QButtonGroup(self)
#        btn_group2.addButton(self.qradio_clk_internal)
#        btn_group2.addButton(self.qradio_clk_external)
#        btn_group2.setId(self.qradio_clk_internal, 2)
#        btn_group2.setId(self.qradio_clk_external, 3)
#        self.close.connect(self.closeEvent)
		
		grid = Qt.QGridLayout()
		
		grid.addWidget(self.qgroupbox_IP_addr, 2, 0, 1, 3)
		
		grid.addWidget(self.qgroupbox_connection, 0, 0, 1, 3)

		grid.addWidget(self.qbtn_reprogram_fpga, 3, 0)
		grid.addWidget(self.qlabel_firmware, 3, 1)
		grid.addWidget(self.qedit_firmware, 3, 2)
		
		grid.addWidget(self.qbtn_reprogram_cpu, 4, 0)
		grid.addWidget(self.qlabel_software, 4, 1)
		grid.addWidget(self.qedit_software, 4, 2)
		
		
#        #FEATURE
#        grid.addWidget(self.qradio_reprogram, 4, 0)
#        grid.addWidget(self.qradio_noreprogram, 4, 1)
		
#        grid.addWidget(self.qradio_clk_internal, 3, 0)
#        grid.addWidget(self.qradio_clk_external, 3, 1)
		
#        grid.addWidget(self.qbtn_yes, 4, 0)
#        grid.addWidget(self.qbtn_no, 4, 1)
		hbox = Qt.QHBoxLayout()
		hbox.addStretch(1)
		hbox.addWidget(self.qbtn_yes)
		hbox.addWidget(self.qbtn_no)
		grid.addLayout(hbox, 5, 0, 1, 3)
		
		
		self.setLayout(grid)
		self.setWindowTitle('Initial configuration')
		self.qbtn_yes.setFocus()
		self.show()

		
	def reset_list_and_send_broadcast(self):

		# clear the list if it exists
		self.strSerialList
		try:
			self.qcombo_serial.clear()
			pass
		except AttributeError:
			pass
		
		# we need to reconnect the UDP discovery socket everytime we change our broadcast address
		try:
			self.udp_discovery.broadcast_address = self.qedit_broadcast.text()
			self.udp_discovery.connectClientSocket()
		except AttributeError:
			pass
		# send a broadcast packet to start building the list:
		try:
			self.udp_discovery.send_broadcast()
		except Exception as e:
			print('Exception when sending UDP broadcast packet')
			print(e)

		
	def MAC_to_display_string(self, strMAC, strIP):
		# build the string that we will display to the user in the combo box:
		strDisplay = ''
		#print('MAC_to_display_string: %s, %s' % (strMAC, strIP))
		#print(self.devices_data)

		try:
			box_name = self.devices_data[strMAC.replace(':', '')]['name']
		except KeyError:
			box_name = ''
			pass
		
		try:
			box_color = self.devices_data[strMAC.replace(':', '')]['color']
		except KeyError:
			box_color = ''
			pass
		
		strDisplay = 'Name = %s, IP = %s, MAC = %s, Color = %s' % (box_name, strIP, strMAC, box_color)
		return strDisplay
		
	def timerEvent(self, e):
		# check if there are any answers to the broadcast packet
		try:
			(strIP, strMAC) = self.udp_discovery.check_answers()
		except AttributeError:
			return
		except Exception as e:
			print('Exception when checking answers to broadcast packet')
			print(e)
			return


		# iterate over answers
		while (strIP is not None):
			
			# build the string that we will display to the user in the combo box:
			strDisplay = self.MAC_to_display_string(strMAC, strIP)
			
			self.strSerialList.append((strIP, strMAC))
			self.qcombo_serial.addItem(strDisplay)
#            print self.qcombo_serial.sizeAdjustPolicy()
#            print self.qcombo_serial.minimumSizeHint()
			
			# for the next iteration:
			# check if there are any answers to the broadcast packet
			(strIP, strMAC) = self.udp_discovery.check_answers()
			
			time.sleep(0.1)

	def readSelectedFPGA(self):
		self.strSelectedIP = ''
		self.strSelectedMAC = ''
		self.strSelectedSerial = ''
		self.strSelectedPort = 5000

		# do we use the manual entry IP address or the one from the list?
		if self.qradio_usefromlist.isChecked():
			# use IP from list
			try:
				(strIP, strMAC) = self.strSerialList[self.qcombo_serial.currentIndex()]
				self.strSelectedSerial = strMAC.replace(':', '') # this is just for legacy compatibility, when we had actual serial numbers
				self.strSelectedMAC = strMAC
				self.strSelectedIP = strIP
				# print(strMAC)
				# print(strIP)
				
			except IndexError:
				# nothing bad happened, we probably simply had an empty list
				print("Error: no selected RedPitaya.")
				pass

		else:
			# use manual entry IP address
			# we don't have a good way of populating the MAC and serial number yet using this manual connection
			self.strSelectedIP = str(self.qedit_manual_entry.text())
			self.strSelectedPort = int(self.qedit_host_port.text())
		
	def okClicked(self):
		self.bOk = True
		self.bContinue = True

		self.strFPGAFirmware = (self.qedit_firmware.text())  # the str() is to convert the QString to a normal Python string object
		self.strCPUFirmware  = (self.qedit_software.text())  # the str() is to convert the QString to a normal Python string object
		

		self.bSendDefaultValues  = self.qradio_reprogram.isChecked()
#        self.bExternalClock = self.qradio_clk_external.isChecked()

		#print(self.strSelectedIP)

		if self.qradio_pushValue.isChecked():
			# connect to the selected RedPitaya.
			self.readSelectedFPGA()
			# print("initialConfiguration.py::okClicked():after readSelectedFPGA")
			if not self.strSelectedIP:
				#print("No selected IP: returning")
				return
			#self.dev.OpenTCPConnection(self.strSelectedIP)
			if self.controller is not None:
				self.controller.pushDefaultValues(self.strSelectedSerial, self.strSelectedIP, self.strSelectedPort)
			#print("initialConfiguration.py::okClicked():after pushDefaultValues")

		elif self.qradio_existingRP.isChecked():
			# Reconnect to the selected RedPitaya.
			print("2")
			self.readSelectedFPGA()
			print("initialConfiguration.py::okClicked():after readSelectedFPGA")
			if not self.strSelectedIP:
				#print("No selected IP: returning")
				return
			print("About to reconnect")
			if self.controller is not None:
				self.controller.getActualValues(self.strSelectedSerial, self.strSelectedIP, self.strSelectedPort)
			print("initialConfiguration.py::okClicked():after getActualValues")

		elif self.qradio_noRP.isChecked():
			#print("3")
			# Open the GUI without any RP
			print("WARNING! The socket has been replaced with a fake one, there might be some problems.")

			if self.controller is not None:
				self.controller.stopCommunication() #Call the function which kill the timers and call the fake socket

		# close UDP discovery server:
		self.killTimer(self.timerID)    # is it guaranteed that no timerEvent will be called after this line? because we delete our reference to udp_discovery, which is used in the timer event
		del self.udp_discovery

		#print("initialConfiguration.py::okClicked():close")
		self.close()
		#self.controller.pushDefaultValues(self.strSelectedIP)

		#self.controller.main()
		
	def programFPGAClicked(self):
		self.readSelectedFPGA()
		if not self.strSelectedIP:
			print("Error: no selected RedPitaya.")
			return

		self.logger.info('Red_Pitaya_GUI{}: Programming FPGA ({}) with new bitfile'.format(self.logger_name, self.strSelectedPort))

		# connect to the selected RedPitaya, send new bitfile, then send programming command to the shell:
		self.dev.OpenTCPConnection(self.strSelectedIP, self.strSelectedPort)
		self.dev.write_file_on_remote(strFilenameLocal=str(self.qedit_firmware.text()), strFilenameRemote='/opt/red_pitaya_top.bit')
		time.sleep(2) # to handle slow SD cards
		print("File written to remote host at /opt/red_pitaya_top.bit.")

		self.dev.send_shell_command('cat /opt/red_pitaya_top.bit > /dev/xdevcfg')
		print("Program FPGA firmware command sent.")
		
		# disconnect:
		self.dev.sock.shutdown(socket.SHUT_RDWR)
		self.dev.sock.close()
		print("Disconnected from remote host.  You can now reconnect to the updated host.")
		
		
	def programCPUClicked(self):
		self.readSelectedFPGA()
		if not self.strSelectedIP:
			print("Error: no selected RedPitaya.")
			return

		self.logger.info('Red_Pitaya_GUI{}: Programming CPU ({}) with new file'.format(self.logger_name, self.strSelectedPort))

		# connect to the selected RedPitaya
		self.dev.OpenTCPConnection(self.strSelectedIP, self.strSelectedPort)
		# send new monitor-tcp version
		self.dev.write_file_on_remote(strFilenameLocal=self.qedit_software.text(), strFilenameRemote='/opt/monitor-tcp-new')
		print("CPU software update sent. Rebooting server using new version")
		
		# set executable permissions
		self.dev.send_shell_command('chmod +x /opt/monitor-tcp-new')
		# copy over old file
		self.dev.send_shell_command('mv /opt/monitor-tcp-new /opt/monitor-tcp')
		
		# send "reboot monitor-tcp" command
		self.dev.send_reboot_command()
		self.dev.sock.shutdown(socket.SHUT_RDWR)
		self.dev.sock.close()
		
		time.sleep(1) # give some time for tcp server to come back up
		print("CPU software update complete.")
		pass

	def cancelClicked(self):
		self.bOk = False
		# close UDP discovery server:
		self.killTimer(self.timerID)    # is it guaranteed that no timerEvent will be called after this line? because we delete our reference to udp_discovery, which is used in the timer event
		del self.udp_discovery

		self.close()
		
	def closeEvent(self, e):
		try:
			del self.udp_discovery
		except AttributeError:
			# Means that we deleted the object already
			pass
		return

def main():

	###########################################################################
	# Start the User Interface
	
	
	# Start Qt:
	app = QtCore.QCoreApplication.instance()
	if app is None:
		app = QtWidgets.QApplication(sys.argv)
	
	# Load a first window which asks the user a question
	# Specify the mapping between the MAC addresses (which are used as a form of serial numbers) and the box data
	devices_data = {}
	devices_data[''] = {'color': '#1CC981',
						'name': 'Red Pitaya 1',
						'shorthand': 'RP 1',
						'config file': 'system_parameters_RP_1.xml',
						#'port': 60002
						}
						
	strFPGAFirmware=r'D:\Projects\RedPitaya\fpga\project\redpitaya.runs\impl_1\red_pitaya_top.bit'
	strCPUFirmware=u'D:\\Université\\Dropbox\\22_H2015\\Red Pitaya\\monitor-tcp\\monitor-tcp'
	dev = RP_PLL_device()
	initial_config = initialConfiguration(dev, None, devices_data=devices_data, strFPGAFirmware=strFPGAFirmware, strCPUFirmware=strCPUFirmware)
	# Run the event loop for this window
	app.exec_()
	print("app.exec_ returned.")
	print(initial_config.bOk)
	print(initial_config.bSendDefaultValues)
	print(initial_config.strSelectedMAC)
	print(initial_config.strSelectedIP)
	
#    question = initialConfiguration()

	
	# Enter main event loop
#    app.exec_()

if __name__ == '__main__':
	main()     