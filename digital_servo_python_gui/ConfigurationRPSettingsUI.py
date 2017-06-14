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
			self.mux1Action()
			self.mux2Action()
			self.mux3Action()
			self.setInternalVCO_0_amplitude()
			self.setInternalVCO_1_amplitude()
			#self.updateClicked()
			#self.residualsClicked()

	def initUI(self):
		self.qgroupbox_MUX1 = Qt.QGroupBox('Select error input to channel B')
		self.qgroupbox_MUX1.setAutoFillBackground(True)
		MUX1 = Qt.QGridLayout()


		self.qradio_DEMOD1toPLL1 = Qt.QRadioButton('Demod B -> Loop filter B input')
		self.qradio_DEMOD0toPLL1        = Qt.QRadioButton('Demod A -> Loop filter B input')
		self.qradio_PLL0toPLL1 = Qt.QRadioButton('Loop filter A output -> Loop filter B input')


		self.qradio_DEMOD1toPLL1.setChecked(True)
		self.qradio_DEMOD1toPLL1.clicked.connect(self.mux1Action)
		self.qradio_DEMOD0toPLL1.clicked.connect(self.mux1Action)
		self.qradio_PLL0toPLL1.clicked.connect(self.mux1Action)
		
		
		self.qgroupbox_MUX2 = Qt.QGroupBox('Select output DAC A connection')
		self.qgroupbox_MUX2.setAutoFillBackground(True)
		MUX2 = Qt.QGridLayout()
		self.qradio_ADC0toDAC0 = Qt.QRadioButton('Loop filter A output -> DAC A')
		self.qradio_VCO0toDAC0 = Qt.QRadioButton('Loop filter A output -> VCO A -> DAC A')
		self.qradio_ADC0toDAC0.setChecked(True)
		self.qradio_ADC0toDAC0.clicked.connect(self.mux2Action)
		self.qradio_VCO0toDAC0.clicked.connect(self.mux2Action)

		self.qlabel_int_vco_0_amplitude = Qt.QLabel('Internal VCO A Amplitude')
		self.qedit_int_vco_0_amplitude = user_friendly_QLineEdit('0.5')
		self.qedit_int_vco_0_amplitude.returnPressed.connect(self.setInternalVCO_0_amplitude)
		self.qedit_int_vco_0_amplitude.setMaximumWidth(60)
  
		self.qgroupbox_MUX3 = Qt.QGroupBox('Select output DAC B connection')
		self.qgroupbox_MUX3.setAutoFillBackground(True)
		MUX3 = Qt.QGridLayout()
		self.qradio_ADC1toDAC1 = Qt.QRadioButton('Loop filter B output -> DAC B')
		self.qradio_VCO1toDAC1 = Qt.QRadioButton('Loop filter B output -> VCO B -> DAC B')
		self.qradio_ADC1toDAC1.setChecked(True)
		self.qradio_ADC1toDAC1.clicked.connect(self.mux3Action)
		self.qradio_VCO1toDAC1.clicked.connect(self.mux3Action)
  
		self.qlabel_int_vco_1_amplitude = Qt.QLabel('Internal VCO B Amplitude')
		self.qedit_int_vco_1_amplitude = user_friendly_QLineEdit('0.5')
		self.qedit_int_vco_1_amplitude.returnPressed.connect(self.setInternalVCO_1_amplitude)
		self.qedit_int_vco_1_amplitude.setMaximumWidth(60)

		MUX1.addWidget(self.qradio_DEMOD1toPLL1,	 0, 0)	
		MUX1.addWidget(self.qradio_DEMOD0toPLL1,	 1, 0)
		MUX1.addWidget(self.qradio_PLL0toPLL1, 		 2, 0)
		MUX1.addItem(Qt.QSpacerItem(0, 0, Qt.QSizePolicy.MinimumExpanding, Qt.QSizePolicy.Minimum), 3, 0)
		MUX1.setRowStretch(3, 1)

		MUX2.addWidget(self.qradio_ADC0toDAC0,			 	0, 0, 1, 2)
		MUX2.addWidget(self.qradio_VCO0toDAC0, 			 	1, 0, 1, 2)
		MUX2.addWidget(self.qlabel_int_vco_0_amplitude, 	2, 0)
		MUX2.addWidget(self.qedit_int_vco_0_amplitude, 		2, 1)


		MUX3.addWidget(self.qradio_ADC1toDAC1, 0, 0, 1, 2)
		MUX3.addWidget(self.qradio_VCO1toDAC1, 1, 0, 1, 2)
		MUX3.addWidget(self.qlabel_int_vco_1_amplitude, 2, 0)
		MUX3.addWidget(self.qedit_int_vco_1_amplitude, 	2, 1)

		self.qgroupbox_MUX1.setLayout(MUX1)
		self.qgroupbox_MUX2.setLayout(MUX2)
		self.qgroupbox_MUX3.setLayout(MUX3)

			
		self.group = Qt.QGroupBox('RP configuration')
		self.group.setAutoFillBackground(True)
		group = Qt.QGridLayout()

		group.addWidget(self.qgroupbox_MUX1, 0, 0, 2, 1)
		group.addWidget(self.qgroupbox_MUX2, 0, 1, 1, 2)
		group.addWidget(self.qgroupbox_MUX3, 1, 1, 1, 2)

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
	def mux1Action(self):
		if self.qradio_DEMOD0toPLL1.isChecked():
			data = 1
		elif self.qradio_PLL0toPLL1.isChecked():
			data = 2
		else:  # qradio_DEMOD1toPLL1 is checked
			data = 0
		self.sl.set_mux_pll2(data)

	
	def mux2Action(self):
		if self.qradio_VCO0toDAC0.isChecked():
			data = 1
		else:  # qradio_ADC0toDAC0 is checked
			data = 0
		self.sl.set_output_mux(0, data)

	def mux3Action(self):

		if self.qradio_VCO1toDAC1.isChecked():
			data = 1
		else:  # qradio_ADC0toDAC0 is checked
			data = 0
		self.sl.set_output_mux(1, data)

	def setInternalVCO_0_amplitude(self):
		try:
			int_vco_amplitude = float(self.qedit_int_vco_0_amplitude.text())
		except:
			int_vco_amplitude = 0.5
		if int_vco_amplitude < 0 or int_vco_amplitude > 1:
			int_vco_amplitude = 0.5
		
		self.sl.set_internal_VCO_amplitude(0, int_vco_amplitude)


	def setInternalVCO_1_amplitude(self):
		try:
			int_vco_amplitude = float(self.qedit_int_vco_1_amplitude.text())
		except:
			int_vco_amplitude = 0.5
		if int_vco_amplitude<0 or int_vco_amplitude>1:
			int_vco_amplitude = 0.5
		
		self.sl.set_internal_VCO_amplitude(1, int_vco_amplitude)
	  


    
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

