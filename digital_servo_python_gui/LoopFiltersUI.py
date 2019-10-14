# -*- coding: utf-8 -*-
"""
Created on Wed Dec 04 20:48:43 2013

Description: Provides a graphical user interface (GUI) for setting the loop filters parameters of the PII^2 filter implemented in the XEM6010 module.
@author: JD Deschenes
"""
from __future__ import print_function
from PyQt5 import QtGui, Qt, QtCore
#import PyQt5.Qwt5 as Qwt
import numpy as np
import weakref

import traceback

from user_friendly_QLineEdit import user_friendly_QLineEdit

# stuff for Python 3 port
import pyqtgraph as pg

from SocketErrorLogger import logCommsErrorsAndBreakoutOfFunction

class LoopFiltersUI(Qt.QWidget):
	
	MINIMUM_GAIN_DISPLAY = 10**(-120/20)
	
	def __init__(self, sl, filter_number=0, bDisplayLockChkBox=True):
		super(LoopFiltersUI, self).__init__()
#        print('LoopFiltersUI::__init__(): Entering')        
		
		# We need sl here because we need to pass it to the pll object, and we need fs to set the correct loop filter gain, because the integrators transfer function depends on that fs
		self.sl = weakref.proxy(sl)
		self.filter_number = filter_number
		# All the gains here are normalized to the DC, open-loop gain of the overall system:
		self.kc = 1
		self.bDisplayLockChkBox = bDisplayLockChkBox

		# # Was valid when we pass pll as a parameter (pll parameter was the same as self.pll)
		# if type(pll) == type(0):
		#     # For debugging only:
		#     self.kp_min = 1e-6
		#     self.kp_max = 1e6
		#     self.ki_min = 1e-6
		#     self.ki_max = 1e6
		#     self.kii_min = 1e-6
		#     self.kii_max = 1e6
		# else:
		#     # Keep a local reference to the related PLL object
		#     self.pll = pll
		#     self.getLimits()
		

		self.getLimits()
		
		# Init our GUI
		self.initUI()
		
#        print('LoopFiltersUI::__init__() Exiting')
#        print('LoopFiltersUI::__init__()')
#        self.updateGraph()
		
#    def __del__(self):
#        print('LoopFiltersUI destructor called')


	def pushValues(self):
		pass

	def getValues(self):
		self.getFilterSettings()
   
	def initUI(self):
#        print('initUI()')
		
		# First create the plot:
		self.qplot_tf = pg.PlotWidget()
#        self.qplot_tf.enableAxis(Qwt.QwtPlot.xBottom, False)
#        self.qplot_tf.enableAxis(Qwt.QwtPlot.yLeft, False)
		self.qplot_tf.setMinimumHeight(100)
		self.qplot_tf.setMinimumWidth(100)
		#self.qplot_tf.setCanvasBackground(Qt.Qt.white)
		#self.qplot_tf.setAxisScaleEngine(Qwt.QwtPlot.xBottom, Qwt.QwtLog10ScaleEngine())
		self.qplot_tf.getPlotItem().setLogMode(x=True)


		#self.qplot_tf.setTitle('Loop filter #%d' % self.filter_number)
		
		#qPolicy = Qt.QSizePolicy(Qt.QSizePolicy.Expanding, Qt.QSizePolicy.Expanding)
		#qPolicy = Qt.QSizePolicy(Qt.QSizePolicy.Expanding, Qt.QSizePolicy.Expanding)
		qPolicy = Qt.QSizePolicy(Qt.QSizePolicy.Ignored, Qt.QSizePolicy.Ignored)
		self.qplot_tf.setSizePolicy(qPolicy)
		
		self.curve_0dB = self.qplot_tf.getPlotItem().plot()
		#FEATURE        
		#self.curve_0dB.attach(self.qplot_tf)
		#pen = Qt.QPen(Qt.Qt.DashLine)
		#pen.setColor(Qt.Qt.black)
		#pen.setBrush(QtGui.QBrush(QtCore.Qt.NoBrush))
		pen = pg.mkPen(color='k', dash=[4, 2])
		self.curve_0dB.setPen(pen)
		
		self.curve_kp = self.qplot_tf.getPlotItem().plot(pen='k')
		#self.curve_kp.attach(self.qplot_tf)
		#self.curve_kp.setPen(Qt.QPen(Qt.Qt.black))
		
		self.curve_fi = self.qplot_tf.getPlotItem().plot(pen='k')
		#self.curve_fi.attach(self.qplot_tf)
		#self.curve_fi.setPen(Qt.QPen(Qt.Qt.black))
		
		self.curve_fii = self.qplot_tf.getPlotItem().plot(pen='k')
		#self.curve_fii.attach(self.qplot_tf)
		#self.curve_fii.setPen(Qt.QPen(Qt.Qt.black))
		
		self.curve_fd = self.qplot_tf.getPlotItem().plot(pen='k')
		# self.curve_fd = self.qplot_tf.getPlotItem().plot()
		#self.curve_fd.attach(self.qplot_tf)
		# self.curve_fd.setPen(Qt.QPen(Qt.Qt.black))
		
		self.curve_fdf = self.qplot_tf.getPlotItem().plot(pen='k')
		#self.curve_fdf.attach(self.qplot_tf)
		# pen2 = Qt.QPen(Qt.Qt.DashLine)
		# pen2.setColor(Qt.Qt.black)
		#self.curve_fdf.setPen(pen2)
		
		self.curve_composite = self.qplot_tf.getPlotItem().plot()
		#self.curve_composite.attach(self.qplot_tf)
		self.curve_composite.setPen(pg.mkPen('r'))
		
		# self.curve_actual = self.qplot_tf.getPlotItem().plot(fillLevel=-140, fillBrush='b')
		self.curve_actual = self.qplot_tf.getPlotItem().plot()
		#self.curve_actual.attach(self.qplot_tf)
		#self.curve_actual.setPen(Qt.QPen(Qt.Qt.blue, 2))
		self.curve_actual.setPen(pg.mkPen('b', width=2))
		
