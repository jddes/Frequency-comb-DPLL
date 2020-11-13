from PyQt4 import QtCore, Qt, QtGui, uic
import sys
import time
import os

# import numpy as np
# import pyqtgraph as pg

class PhaseDisplayWidget(QtGui.QWidget):
    def __init__(self, parent=None, *args, **kwargs):
        super(EmptyQtWidgetTemplate, self).__init__(parent)

        self.phi_last = 0
        self.phi_offset = 0
        self.channel_id = channel_id

        self.setupUI()

    def setupUI(self):
        self.grid = QtWidgets.QGridLayout()
        self.grid.setVerticalSpacing(0)
        n_bars = 4
        ratio_between_bars = 100.
        smallest_bar_scale_factor = 100. # 100th of a cycle
        largest_bar_scale_factor = smallest_bar_scale_factor / ratio_between_bars**(n_bars-1)
        self.bars = list()
        self.lbls = list()
        self.scale_factors = list()

        current_grid_line = 0
        self.lblPhase = QtWidgets.QLabel('0')
        self.lblPhase.setAlignment(QtCore.Qt.AlignHCenter)
        self.grid.addWidget(self.lblPhase, current_grid_line, 0, 1, 2)
        current_grid_line += 1

        for line_index in range(n_bars):
            self.bars.append(QtWidgets.QProgressBar())
            self.bars[-1].setTextVisible(False)
            self.bars[-1].setValue(50)
            self.grid.addWidget(self.bars[-1], current_grid_line, 0)

            self.scale_factors.append(largest_bar_scale_factor * ratio_between_bars**line_index)
            if self.scale_factors[-1] > 1.0:
                text = '1/%dth cycles' % self.scale_factors[-1]
            else:
                text = '%d cycles' % (1./self.scale_factors[-1])
            self.lbls.append(QtWidgets.QLabel(text))

            self.grid.addWidget(self.lbls[-1], current_grid_line, 1)
            current_grid_line += 1

        btnResetPhase = QtWidgets.QPushButton('Reset phase')
        btnResetPhase.clicked.connect(self.resetPhase)
        self.grid.addWidget(btnResetPhase, current_grid_line, 0, 1, 2)
        current_grid_line += 1

        self.grid.setRowStretch(current_grid_line, 1)

        self.setLayout(self.grid)

    def newPhasePoint(self, phi):
        """ phi should be in units of cycles """
        self.phi_last = phi
        phi_display = (phi - self.phi_offset)

        for line_index, bar in enumerate(self.bars):
            phi_scaled = ((self.scale_factors[line_index] * phi_display + 0.5) % 1.0) - 0.5
            bar.setValue(50+int(round(phi_scaled*100)))

        self.lblPhase.setText('%.6f cycles' % phi_display)

    def resetPhase(self):
        self.phi_offset = self.phi_last

################################################################
## Main code
################################################################
def main():
    app = QtGui.QApplication(sys.argv)  
      
    GUI = PhaseDisplayWidget()
    # Show GUI
    GUI.show()

    # GUI.showMaximized()
    
#    # Set program icon
#    # hack for win7
#    APPID = u'TITLE'
#    ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(APPID)
#    icon = QtGui.QIcon('icons/poutine.png')
#    app.setWindowIcon(icon)
#    GUI.setWindowIcon(icon)

    # log_append("after show()")
        
    # Execute application
    app.exec_()
    del GUI
    
    
if __name__ == '__main__':
    main()
    