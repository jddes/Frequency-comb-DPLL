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
import sys


#from SuperLaserLand_JD2 import SuperLaserLand_JD2

# To communication with the temperature controller process
import AsyncSocketComms

import weakref


class FreqErrorWindowWithTempControlV2(QtGui.QWidget):

        
    def __init__(self, sl, strTitle, output_number=0, strNameTemplate='', custom_style_sheet='', port_number=0, xem_gui_mainwindow=0):
        super(FreqErrorWindowWithTempControlV2, self).__init__()

        self.strTitle = strTitle
        self.strNameTemplate = strNameTemplate
        self.sl = weakref.proxy(sl)
        self.output_number = output_number
        self.setObjectName('MainWindow')
        self.setStyleSheet(custom_style_sheet)
        if xem_gui_mainwindow:
            self.xem_gui_mainwindow = weakref.proxy(xem_gui_mainwindow)
        else:
            self.xem_gui_mainwindow = None
        
        self.port_number = port_number
        print('before openTCPConnection')
        self.openTCPConnection()
        print('after openTCPConnection')
        if self.client is None:
            print('here')
            print('Error: no connection to temp control')
            
        self.last_update_freq = time.clock()
        self.initUI()
        self.openOutputFiles()
        self.initSL()


#    def __del__(self):
#        # Close data files:
#        if hasattr(self, 'file_output1'):
#            self.file_output1.close()
#        if hasattr(self, 'file_output2'):
#            self.file_output2.close()

    def openTCPConnection(self):
        start_time = time.clock()
        if self.port_number != 0:
            try:
                time_before = time.clock()
                self.client = AsyncSocketComms.AsyncSocketClient(self.port_number)
                self.last_update = float("-inf")
                self.setpoint_change = 0.
                print('Connection to temp control established.')
            except:
                time_after = time.clock()
                print('openTCPConnection(): Time taken by AsyncSocketComms.AsyncSocketClient(): %f sec' % (time_after-time_before))
                self.client = None
                self.last_update = time.clock()
                self.setpoint_change = 0.
        else:
            self.client = None
        end_time = time.clock()
        print('openTCPConnection(): Time taken: %f sec' % (end_time-start_time))
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
        
        if self.output_number == 0:
            self.DAC0_history = np.zeros(self.N_history_dacs)
        if self.output_number == 1:
            self.DAC1_history = np.zeros(self.N_history_dacs)
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
        print('Updating counter mode')

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
        
        # Controls for the vertical scale of the frequency graph:
        self.qedit_ymin = Qt.QLineEdit('-25e6')
        self.qedit_ymax = Qt.QLineEdit('25e6')

        
        self.qchk_phd_in_the_loop = Qt.QCheckBox('PhD-in-the-loop')
        self.qchk_phd_in_the_loop.setChecked(False)
        
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
        #grid.addWidget(self.qchk_phd_in_the_loop,           7, 0, 1, 2)        
        

        
        if self.client or True:
            # we need to add the controls which implement the temperature control loop:
            self.qlabel_threshold_step = Qt.QLabel('Threshold for step:')
            self.qedit_threshold_step = Qt.QLineEdit('0.2')
            self.qedit_threshold_step.setMaximumWidth(40)
            
            
            self.qlabel_threshold_disable = Qt.QLabel('Threshold for disable:')
            self.qedit_threshold_disable = Qt.QLineEdit('0.05')
            self.qedit_threshold_disable.setMaximumWidth(40)
            
            self.qlabel_step_size = Qt.QLabel('Step size [deg C]:')
            self.qedit_step_size = Qt.QLineEdit('0.05')
            self.qedit_step_size.setMaximumWidth(40)
            
            self.qlabel_step_delay = Qt.QLabel('Step delay [s]:')
            self.qedit_step_delay = Qt.QLineEdit('120')
            self.qedit_step_delay.setMaximumWidth(40)
            
            self.qchk_temp_control = Qt.QCheckBox('Temperature control')
            self.qchk_temp_control.setChecked(False)
            
            self.qchk_clear_temp_control = Qt.QCheckBox('Clear Temperature control')
            self.qchk_clear_temp_control.setChecked(False)
            
            #FEATURE
            #grid.addWidget(self.qlabel_threshold_step,          8, 0)
            #grid.addWidget(self.qedit_threshold_step,           8, 1)
            #grid.addWidget(self.qlabel_threshold_disable,       9, 0)
            #grid.addWidget(self.qedit_threshold_disable,        9, 1)
            #grid.addWidget(self.qlabel_step_size,               10, 0)
            #grid.addWidget(self.qedit_step_size,                11, 1)
            #
            #grid.addWidget(self.qlabel_step_delay,              12, 0)
            #grid.addWidget(self.qedit_step_delay,               13, 1)
            #
            #grid.addWidget(self.qchk_temp_control,              14, 0, 1, 2)
            #grid.addWidget(self.qchk_clear_temp_control,        15, 0, 1, 2)
            
            
            grid.addWidget(Qt.QLabel(''),                       16, 0, 1, 2)
            grid.setRowStretch(15, 1)
            grid.setColumnStretch(2, 1)
        else:
            # no controls for the temp control loop
        
        
            grid.addWidget(Qt.QLabel(''),                       8, 0, 1, 2)
            grid.setRowStretch(8, 1)
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
        self.qchk_triangular.blockSignals(True)
        self.qchk_triangular.setChecked(self.sl.bTriangularAveraging)
        self.qchk_triangular.blockSignals(False)
        
        self.displayFreqCounter()
        
        return
        
    def runTempControlLoop(self, current_time, current_output):
        # Simple algorithm:
        # If the dac2 output crosses a threshold, we send a step to the temperature setpoint to nudge it in the right direction.
        # We then wait for a certain delay before we re-do a step
