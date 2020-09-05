from PyQt5 import QtCore, QtGui, QtWidgets, uic
import time
import sys
import numpy as np

from common import freq_text_eng_format, freq_value_from_text

class ControllerSettingsWidget(QtWidgets.QWidget):

    def __init__(self, parent=None):
        """  """
        super().__init__(parent)

        # Load UI elements:
        self.setupUi()

        self.openloop_widgets = [self.label_7, self.editExpectedFreq]
        self.closedloop_widgets = [self.editModulatorNominalFreq, self.comboModulatorSign, self.editModulatorGain,
                                   self.lblDetectedModulatorGain, self.comboTargetBW, self.chkLock,
                                   self.label_5, self.label_2, self.label, self.label_4, self.label_3]
        self.comboMode_currentIndexChanged()

    def setupUi(self):
        uic.loadUi("controller_settings_widget.ui", self)
        self.comboMode.currentIndexChanged.connect(self.comboMode_currentIndexChanged)

    def populateClosedLoopBW(self, list_of_BW):
        self.comboTargetBW.clear()
        for BW in list_of_BW:
            self.comboTargetBW.addItem(freq_text_eng_format(BW))

    def comboMode_currentIndexChanged(self):
        mode_is_closed_loop = self.comboMode.currentText() == "Closed-loop fiber noise canceler"
        for w in self.openloop_widgets:
            w.setEnabled(not mode_is_closed_loop)
        for w in self.closedloop_widgets:
            w.setEnabled(mode_is_closed_loop)


def main():
    app = QtWidgets.QApplication(sys.argv)
    gui = ControllerSettingsWidget()
    gui.show()
    gui.populateClosedLoopBW([1, 10, 100, 1e3, 10e3, 100e3, 1e6])
    app.exec_()

if __name__ == '__main__':
    main()

