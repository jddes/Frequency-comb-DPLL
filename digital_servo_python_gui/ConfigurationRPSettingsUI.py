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
# 
class ConfigRPSettingsUI(Qt.QWidget):
	"""docstring for ConfigRP"""
	def __init__(self, sl, custom_style_sheet='', custom_shorthand='', bUpdateFPGA = True):
		#initial values to add : mux1value = 0, mux2value = 0, mux3value = 0, VCO1value = 0.5, VCO2value = 0.5,
		super(ConfigRPSettingsUI, self).__init__()  
		print('ConfigRPSettingsUI::__init(): Entering')		
		self.sl = weakref.proxy(sl)
		self.setObjectName('MainWindow')
		self.setStyleSheet(custom_style_sheet)
		self.custom_shorthand = custom_shorthand


		self.initUI()

		if bUpdateFPGA == True:
			self.mux_vco_Action()
			self.mux_pll2_Action()
			self.setInternalVCO_amplitude()
			#self.updateClicked()
			#self.residualsClicked()

	def initUI(self):

		self.qgroupbox_MUX_vco = Qt.QGroupBox('Select connection to VCO')
		self.qgroupbox_MUX_vco.setAutoFillBackground(True)
		MUX_vco = Qt.QGridLayout()

		self.qradio_VCO_to_DAC0 = Qt.QRadioButton('VCO connected to DAC A')
		self.qradio_VCO_to_DAC1 = Qt.QRadioButton('VCO connected to DAC B')
		self.qradio_no_VCO = Qt.QRadioButton('No VCO connected')
		self.qradio_no_VCO.setChecked(True)
		self.qradio_VCO_to_DAC0.clicked.connect(self.mux_vco_Action)
		self.qradio_VCO_to_DAC1.clicked.connect(self.mux_vco_Action)
		self.qradio_no_VCO.clicked.connect(self.mux_vco_Action)

		self.qlabel_int_vco_amplitude = Qt.QLabel('Internal VCO Amplitude')
		self.qedit_int_vco_amplitude = user_friendly_QLineEdit('0.5')
		self.qedit_int_vco_amplitude.returnPressed.connect(self.setInternalVCO_amplitude)
		self.qedit_int_vco_amplitude.setMaximumWidth(60)
  

		MUX_vco.addWidget(self.qradio_VCO_to_DAC0,	 0, 0)	
		MUX_vco.addWidget(self.qradio_VCO_to_DAC1,	 1, 0)
		MUX_vco.addWidget(self.qradio_no_VCO, 		 2, 0)
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
		self.qradio_pll1_to_pll2 = Qt.QRadioButton('PLL_a output to PLL_b input')
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
			
		self.group = Qt.QGroupBox('RP configuration')
		self.group.setAutoFillBackground(True)
		group = Qt.QGridLayout()

		group.addWidget(self.qgroupbox_MUX_vco, 0, 0, 2, 1)
		group.addWidget(self.qgroupbox_MUX_pll2, 3, 0, 2, 1)
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

	def center(self):
				
		qr = self.frameGeometry()
		cp = QtGui.QDesktopWidget().availableGeometry().center()
		qr.moveCenter(cp)
		#self.move(qr.topLeft())
		#self.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(50, 50))

	def mux_vco_Action(self):
		if self.qradio_VCO_to_DAC0.isChecked():
			data = 1
		elif self.qradio_VCO_to_DAC1.isChecked():
			data = 2
		else:  # no VCO is checked
			data = 0
		self.sl.set_mux_vco(data)

	def setInternalVCO_amplitude(self):
		try:
			int_vco_amplitude = float(self.qedit_int_vco_amplitude.text())
		except:
			int_vco_amplitude = 0.5
		if int_vco_amplitude < 0 or int_vco_amplitude > 1:
			int_vco_amplitude = 0.5
		
		self.sl.set_internal_VCO_amplitude(int_vco_amplitude)
	  
	def mux_pll2_Action(self):
		if self.qradio_ddc1_to_pll2.isChecked():
			data = 0
		elif self.qradio_pll1_to_pll2.isChecked():
			data = 1
		else: #self.qradio_ddc2_to_pll2.isChecked()
			data = 2
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