#        print('runTempControlLoop(): current_time = %f, current_output = %f' % (current_time, current_output))
    
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
            if self.client:
#                print('Temp control established, client connected.')
                
    #            print('last_update = %f, step_delay = %f, current_time = %f' % (self.last_update, step_delay, current_time))
                if self.last_update + step_delay <= current_time:
                    # Compare the output to two thresholds:
                    # first threshold means to disable the temperature control loop completely, because the low PZT has railed.
                    if current_output < threshold_disable or current_output > 1-threshold_disable:
                        # disable temp control loop:
                        self.qchk_temp_control.setChecked(False)
                        strOfTime = time.strftime("%m_%d_%Y_%H_%M_%S_")
                        print('Disabled temp control because the PZT is too close to the rail and thus has most likely railed already. time = %s' % strOfTime)
                        return
                    
                    # Second threshold means to send a step (in the right direction)
                    if current_output < threshold_step or current_output > 1-threshold_step:
                        if current_output < threshold_step:
                            step_sign = -1
                        else:
                            step_sign = 1
                            
                       
                        self.setpoint_change = self.setpoint_change + step_sign*step_size
                        # Implement limits:
                        if self.setpoint_change > 10.:
                            self.setpoint_change = 10.
                        elif self.setpoint_change < -10.:
                            self.setpoint_change = -10.
                        
                        self.last_update = time.clock()

                        try:                        
                            print('Sending a new setpoint: %f degrees' % self.setpoint_change)
                            self.client.send_text('%f\n' % self.setpoint_change)
                        except:
                            e = sys.exc_info()[0]
                            # If we get here, this probably means that the TCP connection to the temperature controller was lost.
                            print('Exception occurred sending the new temperature setpoint.')
                            print(str(e))
                            self.client = None
                            
#                            raise
                        return
                    
                else:
                    # the steps are inhibited because we made one too recently
#                    print('Steps inhibited')
                    return
            
                #clear temperature control integrator if temp control is turned off        
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
                self.openTCPConnection()
