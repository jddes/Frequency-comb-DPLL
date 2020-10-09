"""
XEM6010 Phase-lock box GUI, VNA (Vector Network Analyzer) controls
by JD Deschenes, October 2013

"""
from __future__ import print_function

import time
from PyQt5 import QtGui, Qt
#import PyQt5.Qwt5 as Qwt
import numpy as np


#from SuperLaserLand_JD2 import SuperLaserLand_JD2
from DisplayTransferFunctionWindow import DisplayTransferFunctionWindow
import weakref

import sys # only used for sys.stdout.flush() because Syper's console sometimes doesn't show all print() outputs before crashing...

class DisplayVNAWindow(QtGui.QWidget):
    number_of_windows = 0   # Number of results windows we have opened
    response_windows = {}   # Dictionary which contains references to each results window
    
    bStop = False   # This is set when the user presses the stop button, and is checked by the wait loop
        
    def __init__(self, sl=None):
        super(DisplayVNAWindow, self).__init__()
        self.sl = weakref.proxy(sl)
        self.initUI()
        
    def getSystemIdentificationSettings(self):
        # Read the System identification settings from the Red Pitaya the set the correct states when opening the VNA window
        print("TO DO")
        #return (input_select, output_select, first_modulation_frequency_in_hz, last_modulation_frequency_in_hz, number_of_frequencies, System_settling_time, output_amplitude)
        
    def getDitherSettings(self):
        # Read the dither settings from the Red Pitaya the set the correct states when opening the VNA window
        print("TO DO")
        #return (output_select, modulation_frequency_in_hz, output_amplitude, bSquareWave, bEnableDither)


    def runSytemIdentification(self):
    
        # Check if another function is currently using the DDR2 logger:
        if self.sl.bDDR2InUse:
            print('DDR2 logger in use, cannot run identification')
            return
        # Block access to the DDR2 Logger to any other function until we are done:
        self.sl.bDDR2InUse = True
        
        # Reset the bStop flag (which is set when the user presses the stop button)
        self.bStop = False
        # The dither will be stopped by sl.setup_system_identification()
        self.qbtn_dither.setChecked(False)
        
        # Reset the progress bar
        self.qprogress_ident.setValue(0)
        
        (input_select, output_select, first_modulation_frequency_in_hz, last_modulation_frequency_in_hz, number_of_frequencies, System_settling_time, output_amplitude) = self.readSystemIdentificationSettings()
        
        self.sl.setup_system_identification(input_select, output_select, first_modulation_frequency_in_hz, last_modulation_frequency_in_hz, number_of_frequencies, System_settling_time, output_amplitude)
        total_wait_time = 0.1+1.3*self.sl.get_system_identification_wait_time()
        print('Waiting for %f sec...\n' % total_wait_time)
        
        # If the wait time is to be > 1 minute, then give the chance to the user to cancel the action
        if total_wait_time > 60:
            reply = QtGui.QMessageBox.question(self, 'Long operation',
                'Warning! The requested identification will take %.1f minute(s), are you sure you want to continue?' % (total_wait_time/60), QtGui.QMessageBox.Yes | 
                QtGui.QMessageBox.No, QtGui.QMessageBox.No)
            if reply == QtGui.QMessageBox.No:
                self.sl.bDDR2InUse = False
                return
            
        
        self.sl.trigger_system_identification()
        
        
        ## Wait until the transfer function measurement is finished, while updating the progress bar:
        start_time = time.perf_counter()
        if total_wait_time > 0.1:
            # Split the wait time in chunks, updating the progress bar every time
            # TODO.
            # Should implement the wait not as time.sleep(). but by recording the start time, and updating the display
            # while we wait, because sleep() will freeze the GUI. Not the best solution anyway but it shouldn't be that bad
            # especially if we havea nicely updated progress bar.
#            time.sleep(total_wait_time)
            qapp = QtGui.QApplication.instance()
            
            while (time.perf_counter()-start_time < total_wait_time) and self.bStop == False:
                self.qprogress_ident.setValue(  100 * (time.perf_counter()-start_time)/total_wait_time )
#                self.qprogress_ident.update()
                self.qprogress_ident.repaint()
                qapp.processEvents()
