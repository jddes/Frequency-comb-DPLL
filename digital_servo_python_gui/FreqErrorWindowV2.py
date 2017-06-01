"""
XEM6010 Phase-lock box GUI, frequency counter display, interfaces to the dual-mode (triangular or rectangular averaging) counter
by JD Deschenes, October 2013

"""

import sys
import time
from PyQt4 import QtGui, Qt
import PyQt4.Qwt5 as Qwt
import numpy as np
import math
from scipy.signal import lfilter
from scipy.signal import decimate

import os
import errno


from SuperLaserLand_JD2 import SuperLaserLand_JD2

import weakref

class FreqErrorWindowV2(QtGui.QWidget):

        
    def __init__(self, sl, strTitle, output_number=0, strNameTemplate='', custom_style_sheet=''):
        super(FreqErrorWindowV2, self).__init__()

        self.strTitle = strTitle
        self.strNameTemplate = strNameTemplate
        self.sl = weakref.proxy(sl)
        self.output_number = output_number
        self.setObjectName('MainWindow')
        self.setStyleSheet(custom_style_sheet)        
        
        self.initUI()
        self.openOutputFiles()
        self.initSL()


#    def __del__(self):
#        # Close data files:
#        if hasattr(self, 'file_output1'):
#            self.file_output1.close()
#        if hasattr(self, 'file_output2'):
#            self.file_output2.close()
            
    def initBuffer(self):
#        print('initBuffer')
        LOG2_N_CYCLES_INTEGRATION = 23
        self.gate_time = (2**LOG2_N_CYCLES_INTEGRATION)/self.sl.fs
        try:
            self.N_history = round(float(self.qedit_history.text()) / self.gate_time)
        except:
            self.N_history = round(10 / self.gate_time)
        
        self.freq_history = np.zeros(self.N_history)
        if self.output_number == 0:
            self.DAC0_history = np.zeros(self.N_history)
        if self.output_number == 1:
            self.DAC1_history = np.zeros(self.N_history)
            self.DAC2_history = np.zeros(self.N_history)
        self.freq_history = np.zeros(self.N_history)
#        self.time_history = np.zeros(self.N_history)
        self.time_history = np.linspace(-self.N_history+1, 0, self.N_history) * self.gate_time
        self.bValid = (np.zeros(self.N_history) == 1)
        self.bVeryFirst = True
            
    def openOutputFiles(self):
        
        
        # Create the subdirectory if it doesn't exist:
        self.make_sure_path_exists('data_logging')

        # Open file for output
        strCurrentName1 = self.strNameTemplate + 'freq_counter0.bin'
        strCurrentName2 = self.strNameTemplate + 'freq_counter1.bin'
        strCurrentName3 = self.strNameTemplate + 'freq_counter0_time_axis.bin'
        strCurrentName4 = self.strNameTemplate + 'DAC0.bin'
        strCurrentName5 = self.strNameTemplate + 'DAC1.bin'
        strCurrentName6 = self.strNameTemplate + 'DAC2.bin'
        self.file_output_counter0 = open(strCurrentName1, 'wb')
        self.file_output_counter1 = open(strCurrentName2, 'wb')
        self.file_output_time = open(strCurrentName3, 'wb')
        self.file_output_dac0 = open(strCurrentName4, 'wb')
        self.file_output_dac1 = open(strCurrentName5, 'wb')
        self.file_output_dac2 = open(strCurrentName6, 'wb')
        
    def initSL(self):
        
