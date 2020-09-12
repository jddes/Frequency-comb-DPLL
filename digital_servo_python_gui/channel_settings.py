from PyQt5 import QtCore, QtGui, QtWidgets, uic
import time
import sys
from datetime import datetime
import os

class ChannelSettings(QtWidgets.QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        uic.loadUi("channel_settings.ui", self)

        self.power_code_to_dBm = lambda x : x # this will be replaced with the real conversion function later
        self.spinDDSpower.valueChanged.connect(self.spinDDSpower_valueChanged)

    def spinDDSpower_valueChanged(self, value):
        self.lblDDSpower.setText('%.1f dBm' % self.power_code_to_dBm(value))

def main():
    app = QtWidgets.QApplication(sys.argv)
    GUI = ChannelSettings()
    GUI.show()
    app.exec_()

    
if __name__ == '__main__':
    main()