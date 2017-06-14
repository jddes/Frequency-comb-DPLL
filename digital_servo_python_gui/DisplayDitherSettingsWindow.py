"""
XEM6010 Phase-lock box GUI, Dither settings controls
by JD Deschenes, October 2013

"""
from __future__ import print_function

import time
from PyQt5 import QtGui, Qt
import numpy as np

import weakref
#from SuperLaserLand_JD2 import SuperLaserLand_JD2
#from DisplayTransferFunctionWindow import DisplayTransferFunctionWindow


class DisplayDitherSettingsWindow(QtGui.QWidget):
        
    def __init__(self, sl, output_number, modulation_frequency_in_hz=1e3, output_amplitude=1e-4, integration_time_in_seconds=0.1, bEnableDither=0, custom_style_sheet=''):
        super(DisplayDitherSettingsWindow, self).__init__()
        
        
        
        self.output_number = output_number        
        self.sl = weakref.proxy(sl)
        self.setObjectName('MainWindow')
        self.setStyleSheet(custom_style_sheet)
        
        
        self.initUI(modulation_frequency_in_hz, output_amplitude, integration_time_in_seconds, bEnableDither)
        

        
        # This will make the window update the FPGA register
        self.ditherClicked()

        
    def readDitherSettings(self):

        # Amplitude
        # Frequency
        # Integration time
        # On/Off
        
        try:
            modulation_frequency_in_hz = float(self.qedit_dither_freq.text())
        except:
            modulation_frequency_in_hz = 1e3
            pass
        
        
        try:
            output_amplitude = int((self.sl.DACs_limit_high[self.output_number]-self.sl.DACs_limit_low[self.output_number])/2.*float(self.qedit_dither_amplitude.text()))
        except:
            output_amplitude = 0
            pass
        if output_amplitude == 0:
            output_amplitude = 1
            
        try:
            integration_time_in_seconds = float(self.qedit_integration_time.text())
        except:
            integration_time_in_seconds = 0.1
            pass
        
#        try:

                
        if self.qchk_mode_auto.isChecked():
            mode_auto = 1
            bEnableDither = 0
        else:
            mode_auto = 0
            if self.qchk_mode_manual_off.isChecked():
                bEnableDither = 0
            else:
                bEnableDither = 1
#        except:
#            bEnableDither = 0
#            mode_auto = 0
#            pass
        
        return (integration_time_in_seconds, modulation_frequency_in_hz, output_amplitude, bEnableDither, mode_auto)
        

        
    def ditherClicked(self):
        (integration_time_in_seconds, modulation_frequency_in_hz, output_amplitude, bEnableDither, mode_auto) = self.readDitherSettings()

#        print('(output_select, modulation_frequency_in_hz, output_amplitude, bSquareWave, bEnableDither) = %d, %f, %f, %d, %d' % (output_select, modulation_frequency_in_hz, output_amplitude, bSquareWave, bEnableDither))
        modulation_period = round(self.sl.fs/modulation_frequency_in_hz)
        integration_time_in_samples = integration_time_in_seconds*self.sl.fs
        N_periods = np.ceil(integration_time_in_samples/modulation_period)
        self.sl.setupDitherLockIn(self.output_number, modulation_period, N_periods, output_amplitude, mode_auto)
        
        if mode_auto == 0:
            # Manual mode:
            print('bEnableDither = %d' % bEnableDither)
            self.sl.setDitherLockInState(self.output_number, bEnableDither)
        
        return
    
    def initUI(self, modulation_frequency_in_hz, output_amplitude, integration_time_in_seconds, bEnableDither):

        # Create the widgets which control the dither module:

        # Controls for the dither mode:        
        # Needs: output select, frequency, amplitude, Square/Sine select, dither on/off
        ######################################################################
        # Settings
        ######################################################################

        self.qgroupbox_dither = Qt.QGroupBox('Dither DAC%d settings' % self.output_number)
        self.qgroupbox_dither.setAutoFillBackground(True)
        
        
        # Modulation frequency:
        self.qedit_freq_label = Qt.QLabel('Frequency [Hz]:')
        self.qedit_dither_freq = Qt.QLineEdit(str(modulation_frequency_in_hz))
        self.qedit_dither_freq.textChanged.connect(self.ditherClicked)
        self.qedit_dither_freq.setMaximumWidth(60)
        
        # Integration time:
        self.qedit_int_label = Qt.QLabel('Integration time [s]:')
        self.qedit_integration_time = Qt.QLineEdit(str(integration_time_in_seconds))
        self.qedit_integration_time.textChanged.connect(self.ditherClicked)
        self.qedit_integration_time.setMaximumWidth(60)
        
        # Amplitude:
        self.qlabel_dither_amplitude = Qt.QLabel('Amplitude [0-1]:')
        self.qedit_dither_amplitude = Qt.QLineEdit(str(output_amplitude))
        self.qedit_dither_amplitude.textChanged.connect(self.ditherClicked)
        self.qedit_dither_amplitude.setMaximumWidth(60)
        
        
#        # On/Off button
#        self.qbtn_dither = QtGui.QPushButton('Activate dither')
#        self.qbtn_dither.clicked.connect(self.ditherClicked)
#        self.qbtn_dither.setCheckable(True)
#        self.qbtn_dither.setChecked(bool(bEnableDither))
        
        # Mode select button (Automatic, Manual Off, Manual On)
        self.qchk_mode_auto = QtGui.QRadioButton('Automatic')
        self.qchk_mode_manual_off = QtGui.QRadioButton('Manual Off')
        self.qchk_mode_manual_on = QtGui.QRadioButton('Manual On')
        qbtn_group = Qt.QButtonGroup()
        qbtn_group.addButton(self.qchk_mode_auto)
        qbtn_group.addButton(self.qchk_mode_manual_off)
        qbtn_group.addButton(self.qchk_mode_manual_on)
        self.qchk_mode_auto.setChecked(True)
        self.qchk_mode_auto.clicked.connect(self.ditherClicked)
        self.qchk_mode_manual_off.clicked.connect(self.ditherClicked)
        self.qchk_mode_manual_on.clicked.connect(self.ditherClicked)
        
        # Put all the widgets into a grid layout
        grid = QtGui.QGridLayout()
        
        grid.addWidget(self.qedit_freq_label,               0, 0)
        grid.addWidget(self.qedit_dither_freq,              0, 1)
        grid.addWidget(self.qedit_int_label,                1, 0)
        grid.addWidget(self.qedit_integration_time,         1, 1)        
        
        grid.addWidget(self.qlabel_dither_amplitude,        2, 0)
        grid.addWidget(self.qedit_dither_amplitude,         2, 1)
        
        grid.addWidget(self.qchk_mode_auto,                 3, 0, 1, 2)
        grid.addWidget(self.qchk_mode_manual_off,           4, 0, 1, 2)
        grid.addWidget(self.qchk_mode_manual_on,            5, 0, 1, 2)
        self.qgroupbox_dither.setLayout(grid)    

        vbox = Qt.QVBoxLayout()
        vbox.addWidget(self.qgroupbox_dither)
        self.setLayout(vbox)
        

        # Adjust the size and position of the window
#        self.resize(800, 600)
        self.center()
        self.setWindowTitle('Dither #%d control' % self.output_number)    
        #self.show()
        

        
    def center(self):
        
        qr = self.frameGeometry()
        cp = QtGui.QDesktopWidget().availableGeometry().center()
        qr.moveCenter(cp)
#        self.move(qr.topLeft())
#        self.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(50, 50))
        

        
        
        