#                print('Updating')
                time.sleep(20e-3)
        else:
            # Wait time is low enough to just use sleep() without giving the impression that the GUI has crashed.
            time.sleep(total_wait_time)
        
        if self.bStop == True:
            # Operation was cancelled by user
            self.sl.bDDR2InUse = False
            self.bStop = False
            self.qprogress_ident.setValue(0)
            self.sl.setVNA_mode_register(0, 1, 0)
            return
            
        #print('runSytemIdentification(): before read')
        ## Read out the results from the FPGA:
        try:
            (transfer_function_complex, frequency_axis) = self.sl.read_VNA_samples_from_DDR2()
            # print('len(transfer_function_complex) = %d, len(frequency_axis) = %d' % (len(transfer_function_complex), len(frequency_axis)))
            # print(np.real(transfer_function_complex))
            # print(np.imag(transfer_function_complex))
        except:
            self.sl.bDDR2InUse = False
            print("Exception reading VNA samples from DDR2")
            raise
            
        # Signal to other functions that they can use the DDR2 logger
        self.sl.bDDR2InUse = False

        #print('runSytemIdentification(): after read')
        
        ## Scale the transfer function to physical units:
        # Current units are (VNA input counts)/(VNA output counts)
        output_volts_per_counts = self.sl.convertDACCountsToVolts(self.qcombo_transfer_output.currentIndex(), 1)
        print('output_volts_per_counts = %s' % output_volts_per_counts)
        
        
        if self.qcombo_transfer_input.currentIndex() == 0 or self.qcombo_transfer_input.currentIndex() == 1:
            # Input units to the VNA were ADC counts.
            # Transfer function units should be scaled to Volts/Volts, or no units:
            volts_per_VNA_input_counts = self.sl.convertADCCountsToVolts(self.qcombo_transfer_input.currentIndex(), 1)
            print('volts_per_VNA_input_counts = %s' % volts_per_VNA_input_counts)
            physical_input_units_per_input_counts = volts_per_VNA_input_counts
            
            physical_units_name = 'V/V'
        
        elif self.qcombo_transfer_input.currentIndex() == 2 or self.qcombo_transfer_input.currentIndex() == 3:
            # Input units to the VNA were frequency counts
            
            if self.qcombo_transfer_input.currentIndex() == 2:
                ddc_freq_for_compare = self.sl.ddc0_frequency_in_hz
            else:
                ddc_freq_for_compare = self.sl.ddc1_frequency_in_hz
            # we wanted to do sign() here but python has no sign function
            if ddc_freq_for_compare >= 0.:
                ddc_freq_sign = 1.
            else:
                ddc_freq_sign = -1.
            
            # Dirty hack because convertDDCCountsToHz expects a numpy array and we only have a scalar to give it
            Hz_per_VNA_input_counts = -ddc_freq_sign * np.mean(self.sl.convertDDCCountsToHz(   np.array((1,))   ))
#            Hz_per_VNA_input_counts = self.sl.convertDDCCountsToHz(1)
            print('Hz_per_VNA_input_counts = %s' % Hz_per_VNA_input_counts)
            physical_input_units_per_input_counts = Hz_per_VNA_input_counts
            
            physical_units_name = 'Hz/V'
        
        print('physical_units_name = %s' % physical_units_name)
        self.qprogress_ident.setValue(0)
        # Scale the actual measured transfer function:
        transfer_function_complex = transfer_function_complex * physical_input_units_per_input_counts / output_volts_per_counts        

        print('runSytemIdentification(): before creating a window())')
        sys.stdout.flush()
        
        ## Create a new window to show the transfer function
        # modified 02-10-2016: we plot everything on the same graph instead, so we open only 1 window
        if self.number_of_windows == 0:
            self.response_windows[self.number_of_windows] = DisplayTransferFunctionWindow(self.number_of_windows)
            self.number_of_windows = self.number_of_windows + 1
        else:
            # do we need to re-create a new window?
            if self.response_windows[0].bClosed:
                self.response_windows[0] = DisplayTransferFunctionWindow(self.number_of_windows)
                                
        
        print('runSytemIdentification(): before addCurve())')
        sys.stdout.flush()

        self.response_windows[0].addCurve(frequency_axis, transfer_function_complex, physical_units_name)
        print('runSytemIdentification(): after addCurve())')
        
        

        
    def readSystemIdentificationSettings(self):
        # Input select
        try:
            input_select = self.qcombo_transfer_input.currentIndex()
        except:
            input_select = 2
            pass
        
        try:
            output_select = self.qcombo_transfer_output.currentIndex()
        except:
            output_select = 0
            pass
        
        try:
            System_settling_time = float(self.qedit_settling_time.text())
        except:
            System_settling_time = 1e-3
            pass
        
        try:
            first_modulation_frequency_in_hz = float(self.qedit_freq_start.text())
            last_modulation_frequency_in_hz = float(self.qedit_freq_end.text())
        except:
            first_modulation_frequency_in_hz = 10e3
            last_modulation_frequency_in_hz = 1e6
            pass
        
        try:
            number_of_frequencies = int(float(self.qedit_freq_number.text()))
        except:
            number_of_frequencies = 16
            pass
        
        try:
            output_amplitude = int(float(self.sl.DACs_limit_high[output_select] - self.sl.DACs_limit_low[output_select])*float(self.qedit_output_amplitude.text())/2)
            # if output_select == 2:
            #     # The DAC2 has a particularity in that the VNA outputs only a 16-bit number, and it is multiplied by 4 to fit the 20-bit range of DAC2.
            #     output_amplitude = output_amplitude/4
        except:
            output_amplitude = 1
            pass
