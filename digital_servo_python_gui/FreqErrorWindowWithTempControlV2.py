"""
XEM6010 Phase-lock box GUI, frequency counter display, interfaces to the dual-mode (triangular or rectangular averaging) counter
by JD Deschenes, October 2013

"""
from __future__ import print_function

import sys
import time
from PyQt5 import QtGui, Qt, QtCore
#import PyQt5.Qwt5 as Qwt
import numpy as np
import math


import os
import errno
import sys


#from SuperLaserLand_JD2 import SuperLaserLand_JD2

# To communicate with the temperature controller process
import AsyncSocketComms

import weakref

# stuff for Python 3 port
import pyqtgraph as pg
import logging

from SocketErrorLogger import logCommsErrorsAndBreakoutOfFunction

class FreqErrorWindowWithTempControlV2(QtGui.QWidget):

    def __init__(self, sl, strTitle, sp, output_number=0, strNameTemplate='', custom_style_sheet='', port_number=0, xem_gui_mainwindow=0):
        super(FreqErrorWindowWithTempControlV2, self).__init__()

        self.logger = logging.getLogger(__name__)
        self.logger_name = ':FreqErrorWindowWithTempControlV2'

        self.strTitle = strTitle
        self.strNameTemplate = strNameTemplate
        self.sl = weakref.proxy(sl)
        self.output_number = output_number
        self.setObjectName('MainWindow')
        self.setStyleSheet(custom_style_sheet)
        self.sp = sp
        self.timerID = None
        self.client = None
        self.bIncrementalOnly = False
        
        # Need to pass xem_gui_window as a parameter (to control DAC offset)
        if xem_gui_mainwindow:
            self.xem_gui_mainwindow = weakref.proxy(xem_gui_mainwindow)
        else:
            self.xem_gui_mainwindow = None
        
        self.port_number = port_number
        #print('before openTCPConnection')
        #self.openTCPConnection() #We cannot open TCP connection on init because we still haven't read deviceData.xml
        #print('after openTCPConnection')
        # if self.client is None:
        #     print('Warning: no connection to temp control: {}'.format(strTitle))
            
        self.last_update = time.perf_counter()
        self.initUI()
        self.openOutputFiles()
        
        self.recovery_history = np.array([])


#    def __del__(self):
#        # Close data files:
#        if hasattr(self, 'file_output1'):
#            self.file_output1.close()
#        if hasattr(self, 'file_output2'):
#            self.file_output2.close()

    def loadParameters(self):
        strDAC = 'DAC{:01d}'.format(self.output_number)
        chk = int(self.sp.getValue('Triangular_averaging', strDAC))
        if chk > 0:
            bTriangularAveraging = True
        else:
            bTriangularAveraging = False

        self.qchk_triangular.setChecked(bTriangularAveraging)
        self.load_autoUnlock_and_TempControl()

    def load_autoUnlock_and_TempControl(self):
        chkAutoUnlock           = bool(self.sp.getValue('Auto_unlock', 'chkAutoUnlock').lower() == 'true')
        autoUnlock_threshold    = float(self.sp.getValue('Auto_unlock', 'threshold'))

        self.qchk_autoUnlock.setChecked(chkAutoUnlock)
        self.qedit_unlock_thresh.setText('{:.2}'.format(autoUnlock_threshold))

        if self.output_number == 1:
            chkTempControl                  = bool( self.sp.getValue('Temperature_control', 'chkControl').lower() == 'true')
            tempControl_threshold_step      = float(self.sp.getValue('Temperature_control', 'threshold_step'))
            tempControl_threshold_disable   = float(self.sp.getValue('Temperature_control', 'threshold_disable'))
            tempControl_step_size           = float(self.sp.getValue('Temperature_control', 'step_size'))
            tempControl_step_delay          = int(  self.sp.getValue('Temperature_control', 'step_delay'))
            try:
                self.bIncrementalOnly       = bool( self.sp.getValue('Temperature_control', 'bIncrementalOnly'))
            except KeyError:
                bIncrementalOnly = False

            self.qchk_temp_control.setChecked(chkTempControl) #warning, if bLock is False, this checkbox is going to be set at False in the first loop
            self.qedit_threshold_step.setText('{:.2}'.format(tempControl_threshold_step))
            self.qedit_threshold_disable.setText('{:.2}'.format(tempControl_threshold_disable))
            self.qedit_step_size.setText('{:.2}'.format(tempControl_step_size))
            self.qedit_step_delay.setText('{}'.format(tempControl_step_delay))

            self.qchk_clear_temp_control.setVisible(not self.bIncrementalOnly)
            if not self.bIncrementalOnly:
                self.qchk_clear_temp_control.setChecked(False)

            if chkTempControl == True:
                self.qchk_temp_control.setStyleSheet('background-color: green')
            else:
                self.qchk_temp_control.setStyleSheet('background-color: red')
            


    def pushDefaultValues(self):
        self.loadParameters()
        self.chkTriangular_checked()
        self.initBuffer()
        # Start timer which grabs data
        self.startTimers()

    def pushActualValues(self):
        # Not use for the moment
        self.chkTriangular_checked()
        self.initBuffer()
        # Start timer which grabs data
        self.startTimers()

    def getValues(self):
        self.getTriangular_checked()
        self.load_autoUnlock_and_TempControl() #These values are not saved in the device, load them from the xml file instead
        self.initBuffer()
        # Start timer which grabs data
        self.startTimers()

    def startTimers(self):
        # print("startTimers(): %s" % self.strTitle)
        self.timerID = self.startTimer(500)

    def killTimers(self):
        
        # print("FreqErrorWindowWithTempControlV2::killTimers(): %s" % self.strTitle)
        
        #if self.timerID.isActive():
        if self.timerID is not None:
            self.killTimer(self.timerID)
        

    def openTCPConnection(self):
        start_time = time.perf_counter()
        if self.port_number != 0:
            try:
                time_before = time.perf_counter()
                self.client = AsyncSocketComms.AsyncSocketClient(self.port_number)
                self.last_update = float("-inf")
                self.setpoint_change = 0.
                
                self.logger.info('Red_Pitaya_GUI{}: Starting temperature control on port {}'.format(self.logger_name, self.port_number))
            except Exception as e:
                print(e)
                time_after = time.perf_counter()
                #print('openTCPConnection(): Time taken by AsyncSocketComms.AsyncSocketClient(): %f sec' % (time_after-time_before))
                self.client = None
                self.last_update = time.perf_counter()
                self.setpoint_change = 0.
        else:
            self.client = None
        end_time = time.perf_counter()
        #print('openTCPConnection(): Time taken: %f sec' % (end_time-start_time))
    
    def closeTCPConnection(self):
        if self.client is not None:
            try: #in case it was already close
                self.client.close()
            except Exception as e:
                print('Error while closing the client: {}'.format(e))
            self.client = None
            self.logger.info('Red_Pitaya_GUI{}: Closing temperature control'.format(self.logger_name, self.port_number))

    def initBuffer(self):
