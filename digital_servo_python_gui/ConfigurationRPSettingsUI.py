# -*- coding: utf-8 -*-
"""
June 2017

Description: Provides a graphical user interface (GUI) to configure the RP 
@author: Alex Tourigny-Plante
"""

from PyQt5 import QtGui, Qt, QtCore, QtWidgets
#import PyQt4.Qwt5 as Qwt
import numpy as np
import weakref
import sys

import traceback

from user_friendly_QLineEdit import user_friendly_QLineEdit


from SuperLaserLand_JD_RP import SuperLaserLand_JD_RP


class ConfigRPSettingsUI(Qt.QWidget):
	"""docstring for ConfigRP"""
	def __init__(self, sl, sp, controller, custom_style_sheet='', custom_shorthand=''):
		super(ConfigRPSettingsUI, self).__init__()  
		self.sl = weakref.proxy(sl)
		self.sp = sp
		self.setObjectName('MainWindow')
		self.setStyleSheet(custom_style_sheet)
		self.custom_shorthand = custom_shorthand

		self.controller = weakref.proxy(controller) #link to the top class

		self.initUI()
		self.loadParameters()

	def loadParameters(self):
		#print("ConfigurationRPSettingsUI::loadParameters()")
		# Load the default parameters from the selected xml file (select by the devices_data dictionnary in the controller class)
		fan_state = int((self.sp.getValue('RP_settings', "Fan_state")))
		mux_pll2 = int((self.sp.getValue('RP_settings', "PLL2_connection")))
		mux_vco = int((self.sp.getValue('VCO_settings', "VCO_connection")))
		vco_amplitude = float((self.sp.getValue('VCO_settings', "VCO_amplitude")))
		vco_offset = float((self.sp.getValue('VCO_settings', "VCO_offset")))

		#print("ConfigurationRPSettingsUI::loadParameters(): after read GUI")

		if fan_state > 0:
			self.qradio_fan_on.setChecked(True)
		else:
			self.qradio_fan_off.setChecked(True)

		if mux_pll2 == 1:
			self.qradio_ddc1_to_pll2.setChecked(True)
		elif mux_pll2 == 2:
			self.qradio_pll1_to_pll2.setChecked(True)
		else:
			self.qradio_ddc2_to_pll2.setChecked(True)

		if mux_vco == 1:
			self.qradio_VCO_to_DAC0.setChecked(True)
		elif mux_vco == 2:
			self.qradio_VCO_to_DAC1.setChecked(True)
		else:
			self.qradio_no_VCO.setChecked(True)

		self.qedit_int_vco_amplitude.blockSignals(True)
		self.qedit_int_vco_amplitude.setText('{:.3f}'.format(vco_amplitude))
		self.qedit_int_vco_amplitude.blockSignals(False)

		self.qedit_int_vco_offset.blockSignals(True)
		self.qedit_int_vco_offset.setText('{:.3f}'.format(vco_offset))
		self.qedit_int_vco_offset.blockSignals(False)

		#print("ConfigurationRPSettingsUI::loadParameters(): end")

	def pushDefaultValues(self):
		# Push the values from the xml file to the red pitaya (load + send)
		self.loadParameters()
		self.pushValues()

	def pushValues(self):
		# Send the values in the different fields to the RP
		self.mux_vco_Action()
		self.mux_pll2_Action()
		self.setInternalVCO_amplitude()
		self.setFan()

	def getValues(self):
		#get value from the memory of the red pitaya 

		#get value for the VCO connection
		mux_vco = self.sl.get_mux_vco()
		if mux_vco == 1:
			self.qradio_VCO_to_DAC0.setChecked(True)
		elif mux_vco == 2:
			self.qradio_VCO_to_DAC1.setChecked(True)
		else:
			self.qradio_no_VCO.setChecked(True)

		#get value for the VCO amplitude
		amplitude = self.sl.get_internal_VCO_amplitude()
		self.qedit_int_vco_amplitude.blockSignals(True)
		self.qedit_int_vco_amplitude.setText('{:.3f}'.format(amplitude))
		self.qedit_int_vco_amplitude.blockSignals(False)

		#get value for the VCO offset
		offset = self.sl.get_internal_VCO_offset()
		self.qedit_int_vco_offset.blockSignals(True)
		self.qedit_int_vco_offset.setText('{:.3f}'.format(offset))
		self.qedit_int_vco_offset.blockSignals(False)

		#get value for the pll2 connection
		mux_pll2 = self.sl.read_pll2_mux()
		if mux_pll2 == 0:
			self.qradio_ddc2_to_pll2.setChecked(True)
		elif mux_pll2 == 1:
			self.qradio_ddc1_to_pll2.setChecked(True)
		elif mux_pll2 == 2:
			self.qradio_pll1_to_pll2.setChecked(True)
		


	def initUI(self):

		self.qgroupbox_MUX_vco = Qt.QGroupBox('Select VCO connection')
		self.qgroupbox_MUX_vco.setAutoFillBackground(True)
		MUX_vco = Qt.QGridLayout()

		self.qradio_VCO_to_DAC0 = Qt.QRadioButton('VCO connected to DAC A')
		self.qradio_VCO_to_DAC1 = Qt.QRadioButton('VCO connected to DAC B')
		self.qradio_no_VCO = Qt.QRadioButton('VCO not connected')
		self.qradio_no_VCO.setChecked(True)
		self.qradio_VCO_to_DAC0.clicked.connect(self.mux_vco_Action)
		self.qradio_VCO_to_DAC1.clicked.connect(self.mux_vco_Action)
		self.qradio_no_VCO.clicked.connect(self.mux_vco_Action)

		self.qlabel_int_vco_amplitude = Qt.QLabel('Internal VCO Amplitude [0-1]')
		self.qedit_int_vco_amplitude = user_friendly_QLineEdit('0.5')
		self.qedit_int_vco_amplitude.returnPressed.connect(self.setInternalVCO_amplitude)
		self.qedit_int_vco_amplitude.setMaximumWidth(100)

		self.qlabel_int_vco_offset = Qt.QLabel('Internal VCO offset [0-1]')
		self.qedit_int_vco_offset = user_friendly_QLineEdit('0.0')
		self.qedit_int_vco_offset.returnPressed.connect(self.setInternalVCO_offset)
		self.qedit_int_vco_offset.setMaximumWidth(60)

		MUX_vco.addWidget(self.qradio_VCO_to_DAC0,	 0, 0)	
		MUX_vco.addWidget(self.qradio_VCO_to_DAC1,	 1, 0)
		MUX_vco.addWidget(self.qradio_no_VCO, 		 2, 0)
		MUX_vco.addWidget(self.qlabel_int_vco_offset, 1,1)
		MUX_vco.addWidget(self.qedit_int_vco_offset, 1,2)
		MUX_vco.addWidget(self.qlabel_int_vco_amplitude, 2,1)
		MUX_vco.addWidget(self.qedit_int_vco_amplitude, 2,2)
		MUX_vco.addItem(Qt.QSpacerItem(0, 0, Qt.QSizePolicy.MinimumExpanding, Qt.QSizePolicy.Minimum), 2, 0)
		MUX_vco.setRowStretch(2, 2)

		self.qgroupbox_MUX_vco.setLayout(MUX_vco)

		###################################################################################
		self.qgroupbox_MUX_pll2 = Qt.QGroupBox('Select connection to PLL 2')
		self.qgroupbox_MUX_pll2.setAutoFillBackground(True)
		MUX_pll2 = Qt.QGridLayout()

		self.qradio_ddc1_to_pll2 = Qt.QRadioButton('DDC_a output to PLL_b input')
		self.qradio_pll1_to_pll2 = Qt.QRadioButton('DAC_a output to PLL_b input (cascade lock)')
		self.qradio_ddc2_to_pll2 = Qt.QRadioButton('DDC_b output to PLL_b input')
		self.qradio_ddc2_to_pll2.setChecked(True)
		self.qradio_pll1_to_pll2.clicked.connect(self.mux_pll2_Action)
		self.qradio_ddc1_to_pll2.clicked.connect(self.mux_pll2_Action)
		self.qradio_ddc2_to_pll2.clicked.connect(self.mux_pll2_Action)

		MUX_pll2.addWidget(self.qradio_ddc1_to_pll2, 	0, 0)
		MUX_pll2.addWidget(self.qradio_pll1_to_pll2, 	1, 0)
		MUX_pll2.addWidget(self.qradio_ddc2_to_pll2, 	2, 0)
		MUX_pll2.setRowStretch(2, 0)

		self.qgroupbox_MUX_pll2.setLayout(MUX_pll2)


		###################################################################################
		self.qgroupbox_read_data = Qt.QGroupBox('Read data from dpll (channel 2)')
		self.qgroupbox_read_data.setAutoFillBackground(True)
		read_data = Qt.QGridLayout()

		self.qlabel_addr = Qt.QLabel('Address: 0x')
		self.qedit_addr = user_friendly_QLineEdit('9000')
		self.qedit_addr.setMaximumWidth(100)

		self.qlabel_data = Qt.QLabel('Data:')
		self.qedit_data = user_friendly_QLineEdit('0')
		self.qedit_data.setMaximumWidth(300)

		self.qbtn_1 = QtGui.QPushButton('Read data')
		self.qbtn_1.clicked.connect(self.read_RP)


		read_data.addWidget(self.qlabel_addr, 	0, 0)
		read_data.addWidget(self.qedit_addr, 	0, 1)
		read_data.addWidget(self.qlabel_data, 	1, 0)
		read_data.addWidget(self.qedit_data, 	1, 1, 1, 2)
		read_data.addWidget(self.qbtn_1, 		0, 2)

		read_data.setRowStretch(1, 2)

		self.qgroupbox_read_data.setLayout(read_data)

		###################################################################################

		self.qgroupbox_fanUI = Qt.QGroupBox('Turn on/off fan')
		self.qgroupbox_fanUI.setAutoFillBackground(True)
		fanUI = Qt.QGridLayout()

		self.qradio_fan_on  = Qt.QRadioButton('Fan on')
		self.qradio_fan_off = Qt.QRadioButton('Fan off')
		self.qradio_fan_on.setChecked(True)
		self.qradio_fan_on.clicked.connect(self.setFan)
		self.qradio_fan_off.clicked.connect(self.setFan)

		fanUI.addWidget(self.qradio_fan_on, 	0, 0)
		fanUI.addWidget(self.qradio_fan_off, 	1, 0)

		#fanUI.setRowStretch(2, 2)

		self.qgroupbox_fanUI.setLayout(fanUI)

		###################################################################################

		self.qbtn_reconnect = QtGui.QPushButton('Open communication menu')
		self.qbtn_reconnect.clicked.connect(self.communication_menu)


		###################################################################################
			
		self.group = Qt.QGroupBox('RP configuration')
		self.group.setAutoFillBackground(True)
		group = Qt.QGridLayout()

		group.addWidget(self.qgroupbox_MUX_vco, 0, 0, 2, 4)
		group.addWidget(self.qgroupbox_MUX_pll2, 3, 0, 2, 4)
		group.addWidget(self.qgroupbox_read_data, 6, 0, 2, 4)
		group.addWidget(self.qgroupbox_fanUI, 8, 0, 1, 1)
		group.addWidget(self.qbtn_reconnect, 8, 1, 1, 2)

		#vbox = Qt.QVBoxLayout()
		#vbox.addStretch(1)
		self.group.setLayout(group)

		grid = Qt.QGridLayout()
		grid.addWidget(self.group)
		self.setLayout(grid)


		#self.center()
		self.setWindowTitle(self.custom_shorthand + ': RP Configuration')    
		#self.show()
		#self.show()

	#Function to read the value in the RAM Block (channel 2) to an address
	#The data we should read are the data sent to dpll_wrapper module (channel 0)
	def read_RP(self):
		addr = int(self.qedit_addr.text(),16)
		bus_address = (2 << 20) + addr*4
		value = str(self.sl.dev.read_Zynq_register_uint32(bus_address))
		self.qedit_data.blockSignals(True)
		self.qedit_data.setText(value)
		self.qedit_data.blockSignals(False)
	
		# bus_address = (2 << 20) + 0x9001*4
		# value = str(self.sl.dev.read_Zynq_register_uint32(bus_address))
		# print(value)

		# bus_address = (2 << 20) + 0x9000*4
		# value = str(self.sl.dev.read_Zynq_register_uint32(bus_address))
		# print(value)		


	def communication_menu(self):
		# Open the initial menu in which we select the RP and if we want to reconnect to one. We can open a new connection without closing the GUI
		self.controller.connectionGUI()
		

	def center(self):
		qr = self.frameGeometry()
		cp = QtGui.QDesktopWidget().availableGeometry().center()
		qr.moveCenter(cp)
		#self.move(qr.topLeft())
		#self.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(50, 50))


	def setFan(self):
		# Set the output of 2 IO pins (0 or 3.3V) for the activation of the fan
		self.sl.setFan(self.qradio_fan_on.isChecked())

	def mux_vco_Action(self):
		if self.qradio_VCO_to_DAC0.isChecked():
			data = 1
		elif self.qradio_VCO_to_DAC1.isChecked():
			data = 2
		else:  # no VCO is checked
			data = 0
		self.sl.set_mux_vco(data)


	def setInternalVCO_offset(self):
		try:
			int_vco_offset = float(self.qedit_int_vco_offset.text())
		except:
			int_vco_offset = 0.0
		if int_vco_offset < -1.0 or int_vco_offset > 1.0:
			int_vco_offset = 0.0
		
		self.sl.set_internal_VCO_offset(int_vco_offset)

	def setInternalVCO_amplitude(self):
		try:
			int_vco_amplitude = float(self.qedit_int_vco_amplitude.text())
		except:
			int_vco_amplitude = 0.5
		if int_vco_amplitude < -1 or int_vco_amplitude > 1:
			int_vco_amplitude = 0.5
			self.qedit_int_vco_amplitude.blockSignals(True)
			self.qedit_int_vco_amplitude.setText('{:.3f}'.format(int_vco_amplitude))
			self.qedit_int_vco_amplitude.blockSignals(False)
		
		self.sl.set_internal_VCO_amplitude(int_vco_amplitude)
	  
	def mux_pll2_Action(self):
		if self.qradio_ddc1_to_pll2.isChecked():
			data = 1
		elif self.qradio_pll1_to_pll2.isChecked():
			data = 2
		else: #self.qradio_ddc2_to_pll2.isChecked()
			data = 0
		self.sl.set_mux_pll2(data)


	
if __name__ == '__main__':

	#app = QApplication(sys.argv)
	app = QtCore.QCoreApplication.instance()
	if app is None:
		app = QtWidgets.QApplication(sys.argv)

	sl = SuperLaserLand_JD_RP()
	w = ConfigRPSettingsUI(sl)
	w.show()
	w.resize(800, 300)


	app.exec_()

