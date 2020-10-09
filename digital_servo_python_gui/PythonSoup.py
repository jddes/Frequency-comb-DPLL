# -*- coding: utf-8 -*-
"""
Created on Mon Dec 16 09:51:07 2013

@author: jnd
"""
from __future__ import print_function

import sys
from PyQt5 import QtGui, Qt
#import numpy as np
import visa
import time

class PythonSoup(QtGui.QDialog):
    
    def __init__(self, counter0_visa_address='GPIB0::9::INSTR', counter1_visa_address='GPIB0::3::INSTR'):
        super(PythonSoup, self).__init__()

        print('before initui')
        self.initUI()
        print('after initui')
        
        self.counter0_visa_address = counter0_visa_address
        self.counter1_visa_address = counter1_visa_address
        self.openGPIB()
        print('after openGPIB()')
        self.setupHP53132ACounter()
        print('after setupHP53132ACounter()')
#        self.startFrequencyMeasurement()
        
        
    def openGPIB(self):
        
        self.rm = visa.ResourceManager()
#        self.listResources()
        
        self.counters = []
        self.counters.append(self.rm.get_instrument(self.counter0_visa_address))
        self.counters.append(self.rm.get_instrument(self.counter1_visa_address))
        
    def setupHP53132ACounter(self):
        try:
            gate_time = float(self.qedit_gate_time.text())
        except:
            gate_time = 1
        expected_freq_channel1 = 200.7e6    # Fr counter
        expected_freq_channel2 = 3e3        # DFr counter, there is a potential problem with this, the specification asks for a value good to 10% for optimal results, so maybe we're better off leaving this to auto?
        
        # Sends all the desired configuration to the counters:
        for counter in self.counters:
            counter.write(':INIT:CONT OFF')
            
            # Input configuration
            counter.write('INP1:IMP 50')    # 50 ohms input impedance
            counter.write('INP1:COUP AC')   # AC input coupling
            counter.write('INP1:ATT 1')     # No attenuation
            counter.write('INP1:FILT OFF')  # 100 kHz low-pass filter off
            counter.write(':ROSC:SOUR EXT') # Use external 10 MHz reference
            
            # Gate time configuration:
            counter.write('FREQ:ARM:SOUR IMM')    # start the measurement immediately, do not wait for a trigger event
            counter.write('FREQ:ARM:STOP:SOUR TIM')    # Wait for the counter to finish
            counter.write('FREQ:ARM:STOP:TIM %f' % gate_time)    # Set the length of the timer (the gate time)
            
            # The expected frequency values
            counter.write(':SENS:FREQ:EXP1 %f' % expected_freq_channel1)
            counter.write(':SENS:FREQ:EXP2 %f' % expected_freq_channel2)
            
#            counter.write(':SENS:FUNC:ON “FREQ 1”')
            counter.write(":FUNC 'FREQ 1'")
 
            counter.write(':EVENT1:LEVEL 0')    # sets the trigger level to 0 (which is optimal for AC-coupled sinewave)
            
        # Set the UI timer to be about half the gate time to make sure we catch all the measurements:
        self.startFrequencyMeasurement()
        
    def listResources(self):
        # List resources to help the user find the exact VISA address name for a given instrument:
        resources_tuple = self.rm.list_resources()
        
        print('Available VISA resources:')
        for resource_name in resources_tuple:
            print(resource_name)
            
    def startFrequencyMeasurement(self):
        for counter in self.counters:
            counter.write(':INIT:CONT ON')
        
        try:
            gate_time = float(self.qedit_gate_time.text())
        except:
            gate_time = 1
            
        if hasattr(self, 'timerPollCounter'):
            self.timerPollCounter.stop()
        self.timerPollCounter = Qt.QTimer(self)
        self.timerPollCounter.timeout.connect(self.timerPollCounterEvent)
        self.timerPollCounter.setInterval(gate_time*0.8) # Should be set to about half the counter period
        self.timerPollCounter.setSingleShot(True) # Should be set to about half the counter period
        self.timerPollCounter.start()
#        print('setting counter to %f period' % (gate_time/2.))
        
    def timerPollCounterEvent(self):
#        print('timerPollCounterEvent')
        try:
            self.readFrequency()
            self.updateDisplay()
            
            # Using a single-shot timer many times means that we will have a set amount of "wait time" before events, rather than trying to reach an overall period.
            # this will make the whole thing more responsive (a little bit) because we are using blocking IO which blocks the whole thread.
            try:
                gate_time = float(self.qedit_gate_time.text())
            except:
                gate_time = 1
            self.timerPollCounter.setInterval(gate_time*0.8) # Should be set to about half the counter period
            self.timerPollCounter.setSingleShot(True) # Should be set to about half the counter period
            self.timerPollCounter.start()
        except:
            # Disable timer
            print('Exception occured in timer handler, disabling further updates.')
            self.timerPollCounter.stop()
            raise
        
    def prettifyFrequency(self, freq, digits_before_decimal, digits_after_decimal):
#        str_freq = str(abs(round(freq*10**digits_after_decimal)/10**digits_after_decimal)) # this causes too much numerical errors (even with double precision!)
        str_freq = str(abs(freq))