#        print('initBuffer')
        self.gate_time_counter = self.sl.N_CYCLES_GATE_TIME/self.sl.fs
        self.gate_time_dacs = self.sl.N_CYCLES_GATE_TIME/self.sl.fs/1
        try:
            self.N_history_counters = int(round(float(self.qedit_history.text()) / self.gate_time_counter))
            self.N_history_dacs = int(round(float(self.qedit_history.text()) / self.gate_time_dacs))
        except:
            self.N_history_counters = int(round(10 / self.gate_time_counter))
            self.N_history_dacs = int(round(10 / self.gate_time_dacs))
        
        self.DAC_history = np.zeros(self.N_history_dacs)
        self.DAC_mean_history = np.zeros(self.N_history_dacs)*np.nan
        self.DAC_thrsh_history = np.zeros(self.N_history_dacs)*np.nan

        if self.output_number == 1:
            self.DAC2_history = np.zeros(self.N_history_dacs)

        self.freq_history = np.zeros(self.N_history_counters)
#        self.time_history = np.zeros(self.N_history)

        self.time_history_counters = np.linspace(-self.N_history_counters+1, 0, self.N_history_counters) * self.gate_time_counter
        self.time_history_dacs = np.linspace(-self.N_history_dacs+1, 0, self.N_history_dacs) * self.gate_time_dacs
        self.bValid_counters = (np.zeros(self.N_history_counters) == 1)
        self.bValid_dacs = (np.zeros(self.N_history_dacs) == 1)
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
        
    @logCommsErrorsAndBreakoutOfFunction()
    def chkTriangular_checked(self, checked=False):
        if self.qchk_triangular.isChecked():
            self.sl.setCounterMode(True)
        else:
            self.sl.setCounterMode(False)
        # self.addTempControlWidget()
        # print('Updating counter mode')

    @logCommsErrorsAndBreakoutOfFunction()
    def getTriangular_checked(self):
        self.bTriangularAveraging = self.sl.getCounterMode()
        
        self.qchk_triangular.blockSignals(True)
        self.qchk_triangular.setChecked(self.sl.bTriangularAveraging)
        self.qchk_triangular.blockSignals(False)

    def initUI(self):
        
        # Put everything in a groupbox so we can change the border of the window without it looking too obnoxious:
        self.qgroupbox_freq = Qt.QGroupBox('')
        self.qgroupbox_freq.setAutoFillBackground(True)

        # Add a QwtPlot to the UI:
        #self.qplt_freq = Qwt.QwtPlot()
        self.qplt_freq = pg.PlotWidget()
        self.qplt_freq.setTitle('Lock #%d Frequency error' % (self.output_number))
        #self.qplt_freq.setCanvasBackground(Qt.Qt.white)
        
        # plotgrid = Qwt.QwtPlotGrid()
        # plotgrid.setMajPen(Qt.QPen(Qt.Qt.black, 0, Qt.Qt.DotLine));
        # plotgrid.setMinPen(Qt.QPen(Qt.Qt.black, 0, Qt.Qt.DotLine));
        # plotgrid.attach(self.qplt_freq);
        self.qplt_freq.showGrid(x=True, y=True)
        
        # Add another QwtPlot to the UI:
        self.qplt_dac = pg.PlotWidget()
        self.qplt_dac.setTitle('Lock #%d DAC outputs' % (self.output_number))
        #self.qplt_dac.setCanvasBackground(Qt.Qt.white)
        self.qplt_dac.setYRange(0, 1)
        
        # plotgrid = Qwt.QwtPlotGrid()
        # plotgrid.setMajPen(Qt.QPen(Qt.Qt.black, 0, Qt.Qt.DotLine));
        # plotgrid.setMinPen(Qt.QPen(Qt.Qt.black, 0, Qt.Qt.DotLine));
        # plotgrid.attach(self.qplt_dac);
        self.qplt_dac.showGrid(x=True, y=True)
        
        # Create the curve in the plot
        self.curve_freq_error = self.qplt_freq.getPlotItem().plot(pen='b')
        #self.curve_freq_error.attach(self.qplt_freq)
        #self.curve_freq_error.setPen(Qt.QPen(Qt.Qt.blue))
        
        # Create the curve in the plot
        self.curve_dac = self.qplt_dac.getPlotItem().plot(pen='b')
        if self.output_number == 1:
            self.curve_dac2 = self.qplt_dac.getPlotItem().plot(pen='r')
        self.curve_dac_uthrsh = self.qplt_dac.getPlotItem().plot(connect='finite', pen=pg.mkPen(0.5, style=QtCore.Qt.DashLine))
        self.curve_dac_lthrsh = self.qplt_dac.getPlotItem().plot(connect='finite', pen=pg.mkPen(0.5, style=QtCore.Qt.DashLine))
                    
        
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
        
        # Controls for the vertical scale of the frequency graph:
        self.qedit_ymin = Qt.QLineEdit('%f' % (-self.sl.fs/4.))
        self.qedit_ymax = Qt.QLineEdit('%f' % (self.sl.fs/4.))

        # Controls for Auto Recovery
        self.qchk_autorecover = Qt.QCheckBox('Auto Recover')
        self.qchk_autorecover.setChecked(False)
        self.qlabel_rec_thresh = Qt.QLabel('Recovery Threshold')
        self.qedit_rec_thresh = Qt.QLineEdit('5')
        self.qedit_rec_thresh.setMaximumWidth(40)


        #Controls for Auto Unlock
        self.qchk_autoUnlock = Qt.QCheckBox('Auto Unlock')
        self.qchk_autoUnlock.setChecked(False)
        self.qlabel_unlock_thresh = Qt.QLabel('Unlock Threshold')
        self.qedit_unlock_thresh = Qt.QLineEdit('0.05')
        self.qedit_unlock_thresh.setMaximumWidth(40)

        if self.output_number == 1: 
            # We add a checkBox to plot the DAC1 and/or DAC2
            self.qchk_show_DAC1 = Qt.QCheckBox('DAC1')
            self.qchk_show_DAC1.setChecked(True)
            self.qchk_show_DAC2 = Qt.QCheckBox('DAC2')
            self.qchk_show_DAC2.setChecked(True)

        
        # Put the two graphs into a vertical box layout, so that they share all the vertical space equally:
        vbox = QtGui.QVBoxLayout()
        vbox.addWidget(self.qplt_freq)
        vbox.addWidget(self.qplt_dac)
        
        # Put all the widgets into a grid layout
        grid = QtGui.QGridLayout()        
        grid.addLayout(vbox,                                0, 2, 16, 1)
        
        grid.addWidget(self.qbtn_reset,                     0, 0, 1, 2)
        grid.addWidget(self.qlabel_history,                 1, 0)
        grid.addWidget(self.qedit_history,                  1, 1)
        grid.addWidget(self.qchk_fullscale_freq,            2, 0, 1, 2)
        grid.addWidget(self.qchk_fullscale_dac,             3, 0, 1, 2)
        grid.addWidget(self.qchk_triangular,                4, 0, 1, 2)

        grid.addWidget(self.qedit_ymin,                     5, 0, 1, 2)
        grid.addWidget(self.qedit_ymax,                     6, 0, 1, 2)        

        #FEATURE        
        # grid.addWidget(self.qchk_autorecover,               7, 0, 1, 2)        
        # grid.addWidget(self.qlabel_rec_thresh,              8, 0)
        # grid.addWidget(self.qedit_rec_thresh,               8, 1)

        grid.addWidget(self.qchk_autoUnlock,               7, 0, 1, 2)        
        grid.addWidget(self.qlabel_unlock_thresh,          8, 0)
        grid.addWidget(self.qedit_unlock_thresh,           8, 1)
        last_widget_line = 8
        if self.output_number == 1: 
            grid.addWidget(self.qchk_show_DAC1,               9, 0)
            grid.addWidget(self.qchk_show_DAC2,               10, 0)
            last_widget_line = 10

        
        if self.output_number == 1: 
            # we need to add the controls which implement the temperature control loop:
            self.qhoriz_line = Qt.QFrame()
            self.qhoriz_line.setFrameShape(Qt.QFrame.HLine)
            self.qhoriz_line.setFrameShadow(Qt.QFrame.Sunken)

            self.qlabel_threshold_step = Qt.QLabel('Threshold for step:')
            self.qedit_threshold_step = Qt.QLineEdit('0.35')
            self.qedit_threshold_step.setMaximumWidth(40)
            
            
            self.qlabel_threshold_disable = Qt.QLabel('Threshold for disable:')
            self.qedit_threshold_disable = Qt.QLineEdit('0.05')
            self.qedit_threshold_disable.setMaximumWidth(40)
            
            self.qlabel_step_size = Qt.QLabel('Step size [deg C]:')
            self.qedit_step_size = Qt.QLineEdit('0.05')
            self.qedit_step_size.setMaximumWidth(40)
            
            self.qlabel_step_delay = Qt.QLabel('Step delay [s]:')
            self.qedit_step_delay = Qt.QLineEdit('60')
            self.qedit_step_delay.setMaximumWidth(40)
            
            self.qchk_temp_control = Qt.QCheckBox('Temperature control')
            self.qchk_temp_control.setChecked(False)
            self.qchk_temp_control.setStyleSheet('background-color: red')
            self.qchk_temp_control.clicked.connect(self.qchk_temp_control_checked)
            
            self.qchk_clear_temp_control = Qt.QCheckBox('Clear Temperature control')
            self.qchk_clear_temp_control.setChecked(False)

            grid.addWidget(self.qhoriz_line,                    11, 0, 1, 2)
            grid.addWidget(self.qlabel_threshold_step,          12, 0)
            grid.addWidget(self.qedit_threshold_step,           12, 1)
            grid.addWidget(self.qlabel_threshold_disable,       13, 0)
            grid.addWidget(self.qedit_threshold_disable,        13, 1)
            grid.addWidget(self.qlabel_step_size,               14, 0)
            grid.addWidget(self.qedit_step_size,                14, 1)
            
            grid.addWidget(self.qlabel_step_delay,              15, 0)
            grid.addWidget(self.qedit_step_delay,               15, 1)
            
            grid.addWidget(self.qchk_temp_control,              16, 0, 1, 2)
            grid.addWidget(self.qchk_clear_temp_control,        17, 0, 1, 2)
            
            
            grid.addWidget(Qt.QLabel(''),                       18, 0, 1, 2)
            grid.setRowStretch(18, 1)
            grid.setColumnStretch(2, 1)

        # else:
            # no controls for the temp control loop
            # grid.addWidget(Qt.QLabel(''),                       8, 0, 1, 2)
            # grid.setRowStretch(8, 1)
            # grid.setColumnStretch(2, 1)
        
        
        self.qgroupbox_freq.setLayout(grid)

        vbox2 = Qt.QVBoxLayout()
        vbox2.addWidget(self.qgroupbox_freq)
        self.setLayout(vbox2)