#        self.curve_0dB.setPen(self.qplot_tf)
		
		self.qlabel_spacerh = Qt.QLabel('')
		self.qlabel_spacerh.setMinimumWidth(30)
		self.qlabel_spacerh2 = Qt.QLabel('')
		self.qlabel_spacerh2.setMinimumWidth(7)
		self.qlabel_spacerv = Qt.QLabel('')
		self.qlabel_spacerv.setMinimumHeight(25)
		
		
		self.qchk_lock = Qt.QCheckBox('Lock On')
		self.qchk_lock.clicked.connect(self.textboxChanged)
		self.qchk_lock.setEnabled(self.bDisplayLockChkBox)
			
		
		self.qchk_kp = Qt.QCheckBox('Kp On')
		self.qchk_kp.clicked.connect(self.textboxChanged)
		
		self.qchk_kd = Qt.QCheckBox('Kd On')
		self.qchk_kd.clicked.connect(self.textboxChanged)
		
		# Labels and controls to show the settings:
		self.qlabel_kp = Qt.QLabel('Kp:')
		self.qlabel_fi = Qt.QLabel('fi:')
		self.qlabel_fii = Qt.QLabel('fii:')
		self.qlabel_fd = Qt.QLabel('fd:')
		self.qlabel_fdf = Qt.QLabel('fdf:')
		self.qedit_kp = user_friendly_QLineEdit('-60')
		self.qedit_fi = user_friendly_QLineEdit('1e3')
		self.qedit_fii = user_friendly_QLineEdit('1e1')
		self.qedit_fd = user_friendly_QLineEdit('1e6')
		self.qedit_fdf = user_friendly_QLineEdit('1e6')
		self.qedit_kp.setMaximumWidth(100)
		self.qedit_fi.setMaximumWidth(100)
		self.qedit_fii.setMaximumWidth(100)
		self.qedit_fd.setMaximumWidth(100)
		self.qedit_fdf.setMaximumWidth(100)
		self.qedit_kp.returnPressed.connect(self.textboxChanged)
		self.qedit_fi.returnPressed.connect(self.textboxChanged)
		self.qedit_fii.returnPressed.connect(self.textboxChanged)
		self.qedit_fd.returnPressed.connect(self.textboxChanged)
		self.qedit_fdf.returnPressed.connect(self.textboxChanged)
		
		
		self.qchk_bKpCrossing = Qt.QCheckBox('fi refer to kp crossover')
		self.qchk_bKpCrossing.setChecked(False)
		self.qchk_bKpCrossing.clicked.connect(self.bKpCrossingPress)
		
		self.qchk_lockSlider = Qt.QCheckBox('Lock D sliders')
		self.qchk_lockSlider.setChecked(False)
		self.qchk_lockSlider.clicked.connect(self.lockSlider)
		self.slider_locked = False
		self.slider_ratio = 10
		self.slider_inhibit = False
		
		# The sliders:
		self.qslider_kp = Qt.QSlider()
		self.qslider_fi = Qt.QSlider()
		self.qslider_fii = Qt.QSlider()
		self.qslider_fd = Qt.QSlider()
		self.qslider_fdf = Qt.QSlider()
		self.qslider_kp.setOrientation(Qt.Qt.Vertical)
		self.qslider_fi.setOrientation(Qt.Qt.Horizontal)
		self.qslider_fii.setOrientation(Qt.Qt.Horizontal)
		self.qslider_fd.setOrientation(Qt.Qt.Horizontal)
		self.qslider_fdf.setOrientation(Qt.Qt.Horizontal)

		# Set bounds:
		(kp, fi, fii, fd, fdf, fmin, fmax, gain_min, gain_max, bLock) = self.getSettings()
		# The fi and fii sliders will contain the value in 100*log10(f) units (similar to dBHz, but with a different scaling - this is because we can only use integer units)
		self.qslider_fi.setMinimum(100*np.log10(fmin))
		self.qslider_fii.setMinimum(100*np.log10(fmin))
		self.qslider_fd.setMinimum(100*np.log10(fmin))
		self.qslider_fdf.setMinimum(100*np.log10(fmin))
		self.qslider_fi.setMaximum(100*np.log10(fmax))
		self.qslider_fii.setMaximum(100*np.log10(fmax))
		self.qslider_fd.setMaximum(100*np.log10(fmax))
		self.qslider_fdf.setMaximum(100*np.log10(fmax))
		self.qslider_kp.setMinimum(10*gain_min)
		self.qslider_kp.setMaximum(10*gain_max)
		self.qslider_fi.setValue((100*np.log10(fi)))
		self.qslider_fii.setValue((100*np.log10(fii)))
		self.qslider_fd.setValue((100*np.log10(fd)))
		self.qslider_fdf.setValue((100*np.log10(fdf)))
		self.qslider_kp.setValue((10*kp))