#        else:
#            print('Temp control disactivated.')
                    

    def runFreqControlLoop(self, current_time, current_frequency_error):




        step_delay = 120.
        frequency_error_threshold = 15e6
        step_size_in_hz = 15e6
        try:
            output_gain_in_hz_per_volts = float(self.xem_gui_mainwindow.qedit_vco_gain[0].text())
        except:
            output_gain_in_hz_per_volts = 4e8
            

        step_size_in_volts = step_size_in_hz / output_gain_in_hz_per_volts
        if self.qchk_phd_in_the_loop.isChecked() == True:
            current_dac_value_in_counts = self.sl.DACs_offset[0]
            current_dac_value_in_Volts = current_dac_value_in_counts/2.**15 * 2.
            

            if self.last_update_freq + step_delay <= current_time:
                # We can do a step if we need to.
            
                if current_frequency_error > frequency_error_threshold:
                    # We are too high. need to lower the voltage
                    new_dac_value_in_volts = current_dac_value_in_Volts - step_size_in_volts
                    new_value_in_counts = new_dac_value_in_volts/2. * (2**15-1)
                    self.sl.set_dac_offset(0, new_value_in_counts)
                    

                    self.last_update_freq = time.clock()
                    print('Decreasing voltage')
                    print('current_frequency_error = %f Hz, current dac value = %f V, new_dac_value = %f V' % (current_frequency_error, current_dac_value_in_Volts, new_dac_value_in_volts))
                    
                elif current_frequency_error < -frequency_error_threshold:
                    # We are too low. need to increase the voltage
                    new_dac_value_in_volts = current_dac_value_in_Volts + step_size_in_volts
                    new_value_in_counts = new_dac_value_in_volts/2. * (2**15-1)
                    self.sl.set_dac_offset(0, new_value_in_counts)
                    
                    self.last_update_freq = time.clock()
                    print('Increasing voltage')
                    print('current_frequency_error = %f Hz, current dac value = %f V, new_dac_value = %f V' % (current_frequency_error, current_dac_value_in_Volts, new_dac_value_in_volts))
                
            
            
#            self.sl.set_dac_offset(k, counts_offset)
    
        
    def displayFreqCounter(self):
#        (freq_counter_samples, time_axis, DAC0_output, DAC1_output, DAC2_output) = self.sl.read_zero_deadtime_freq_counter(self.output_number)
        try:
            (freq_counter_samples, time_axis, DAC0_output, DAC1_output, DAC2_output) = self.sl.read_dual_mode_counter(self.output_number)   
            # print (freq_counter_samples, time_axis, DAC0_output, DAC1_output, DAC2_output)
            
        except:
            print('Exception occured reading counter data. disabling further updates.')
            self.killTimer(self.timerID)
            freq_counter_samples = 0
            time_axis = 0
            DAC0_output = 0
            DAC1_output = 0
            DAC2_output = 0
            
            raise
            
        try:
            if time_axis is not None:
                # scale to seconds:
                time_axis = time_axis.astype(float) * self.gate_time
                # Write data to disk:
                self.file_output_time.write(time_axis)
                
            if DAC0_output is not None:
                # Scale to minimum and maximum limits: 0 means minimum, 1 means maximum
                DAC0_output = (DAC0_output - self.sl.DACs_limit_low[0]).astype(np.float)/float(self.sl.DACs_limit_high[0] - self.sl.DACs_limit_low[0])
                # Write data to disk:
                self.file_output_dac0.write(DAC0_output)
                
            if DAC1_output is not None:
                # Scale to minimum and maximum limits: 0 means minimum, 1 means maximum
                DAC1_output = (DAC1_output - self.sl.DACs_limit_low[1]).astype(np.float)/float(self.sl.DACs_limit_high[1] - self.sl.DACs_limit_low[1])
                # Write data to disk:
                self.file_output_dac1.write(DAC1_output)
                
            if DAC2_output is not None:
                # Scale to minimum and maximum limits: 0 means minimum, 1 means maximum
                DAC2_output = (DAC2_output - self.sl.DACs_limit_low[2]).astype(np.float)/float(self.sl.DACs_limit_high[2] - self.sl.DACs_limit_low[2])
                # Write data to disk:
                self.file_output_dac2.write(DAC2_output)
                
                self.runTempControlLoop(time.clock(), DAC2_output[-1:])
                
                
                
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
                    
                self.runFreqControlLoop(time.clock(), freq_counter_samples[-1:])
                    
                # Write data to disk:
                if self.output_number == 0:
                    self.file_output_counter0.write(freq_counter_samples)
                elif self.output_number == 1:
                    self.file_output_counter1.write(freq_counter_samples)
                            
                # Record the new chunk of data in the buffer:
#                print('len = %d' % len(freq_counter_samples))
                self.freq_history[:-len(freq_counter_samples)] = self.freq_history[len(freq_counter_samples):]
                self.freq_history[-len(freq_counter_samples):] = freq_counter_samples
                
                if self.output_number == 0:
                    self.DAC0_history[:-len(DAC0_output)] = self.DAC0_history[len(DAC0_output):]
                    self.DAC0_history[-len(DAC0_output):] = DAC0_output
                    self.bValid_dacs[:-len(DAC0_output)] = self.bValid_dacs[len(DAC0_output):]
                    self.bValid_dacs[-len(DAC0_output):] = True
                if self.output_number == 1:
                    self.DAC1_history[:-len(DAC1_output)] = self.DAC1_history[len(DAC1_output):]
                    self.DAC1_history[-len(DAC1_output):] = DAC1_output
                    self.DAC2_history[:-len(DAC1_output)] = self.DAC2_history[len(DAC1_output):]
                    self.DAC2_history[-len(DAC1_output):] = DAC2_output
                    self.bValid_dacs[:-len(DAC1_output)] = self.bValid_dacs[len(DAC1_output):]
                    self.bValid_dacs[-len(DAC1_output):] = True
                    
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
                    self.qplt_freq.setAxisScaleEngine(Qwt.QwtPlot.yLeft, Qwt.QwtLinearScaleEngine())
                    try:
                        ymin = float(self.qedit_ymin.text())
                        ymax = float(self.qedit_ymax.text())
                    except:
                        ymin = -25e6
                        ymax = 25e6
                        
                    self.qplt_freq.setAxisScale(Qwt.QwtPlot.yLeft, ymin, ymax)
                else:
                    self.qplt_freq.setAxisAutoScale(Qwt.QwtPlot.yLeft)
                    
                self.qplt_freq.replot()
                
                # Update graph:
                if self.output_number == 0:
                    self.curve_dac0.setData(self.time_history_dacs[self.bValid_dacs] - self.time_history_dacs[len(self.time_history_dacs)-1], self.DAC0_history[self.bValid_dacs])            
                    self.qplt_dac.setTitle('%s Lock DAC outputs, last raw code = %f' % (channelName, self.DAC0_history[-1]))
                    
                if self.output_number == 1:
                    self.curve_dac1.setData(self.time_history_dacs[self.bValid_dacs] - self.time_history_dacs[len(self.time_history_dacs)-1], self.DAC1_history[self.bValid_dacs])            
                    self.curve_dac2.setData(self.time_history_dacs[self.bValid_dacs] - self.time_history_dacs[len(self.time_history_dacs)-1], self.DAC2_history[self.bValid_dacs])            
                    self.qplt_dac.setTitle('%s Lock DAC outputs, last raw codes = %f, %f' % (channelName, self.DAC1_history[-1], self.DAC2_history[-1]))
                
                if self.qchk_fullscale_dac.isChecked():
                    self.qplt_dac.setAxisScaleEngine(Qwt.QwtPlot.yLeft, Qwt.QwtLinearScaleEngine())
                    self.qplt_dac.setAxisScale(Qwt.QwtPlot.yLeft, 0, 1)
                else:
                    self.qplt_dac.setAxisAutoScale(Qwt.QwtPlot.yLeft)
                    
                self.qplt_dac.replot()
            
        except:
            print('Exception occured parsing counter data. disabling further updates.')
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
                