#        self.setLayout(vbox)

        # Adjust the size and position of the window
        # self.resize(800, 480)
        self.center()
        self.setWindowTitle(self.strTitle)    
        # self.show()
        
    def addTempControlWidget(self):
        # self.client = True
        # self.showUI()
        self.qlabel_threshold_step = None
        self.qedit_threshold_step = None


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
        self.qchk_triangular.blockSignals(True)
        self.qchk_triangular.setChecked(self.sl.bTriangularAveraging)
        self.qchk_triangular.blockSignals(False)
        
        self.displayFreqCounter()
        
        return

    def qchk_temp_control_checked(self):
        if self.qchk_temp_control.isChecked() == True:
            self.qchk_temp_control.setStyleSheet('background-color: green')
            self.openTCPConnection()
        else:
            self.qchk_temp_control.setStyleSheet('background-color: red')
        
    def runTempControlLoop(self, current_time, current_output):
        # Simple algorithm:
        # If the dac2 output crosses a threshold, we send a step to the temperature setpoint to nudge it in the right direction.
        # We then wait for a certain delay before we re-do a step
        # print('runTempControlLoop(): current_time = %f, current_output = %f' % (current_time, current_output))
    
        # Read off the values from the UI:
        try:
            step_delay = float(self.qedit_step_delay.text())
        except:
            step_delay = 0
            
        try:
            threshold_step = float(self.qedit_threshold_step.text())
        except:
            threshold_step = 0.2
            
        try:
            threshold_disable = float(self.qedit_threshold_disable.text())
        except:
            threshold_disable = 0.05
            
        try:
            step_size = float(self.qedit_step_size.text())
        except:
            step_size = 0.01
        


        if self.qchk_temp_control.isChecked() == True:
            self.qchk_temp_control.setStyleSheet('background-color: green')
            try:
                bLock = self.xem_gui_mainwindow.qchk_lock.isChecked()
            except:
                print('failed to read lock state')
                bLock = False
            
            if bLock == False: #We don't control the temperature of the oscillator box if the lock is off
                print('Setting temp control off : We don\'t control the temperature of the oscillator box if the lock is off')
                self.qchk_temp_control.setChecked(False)
                self.qchk_temp_control.setStyleSheet('background-color: red')
                return

            if self.client:
                # print('last_update = %f, step_delay = %f, current_time = %f' % (self.last_update, step_delay, current_time))
                if self.last_update + step_delay <= current_time:
                    # Compare the output to two thresholds:
                    # first threshold means to disable the temperature control loop completely, because the low PZT has railed.
                    if current_output < threshold_disable or current_output > 1-threshold_disable:
                        # disable temp control loop:
                        self.qchk_temp_control.setChecked(False)
                        strOfTime = time.strftime("%m_%d_%Y_%H_%M_%S_")
                        self.closeTCPConnection()
                        print('Disabled temp control because the PZT is too close to the rail and thus has most likely railed already. time = %s' % strOfTime)
                        self.logger.critical('Red_Pitaya_GUI{}: Disabled temp control because the PZT is too close to the rail.'.format(self.logger_name))
                        return
                    
                    # Second threshold means to send a step (in the right direction)
                    if current_output < threshold_step or current_output > 1-threshold_step:
                        if current_output < threshold_step:
                            step_sign = -1
                        else:
                            step_sign = 1
                            
                        delta_temperature = step_sign*step_size
                        self.setpoint_change = self.setpoint_change + delta_temperature
                        # Implement limits:
                        if self.setpoint_change > 10.:
                            self.setpoint_change = 10.
                            delta_temperature = 0
                        elif self.setpoint_change < -10.:
                            self.setpoint_change = -10.
                            delta_temperature = 0
                        
                        self.last_update = time.perf_counter()

                        try:                        
                            print('Sending a new setpoint: %f degrees' % self.setpoint_change)
                            self.logger.debug('Red_Pitaya_GUI{}: Sending a new setpoint : {} degrees'.format(self.logger_name, self.setpoint_change))
                            if self.bIncrementalOnly:
                                self.client.send_text('%f\n' % delta_temperature)
                            else:
                                self.client.send_text('%f\n' % self.setpoint_change)
                        except:
                            e = sys.exc_info()[0]
                            # If we get here, this probably means that the TCP connection to the temperature controller was lost.
                            self.closeTCPConnection()
                            print('Exception occurred sending the new temperature setpoint.')
                            print(str(e))
                            self.logger.warning('Red_Pitaya_GUI{}: Exception occurred sending the new temperature setpoint. Connection probably lost. {}'.format(self.logger_name, str(e)))
                            