#        print('10*gain_min = %f, 10*gain_min = %f, 10*kp = %f' % (10*gain_min, 10*gain_min, 10*kp))
		
		self.qslider_kp.valueChanged.connect(self.kpSliderEvent)
		self.qslider_fi.valueChanged.connect(self.fiSliderEvent)
		self.qslider_fii.valueChanged.connect(self.fiiSliderEvent)
		self.qslider_fd.valueChanged.connect(self.fdSliderEvent)
		self.qslider_fdf.valueChanged.connect(self.fdfSliderEvent)


		# Every control for the proportional gain goes into an hbox:
		
		vbox = Qt.QVBoxLayout()
		vbox.addStretch(1)
		vbox.addWidget(self.qchk_kp)
		vbox.addWidget(self.qchk_kd)


		
		# Put everything in a grid layout:
		grid = Qt.QGridLayout()


		grid.addLayout(vbox,                    0, 0, 2, 2)
		grid.addWidget(self.qslider_kp,         0, 2, 3, 1)

		grid.addWidget(self.qplot_tf,           0, 3, 9, 1)
		grid.setColumnStretch(3, 1)
		grid.setRowStretch(8, 1)


		
		grid.addWidget(self.qlabel_kp,          2, 0)
		grid.addWidget(self.qlabel_fi,          3, 0)
		grid.addWidget(self.qlabel_fii,         4, 0)
		grid.addWidget(self.qlabel_fd,          5, 0)
		grid.addWidget(self.qlabel_fdf,         6, 0)
		
		grid.addWidget(self.qedit_kp,           2, 1, 1, 1)
		grid.addWidget(self.qedit_fi,           3, 1, 1, 1)
		grid.addWidget(self.qedit_fii,          4, 1, 1, 1)
		grid.addWidget(self.qedit_fd,           5, 1, 1, 1)
		grid.addWidget(self.qedit_fdf,          6, 1, 1, 1)

		


		
		grid.addWidget(self.qchk_bKpCrossing,   7, 0, 1, 3)
		
		
		
		grid.addWidget(self.qslider_fi,         3, 2, 1, 1)
		grid.addWidget(self.qslider_fii,        4, 2, 1, 1)
		grid.addWidget(self.qslider_fd,         5, 2, 1, 1)
		grid.addWidget(self.qslider_fdf,        6, 2, 1, 1)
		#grid.addWidget(self.qlabel_spacerh2,    4, 5, 1, 1)

		self.setLayout(grid)
		
		# hbox = Qt.QHBoxLayout()
		# hbox.addLayout(grid)
		# hbox.addWidget(self.qplot_tf)
		# hbox.setColumnStretch(1, 1)
		# self.setLayout(hbox)

		
		#qPolicy = Qt.QSizePolicy(Qt.QSizePolicy.MinimumExpanding, Qt.QSizePolicy.MinimumExpanding)
		#self.setSizePolicy(qPolicy)
		
	def loadParameters(self, sp):
#        print('loadParameters(): Entering')
		
#        self.root.append(Element('PLL0_settings', kp='-60', fi='1e3', fii='0', chkKp='True', chkLock='False', chkKpCrossing='True'))
		strPLL = 'PLL{:01d}_settings'.format(self.filter_number)
		kp = float(sp.getValue(strPLL, 'kp'))
		fi = float(sp.getValue(strPLL, 'fi'))
		fii = float(sp.getValue(strPLL, 'fii'))
		fd = float(sp.getValue(strPLL, 'fd'))
		fdf = float(sp.getValue(strPLL, 'fdf'))
		bKp = bool(sp.getValue(strPLL, 'chkKp').lower() == 'true')
		bKd = bool(sp.getValue(strPLL, 'chkKd').lower() == 'true')
		bLock = bool(sp.getValue(strPLL, 'chkLock').lower() == 'true')
		kKpCrossing = bool(sp.getValue(strPLL, 'chkKpCrossing').lower() == 'true')
#        print('loadParameters(): kp = %f, fi = %f, fii = %f' % (kp, fi, fii))
		
		# Update the values in the UI to reflect the internal values:
		# We block the signals first because otherwise the edit box event handler will try to change the values.
		# We instead call textboxChanged() explicitely at the end
		self.qedit_kp.blockSignals(True)
		self.qedit_fi.blockSignals(True)
		self.qedit_fii.blockSignals(True)
		self.qedit_fd.blockSignals(True)
		self.qedit_fdf.blockSignals(True)
		
		self.qedit_kp.setText('{:.3}'.format(kp))
		self.qedit_fi.setText('{:.3e}'.format(fi))
		self.qedit_fii.setText('{:.3e}'.format(fii))
		self.qedit_fd.setText('{:.3e}'.format(fd))
		self.qedit_fdf.setText('{:.3e}'.format(fdf))
		
		self.qedit_kp.blockSignals(False)
		self.qedit_fi.blockSignals(False)
		self.qedit_fii.blockSignals(False)
		self.qedit_fd.blockSignals(False)
		self.qedit_fdf.blockSignals(False)