#        print(str_freq)
        
        # Find the decimal point:
        decimal_position = str_freq.find('.')
        if decimal_position == -1:
            # decimal point was not found: add it explicitly:
            str_freq = str_freq + '.'

                
        decimal_position = str_freq.find('.')
        
        # Append the right number of zeros after decimal:
        for k in range(digits_after_decimal - (len(str_freq) - decimal_position) + 1):
            str_freq += '0'

        # Make sure that there are digits_before_decimal digits:
        for k in range(digits_before_decimal-decimal_position):
            # Add the required number of space to match the digits.
            str_freq = ' ' + str_freq
            


        
        # Add commas (or spaces!) every three digits on either side of the decimal point:
        two_parts = str_freq.split('.')
        integer_part = two_parts[0]
        fract_part = two_parts[1]
        fract_part_output = ''
        for k in range(len(fract_part)):
            if (k % 3) == 0 and k != 0:
                fract_part_output = fract_part_output + ',' + fract_part[k]
            else:
                fract_part_output = fract_part_output + fract_part[k]
                
        integer_part_output = ''
        for k in range(len(integer_part)):
            if (k % 3) == 0 and k != 0:
                # We have to add a character, either a comma or a space
                if integer_part[-k-1] != ' ':
                    integer_part_output = integer_part[-k-1] + ',' + integer_part_output
                else:
                    integer_part_output = integer_part[-k-1] + ' '  + integer_part_output
            else:
                integer_part_output = integer_part[-k-1] + integer_part_output
                
        str_freq = integer_part_output + '.' + fract_part_output
        
        # We have stripped off the - sign of negative values, to make the processing the same for both. here we re-add it to the start of the string:
        if freq<0:
            str_freq = '-' + str_freq
        else:
            str_freq = ' ' + str_freq
        return str_freq
            
        
        return str_freq
        
    def updateDisplay(self):
        # Update the GUI text display based on the last received values.
        # Read the internal values and the user-entered values:
        Fr_blue = self.frequencies[0]
        Fr_orange = self.frequencies[1]
        
        DFr = self.frequencies[1] - self.frequencies[0]
        print(DFr)
        
        try:
            F_cw = float(str(self.qedit_Fcw.text()).replace(',', ''))
        except:
            F_cw = 0.
            
        
        # Compute the mode numbers based on Fr orange and Fr blue
        N_mode_blue = F_cw/Fr_blue
        N_mode_orange = F_cw/Fr_orange
        # Compute DFr based on Fr blue and Fr orange:
#        print(type(Fr_blue))
        print(str(Fr_blue))
        print(str(Fr_orange))
#        print(str(Fr_orange))
        DFr = Fr_orange - Fr_blue
        print('type(DFr) = %s, type(Fr_orange) = %s, type(Fr_blue) = %s' % (type(DFr), type(Fr_orange), type(Fr_blue)))
        print(DFr)
#        print(str(DFr))
#        print(str(200751863.528 - 200747817.652))
            
        # Update the display with well-formatted strings:
        self.qlbl_Fr_blue_disp.setText(self.prettifyFrequency(Fr_blue, 9, 6) + ' Hz')
        self.qlbl_Fr_orange_disp.setText(self.prettifyFrequency(Fr_orange, 9, 6) + ' Hz')
        self.qlbl_DFr_disp.setText(self.prettifyFrequency(DFr, 9, 6) + ' Hz')
        self.qlbl_N_blue_disp.setText(self.prettifyFrequency(N_mode_blue, 9, 6) + ' (no units)')
        self.qlbl_N_orange_disp.setText(self.prettifyFrequency(N_mode_orange, 9, 6) + ' (no units)')
        
        self.qlbl_Fcw_blue_disp.setText(self.prettifyFrequency(round(N_mode_blue)*Fr_blue/1e12, 3, 12) + ' THz')
        self.qlbl_Fcw_orange_disp.setText(self.prettifyFrequency(round(N_mode_orange)*Fr_orange/1e12, 3, 12) + ' THz')
        
        # Change the color of the background for the mode number labels based on the fractional part:
        if abs((N_mode_blue+0.5) % 1 - 0.5) > 0.1:
            # red
            self.qlbl_N_blue_disp.setStyleSheet('background-color: red')
        else:
            # green
            self.qlbl_N_blue_disp.setStyleSheet('background-color: green')
            
        if abs((N_mode_orange+0.5) % 1 - 0.5) > 0.1:
            # red
            self.qlbl_N_orange_disp.setStyleSheet('background-color: red')
        else:
            # green
            self.qlbl_N_orange_disp.setStyleSheet('background-color: green')
        
        return
        
    def readFrequency(self):
        self.frequencies = []
        for counter in self.counters:
            freq = float(counter.ask(':FETCH:FREQUENCY?'))
            self.frequencies.append(freq)
            print(freq)