#        if output_amplitude == 0:
#            output_amplitude = 1
            
        return (input_select, output_select, first_modulation_frequency_in_hz, last_modulation_frequency_in_hz, number_of_frequencies, System_settling_time, output_amplitude)
        
        
    def readDitherSettings(self):

        # Output select
        # Amplitude
        # Frequency
        # Sine or square wave
        try:
            output_select = self.qcombo_dither_output.currentIndex()
        except:
            output_select = 0
            pass
        
        try:
            modulation_frequency_in_hz = float(self.qedit_dither_freq.text())
        except:
            modulation_frequency_in_hz = 1e3
            pass
        
        
        try:
            output_amplitude = int(float(self.sl.DACs_limit_high[output_select] - self.sl.DACs_limit_low[output_select])*float(self.qedit_dither_amplitude.text())/2)
            # if output_select == 2:
            #     # The DAC2 has a particularity in that the VNA outputs only a 16-bit number, and it is multiplied by 4 to fit the 20-bit range of DAC2.
            #     output_amplitude = output_amplitude/4
        except:
            output_amplitude = 0
            pass
#        if output_amplitude == 0:
#            output_amplitude = 1
            
        try:
            if self.qradio_squarewave.isChecked():
                bSquareWave = 1
            else:
                bSquareWave = 0
        except:
            bSquareWave = 0
            pass
        
        try:
            if self.qbtn_dither.isChecked():
                bEnableDither = 1
            else:
                bEnableDither = 0
        except:
            bEnableDither = 0
            pass
        return (output_select, modulation_frequency_in_hz, output_amplitude, bSquareWave, bEnableDither)
        
    def stopClicked(self):
        self.bStop = True   # This signals the waiting loop to cancel the operation
        return
        
    def ditherClicked(self):
        # Check if dither is set, then call 
#        setVNA_mode_register(self, trigger_dither, stop_flag, bSquareWave):
        (output_select, modulation_frequency_in_hz, output_amplitude, bSquareWave, bEnableDither) = self.readDitherSettings()
        # This is only really to set the dither
        # we don't care about these values:
        input_select = 0
        number_of_frequencies = 8
        System_settling_time = 1e-3
        print("before syst ident")
        self.sl.setup_system_identification(input_select, output_select, modulation_frequency_in_hz, modulation_frequency_in_hz, number_of_frequencies, System_settling_time, output_amplitude)
        
        print('(output_select, modulation_frequency_in_hz, output_amplitude, bSquareWave, bEnableDither) = %d, %f, %f, %d, %d' % (output_select, modulation_frequency_in_hz, output_amplitude, bSquareWave, bEnableDither))
        
        trigger_dither = bEnableDither
        if bEnableDither == False:
            stop_flag = 1
            self.qbtn_dither.setText("Activate dither")
        else:
            stop_flag = 0
            self.qbtn_dither.setText("Stop dither")
        bSquareWave = bSquareWave
        self.sl.setVNA_mode_register(trigger_dither, stop_flag, bSquareWave)
        print('(trigger_dither, stop_flag, bSquareWave) = %d, %d, %d' % (trigger_dither, stop_flag, bSquareWave))
        return
        
    def updateIntegrationTime(self):
        (input_select, output_select, first_modulation_frequency_in_hz, last_modulation_frequency_in_hz, number_of_frequencies, System_settling_time, output_amplitude) = self.readSystemIdentificationSettings()
        integration_time_in_samples = self.sl.compute_integration_time_for_syst_ident(System_settling_time, first_modulation_frequency_in_hz)
        self.qlbl_integration_time.setText('Integration time per freq [s]: %.1e' % (float(integration_time_in_samples)/self.sl.fs))
        
    
    def initUI(self):

        # Create the widgets which control the system identification module:
        
        # Input select
        transfer_input_label = Qt.QLabel('Input:')
        self.qcombo_transfer_input = Qt.QComboBox()
        self.qcombo_transfer_input.addItems(['ADC 0', 'ADC 1', 'DDC 0', 'DDC 1'])
        self.qcombo_transfer_input.setCurrentIndex(2)