#        print('self.qedit_kp = %s' % self.qedit_kp.text())
		
		self.qchk_kp.setChecked(bKp)
		self.qchk_kd.setChecked(bKd)
		self.qchk_lock.setChecked(bLock)
		self.qchk_bKpCrossing.setChecked(kKpCrossing)
		
#        print('loadParameters(): Calling textboxChanged()')
		self.textboxChanged()
		
#        print('loadParameters(): Calling updateGraph()')
#        self.updateGraph()
		
#        print('loadParameters(): Exiting')
		
	def getSettings(self):

		if self.qchk_lock.isChecked():
			bLock = 1
		else:
			bLock = 0
			
		if self.qchk_kp.isChecked():
			try:
				kp = float(self.qedit_kp.text())
			except:
				kp = -20.0

		else:
			# Kp is off: put -120 dB right now to indicate 0 gain
			kp = -120
			
		try:
			fi = float(self.qedit_fi.text())
		except:
			fi = 1e3
			
		try:
			fii = float(self.qedit_fii.text())
		except:
			fii = 0.0
			
		try:
			fd = float(self.qedit_fd.text())
		except:
			fd = 0.0
			
		try:
			fdf = float(self.qedit_fdf.text())
		except:
			fdf = 0.0
			
		# TODO: make this changeable from the UI:
		try:
			fmin = 10.0
		except:
			fmin = 10.0
		try:
			fmax = 10e6
		except:
			fmax = 10e6
			
		gain_min = -30
		gain_max = 100
			
		return (kp, fi, fii, fd, fdf, fmin, fmax, gain_min, gain_max, bLock)
		
	def kpSliderEvent(self):
#        print('kpSliderEvent()')
		# Read the setting from the slider, apply limits, then update the textbox and the graph:
		sliderValue = self.qslider_kp.value()
		
		self.qedit_kp.blockSignals(True)
		self.qedit_kp.setText('%.2e' % (sliderValue/10.))
		self.qedit_kp.blockSignals(False)
		
		self.checkFirmwareLimits()
		self.updateFilterSettings()
		self.updateGraph()
		
	def fiSliderEvent(self):
#        print('fiSliderEvent()')
		# Read the setting from the slider, apply limits, then update the textbox and the graph:
		# The fi and fii sliders will contain the value in 100*log10(f) units
		sliderValue = self.qslider_fi.value()
		
		
		self.qedit_fi.blockSignals(True)
		self.qedit_fi.setText('%.2e' % 10**(sliderValue/100.))
		self.qedit_fi.blockSignals(False)
		
		self.checkFirmwareLimits()
		self.updateFilterSettings()
		self.updateGraph()
		
	def fiiSliderEvent(self):
#        print('fiiSliderEvent()')
		# Read the setting from the slider, apply limits, then update the textbox and the graph:
		sliderValue = self.qslider_fii.value()
		
		
		self.qedit_fii.blockSignals(True)
		self.qedit_fii.setText('%.2e' % 10**(sliderValue/100.))
		self.qedit_fii.blockSignals(False)
		
		self.checkFirmwareLimits()
		self.updateFilterSettings()
		self.updateGraph()
		
	def fdSliderEvent(self):
#        print('fiiSliderEvent()')
		# Read the setting from the slider, apply limits, then update the textbox and the graph:
		sliderValue = self.qslider_fd.value()
		
		self.qedit_fd.blockSignals(True)
		self.qedit_fd.setText('%.2e' % 10**(sliderValue/100.))
		self.qedit_fd.blockSignals(False)
		
		if (self.slider_locked == True and self.slider_inhibit == True) or self.slider_locked == False:
			self.checkFirmwareLimits()
			self.updateFilterSettings()
			self.updateGraph()

		if self.slider_locked == True and self.slider_inhibit == False:
			self.slider_inhibit = True
			self.qslider_fdf.setValue(int(float(sliderValue)+100*np.log10(self.slider_ratio)))
		self.slider_inhibit = False
		
	def fdfSliderEvent(self):
#        print('fiiSliderEvent()')
		# Read the setting from the slider, apply limits, then update the textbox and the graph:
		sliderValue = self.qslider_fdf.value()
		
		
		self.qedit_fdf.blockSignals(True)
		self.qedit_fdf.setText('%.2e' % 10**(sliderValue/100.))
		self.qedit_fdf.blockSignals(False)
		
		if (self.slider_locked == True and self.slider_inhibit == True) or self.slider_locked == False:
			self.checkFirmwareLimits()
			self.updateFilterSettings()
			self.updateGraph()
		
		if self.slider_locked == True and self.slider_inhibit == False:
			self.slider_inhibit = True
			self.qslider_fd.setValue(int(float(sliderValue)-100*np.log10(self.slider_ratio)))
		self.slider_inhibit = False
		
	def textboxChanged(self):
#        print('textboxChanged()')
#        traceback.print_stack()
	
		# Read the settings from the textboxes
		(kp, fi, fii, fd, fdf, fmin, fmax, gain_min, gain_max, bLock) = self.getSettings()
		# Update the sliders to match:
		# We block the signals from the sliders so we don't cause infinite recursion