#                            raise
                        return
                    
                else:
                    # the steps are inhibited because we made one too recently
#                    print('Steps inhibited')
                    return
            
                #clear temperature control integrator if temp control is turned off
                
                ### -> Was removed, the Laser Controller GUI only keeps the lastest value in memory    
                if self.qchk_clear_temp_control.isChecked() == True:
                    self.setpoint_change = 0.
                    try:
                        print('Clearing Temperature Control')
                        self.client.send_text('%f\n' % self.setpoint_change)
                        self.qchk_clear_temp_control.setChecked(False)
                    except:
                        e = sys.exc_info()[0]
                        # If we get here, this probably means that the TCP connection to the temperature controller was lost.
                        print('Exception occurred sending the new temperature setpoint.')
                        print(str(e))
                        self.client = None
                else:
                    return
            else:   # self.client == None
                # Try to open TCP connection to the temperature controller code
                print('Trying to establish connection to the temperature controller')
                self.logger.debug('Red_Pitaya_GUI{}: Trying to establish connection to the temperature controller'.format(self.logger_name))
                self.qchk_temp_control.setStyleSheet('background-color: orange')
                self.openTCPConnection()
       # else:
#            print('Temp control disactivated.')

    @logCommsErrorsAndBreakoutOfFunction(((np.nan, np.nan)))
    def runAutoRecover(self, output_number, current_dac):
        # Try to read the lock state
        try:
            bLock = self.xem_gui_mainwindow.qchk_lock.isChecked()
        except:
            print('failed to read lock state')
            bLock = False

        if bLock and self.qchk_autorecover.isChecked():
        # If the lock and auto recovery are enabled
            if self.recovery_history.size < 50:
            # Append to the DAC history if the sample size is too small
                self.recovery_history = np.append(current_dac, self.recovery_history)
                # Return NANs for plotting
                return (np.nan, np.nan)
            else:
            # Calculate the historical mean and standard deviation
                dac_mean = np.mean(self.recovery_history)
                dac_std = np.std(self.recovery_history)
                rec_threshold = float(self.qedit_rec_thresh.text())
                if np.abs(current_dac - dac_mean) > rec_threshold*dac_std:
                # If the current DAC value is out of bounds, relock to the average
                    self.sl.set_dac_offset(output_number, int(dac_mean))
                    self.xem_gui_mainwindow.qloop_filters[output_number].qchk_lock.setChecked(False)
                    self.xem_gui_mainwindow.qloop_filters[output_number].updateFilterSettings()
                    self.xem_gui_mainwindow.qloop_filters[output_number].qchk_lock.setChecked(True)
                    self.xem_gui_mainwindow.qloop_filters[output_number].updateFilterSettings()
                    print("{}: channel {} lost lock".format(time.strftime('%c'),output_number))
                else:
                # If the current DAC value is in bounds, add it to the DAC history
                    if self.recovery_history.size < 500:
                    # Append up to a certain size
                        self.recovery_history = np.append(current_dac, self.recovery_history)
                    else:
                    # Roll the values otherwise
                        self.recovery_history = np.roll(self.recovery_history, 1)
                        self.recovery_history[0] = current_dac
                # Return the mean and std deviation for plotting
                return (dac_mean, rec_threshold*dac_std)
        else:
        # If lock or auto recovery are disabled, clear the accumulated DAC history
            self.recovery_history = np.array([])
            # Return NANs for plotting
            return (np.nan, np.nan)

    def checkAutoUnlock(self, output_number, DAC_output):
        # Try to read the lock state
        try:
            bLock = self.xem_gui_mainwindow.qchk_lock.isChecked()
        except:
            print('failed to read lock state')
            bLock = False

        if bLock and self.qchk_autoUnlock.isChecked(): # If the lock and auto unlock are enabled
            unlock_threshold = float(self.qedit_unlock_thresh.text())

            if DAC_output < unlock_threshold or DAC_output > 1-unlock_threshold:
                # If the current DAC value is out of bounds, we unlock
                self.xem_gui_mainwindow.qchk_lock.setChecked(False)
                self.xem_gui_mainwindow.chkLockClickedEvent()
                print("{}: channel {} lost lock. Doing lock to unlock transition".format(time.strftime('%c'),output_number))
                self.logger.critical('Red_Pitaya_GUI{}: Channel {} lost lock. DAC too close to the rail.'.format(self.logger_name, output_number))
                # logger.warning("{}: channel {} lost lock. Doing lock to unlock transition".format(time.strftime('%c'),output_number))
   
    @logCommsErrorsAndBreakoutOfFunction()
    def displayFreqCounter(self):
        (freq_counter_samples, time_axis, DAC0_output, DAC1_output, DAC2_output) = self.sl.read_dual_mode_counter(self.output_number)
        # print(freq_counter_samples, time_axis, DAC0_output, DAC1_output, DAC2_output)
        # try:
            
        #     # print (freq_counter_samples, time_axis, DAC0_output, DAC1_output, DAC2_output)
            
        # except:
        #     print('Exception occured reading counter data. Disabling further updates.')
        #     self.logger.warning('Red_Pitaya_GUI{}: Exception occured reading counter data. Disabling further updates.'.format(self.logger_name))
        #     self.killTimer(self.timerID)
        #     freq_counter_samples = 0
        #     time_axis = 0
        #     DAC0_output = 0
        #     DAC1_output = 0
        #     DAC2_output = 0
            
        #     raise
            
        try:
            if time_axis is not None:
                # scale to seconds:
                time_axis = time_axis.astype(float) * self.gate_time
                # Write data to disk:
                self.file_output_time.write(time_axis)
                
            if DAC0_output is not None:
                if self.output_number == 0:
                # Run auto recovery for DAC0
                    dac_mean, dac_thrsh = self.runAutoRecover(self.output_number, np.mean(DAC0_output))
                    DAC0_output_voltage = DAC0_output/float(self.sl.DACs_limit_high[0] - self.sl.DACs_limit_low[0])*2.
                    dac_output = (DAC0_output - self.sl.DACs_limit_low[0]).astype(np.float)/float(self.sl.DACs_limit_high[0] - self.sl.DACs_limit_low[0])   #We want the graph scale between 0 and 1
                    dac_mean = dac_mean/float(self.sl.DACs_limit_high[0] - self.sl.DACs_limit_low[0])*2.
                    dac_thrsh = dac_thrsh/float(self.sl.DACs_limit_high[0] - self.sl.DACs_limit_low[0])*2.

                # Scale to minimum and maximum limits: 0 means minimum, 1 means maximum
                DAC0_output = (DAC0_output - self.sl.DACs_limit_low[0]).astype(np.float)/float(self.sl.DACs_limit_high[0] - self.sl.DACs_limit_low[0])
                # Write data to disk:
                self.file_output_dac0.write(DAC0_output)

                if self.output_number == 0:
                    self.checkAutoUnlock(self.output_number, DAC0_output)                
                
            if DAC1_output is not None:
                if self.output_number == 1:
                # Run auto recovery for DAC1
                    dac_mean, dac_thrsh = self.runAutoRecover(self.output_number, np.mean(DAC1_output))
                    DAC1_output_voltage = DAC1_output/float(self.sl.DACs_limit_high[1] - self.sl.DACs_limit_low[1])*2.
                    dac_output = (DAC1_output - self.sl.DACs_limit_low[1]).astype(np.float)/float(self.sl.DACs_limit_high[1] - self.sl.DACs_limit_low[1])    #We want the graph scale between 0 and 1
                    dac_mean = dac_mean/float(self.sl.DACs_limit_high[1] - self.sl.DACs_limit_low[1])*2.
                    dac_thrsh = dac_thrsh/float(self.sl.DACs_limit_high[1] - self.sl.DACs_limit_low[1])*2.
                # Scale to minimum and maximum limits: 0 means minimum, 1 means maximum
                DAC1_output = (DAC1_output - self.sl.DACs_limit_low[1]).astype(np.float)/float(self.sl.DACs_limit_high[1] - self.sl.DACs_limit_low[1])
                # self.checkAutoUnlock(self.output_number, DAC1_output)
                # Write data to disk:
                self.file_output_dac1.write(DAC1_output)
                
            if DAC2_output is not None:
                DAC2_output_voltage = DAC2_output/float(self.sl.DACs_limit_high[2] - self.sl.DACs_limit_low[2])*2.
                # Scale to minimum and maximum limits: 0 means minimum, 1 means maximum
                DAC2_output = (DAC2_output - self.sl.DACs_limit_low[2]).astype(np.float)/float(self.sl.DACs_limit_high[2] - self.sl.DACs_limit_low[2])
                # Write data to disk:
                self.file_output_dac2.write(DAC2_output)
                
                if self.output_number == 1:
                    self.checkAutoUnlock(self.output_number, DAC2_output)
                    self.runTempControlLoop(time.perf_counter(), DAC2_output)
                
                
                
            if freq_counter_samples is not None:
                if self.bVeryFirst == True:
                    # We flush the first two samples because the system isn't fully initialized and they always force the plot scale too wide
                    freq_counter_samples = freq_counter_samples[2:]
                    if self.output_number == 0 and (DAC0_output is not None):
                        DAC0_output = DAC0_output[2:]
                    if self.output_number == 1 and (DAC1_output is not None):
                        DAC1_output = DAC1_output[2:]
                        DAC2_output = DAC2_output[2:]
                    self.bVeryFirst = False
                    return
                    
                # Write data to disk:
                if self.output_number == 0:
                    self.file_output_counter0.write(freq_counter_samples)
                elif self.output_number == 1:
                    self.file_output_counter1.write(freq_counter_samples)
                            
                # Record the new chunk of data in the buffer:

#                print('len = %d' % len(freq_counter_samples))
                self.freq_history[:-len(freq_counter_samples)] = self.freq_history[len(freq_counter_samples):]
                self.freq_history[-len(freq_counter_samples):] = freq_counter_samples
                
                self.DAC_history[:-1] = self.DAC_history[1:]
                self.DAC_history[-1:] = dac_output
                self.DAC_mean_history[:-1] = self.DAC_mean_history[1:]
                self.DAC_mean_history[-1:] = dac_mean
                self.DAC_thrsh_history[:-1] = self.DAC_thrsh_history[1:]
                self.DAC_thrsh_history[-1:] = dac_thrsh
                self.bValid_dacs[:-1] = self.bValid_dacs[1:]
                self.bValid_dacs[-1:] = True

                if self.output_number == 1:
                    self.DAC2_history[:-1] = self.DAC2_history[1:]
                    self.DAC2_history[-1:] = DAC2_output

                
    #            self.time_history[:-len(freq_counter_samples)] = self.time_history[len(freq_counter_samples):]
    #            self.time_history[-len(freq_counter_samples):] = time_axis
                
                self.bValid_counters[:-len(freq_counter_samples)] = self.bValid_counters[len(freq_counter_samples):]
                self.bValid_counters[-len(freq_counter_samples):] = True

                                
                channelName = ''
                if self.output_number == 0:
                    channelName = 'CEO'
                if self.output_number == 1:
                    channelName = 'Optical'
                
                # Update graph:
                self.curve_freq_error.setData(self.time_history_counters[self.bValid_counters] - self.time_history_counters[len(self.time_history_counters)-1], self.freq_history[self.bValid_counters])            
                self.qplt_freq.setTitle('%s Lock Freq error, mean = %.6f Hz, std = %.3f mHz' % (channelName, np.mean(self.freq_history[self.bValid_counters]), 1e3*np.std(self.freq_history[self.bValid_counters])))
                if self.qchk_fullscale_freq.isChecked():
                    #self.qplt_freq.setAxisScaleEngine(Qwt.QwtPlot.yLeft, Qwt.QwtLinearScaleEngine())
                    try:
                        ymin = float(self.qedit_ymin.text())
                        ymax = float(self.qedit_ymax.text())
                    except:
                        ymin = -25e6
                        ymax = 25e6
                        
                    #self.qplt_freq.setAxisScale(Qwt.QwtPlot.yLeft, ymin, ymax)
                    self.qplt_freq.setYRange(ymin, ymax)
                else:
                    #self.qplt_freq.setAxisAutoScale(Qwt.QwtPlot.yLeft)
                    self.qplt_freq.enableAutoRange(y=True)
                    
                #self.qplt_freq.replot()
                
                # Update graph:
                if self.output_number == 0:
                    self.curve_dac.setData(self.time_history_dacs[self.bValid_dacs] - self.time_history_dacs[len(self.time_history_dacs)-1], self.DAC_history[self.bValid_dacs])
                    self.curve_dac_uthrsh.setData(self.time_history_dacs[self.bValid_dacs] - self.time_history_dacs[len(self.time_history_dacs)-1], self.DAC_mean_history[self.bValid_dacs]+self.DAC_thrsh_history[self.bValid_dacs])
                    self.curve_dac_lthrsh.setData(self.time_history_dacs[self.bValid_dacs] - self.time_history_dacs[len(self.time_history_dacs)-1], self.DAC_mean_history[self.bValid_dacs]-self.DAC_thrsh_history[self.bValid_dacs])
                    self.qplt_dac.setTitle('%s Lock DAC outputs, last raw code = %f (%f)' % (channelName, self.DAC_history[-1], DAC0_output_voltage))

                if self.output_number == 1:
                    if self.qchk_show_DAC1.isChecked():
                        self.curve_dac.setData(self.time_history_dacs[self.bValid_dacs] - self.time_history_dacs[len(self.time_history_dacs)-1], self.DAC_history[self.bValid_dacs])            
                    else:
                        self.curve_dac.clear()

                    if self.qchk_show_DAC2.isChecked():
                        self.curve_dac2.setData(self.time_history_dacs[self.bValid_dacs] - self.time_history_dacs[len(self.time_history_dacs)-1], self.DAC2_history[self.bValid_dacs])
                    else:
                        self.curve_dac2.clear()
                    
                    self.curve_dac_uthrsh.setData(self.time_history_dacs[self.bValid_dacs] - self.time_history_dacs[len(self.time_history_dacs)-1], self.DAC_mean_history[self.bValid_dacs]+self.DAC_thrsh_history[self.bValid_dacs])
                    self.curve_dac_lthrsh.setData(self.time_history_dacs[self.bValid_dacs] - self.time_history_dacs[len(self.time_history_dacs)-1], self.DAC_mean_history[self.bValid_dacs]-self.DAC_thrsh_history[self.bValid_dacs])
                    self.qplt_dac.setTitle('%s Lock DAC outputs, last raw code DAC1= %f (%f), DAC2 = %f (%f)' % (channelName, self.DAC_history[-1], DAC1_output_voltage, self.DAC2_history[-1], DAC2_output_voltage))
                
                if self.qchk_fullscale_dac.isChecked():
                    #self.qplt_dac.setAxisScaleEngine(Qwt.QwtPlot.yLeft, Qwt.QwtLinearScaleEngine())
                    self.qplt_dac.setYRange(0, 1)
                    #self.qplt_dac.setAxisScale(Qwt.QwtPlot.yLeft, 0, 1)

                else:
                    self.qplt_dac.enableAutoRange(y=True)
                    #self.qplt_dac.setAxisAutoScale(Qwt.QwtPlot.yLeft)
                    
                #self.qplt_dac.replot()
            
        except:
            print('Exception occured parsing counter data. Disabling further updates.')
            self.logger.warning('Red_Pitaya_GUI{}: Exception occured reading counter data. Disabling further updates.'.format(self.logger_name))
            self.killTimer(self.timerID)
            freq_counter_samples = 0
            time_axis = 0
            DAC0_output = 0
            DAC1_output = 0
            DAC2_output = 0
            
            raise

    # From: http://stackoverflow.com/questions/273192/create-directory-if-it-doesnt-exist-for-file-write
    def make_sure_path_exists(self, path):
        try:
            os.makedirs(path)
        except OSError as exception:
            if exception.errno != errno.EEXIST:
                raise
                