#        transfer_input_label.setSizePolicy(QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Fixed)
#        self.qcombo_transfer_input.setSizePolicy(QtGui.QSizePolicy.Maximum, QtGui.QSizePolicy.Fixed)
        
        # Output select
        transfer_output_label = Qt.QLabel('Output:')
        self.qcombo_transfer_output = Qt.QComboBox()
        self.qcombo_transfer_output.addItems(['DAC 0', 'DAC 1', 'DAC 2'])
        self.qcombo_transfer_output.setCurrentIndex(0)
#        transfer_output_label.setSizePolicy(QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Fixed)
#        self.qcombo_transfer_output.setSizePolicy(QtGui.QSizePolicy.Maximum, QtGui.QSizePolicy.Fixed)
        
        # 
        settling_time_label = Qt.QLabel('System settling time [s]:')
        self.qedit_settling_time = Qt.QLineEdit('1e-3')
        self.qedit_settling_time.setMaximumWidth(60)
        self.qedit_settling_time.editingFinished.connect(self.updateIntegrationTime)
        
#        settling_time_label.setSizePolicy(QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Fixed)
#        self.qedit_settling_time.setSizePolicy(QtGui.QSizePolicy.Maximum, QtGui.QSizePolicy.Fixed)
        
        freq_start_label = Qt.QLabel('Freq start [Hz]:')
        self.qedit_freq_start = Qt.QLineEdit('10e3')
        self.qedit_freq_start.setMaximumWidth(60)
        self.qedit_freq_start.editingFinished.connect(self.updateIntegrationTime)
#        freq_start_label.setSizePolicy(QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Fixed)
#        self.qedit_freq_start.setSizePolicy(QtGui.QSizePolicy.Maximum, QtGui.QSizePolicy.Fixed)
        
        freq_end_label = Qt.QLabel('Freq end [Hz]:')
        self.qedit_freq_end = Qt.QLineEdit('2e6')
        self.qedit_freq_end.setMaximumWidth(60)
#        self.qedit_freq_end.setSizePolicy(QtGui.QSizePolicy.Maximum, QtGui.QSizePolicy.Fixed)
        
        freq_number_label = Qt.QLabel('Number of freq [max 3276]:')
        self.qedit_freq_number = Qt.QLineEdit('160')
        self.qedit_freq_number.setMaximumWidth(60)
#        self.qedit_freq_number.setSizePolicy(QtGui.QSizePolicy.Maximum, QtGui.QSizePolicy.Fixed)
        
        amplitude_label = Qt.QLabel('Modulation amplitude [0-1]:')
        self.qedit_output_amplitude = Qt.QLineEdit('0.01')
        self.qedit_output_amplitude.setMaximumWidth(60)
#        self.qedit_output_amplitude.setSizePolicy(QtGui.QSizePolicy.Maximum, QtGui.QSizePolicy.Fixed)
        
        self.qlbl_integration_time = Qt.QLabel('Integration time per freq [s]: ')
        self.updateIntegrationTime()
        
        # Button which triggers the system identification
        self.qbtn_ident = QtGui.QPushButton('Run identification')
        self.qbtn_ident.clicked.connect(self.runSytemIdentification)