#        self.qslider_fi.setValue((100*np.log10(fi)))
		self.qslider_fi.blockSignals(True)
		self.qslider_fi.setValue((100*np.log10(np.max((fi, fmin)))))
		self.qslider_fi.blockSignals(False)
		self.qslider_fii.blockSignals(True)
		self.qslider_fii.setValue((100*np.log10(np.max((fii, fmin)))))
		self.qslider_fii.blockSignals(False)
		self.qslider_fd.blockSignals(True)
		self.qslider_fd.setValue((100*np.log10(np.max((fd, fmin)))))
		self.qslider_fd.blockSignals(False)
		self.qslider_fdf.blockSignals(True)
		self.qslider_fdf.setValue((100*np.log10(np.max((fdf, fmin)))))
		self.qslider_fdf.blockSignals(False)
		self.qslider_kp.blockSignals(True)
		self.qslider_kp.setValue(np.max((10*kp, 10*gain_min)))
		self.qslider_kp.blockSignals(False)
		
		# Update the display:
		self.checkFirmwareLimits()
		self.updateFilterSettings()
		self.updateGraph()

	def textboxChanged_withoutUpdatingFPGA(self):
#        print('textboxChanged()')
#        traceback.print_stack()
	
		# Read the settings from the textboxes
		(kp, fi, fii, fd, fdf, fmin, fmax, gain_min, gain_max, bLock) = self.getSettings()
		# Update the sliders to match:
		# We block the signals from the sliders so we don't cause infinite recursion
#        self.qslider_fi.setValue((100*np.log10(fi)))
		self.qslider_fi.blockSignals(True)
		self.qslider_fi.setValue((100*np.log10(np.max((fi, fmin)))))
		self.qslider_fi.blockSignals(False)
		self.qslider_fii.blockSignals(True)
		self.qslider_fii.setValue((100*np.log10(np.max((fii, fmin)))))
		self.qslider_fii.blockSignals(False)
		self.qslider_fd.blockSignals(True)
		self.qslider_fd.setValue((100*np.log10(np.max((fd, fmin)))))
		self.qslider_fd.blockSignals(False)
		self.qslider_fdf.blockSignals(True)
		self.qslider_fdf.setValue((100*np.log10(np.max((fdf, fmin)))))
		self.qslider_fdf.blockSignals(False)
		self.qslider_kp.blockSignals(True)
		self.qslider_kp.setValue(np.max((10*kp, 10*gain_min)))
		self.qslider_kp.blockSignals(False)
		
		# Update the display:
		self.checkFirmwareLimits()
		self.updateGraph()
		
	def checkFirmwareLimits(self):
