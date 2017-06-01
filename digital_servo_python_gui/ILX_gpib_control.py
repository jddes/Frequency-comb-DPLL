# -*- coding: utf-8 -*-
"""
Created on Mon Dec 16 09:51:07 2013

@author: jnd
"""

import sys
from PyQt4 import QtGui, Qt
#import numpy as np
import visa

class ILX_gpib_control(QtGui.QDialog):
    
    def __init__(self):
        super(ILX_gpib_control, self).__init__()
        
        self.rm = visa.ResourceManager()
        self.ilx = None
        self.initUI()
        
        # Populate the list and open the most likely item:
        self.refreshClicked()
        self.openClicked()
        

    def refreshClicked(self):
        
        resources_tuple = self.rm.list_resources()
        
        self.qcombo_instr.clear()
        for resource_name in resources_tuple:
            self.qcombo_instr.addItem(resource_name)
 
            # Set this as the currently selected item if it contains gpib:
            if 'gpib' in resource_name or 'GPIB' in resource_name:
                self.qcombo_instr.setCurrentIndex(self.qcombo_instr.count()-1)
                
    def openClicked(self):
        print('Opening GPIB connection...')
        strDevice = str(self.qcombo_instr.itemText(self.qcombo_instr.currentIndex()))
        self.ilx = self.rm.get_instrument(strDevice)
        
        print('*IDN?')
        print(self.ilx.ask('*IDN?'))
        
        for k in self.laser_control:
            self.laser_control[k].ilx = self.ilx
            self.laser_control[k].readChannelStatus()
        
    def initUI(self):
        
        
        self.qbtn_refresh = Qt.QPushButton('Refresh list')
        self.qbtn_open = Qt.QPushButton('Open')
    
        self.qbtn_refresh.clicked.connect(self.refreshClicked)
        self.qbtn_open.clicked.connect(self.openClicked)
        
        self.qcombo_instr = Qt.QComboBox()
#        self.qcombo_instr.currentIndexChanged.connect()

        hbox = Qt.QHBoxLayout()
        
        hbox.addWidget(self.qbtn_refresh)
        hbox.addWidget(self.qcombo_instr)
        hbox.addWidget(self.qbtn_open)
        
        hbox.addStretch(1)
        
        
        hbox2 = Qt.QHBoxLayout()
        
        self.laser_control = {}
        for k in range(4):
            self.laser_control[k] = ILX_laser_control_widget(k+1)
            qgroupbox_channel = Qt.QGroupBox('Channel %d' % (k+1))
            hbox3 = Qt.QHBoxLayout()
            hbox3.addWidget(self.laser_control[k])
            qgroupbox_channel.setLayout(hbox3)
            hbox2.addWidget(qgroupbox_channel)
        
        vbox = Qt.QVBoxLayout()
        vbox.addLayout(hbox)
        vbox.addLayout(hbox2)
        
        self.setLayout(vbox)
        
        
        self.setWindowTitle('ILX gpib control')
        self.show()
        

# This widget controls one ILX channel
class ILX_laser_control_widget(Qt.QWidget):
    def __init__(self, channel_number):
        super(ILX_laser_control_widget, self).__init__()
        self.channel_number = channel_number
        self.channel_state = False
        self.ilx = None
        self.initUI()
        self.readChannelStatus()
        
    def readChannelStatus(self):
        # Set the ILX to the correct channel:
        if self.ilx is not None:
            self.ilx.write('LAS:CHAN %d' % self.channel_number)
            answer = self.ilx.ask('LAS:OUT?')
            self.channel_state = (answer == '1')
        
        # Update the display accordingly:
        self.updateDisplay()
        
    def writeChannelStatus(self):
        # Set the ILX to the correct channel:
        if self.ilx is not None:
            self.ilx.write('LAS:CHAN %d' % self.channel_number)
            if self.channel_state:
                # Activate the channel
                self.ilx.write('LAS:OUT 1')
                print('turning output on')
            else:
                # De-activate the channel
                self.ilx.write('LAS:OUT 0')
                print('turning output off')
                
        self.updateDisplay()
        
    def updateInternalStateFromDisplay(self):
        # User has clicked our button
        self.channel_state = self.qbtn_on.isChecked()
        # Push the new value to the ILX:
        self.writeChannelStatus()
            
    def updateDisplay(self):
        
        
        if self.channel_state:
            # channel is currently on:
            self.qlbl_led.setStyleSheet('background-color: #84FF00')    # green
            self.qbtn_on.blockSignals(True)
            self.qbtn_on.setChecked(True)
            self.qbtn_on.blockSignals(False)
        else:
            # channel is currently off:
            self.qlbl_led.setStyleSheet('background-color: red') # red
            self.qbtn_on.blockSignals(True)
            self.qbtn_on.setChecked(False)
            self.qbtn_on.blockSignals(False)
        
    def initUI(self):
#        self.qlbl_channel_number = Qt.QLabel('%d' % self.channel_number)
#        self.qlbl_channel_number.setAlignment(Qt.Qt.AlignHCenter)
#        self.qlbl_channel_number.setMinimumWidth(10)
        
        self.qlbl_led = Qt.QLineEdit('   ')
        self.qlbl_led.setAlignment(Qt.Qt.AlignHCenter)
        self.qlbl_led.setMaximumWidth(50)
#        self.qlbl_led.setStyleSheet('border: 2px solid black; border-radius: 10px;')
#        self.qlbl_led.setStyleSheet('background-color=green; border: 2px solid black; border-radius: 10px;')
#        self.qlbl_led.setAutoFillBackground(True)
        
        
        
#        self.setStyleSheet('background-color : red; color : blue')
        
        
        self.qbtn_on = Qt.QPushButton('On')
        self.qbtn_on.setCheckable(True)
        self.qbtn_on.setChecked(False)
        self.qbtn_on.setMinimumWidth(10)
        self.qbtn_on.clicked.connect(self.updateInternalStateFromDisplay)
        
        
        vbox = Qt.QVBoxLayout()
#        vbox.addWidget(self.qlbl_channel_number)
        vbox.addWidget(self.qlbl_led)
        vbox.addWidget(self.qbtn_on)
        
        self.setLayout(vbox)
#        self.setAutoFillBackground(True)
        
        
        
        
def main():
    
    ###########################################################################
    # Start the User Interface
    
    
    # Start Qt:
    app = QtGui.QApplication(sys.argv)
    
    
    gpib_control = ILX_gpib_control()
    # Run the event loop for this window
    app.exec_()
    
    
#    question = initialConfiguration()

    
    # Enter main event loop
#    app.exec_()

if __name__ == '__main__':
    main()     