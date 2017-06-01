# -*- coding: utf-8 -*-
"""
Created on Wed Dec 04 20:48:43 2013

@author: JD
"""
from PyQt4 import QtGui, Qt
import numpy as np
import sys

class SLLConfigurationWindow(Qt.QDialog):
    
    def __init__(self):
        super(SLLConfigurationWindow, self).__init__()
        
        self.initUI()
        self.show()
        
    def initUI(self):
        
        textBoxSize = 100
        
        # Put everything in a grid layout:
        grid = Qt.QGridLayout()
#        grid.setRowStretch(0, 1)
#        grid.setColumnStretch(0, 1)
        
        # Create empty variables to hold the UI objects:
        self.qlabel_dac_beat_frequency_range = {}
        self.qedit_dac_beat_frequency_range = {}
        self.qlabel_dac_limits = {}
        self.qedit_dac_limit_low = {}
        self.qedit_dac_limit_high = {}
        self.qlabel_dac_default_offset = {}
        self.qedit_dac_default_offset = {}
        self.qlabel_dac_range = {}
        self.qcombo_dac_range = {}
        self.qlabel_adc_range = {}
        self.qcombo_adc_range = {}
        self.qlabel_ddc_freq = {}
        self.qedit_ddc_freq = {}
        
        lines_per_dac = 5
        
        for k in range(3):
            self.qlabel_dac_beat_frequency_range[k] = Qt.QLabel('DAC{:d} beat frequency range [Hz]'.format(k))
            self.qedit_dac_beat_frequency_range[k] = Qt.QLineEdit('')
            self.qedit_dac_beat_frequency_range[k].setMaximumWidth(textBoxSize)
            grid.addWidget(self.qlabel_dac_beat_frequency_range[k], 0+k*lines_per_dac, 0)
            grid.addWidget(self.qedit_dac_beat_frequency_range[k], 0+k*lines_per_dac, 1)
            
            self.qlabel_dac_limits[k] = Qt.QLabel('DAC{:d} limits [V]'.format(k))
            self.qedit_dac_limit_low[k] = Qt.QLineEdit('')
            self.qedit_dac_limit_high[k] = Qt.QLineEdit('')
            self.qedit_dac_limit_low[k].setMaximumWidth(textBoxSize)
            self.qedit_dac_limit_high[k].setMaximumWidth(textBoxSize)
            grid.addWidget(self.qlabel_dac_limits[k], 1+k*lines_per_dac, 0)
            grid.addWidget(self.qedit_dac_limit_low[k], 1+k*lines_per_dac, 1)
            grid.addWidget(self.qedit_dac_limit_high[k], 1+k*lines_per_dac, 2)
            
            self.qlabel_dac_default_offset[k] = Qt.QLabel('DAC{:d} default offset [V]'.format(k))
            self.qedit_dac_default_offset[k] = Qt.QLineEdit('0')
            self.qedit_dac_default_offset[k].setMaximumWidth(textBoxSize)
            grid.addWidget(self.qlabel_dac_default_offset[k], 2+k*lines_per_dac, 0)
            grid.addWidget(self.qedit_dac_default_offset[k], 2+k*lines_per_dac, 1)
            
            self.qlabel_dac_range[k] = Qt.QLabel('DAC{:d} output range [V]'.format(k))
            self.qcombo_dac_range[k] = Qt.QComboBox()
            self.qcombo_dac_range[k].addItems(['+/- 1V', '+/- 2V', '+/- 4V', '+/- 8V'])
            
            grid.addWidget(self.qlabel_dac_range[k], 3+k*lines_per_dac, 0)
            grid.addWidget(self.qcombo_dac_range[k], 3+k*lines_per_dac, 1, 1, 2)

            # Draw a separator line: (apparently this is the right way to do it)
            line = Qt.QFrame()
            line.setFrameShape(Qt.QFrame.HLine)
            line.setFrameShadow(Qt.QFrame.Sunken)
            grid.addWidget(line, 4+k*lines_per_dac, 0, 1, 3)
            
        for k in range(2):
            self.qlabel_adc_range[k] = Qt.QLabel('ADC{:d} input range [V]'.format(k))
            self.qcombo_adc_range[k] = Qt.QComboBox()
            self.qcombo_adc_range[k].addItems(['+/- 1V', '+/- 0.5V', '+/- 0.25V', '+/- 0.125V'])
            grid.addWidget(self.qlabel_adc_range[k], 0+k*2+3*lines_per_dac, 0)
            grid.addWidget(self.qcombo_adc_range[k], 0+k*2+3*lines_per_dac, 1, 1, 2)
            self.qlabel_ddc_freq[k] = Qt.QLabel('ADC{:d} lock frequency [Hz]'.format(k))
            self.qedit_ddc_freq[k] = Qt.QLineEdit('5e6'.format(k))
            grid.addWidget(self.qlabel_ddc_freq[k], 1+k*2+3*lines_per_dac, 0)
            grid.addWidget(self.qedit_ddc_freq[k], 1+k*2+3*lines_per_dac, 1, 1, 2)
        
        # Spacer: (empty label):
        grid.addWidget(Qt.QLabel(''), 4+3*lines_per_dac, 0, 1, 3)
        grid.setRowStretch(4+3*lines_per_dac, 1)
        # OK/Cancel buttons:
        hbox = Qt.QHBoxLayout()
        self.qok = Qt.QPushButton('OK')
        self.qcancel = Qt.QPushButton('Cancel')
        hbox.addSpacerItem(Qt.QSpacerItem(0, 0, Qt.QSizePolicy.MinimumExpanding, Qt.QSizePolicy.Minimum))
        hbox.addWidget(self.qok)
        hbox.addWidget(self.qcancel)
        
        
        self.qok.clicked.connect(self.saveEvent)
        self.qcancel.clicked.connect(self.cancelEvent)
        
        
        grid.addLayout(hbox, 5+3*lines_per_dac, 0, 1, 3);
        self.setLayout(grid)
        
        self.setWindowTitle('Configuration')
        
    def saveEvent(self):
        self.close()
        print('TODO: Write values in configuration, write to FPGA')
        
    def cancelEvent(self):
        self.close()
        
    def loadParameters(self, sp):
