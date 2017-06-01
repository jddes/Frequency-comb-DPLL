"""
XEM6010 Phase-lock box GUI, Transfer function display window
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
import copy

# For make_sure_path_exists()
import os
import errno

import weakref

class DisplayCrashMonitorWindow(QtGui.QWidget):

        
    def __init__(self, crash_data, crash_number, strFGPASerialNumber, sl, input_number):
        super(DisplayCrashMonitorWindow, self).__init__()
        print('DisplayCrashMonitorWindow::__init__()')
        self.crash_number = copy.copy(crash_number)
        self.crash_data = copy.copy(crash_data)
        self.sl = weakref.proxy(sl)
        self.input_number = input_number
        self.strFGPASerialNumber = strFGPASerialNumber
        
        self.writeOutputFile()
        
        self.setWindowTitle('Crash #%d' % crash_number)
        
        self.initUI()
#        self.initSL()
        
        self.updateGraph()


    def writeOutputFile(self):
        
        print('writing output file')
        # Create the subdirectory if it doesn't exist:
        self.make_sure_path_exists('crash_data')

        # Open file for output
        self.strNameTemplate = time.strftime("crash_data\%m_%d_%Y_%H_%M_%S")
        
        strCurrentName = self.strNameTemplate + ('_crash_data_%s_%03d.bin' % (self.strFGPASerialNumber, self.crash_number))
        f = open(strCurrentName, 'wb')
        f.write(self.crash_data)
        f.close()
        

            
        
    def initUI(self):
        print('DisplayCrashMonitorWindow::initUI()')
        
        # Add controls for the x axis:
        self.qedit_x0 = Qt.QLineEdit('-4.096e3')
        self.qedit_x1 = Qt.QLineEdit('4.096e3')
        self.qedit_x0.textChanged.connect(self.updateGraph)
        self.qedit_x1.textChanged.connect(self.updateGraph)
        
        # Add a first QwtPlot to the UI:
        self.qplt1 = Qwt.QwtPlot()
        self.qplt1.setTitle('ADC0')
        self.qplt1.setCanvasBackground(Qt.Qt.white)
#        self.qplt1.setAxisScaleEngine(Qwt.QwtPlot.xBottom, Qwt.QwtLog10ScaleEngine())
        
        self.qplt2 = Qwt.QwtPlot()
        self.qplt2.setTitle('Instantaneous frequency [MHz]')
        self.qplt2.setCanvasBackground(Qt.Qt.white)
        
        self.qplt3 = Qwt.QwtPlot()
        self.qplt3.setTitle('DAC0 [Volts]')
        self.qplt3.setCanvasBackground(Qt.Qt.white)
        
        self.qplt4 = Qwt.QwtPlot()
        self.qplt4.setTitle('DAC1 [Volts]')
        self.qplt4.setCanvasBackground(Qt.Qt.white)

        # Create the curves in the plots
        self.curve1 = Qwt.QwtPlotCurve()
        self.curve1.attach(self.qplt1)
        self.curve1.setPen(Qt.QPen(Qt.Qt.blue))
#        self.curve1.setSymbol(Qwt.QwtSymbol(Qwt.QwtSymbol.Ellipse,
#                                    Qt.QBrush(Qt.Qt.red),
#                                    Qt.QPen(Qt.Qt.red),
#                                    Qt.QSize(3, 3)))
#        self.curve1.setRenderHint(Qwt.QwtPlotItem.RenderAntialiased);
        
        self.curve2 = Qwt.QwtPlotCurve()
        self.curve2.attach(self.qplt2)
        self.curve2.setPen(Qt.QPen(Qt.Qt.blue))
#        self.curve1.setSymbol(Qwt.QwtSymbol(Qwt.QwtSymbol.Ellipse,
#                                    Qt.QBrush(Qt.Qt.red),
#                                    Qt.QPen(Qt.Qt.red),
#                                    Qt.QSize(3, 3)))
#        self.curve1.setRenderHint(Qwt.QwtPlotItem.RenderAntialiased);
        
        self.curve3 = Qwt.QwtPlotCurve()
        self.curve3.attach(self.qplt3)
        self.curve3.setPen(Qt.QPen(Qt.Qt.blue))
#        self.curve1.setSymbol(Qwt.QwtSymbol(Qwt.QwtSymbol.Ellipse,
#                                    Qt.QBrush(Qt.Qt.red),
#                                    Qt.QPen(Qt.Qt.red),
#                                    Qt.QSize(3, 3)))
#        self.curve1.setRenderHint(Qwt.QwtPlotItem.RenderAntialiased);
        
        self.curve4 = Qwt.QwtPlotCurve()
        self.curve4.attach(self.qplt4)
        self.curve4.setPen(Qt.QPen(Qt.Qt.blue))

        
        vbox = Qt.QVBoxLayout()
        
        hbox = Qt.QHBoxLayout()
        hbox.addWidget(self.qedit_x0)
        hbox.addWidget(self.qedit_x1)
        hbox.addSpacing(1)
        
        vbox.addLayout(hbox)
        vbox.addWidget(self.qplt1)
        vbox.addWidget(self.qplt2)
        vbox.addWidget(self.qplt3)
        vbox.addWidget(self.qplt4)
        
        
        self.setLayout(vbox)
        #self.setGeometry(300, 250, 1400, 800)
        self.show()
        
    def center(self):
        
        qr = self.frameGeometry()
        cp = QtGui.QDesktopWidget().availableGeometry().center()
#        print()
#        5435sdfsf
        qr.moveCenter(cp)
        self.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(800+100, 50))

    def updateGraph(self):
        
        N = 2**13
        
        data_adc = self.crash_data[0:N-2]
        data_dac0 = self.crash_data[N:2*N-2]/2.**15*2.
        data_dac1 = self.crash_data[2*N-1:3*N-1]/2.**15*8.
        
        # Extract instantaneous frequency:
        complex_baseband = self.sl.frontend_DDC_processing(data_adc, 1., self.input_number)
        f_inst = np.diff(np.unwrap(np.angle(complex_baseband)))/2/np.pi * self.sl.fs
        

        x_axis = np.arange(len(self.crash_data))
        self.curve1.setData(x_axis[0:N-2]-N/2, data_adc)
        self.curve2.setData(x_axis[0:N-2]-N/2, f_inst/1e6)
        self.curve3.setData(x_axis[0:N-2]-N/2, data_dac0)
        self.curve4.setData(x_axis[0:N-2]-N/2, data_dac1)
        
        try:
            x0 = float(self.qedit_x0.text())
        except:
            x0 = -8e3
            
        try:
            x1 = float(self.qedit_x1.text())
        except:
            x1 = 8e3
            
        self.qplt1.setAxisScale(Qwt.QwtPlot.xBottom, x0, x1)
        self.qplt2.setAxisScale(Qwt.QwtPlot.xBottom, x0, x1)
        self.qplt3.setAxisScale(Qwt.QwtPlot.xBottom, x0, x1)
        self.qplt4.setAxisScale(Qwt.QwtPlot.xBottom, x0, x1)
        
        self.qplt1.replot()
        self.qplt2.replot()
        self.qplt3.replot()
        self.qplt4.replot()
        
    # From: http://stackoverflow.com/questions/273192/create-directory-if-it-doesnt-exist-for-file-write
    def make_sure_path_exists(self, path):
        try:
            os.makedirs(path)
        except OSError as exception:
            if exception.errno != errno.EEXIST:
                raise
                
