# -*- coding: utf-8 -*-
"""
Created on Mon Dec 16 09:51:07 2013

@author: jnd
"""

import sys
from PyQt4 import QtGui, Qt
#import numpy as np


class initialConfiguration(QtGui.QDialog):
    
    def __init__(self, strSerialList={}, serial_to_name_mapping = {}, serial_to_color_mapping = {}, strFirmware='superlaserland.bit'):
        super(initialConfiguration, self).__init__()
        self.bSendFirmware = False
        self.strSelectedSerial = ''
        self.strSerialList = strSerialList
        self.strFirmware = strFirmware
        self.bOk = False
        
        
        grid = Qt.QGridLayout()
        
        self.qbtn_yes = Qt.QPushButton('OK')
        self.qbtn_no = Qt.QPushButton('Cancel')
    
        self.qbtn_yes.clicked.connect(self.okClicked)
        self.qbtn_no.clicked.connect(self.cancelClicked)
        
        self.qlabel_serial = Qt.QLabel('Connected FPGAs')
        self.qlabel_firmware = Qt.QLabel('Firmware file')
        
        self.qcombo_serial = Qt.QComboBox()
        for key in strSerialList:
            strDisplay = ''
            print(key)
            print(strSerialList)
            print(strSerialList[key])
            try:
                box_name = serial_to_name_mapping[strSerialList[key]]
            except KeyError:
                box_name = ''
                pass
            
            try:
                box_color = serial_to_color_mapping[strSerialList[key]]
            except KeyError:
                box_color = ''
                pass
            
            strDisplay = 'Name = %s, Serial # = %s, Color = %s' % (box_name, strSerialList[key], box_color)
            self.qcombo_serial.addItem(strDisplay)
            
            
        
        self.qedit_firmware = Qt.QLineEdit(self.strFirmware)
        
        self.qradio_reprogram = Qt.QRadioButton('Send firmware')
        self.qradio_noreprogram = Qt.QRadioButton('Connect to an already running box (NOT REALLY WORKING YET)')
        self.qradio_reprogram.setChecked(True)
        # self.qradio_reprogram.setDisabled(True)
        # self.qradio_noreprogram.setDisabled(True)
#        self.qradio_reprogram.click.connect(self.sendFirmwareClick)
#        self.qradio_noreprogram.click.connect(self.sendFirmwareClick)
        
        self.qradio_clk_internal = Qt.QRadioButton('Internal clock (100 MHz)')
        self.qradio_clk_external = Qt.QRadioButton('External clock (200 MHz, divided by 2 internally)')
        self.qradio_clk_external.setChecked(True)
        
        btn_group = Qt.QButtonGroup(self)
        btn_group.addButton(self.qradio_reprogram)
        btn_group.setId(self.qradio_reprogram, 0)
        btn_group.addButton(self.qradio_noreprogram)
        btn_group.setId(self.qradio_noreprogram, 1)
        
        btn_group2 = Qt.QButtonGroup(self)
        btn_group2.addButton(self.qradio_clk_internal)
        btn_group2.addButton(self.qradio_clk_external)
        btn_group2.setId(self.qradio_clk_internal, 2)
        btn_group2.setId(self.qradio_clk_external, 3)
#        self.close.connect(self.closeEvent)
        
        grid.addWidget(self.qlabel_serial, 0, 0)
        grid.addWidget(self.qcombo_serial, 0, 1)
        grid.addWidget(self.qlabel_firmware, 1, 0)
        grid.addWidget(self.qedit_firmware, 1, 1)
        
        #FEATURE
        #grid.addWidget(self.qradio_reprogram, 2, 0)
        #grid.addWidget(self.qradio_noreprogram, 2, 1)
        
        grid.addWidget(self.qradio_clk_internal, 3, 0)
        grid.addWidget(self.qradio_clk_external, 3, 1)
        
#        grid.addWidget(self.qbtn_yes, 4, 0)
#        grid.addWidget(self.qbtn_no, 4, 1)
        hbox = Qt.QHBoxLayout()
        hbox.addStretch(1)
        hbox.addWidget(self.qbtn_yes)
        hbox.addWidget(self.qbtn_no)
        grid.addLayout(hbox, 4, 0, 1, 2)
        
        
        self.setLayout(grid)
        self.setWindowTitle('Initial configuration')
        self.show()
        
    def okClicked(self):
        self.bOk = True
        self.strFirmware = str(self.qedit_firmware.text())  # the str() is to convert the QString to a normal Python string object
        self.bSendFirmware = self.qradio_reprogram.isChecked()
        self.bExternalClock = self.qradio_clk_external.isChecked()
        try:
            self.strSelectedSerial = str(self.strSerialList[self.qcombo_serial.currentIndex()])    # the str() is to convert the QString to a normal Python string object
        except KeyError:
            # nothing bad happened, we probably simply had an empty list
            self.strSelectedSerial = ''
            pass

        self.close()

    def cancelClicked(self):
        self.bOk = False
        self.close()
        
    def closeEvent(self, e):
#        print('close')
        return

def main():
    
    ###########################################################################
    # Start the User Interface
    
    
    # Start Qt:
    app = QtGui.QApplication(sys.argv)
    
    
    # Load a first window which asks the user a question
    strList = {0: '01', 1: '02'}
    initial_config = initialConfiguration(strList)
    # Run the event loop for this window
    app.exec_()
    print(initial_config.bOk)
    print(initial_config.strFirmware)
    print(initial_config.bSendFirmware)
    print(initial_config.strSelectedSerial)
    
    
#    question = initialConfiguration()

    
    # Enter main event loop
#    app.exec_()

if __name__ == '__main__':
    main()     