#        traceback.print_stack()
		(P_gain, I_gain, II_gain, D_gain, D_coef, bLock) = self.getActualControllerDesign()
		
		# Read the firmware gain limits to check if the values are within range:
		self.getLimits()
		
		if self.kp_min <= P_gain and P_gain <= self.kp_max:
			self.qlabel_kp.setStyleSheet("background-color: #F0F0F0")
		else:
			# red background
			self.qlabel_kp.setStyleSheet("background-color: #FF0000")

		if self.ki_min <= I_gain and I_gain <= self.ki_max:
			self.qlabel_fi.setStyleSheet("background-color: #F0F0F0")
		else:
			# red background
			self.qlabel_fi.setStyleSheet("background-color: #FF0000")
			
		if self.kii_min <= II_gain and II_gain <= self.kii_max:
			self.qlabel_fii.setStyleSheet("background-color: #F0F0F0")
		else:
			# red background
			self.qlabel_fii.setStyleSheet("background-color: #FF0000")
			
		if self.kd_min <= D_gain and D_gain <= self.kd_max:
			self.qlabel_fd.setStyleSheet("background-color: #F0F0F0")
		else:
			# red background
			self.qlabel_fd.setStyleSheet("background-color: #FF0000")
			
		if self.kdf_min <= D_coef and D_coef <= self.kdf_max:
			self.qlabel_fdf.setStyleSheet("background-color: #F0F0F0")
		else:
			# red background
			self.qlabel_fdf.setStyleSheet("background-color: #FF0000")
		
	def getLimits(self):
		
		(kp_min, kp_max) = self.sl.pll[self.filter_number].get_p_limits()
		self.kp_min = kp_min
		self.kp_max = kp_max
		(ki_min, ki_max) = self.sl.pll[self.filter_number].get_i_limits()
		self.ki_min = ki_min
		self.ki_max = ki_max
		(kii_min, kii_max) = self.sl.pll[self.filter_number].get_ii_limits()
		self.kii_min = kii_min
		self.kii_max = kii_max
		(kd_min, kd_max) = self.sl.pll[self.filter_number].get_d_limits()
		self.kd_min = kd_min
		self.kd_max = kd_max
		(kdf_min, kdf_max, kfd_den) = self.sl.pll[self.filter_number].get_df_limits()
		self.kdf_min = kdf_min
		self.kdf_max = kdf_max
		self.kfd_den = kfd_den
		
	def updateTooltips(self):
		
		# Get the firmware gain limits and show them in the tooltips
		self.getLimits()
		(kp, fi, fii, fd, fdf, fmin, fmax, gain_min, gain_max, bLock) = self.getSettings()
		
		# to prevent divides by zero:
		if fi == 0.0:
			fi = 1e-12
		
		if self.qchk_bKpCrossing.isChecked() == False:
			if self.kp_min * self.kc == 0.0:
				kp_min_dB = float('-inf')
			else:
				kp_min_dB = 20*np.log10(self.kp_min * self.kc)
				
			kp_max_dB = 20*np.log10(self.kp_max * self.kc)
			fi_min = self.ki_min * self.kc / (2*np.pi/self.sl.fs)
			fi_max = self.ki_max * self.kc / (2*np.pi/self.sl.fs)
			fii_min = self.kii_min *self.kc / fi / (2*np.pi/self.sl.fs)**2
			fii_max = self.kii_max *self.kc / fi / (2*np.pi/self.sl.fs)**2
			fd_min = self.kd_min * self.kc * fd * (2*np.pi/self.sl.fs)
			fd_max = self.kd_max * self.kc * fd * (2*np.pi/self.sl.fs)
		else:
			
			if self.kp_min * self.kc == 0.0:
				kp_min_dB = float('-inf')
			else:
				kp_min_dB = 20*np.log10(self.kp_min * self.kc)
			kp_max_dB = 20*np.log10(self.kp_max * self.kc)
			fi_min = self.ki_min * self.kc/10**(kp/20) / (2*np.pi/self.sl.fs)
			fi_max = self.ki_max * self.kc/10**(kp/20) / (2*np.pi/self.sl.fs)
			fii_min = self.kii_min *self.kc/10**(kp/20) / fi / (2*np.pi/self.sl.fs)**2
			fii_max = self.kii_max *self.kc/10**(kp/20) / fi / (2*np.pi/self.sl.fs)**2
			fd_min = self.kd_min * self.kc/10**(kp/20) * fd * (2*np.pi/self.sl.fs)
			fd_max = self.kd_max * self.kc/10**(kp/20) * fd * (2*np.pi/self.sl.fs)
		fdf_min = (self.sl.fs*self.kdf_min)/(2*np.pi*self.kfd_den)
		fdf_max = (self.sl.fs*self.kdf_max)/(2*np.pi*self.kfd_den)
			
		self.qedit_kp.setToolTip('Proportional gain in dB: [{:.2f}, {:.2f}]'.format(kp_min_dB, kp_max_dB))
		self.qedit_fi.setToolTip('Integrator cross-over frequency in Hz: [{:.2e}, {:.2e}]'.format(fi_min, fi_max))
		self.qedit_fii.setToolTip('Double integrator cross-over frequency in Hz: [{:.2e}, {:.2e}]'.format(fii_min, fii_max))
		self.qedit_fd.setToolTip('Differentiator cross-over frequency in Hz: [{:.2e}, {:.2e}]'.format(fd_min, fd_max))
		self.qedit_fdf.setToolTip('Differentiator filter roll-off frequency in Hz: [{:.2e}, {:.2e}]'.format(fdf_min, fdf_max))
	
	def getActualControllerDesign(self):
		(kp, fi, fii, fd, fdf, fmin, fmax, gain_min, gain_max, bLock) = self.getSettings()
		
		if self.qchk_bKpCrossing.isChecked() == False:
			# I is relative to 1/kc
			# all the values here are relative to the open-loop DC gain of the system, self.kc:
			P_gain = 10**(kp/20)/self.kc
			I_gain = 1/self.kc * fi * (2*np.pi/self.sl.fs)
			II_gain = 1/self.kc * fi * fii * (2*np.pi/self.sl.fs)**2
			if fd == 0.0:
				D_gain = 0.0
			else:
				D_gain = 1/self.kc * self.sl.fs / (2*np.pi*fd)
		else:
			# I is relative to kp/kc
			# all the values here are relative to the open-loop DC gain of the system, self.kc:
			P_gain = 10**(kp/20)/self.kc
			I_gain = 10**(kp/20)/self.kc * fi * (2*np.pi/self.sl.fs)
			II_gain = 10**(kp/20)/self.kc * fi * fii * (2*np.pi/self.sl.fs)**2
			if fd == 0.0:
				D_gain = 0.0
			else:
				D_gain = 10**(kp/20)/self.kc * self.sl.fs / (2*np.pi*fd)
		
		D_coef = (2*np.pi*fdf) / self.sl.fs
		
			
		if self.qchk_kp.isChecked() == False:
			P_gain = 0
		if self.qchk_kd.isChecked() == False:
			D_gain = 0
			
			
		return (P_gain, I_gain, II_gain, D_gain, D_coef, bLock)
		
	@logCommsErrorsAndBreakoutOfFunction()
	def updateFilterSettings(self):
#        print('LoopFiltersUI::updateFilterSettings(): Entering')
#		traceback.print_stack()

		(P_gain, I_gain, II_gain, D_gain, D_coef, bLock) = self.getActualControllerDesign()
		
		self.sl.pll[self.filter_number].set_pll_settings(self.sl, P_gain, I_gain, II_gain, D_gain, D_coef, bLock)
#        print('LoopFiltersUI::updateFilterSettings(): Exiting')
		
	@logCommsErrorsAndBreakoutOfFunction()
	def getFilterSettings(self):

		(P_gain, I_gain, II_gain, D_gain, D_coef, bLock) = self.sl.pll[self.filter_number].get_pll_settings(self.sl)
		
		# print("P_gain %f" % P_gain)
		# print("I_gain %f" % I_gain)
		# print("II_gain %f" % II_gain)
		# print("D_gain %f" % D_gain)
		# print("D_coef %f" % D_coef)
		# print("bLock %f" % bLock)

		if P_gain == 0:
			kp = -120
			self.qchk_bKpCrossing.setChecked(False) #We don't want to define fi, fii and fd with kp if kp is off

		else:
			kp = np.log10(P_gain*self.kc)*20
