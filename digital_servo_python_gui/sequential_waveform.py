# -*- coding: utf-8 -*-
"""
June 2017

Description: GUI to control the sequential waveform sent to the RP and to play the sequence 
@author: Alex Tourigny-Plante
"""

from PyQt5 import QtGui, Qt, QtCore, QtWidgets
from PyQt5.QtWidgets import QApplication, QWidget, QInputDialog, QLineEdit, QFileDialog
from PyQt5.QtGui import QIcon
#import PyQt4.Qwt5 as Qwt
import numpy as np
import weakref
import sys

import traceback

from user_friendly_QLineEdit import user_friendly_QLineEdit


from SuperLaserLand_JD_RP import SuperLaserLand_JD_RP


class sequential_waveform(Qt.QWidget):
	"""docstring for ConfigRP"""
	def __init__(self, sl, sp, controller, custom_style_sheet='', custom_shorthand=''):
		super(sequential_waveform, self).__init__()  
		print('sequential_waveform::__init(): Entering')		
		self.sl = weakref.proxy(sl)
		self.sp = sp
		self.setObjectName('MainWindow')
		self.setStyleSheet(custom_style_sheet)
		self.custom_shorthand = custom_shorthand

		self.controller = controller #link to the top class

		self.initUI()
		self.loadParameters()

	def loadParameters(self):
		# Load the default parameters from the selected xml file (select by the devices_data dictionnary in the controller class)
		#path = self.sp.getValue('RP_settings', "Fan_state")
		path = "test_sequence.txt"
		self.qedit_path.blockSignals(True)
		self.qedit_path.setText(path)
		self.qedit_path.blockSignals(False)	

		run_sequence = 0
		if run_sequence > 0:
			self.qchk_run_sequence.setChecked(True)
		else:
			self.qchk_run_sequence.setChecked(False)

		self.loadSequence(path)


	def pushDefaultValues(self):
		# Push the values from the xml file to the red pitaya (load + send)
		self.loadParameters()
		self.pushValues()

	def pushValues(self):
		# Send the values in the different fields to the RP
		print("to do")

	def getValues(self):
		#get value from the memory of the red pitaya 

		#get value for the VCO connection
		#run_sequence = self.sl.get_mux_vco() #function to do
		print("to do")		
		


	def initUI(self):

		self.qgroupbox_parameters = Qt.QGroupBox('Parameters')
		self.qgroupbox_parameters.setAutoFillBackground(True)
		parameters = Qt.QGridLayout()

		self.qlabel_path = Qt.QLabel('Select path for sequence data')
		self.qedit_path = user_friendly_QLineEdit('path')
		#self.qedit_path.setMaximumWidth(300)
		self.qbtn_select = Qt.QPushButton('Select file')
		self.qbtn_select.clicked.connect(self.selectFile)
		self.qbtn_load = Qt.QPushButton('Load')
		self.qbtn_load.clicked.connect(self.loadSequence)

		parameters.addWidget(self.qlabel_path,	 0, 0, 1, 1)	
		parameters.addWidget(self.qedit_path,	 0, 1, 1, 4)
		parameters.addWidget(self.qbtn_select,	 0, 5, 1, 1)
		parameters.addWidget(self.qbtn_load,	 1, 0, 1, 1)

		self.qgroupbox_parameters.setLayout(parameters)

		###################################################################################
		self.qgroupbox_run_sequence = Qt.QGroupBox('Run sequence')
		self.qgroupbox_run_sequence.setAutoFillBackground(True)
		run_sequence = Qt.QGridLayout()


		self.qchk_run_sequence = Qt.QCheckBox('Run sequence')
		self.qchk_run_sequence.clicked.connect(self.runSequence)

		self.qchk_pulse = Qt.QCheckBox('Pulse on second channel when start sequence')
		self.qchk_pulse.clicked.connect(self.runSequence)

		run_sequence.addWidget(self.qchk_run_sequence, 	0, 0)
		run_sequence.addWidget(self.qchk_pulse, 	1, 0)

		self.qgroupbox_run_sequence.setLayout(run_sequence)

		###################################################################################			
		self.group = Qt.QGroupBox('Waveform sequency')
		self.group.setAutoFillBackground(True)
		group = Qt.QGridLayout()

		group.addWidget(self.qgroupbox_parameters, 0, 0, 1, 1)
		group.addWidget(self.qgroupbox_run_sequence, 1, 0, 1, 1)

		#vbox = Qt.QVBoxLayout()
		#vbox.addStretch(1)
		self.group.setLayout(group)

		grid = Qt.QGridLayout()
		grid.addWidget(self.group)
		self.setLayout(grid)


		#self.center()
		self.setWindowTitle(self.custom_shorthand + ': waveform sequence')    
		#self.show()
		

	def center(self):
		qr = self.frameGeometry()
		cp = QtGui.QDesktopWidget().availableGeometry().center()
		qr.moveCenter(cp)
		#self.move(qr.topLeft())
		#self.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(50, 50))

	#--------------------------------------------------------
	def loadSequence(self,path):
		path = self.qedit_path.text()
		data_sequence = np.loadtxt(path, dtype=int)
		self.sl.send_length_sequence(len(data_sequence))	 
		for x in range(0, len(data_sequence)):
			# Send data to FPGA (with progress line?)
			self.sl.send_sequence(data_sequence[x])	 
		self.sequence_loaded = True


	def runSequence(self):
		if self.qchk_run_sequence.isChecked():
			run_sequence = 1;
		else:
			run_sequence = 0

		if self.qchk_pulse.isChecked():
			pulse = 1;
		else:
			pulse = 0
		self.sl.set_run_sequence(run_sequence,pulse)

	def selectFile(self):
		options = QFileDialog.Options()
		options |= QFileDialog.DontUseNativeDialog
		fileName, _ = QFileDialog.getOpenFileName(self,"QFileDialog.getOpenFileName()", "","Text Files (*.txt);;Text Files (*.txt)", options=options)
		if fileName:
			self.qedit_path.blockSignals(True)
			self.qedit_path.setText(fileName)
			self.qedit_path.blockSignals(False)
			self.sequence_loaded = False
	
# if __name__ == '__main__':

# 	#app = QApplication(sys.argv)
# 	app = QtCore.QCoreApplication.instance()
# 	if app is None:
# 		app = QtWidgets.QApplication(sys.argv)

# 	sl = SuperLaserLand_JD_RP()
# 	w = ConfigRPSettingsUI(sl)
# 	w.show()
# 	w.resize(800, 300)


# 	app.exec_()