#        print('initSL')
        self.initBuffer()
        # Start timer which grabs data
        self.timerID = self.startTimer(500)

    def chkTriangular_checked(self):
        if self.qchk_triangular.isChecked():
            self.sl.setCounterMode(True)
        else:
            self.sl.setCounterMode(False)

    def initUI(self):
        
        # Put everything in a groupbox so we can change the border of the window without it looking too obnoxious:
        self.qgroupbox_freq = Qt.QGroupBox('')
        self.qgroupbox_freq.setAutoFillBackground(True)

        # Add a QwtPlot to the UI:
        self.qplt_freq = Qwt.QwtPlot()
        self.qplt_freq.setTitle('Lock #%d Frequency error' % (self.output_number))
        self.qplt_freq.setCanvasBackground(Qt.Qt.white)
        
        plotgrid = Qwt.QwtPlotGrid()
        plotgrid.setMajPen(Qt.QPen(Qt.Qt.black, 0, Qt.Qt.DotLine));
        plotgrid.setMinPen(Qt.QPen(Qt.Qt.black, 0, Qt.Qt.DotLine));
        plotgrid.attach(self.qplt_freq);
        
        # Add another QwtPlot to the UI:
        self.qplt_dac = Qwt.QwtPlot()
        self.qplt_dac.setTitle('Lock #%d DAC outputs' % (self.output_number))
        self.qplt_dac.setCanvasBackground(Qt.Qt.white)
        self.qplt_dac.setAxisScale(Qwt.QwtPlot.yLeft, 0, 1)
        
        plotgrid = Qwt.QwtPlotGrid()
        plotgrid.setMajPen(Qt.QPen(Qt.Qt.black, 0, Qt.Qt.DotLine));
        plotgrid.setMinPen(Qt.QPen(Qt.Qt.black, 0, Qt.Qt.DotLine));
        plotgrid.attach(self.qplt_dac);
        
        # Create the curve in the plot
        self.curve_freq_error = Qwt.QwtPlotCurve('Spectrum')
        self.curve_freq_error.attach(self.qplt_freq)
        self.curve_freq_error.setPen(Qt.QPen(Qt.Qt.blue))
        
        # Create the curve in the plot
        if self.output_number == 0:
            self.curve_dac0 = Qwt.QwtPlotCurve('DAC')
            self.curve_dac0.attach(self.qplt_dac)
            self.curve_dac0.setPen(Qt.QPen(Qt.Qt.blue))
            
        if self.output_number == 1:
            self.curve_dac1 = Qwt.QwtPlotCurve('DAC')
            self.curve_dac1.attach(self.qplt_dac)
            self.curve_dac1.setPen(Qt.QPen(Qt.Qt.blue))
            
            self.curve_dac2 = Qwt.QwtPlotCurve('DAC')
            self.curve_dac2.attach(self.qplt_dac)
            self.curve_dac2.setPen(Qt.QPen(Qt.Qt.red))
        
        # Create widgets to specify buffer length and clear buffer:
        self.qbtn_reset = Qt.QPushButton('Clear display')
        self.qbtn_reset.clicked.connect(self.initBuffer)
        self.qlabel_history = Qt.QLabel('Display [s]')
        self.qedit_history = Qt.QLineEdit('600')
        self.qedit_history.setMaximumWidth(40)
        self.qedit_history.textChanged.connect(self.initBuffer)
        

        self.qchk_fullscale_freq = Qt.QCheckBox('Fullscale Freq Graph')
        self.qchk_fullscale_freq.setChecked(True)
        
        self.qchk_fullscale_dac = Qt.QCheckBox('Fullscale DAC Graph')
        self.qchk_fullscale_dac.setChecked(True)
        
        self.qchk_triangular = Qt.QCheckBox('Triangular averaging')
        self.qchk_triangular.setChecked(True)
        self.qchk_triangular.clicked.connect(self.chkTriangular_checked)
        
        # Put the two graphs into a vertical box layout, so that they share all the vertical space equally:
        vbox = QtGui.QVBoxLayout()
        vbox.addWidget(self.qplt_freq)
        vbox.addWidget(self.qplt_dac)
        
        # Put all the widgets into a grid layout
        grid = QtGui.QGridLayout()        
        grid.addLayout(vbox,                                0, 2, 5, 1)
        
        grid.addWidget(self.qbtn_reset,                     0, 0, 1, 2)
        grid.addWidget(self.qlabel_history,                 1, 0)
        grid.addWidget(self.qedit_history,                  1, 1)
        grid.addWidget(self.qchk_fullscale_freq,            2, 0, 1, 2)
        grid.addWidget(self.qchk_fullscale_dac,             3, 0, 1, 2)
        grid.addWidget(self.qchk_triangular,                4, 0, 1, 2)
        
        grid.addWidget(Qt.QLabel(''),                       5, 0, 1, 2)
        grid.setRowStretch(5, 1)
        grid.setColumnStretch(2, 1)
        
        
        self.qgroupbox_freq.setLayout(grid)

        vbox2 = Qt.QVBoxLayout()
        vbox2.addWidget(self.qgroupbox_freq)
        self.setLayout(vbox2)
#        self.setLayout(vbox)

        # Adjust the size and position of the window
        # self.resize(800, 480)
        self.center()
        self.setWindowTitle(self.strTitle)    
        self.show()
        
    def center(self):
        
        qr = self.frameGeometry()
        cp = QtGui.QDesktopWidget().availableGeometry().center()
#        print()
#        5435sdfsf
#        qr.moveCenter(cp)
#        self.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(800+100, 50))
        if self.output_number == 0:
            self.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(985, 10))
        else:
            self.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(985, 10+450+80))
            
    def timerEvent(self, e):
        