#            print("kp %f" % kp)



		if self.qchk_bKpCrossing.isChecked() == False:

			fi = float(I_gain)*float(self.kc)*float(self.sl.fs)/(float(2)*float(np.pi))
#            print("fi %f" % fi)
			try:
				fii = II_gain*self.kc/fi/((2*np.pi/self.sl.fs)**2)
			except:
				fii = 0
#            print("fii %f" % fii)

			if D_gain == 0:
				fd = 0
			else:
				fd = 1/(D_gain*self.kc/self.sl.fs*2*np.pi)
#            print("fd %f" % fd)

		else:
			fi = (I_gain*self.kc*self.sl.fs/(2*np.pi))/10**(kp/20)
			#print("fi %f" % fi)
			try:
				fii = II_gain*self.kc/fi/10**(kp/20)/((2*np.pi/self.sl.fs)**2)
			except:
				fii = 0
			#print("fii %f" % fii)
			if D_gain == 0:
				fd = 0
			else:
				fd = 1/(D_gain/(10**(kp/20))*self.kc/self.sl.fs*2*np.pi)
			#print("fd %f" % fd)

		fdf = D_coef*self.sl.fs/(2*np.pi)

		# print("kp %f" % kp)
		# print("fi %f" % fi)
		# print("fii %f" % fii)
		# print("fd %f" % fd)
		# print("fdf %f" % fdf)

		# Update the values in the UI to reflect the internal values:
		# We block the signals first because otherwise the edit box event handler will try to change the values.
		# We instead call textboxChanged() explicitely at the end

		self.qedit_kp.blockSignals(True)
		self.qedit_fi.blockSignals(True)
		self.qedit_fii.blockSignals(True)
		self.qedit_fd.blockSignals(True)
		self.qedit_fdf.blockSignals(True)

		if kp == -120:
			self.qedit_kp.setText('0')
			self.qchk_kp.setChecked(False)
		else:
			self.qedit_kp.setText('{:.3e}'.format(kp))
			self.qchk_kp.setChecked(True)
		
		self.qedit_fi.setText('{:.3e}'.format(fi))
		self.qedit_fii.setText('{:.3e}'.format(fii))
		self.qedit_fd.setText('{:.3e}'.format(fd))
		self.qedit_fdf.setText('{:.3e}'.format(fdf))
		
		self.qedit_kp.blockSignals(False)
		self.qedit_fi.blockSignals(False)
		self.qedit_fii.blockSignals(False)
		self.qedit_fd.blockSignals(False)
		self.qedit_fdf.blockSignals(False)
		
		if fd == 0:
			self.qchk_kd.setChecked(False)
		else:
			self.qchk_kd.setChecked(True)

		if bLock == 1:
			self.qchk_lock.setChecked(True) #Nothing on the gui, but XEM_GUI_MainWindow use this qchk to check at the lock
		else:
			self.qchk_lock.setChecked(False)


		try:
			fmin = 10.0
		except:
			fmin = 10.0
		try:
			fmax = 10e6
		except:
			fmax = 10e6
			
		gain_min = -30
		gain_max = 100

		self.qslider_fi.blockSignals(True)
		self.qslider_fi.setValue((100*np.log10(np.max((fi, fmin)))))
		self.qslider_fi.blockSignals(False)
		self.qslider_fii.blockSignals(True)
		self.qslider_fii.setValue((100*np.log10(np.max((fii, fmin)))))
		self.qslider_fii.blockSignals(False)
		self.qslider_fd.blockSignals(True)
		self.qslider_fd.setValue((100*np.log10(np.max((fd, fmin)))))
		self.qslider_fd.blockSignals(False)
		self.qslider_fdf.blockSignals(True)
		self.qslider_fdf.setValue((100*np.log10(np.max((fdf, fmin)))))
		self.qslider_fdf.blockSignals(False)
		self.qslider_kp.blockSignals(True)
		self.qslider_kp.setValue(np.max((10*kp, 10*gain_min)))
		self.qslider_kp.blockSignals(False)
		
		self.textboxChanged_withoutUpdatingFPGA() # To update the sliders

				
	def bKpCrossingPress(self):
		(kp, fi, fii, fd, fdf, fmin, fmax, gain_min, gain_max, bLock) = self.getSettings()
		if self.qchk_bKpCrossing.isChecked(): #Give new state
			#print('Was referring to 0db, now refer to kp')
			I_gain = 1/self.kc * fi * (2*np.pi/self.sl.fs)
			fi = (I_gain*self.kc*self.sl.fs/(2*np.pi))/10**(kp/20)
		else:
			#print('Was referring to kp, now refer to 0db')
			I_gain = 10**(kp/20)/self.kc * fi * (2*np.pi/self.sl.fs)
			fi = float(I_gain)*float(self.kc)*float(self.sl.fs)/(float(2)*float(np.pi))
		self.qedit_fi.blockSignals(True)
		self.qedit_fi.setText('{:.3e}'.format(fi))
		self.qedit_fi.blockSignals(False)
		self.qslider_fi.blockSignals(True)
		self.qslider_fi.setValue((100*np.log10(np.max((fi, fmin)))))
		self.qslider_fi.blockSignals(False)
		self.textboxChanged_withoutUpdatingFPGA() # To update the sliders
		self.textboxChanged()
		
		
	def lockSlider(self):
		if self.qchk_lockSlider.isChecked() == True:
			(kp, fi, fii, fd, fdf, fmin, fmax, gain_min, gain_max, bLock) = self.getSettings()
			self.slider_locked = True
			self.slider_inhibit = False
			self.slider_ratio = float(fdf)/float(fd)
		else:
			self.slider_locked = False
			self.slider_inhibit = False
		
	def updateGraph(self):