#        self.qbtn_ident.setSizePolicy(QtGui.QSizePolicy.Maximum, QtGui.QSizePolicy.Fixed)
        
        self.qbtn_stop_ident = QtGui.QPushButton('Stop identification')
        self.qbtn_stop_ident.clicked.connect(self.stopClicked)
        
        
        # Progress bar which indicates the progression of the identification
        self.qprogress_ident = Qt.QProgressBar()
        self.qprogress_ident.setTextVisible(False)
        self.qprogress_ident.setValue(0)
#        self.qprogress_ident.setSizePolicy(QtGui.QSizePolicy.Maximum, QtGui.QSizePolicy.Fixed)
        
        # Controls for the dither mode:        
        # Needs: output select, frequency, amplitude, Square/Sine select, dither on/off
        ######################################################################
        # Settings
        ######################################################################
        self.qgroupbox_dither = Qt.QGroupBox('Continuous output', self)
        
        
        self.dither_output_label = Qt.QLabel('Output:')
        self.qcombo_dither_output = Qt.QComboBox()
        self.qcombo_dither_output.addItems(['DAC 0', 'DAC 1', 'DAC 2'])
        self.qcombo_dither_output.setCurrentIndex(0)
        self.qcombo_dither_output.currentIndexChanged.connect(self.ditherClicked)
        
        # Modulation frequency:
        self.qedit_freq_label = Qt.QLabel('Frequency [Hz]:')
        self.qedit_dither_freq = Qt.QLineEdit('1e6')
        self.qedit_dither_freq.textChanged.connect(self.ditherClicked)
        self.qedit_dither_freq.setMaximumWidth(60)
        
        # Amplitude:
        self.qlabel_dither_amplitude = Qt.QLabel('Amplitude [0-1]:')
        self.qedit_dither_amplitude = Qt.QLineEdit('0.01')
        self.qedit_dither_amplitude.textChanged.connect(self.ditherClicked)
        self.qedit_dither_amplitude.setMaximumWidth(60)
        
        # Sine/Square wave
        self.qradio_sinewave = Qt.QRadioButton('Sine wave')
        self.qradio_squarewave = Qt.QRadioButton('Square wave')
        self.qsign_group = Qt.QButtonGroup(self)
        self.qsign_group.addButton(self.qradio_sinewave)
        self.qsign_group.addButton(self.qradio_squarewave)
        
        self.qradio_sinewave.setChecked(True)
        self.qradio_squarewave.setChecked(False)
        self.qradio_sinewave.clicked.connect(self.ditherClicked)
        self.qradio_squarewave.clicked.connect(self.ditherClicked)
        
        # On/Off button
        self.qbtn_dither = QtGui.QPushButton('Activate dither')
        self.qbtn_dither.clicked.connect(self.ditherClicked)
        self.qbtn_dither.setCheckable(True)
        
        
        # Put all the widgets into a grid layout
        grid = QtGui.QGridLayout()
        
        grid.addWidget(self.dither_output_label,            0, 0)
        grid.addWidget(self.qcombo_dither_output,           0, 1)
        grid.addWidget(self.qedit_freq_label,               1, 0)
        grid.addWidget(self.qedit_dither_freq,              1, 1)
        grid.addWidget(self.qlabel_dither_amplitude,        2, 0)
        grid.addWidget(self.qedit_dither_amplitude,         2, 1)
        grid.addWidget(self.qradio_sinewave,                3, 0)
        grid.addWidget(self.qradio_squarewave,              3, 1)
        
        grid.addWidget(self.qbtn_dither,                    4, 0, 1, 2)
        self.qgroupbox_dither.setLayout(grid)    


        ######################################################################
        # Settings
        ######################################################################
        self.qgroupbox_test_osc = Qt.QGroupBox('Variable duty-cycle oscillator')
        self.qlbl_osc_freq = Qt.QLabel('Frequency [Hz]:')
        self.qedit_osc_freq = Qt.QLineEdit('200e3')
        self.qedit_osc_freq.textChanged.connect(self.oscClicked)
        # On/Off button
        self.qbtn_osc = QtGui.QPushButton('Activate output')
        self.qbtn_osc.setCheckable(True)
        self.qbtn_osc.setChecked(True)
        self.qbtn_osc.clicked.connect(self.oscClicked)
        # Polarity setting
        self.qchk_osc_polarity = Qt.QCheckBox('Invert polarity')
        self.qchk_osc_polarity.clicked.connect(self.oscClicked)
        # Duty cycle slider
        self.q_osc_duty_cyle = Qt.QSlider()
        self.q_osc_duty_cyle.valueChanged.connect(self.oscClicked)
        self.q_osc_duty_cyle.setSliderPosition(0)
        self.q_osc_duty_cyle.setOrientation(Qt.Qt.Horizontal)
        # Units are millionth of the full range available
        self.q_osc_duty_cyle.setMinimum(0)
        self.q_osc_duty_cyle.setMaximum(1e6)

        self.q_osc_duty_cyle.setSingleStep(1e6/100./3.)
        self.q_osc_duty_cyle.setPageStep(1e6/10.)
        # Put all the widgets into a grid layout
        grid = QtGui.QGridLayout()
        grid.addWidget(self.qlbl_osc_freq, 0, 0)
        grid.addWidget(self.qedit_osc_freq, 0, 1)
        grid.addWidget(self.qbtn_osc, 1, 0, 1, 2)
        grid.addWidget(self.qchk_osc_polarity, 2, 0, 1, 2)
        grid.addWidget(self.q_osc_duty_cyle, 3, 0, 1, 2)
        self.qgroupbox_test_osc.setLayout(grid)

        

        
        # Put all the widgets into a grid layout
        grid = QtGui.QGridLayout()
        
        grid.addWidget(transfer_input_label, 0, 0)
        grid.addWidget(self.qcombo_transfer_input, 0, 1)
        grid.addWidget(transfer_output_label, 1, 0)
        grid.addWidget(self.qcombo_transfer_output, 1, 1)
        grid.addWidget(settling_time_label, 2, 0)
        grid.addWidget(self.qedit_settling_time, 2, 1)
        grid.addWidget(freq_start_label, 3, 0)
        grid.addWidget(self.qedit_freq_start, 3, 1)
        grid.addWidget(freq_end_label, 4, 0)
        grid.addWidget(self.qedit_freq_end, 4, 1)
        grid.addWidget(freq_number_label, 5, 0)
        grid.addWidget(self.qedit_freq_number, 5, 1)
        grid.addWidget(amplitude_label, 6, 0)
        grid.addWidget(self.qedit_output_amplitude, 6, 1)
        grid.addWidget(self.qlbl_integration_time, 7, 0, 1, 2)
        grid.addWidget(self.qbtn_ident, 8, 0, 1, 2)
        grid.addWidget(self.qbtn_stop_ident, 9, 0, 1, 2)
        
        grid.addWidget(self.qprogress_ident, 10, 0, 1, 2)
        
        self.qgroupbox_vna = Qt.QGroupBox('Swept sine', self)
        self.qgroupbox_vna.setLayout(grid)
        
        vbox = Qt.QVBoxLayout()
        vbox.addWidget(self.qgroupbox_vna)
        vbox.addWidget(self.qgroupbox_dither)
        # vbox.addWidget(self.qgroupbox_test_osc)

        # Spacer which takes up the rest of the space:
        spacerItem = QtGui.QSpacerItem(1, 1, QtGui.QSizePolicy.Maximum, QtGui.QSizePolicy.Expanding)
        vbox.addItem(spacerItem)

        self.setLayout(vbox)
        

        # Adjust the size and position of the window
#        self.resize(800, 600)
        self.center()
        self.setWindowTitle('VNA control')    
        self.show()
        

        
    def center(self):
        
        qr = self.frameGeometry()
        cp = QtGui.QDesktopWidget().availableGeometry().center()
        qr.moveCenter(cp)
#        self.move(qr.topLeft())
        self.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(50, 50))
        

    def oscClicked(self):
        print("oscClicked")
        #def setTestOscillator(self, bEnable=1, bPolarity=1, oscillator_modulus, oscillator_modulus_active)

        oscillator_modulus = int(round(  self.sl.fs/float(self.qedit_osc_freq.text()) ))
        oscillator_modulus_active = int(round(  oscillator_modulus * float(self.q_osc_duty_cyle.value()/1e6) ))

        print("self.q_osc_duty_cyle.value()")
        self.sl.setTestOscillator(int(self.qbtn_osc.isChecked()), int(not self.qchk_osc_polarity.isChecked()), oscillator_modulus, oscillator_modulus_active)