#        self.root.append(Element('Reference_frequency', DDC0='5e6', DDC1='5e6'))
#        self.root.append(Element('Beat_frequency_modulation_range', DAC0='20e9', DAC1='5e6', DAC2='600e6'))
#
        # DAC settings:
        for k in range(3):
            strDAC = 'DAC{:01d}'.format(k)
            
            # Only DAC0 and DAC1 have a gain setting:
            if k == 0 or k == 1:
                gain = int(sp.getValue('Input_Output_gain', strDAC))
                if gain == 1:
                    self.qcombo_dac_range[k].setCurrentIndex(0)
                elif gain == 2:
                    self.qcombo_dac_range[k].setCurrentIndex(1)
                elif gain == 4:
                    self.qcombo_dac_range[k].setCurrentIndex(2)
                else: # gain == 8:
                    self.qcombo_dac_range[k].setCurrentIndex(3)
                
            freq_range = float(sp.getValue('Beat_frequency_modulation_range', strDAC))
            self.qedit_dac_beat_frequency_range[k].setText('{:e}'.format(freq_range))
            
            limit_low = float(sp.getValue('Output_limits_low', strDAC))    # the limit is in volts
            limit_high = float(sp.getValue('Output_limits_high', strDAC))    # the limit is in volts
            self.qedit_dac_limit_low[k].setText('{:f}'.format(limit_low))
            self.qedit_dac_limit_high[k].setText('{:f}'.format(limit_high))
            
            offset = float(sp.getValue('Output_offset_in_volts', strDAC))    # the limit is in volts
            self.qedit_dac_default_offset[k].setText('{:f}'.format(offset))

            
        # ADC and DDC settings:
        for k in range(2):
            strADC = 'ADC{:01d}'.format(k)
            gain = int(sp.getValue('Input_Output_gain', strADC))
            if gain == 1:
                self.qcombo_adc_range[k].setCurrentIndex(0)
            elif gain == 2:
                self.qcombo_adc_range[k].setCurrentIndex(1)
            elif gain == 4:
                self.qcombo_adc_range[k].setCurrentIndex(2)
            else: # gain == 8:
                self.qcombo_adc_range[k].setCurrentIndex(3)
            
            strDDC = 'DDC{:01d}'.format(k)
            ref_freq = float(sp.getValue('Reference_frequency', strDDC))
            self.qedit_ddc_freq[k].setText('{:e}'.format(ref_freq))
            
        
        # Update the values in the UI to reflect the internal values:
        
        return
        
def main():
    
    app = QtGui.QApplication(sys.argv)
    w = SLLConfigurationWindow()
    

#    sys.exit(app.exec_())
    app.exec_()

if __name__ == '__main__':
    main()    
    