#        print('LoopFiltersUI::updateGraph(): Entering')
		#self.updateFilterSettings()
		self.updateTooltips()
		#self.checkFirmwareLimits()
		# Read the settings from the textboxes
		(kp, fi, fii, fd, fdf, fmin, fmax, gain_min, gain_max, bLock) = self.getSettings()
		# print("kp %f" % kp)
		# print("fi %f" % fi)
		# print("fii %f" % fii)
		# print("fd %f" % fd)
		# print("fdf %f" % fdf)
		# print("fmin %f" % fmin)
		# print("fmax %f" % fmax)
		# print("gain_min %f" % gain_min)
		# print("gain_max %f" % gain_max)
		
		# Draw a first line at 0 dB
		f_array = np.array((fmin, fmax))
		gain_array = np.array((1, 1))

		self.curve_0dB.setData(f_array, 20*np.log10(gain_array))
		
		# Draw the P gain curve:
		gain_array = 10**(kp/20) + 0*f_array
#        print(20*np.log10(gain_array))
		self.curve_kp.setData(f_array, 20*np.log10(gain_array))
		# Draw the I gain curve:
		if fi == 0.0:
			gain_array = 10**(gain_min/20 - 1) + 0*f_array
		else:
			if self.qchk_bKpCrossing.isChecked() == False:
				# fi relative to 0 dB crossing
				gain_array = fi/f_array
			else:
				# fi relative to kp dB crossing
				gain_array = 10**(kp/20) * fi/f_array
#        print(20*np.log10(gain_array))
		self.curve_fi.setData(f_array, 20*np.log10(gain_array + self.MINIMUM_GAIN_DISPLAY))
		# Draw the II gain curve:
		if fii == 0.0:
			gain_array = 10**(gain_min/20 - 1) + 0*f_array
		else:
			if self.qchk_bKpCrossing.isChecked() == False:
				# fi relative to 0 dB crossing
				gain_array = fi/f_array * fii/f_array
			else:
				# fi relative to kp dB crossing
				gain_array = 10**(kp/20) * fi/f_array * fii/f_array
#        print(20*np.log10(gain_array))
		self.curve_fii.setData(f_array, 20*np.log10(gain_array + self.MINIMUM_GAIN_DISPLAY))
		
		# Draw the D gain curve:
		if fd == 0.0:
			gain_array = 10**(gain_min/20 - 1) + 0*f_array
		else:
			if self.qchk_bKpCrossing.isChecked() == False:
				# fi relative to 0 dB crossing
				gain_array = f_array/fd
			else:
				# fi relative to kp dB crossing
				gain_array = 10**(kp/20) * f_array/fd
#        print(20*np.log10(gain_array))
		self.curve_fd.setData(f_array, 20*np.log10(gain_array + self.MINIMUM_GAIN_DISPLAY))
		
		#print("fd %f" % fd)
		if (fdf == 0) or (fd == 0):
			gain_array = 0*f_array
		else:
			# Draw the D gain curve:
			if self.qchk_bKpCrossing.isChecked() == False:
				# fi relative to 0 dB crossing
				gain_array = fdf/fd + 0*f_array
			else:
				# fi relative to kp dB crossing
				gain_array = 10**(kp/20) * fdf/fd + 0*f_array
	#        print(20*np.log10(gain_array))
		self.curve_fdf.setData(f_array, 20*np.log10(gain_array + self.MINIMUM_GAIN_DISPLAY))


		f_array = np.logspace(np.log10(fmin), np.log10(fmax), 100)
		actual_gain_array = np.abs(self.sl.pll[self.filter_number].get_current_transfer_function(f_array, self.sl.fs) * self.kc)
		self.curve_actual.setData(f_array, 20*np.log10(actual_gain_array + self.MINIMUM_GAIN_DISPLAY))

		# print('LoopFiltersUI: setting X range: %f, %f' % (fmin, fmax))
		# print('LoopFiltersUI: setting Y range: %f, %f' % (gain_min, gain_max))
		#self.qplot_tf.setXRange(np.log10(fmin), np.log10(fmax))
		self.qplot_tf.setYRange(gain_min, gain_max)


		
		#self.qplot_tf.replot()
		
#        print('LoopFiltersUI::updateGraph(): Exiting')
		
#def main():
#    
#    app = QtGui.QApplication(sys.argv)
#    w = LoopFiltersUI()
#    w.show()
#    w.resize(800, 300)
#    
##    sys.exit(app.exec_())
#    app.exec_()
#
#if __name__ == '__main__':
#    main()    
#    