#        print('timerEvent, timerID = %d' % self.timerID)
        self.displayFreqCounter()
        
        return
        
    def displayFreqCounter(self):
        (freq_counter_samples, time_axis, DAC0_output, DAC1_output, DAC2_output) = self.sl.read_zero_deadtime_freq_counter(self.output_number)
        
        if type(time_axis) != type(0):
            # scale to seconds:
            time_axis = time_axis.astype(float) * self.gate_time
            # Write data to disk:
            self.file_output_time.write(time_axis)
            
        if type(DAC0_output) != type(0):
            # Scale to minimum and maximum limits: 0 means minimum, 1 means maximum
            DAC0_output = (DAC0_output - self.sl.DACs_limit_low[0]).astype(np.float)/float(self.sl.DACs_limit_high[0] - self.sl.DACs_limit_low[0])
            # Write data to disk:
            self.file_output_dac0.write(DAC0_output)
            
        if type(DAC1_output) != type(0):
            # Scale to minimum and maximum limits: 0 means minimum, 1 means maximum
            DAC1_output = (DAC1_output - self.sl.DACs_limit_low[1]).astype(np.float)/float(self.sl.DACs_limit_high[1] - self.sl.DACs_limit_low[1])
            # Write data to disk:
            self.file_output_dac1.write(DAC1_output)
            
        if type(DAC2_output) != type(0):
            # Scale to minimum and maximum limits: 0 means minimum, 1 means maximum
            DAC2_output = (DAC2_output - self.sl.DACs_limit_low[2]).astype(np.float)/float(self.sl.DACs_limit_high[2] - self.sl.DACs_limit_low[2])
            # Write data to disk:
            self.file_output_dac2.write(DAC2_output)
            
        if type(freq_counter_samples) != type(0):
            if self.bVeryFirst == True:
                # We flush the first two samples because the system isn't fully initialized and they always force the plot scale too wide
                freq_counter_samples = freq_counter_samples[2:]
                if self.output_number == 0:
                    DAC0_output = DAC0_output[2:]
                if self.output_number == 1:
                    DAC1_output = DAC1_output[2:]
                    DAC2_output = DAC2_output[2:]
                self.bVeryFirst = False
                
            # Write data to disk:
            if self.output_number == 0:
                self.file_output_counter0.write(freq_counter_samples)
            elif self.output_number == 1:
                self.file_output_counter1.write(freq_counter_samples)
                        
            # Record the new chunk of data in the buffer:
            self.freq_history[:-len(freq_counter_samples)] = self.freq_history[len(freq_counter_samples):]
            self.freq_history[-len(freq_counter_samples):] = freq_counter_samples
            
            if self.output_number == 0:
                self.DAC0_history[:-len(freq_counter_samples)] = self.DAC0_history[len(freq_counter_samples):]
                self.DAC0_history[-len(freq_counter_samples):] = DAC0_output
            if self.output_number == 1:
                self.DAC1_history[:-len(freq_counter_samples)] = self.DAC1_history[len(freq_counter_samples):]
                self.DAC1_history[-len(freq_counter_samples):] = DAC1_output
                self.DAC2_history[:-len(freq_counter_samples)] = self.DAC2_history[len(freq_counter_samples):]
                self.DAC2_history[-len(freq_counter_samples):] = DAC2_output
                
#            self.time_history[:-len(freq_counter_samples)] = self.time_history[len(freq_counter_samples):]
#            self.time_history[-len(freq_counter_samples):] = time_axis
            
            self.bValid[:-len(freq_counter_samples)] = self.bValid[len(freq_counter_samples):]
            self.bValid[-len(freq_counter_samples):] = True
            
            # Update graph:
            self.curve_freq_error.setData(self.time_history[self.bValid] - self.time_history[len(self.time_history)-1], self.freq_history[self.bValid])            
            self.qplt_freq.setTitle('Lock #%d Frequency error, mean = %f Hz, std = %.3f mHz' % (self.output_number, np.mean(self.freq_history[self.bValid]), 1e3*np.std(self.freq_history[self.bValid])))
            if self.qchk_fullscale_freq.isChecked():
                self.qplt_freq.setAxisScaleEngine(Qwt.QwtPlot.yLeft, Qwt.QwtLinearScaleEngine())
                self.qplt_freq.setAxisScale(Qwt.QwtPlot.yLeft, -5e6, 5e6)
            else:
                self.qplt_freq.setAxisAutoScale(Qwt.QwtPlot.yLeft)
                
            self.qplt_freq.replot()
            
            # Update graph:
            if self.output_number == 0:
                self.curve_dac0.setData(self.time_history[self.bValid] - self.time_history[len(self.time_history)-1], self.DAC0_history[self.bValid])            
                self.qplt_dac.setTitle('Lock #%d DAC outputs, last raw code = %f' % (self.output_number, self.DAC0_history[-1]))
                
            if self.output_number == 1:
                self.curve_dac1.setData(self.time_history[self.bValid] - self.time_history[len(self.time_history)-1], self.DAC1_history[self.bValid])            
                self.curve_dac2.setData(self.time_history[self.bValid] - self.time_history[len(self.time_history)-1], self.DAC2_history[self.bValid])            
                self.qplt_dac.setTitle('Lock #%d DAC outputs, last raw codes = %f, %f' % (self.output_number, self.DAC1_history[-1], self.DAC2_history[-1]))
            
            if self.qchk_fullscale_dac.isChecked():
                self.qplt_dac.setAxisScaleEngine(Qwt.QwtPlot.yLeft, Qwt.QwtLinearScaleEngine())
                self.qplt_dac.setAxisScale(Qwt.QwtPlot.yLeft, 0, 1)
            else:
                self.qplt_dac.setAxisAutoScale(Qwt.QwtPlot.yLeft)
                
            self.qplt_dac.replot()
            

    # From: http://stackoverflow.com/questions/273192/create-directory-if-it-doesnt-exist-for-file-write
    def make_sure_path_exists(self, path):
        try:
            os.makedirs(path)
        except OSError as exception:
            if exception.errno != errno.EEXIST:
                raise
                