#        counter = self.counters[0]
#        freq = float(counter.ask(':FETCH:FREQUENCY?'))
#        time_after = time.perf_counter()
#        print('Time after: %f sec' % (time_after-time_before))
#        print(freq)
#        frequencies.append(freq)
#        
#        counter = self.counters[1]
#        freq = float(counter.ask(':FETCH:FREQUENCY?'))
#        time_after = time.perf_counter()
#        print('Time after: %f sec' % (time_after-time_before))
#        print(freq)
#        
#        frequencies.append(freq)

        return self.frequencies
        
    def getCounterValues(self):
        return
 
                
    def initUI(self):
        # Set style sheets:
        text_css = 'font-size: 24pt; font-family: courier; font-weight: bold;'   # this sets a monospace font which is needed for nice alignment of the values
        self.setStyleSheet(text_css)
        
        
        self.qlbl_Fr_blue = Qt.QLabel('Fr blue')
        self.qlbl_Fr_orange = Qt.QLabel('Fr orange')
        self.qlbl_DFr = Qt.QLabel('Delta Fr')
        self.qlbl_Fcw = Qt.QLabel('Fcw')
        self.qlbl_N_blue = Qt.QLabel('Nblue = Fcw/Fr blue')
        self.qlbl_N_orange = Qt.QLabel('Norange = Fcw/Fr orange')
        self.qlbl_Fcw_blue = Qt.QLabel('Fcw = round(Nblue)*Fr blue')
        self.qlbl_Fcw_orange = Qt.QLabel('Fcw = round(Norange)*Fr orange')
        self.qlbl_gate_time = Qt.QLabel('Gate time [seconds]')
        
        self.qlbl_Fr_blue_disp = Qt.QLabel('200.000,000,000 MHz')
        self.qlbl_Fr_orange_disp = Qt.QLabel('200.000,000,000 MHz')
        self.qlbl_DFr_disp = Qt.QLabel('2.100,000,000 kHz')
        self.qedit_Fcw = Qt.QLineEdit('191.501,211,857e12')
        self.qlbl_N_blue_disp = Qt.QLabel('953,010.002')
        self.qlbl_N_orange_disp = Qt.QLabel('953,010.002')
        
        self.qlbl_Fcw_blue_disp = Qt.QLabel('191.501,211,857 THz')
        self.qlbl_Fcw_orange_disp = Qt.QLabel('191.501,211,857 THz')
        self.qedit_gate_time = Qt.QLineEdit('1')
        self.qedit_gate_time.editingFinished.connect(self.setupHP53132ACounter)
        
        # put everything in a grid layout:
        grid = Qt.QGridLayout()
        grid.addWidget(self.qlbl_Fr_blue,           1, 0)
        grid.addWidget(self.qlbl_Fr_blue_disp,      1, 1)
        grid.addWidget(self.qlbl_Fr_orange,         2, 0)
        grid.addWidget(self.qlbl_Fr_orange_disp,    2, 1)
        grid.addWidget(self.qlbl_DFr,               3, 0)
        grid.addWidget(self.qlbl_DFr_disp,          3, 1)
        grid.addWidget(self.qlbl_N_blue,            4, 0)
        grid.addWidget(self.qlbl_N_blue_disp,       4, 1)
        grid.addWidget(self.qlbl_N_orange,          5, 0)
        grid.addWidget(self.qlbl_N_orange_disp,     5, 1)
        grid.addWidget(self.qlbl_Fcw,               6, 0)
        grid.addWidget(self.qedit_Fcw,              6, 1)
        
        grid.addWidget(self.qlbl_Fcw_blue,          7, 0)
        grid.addWidget(self.qlbl_Fcw_blue_disp,     7, 1)
        
        grid.addWidget(self.qlbl_Fcw_orange,        8, 0)
        grid.addWidget(self.qlbl_Fcw_orange_disp,   8, 1)
        grid.addWidget(self.qlbl_gate_time,         9, 0)
        grid.addWidget(self.qedit_gate_time,        9, 1)
        

        self.setLayout(grid)
        
#        self.qcombo_instr.currentIndexChanged.connect()
#
#        hbox = Qt.QHBoxLayout()
#        
#        hbox.addWidget(self.qbtn_refresh)
#        hbox.addWidget(self.qcombo_instr)
#        hbox.addWidget(self.qbtn_open)
#        
#        hbox.addStretch(1)
#        
#        
#        hbox2 = Qt.QHBoxLayout()
#        
#
#        
#        vbox = Qt.QVBoxLayout()
#        vbox.addLayout(hbox)
#        vbox.addLayout(hbox2)
#        
#        self.setLayout(vbox)
#        
        
        self.setWindowTitle('PythonSoup (HP 53132A control)')
        self.show()
        
        
def main():
    
    ###########################################################################
    # Start the User Interface
    
    
    # Start Qt:
    app = QtGui.QApplication(sys.argv)
    
    # Blue counter GPIB address = 3, Orange counter GPIB address = 9
    # FOrmat is "GPIBX::Y::INSTR", where X is the GPIB interface number (usually 0)
    gpib_control = PythonSoup(counter0_visa_address='GPIB0::3::INSTR', counter1_visa_address='GPIB0::9::INSTR')
    # Run the event loop for this window
    app.exec_()
    
    
#    question = initialConfiguration()

    
    # Enter main event loop
#    app.exec_()

if __name__ == '__main__':
    main()     