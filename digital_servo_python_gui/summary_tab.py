from PyQt5 import QtCore, QtGui, QtWidgets, uic
import time
import sys
from datetime import datetime
import os
import inspect

import numpy as np
from functools import partial

from common import tictoc, style_sheets, getSNRcolorName, getPowerColorName

class SummaryTab(QtWidgets.QWidget):
    sig_reset_phase = QtCore.pyqtSignal(int)

    def __init__(self, channels_list=[1, 2, 3, 4], parent=None):
        super().__init__(parent)
        self.bDisplayTiming = False # set this to True to print profiling information
        self.channels_list = channels_list
        self.style_sheets = style_sheets

        self.setupUI()

    def setupUI(self):
        uic.loadUi("summary_tab.ui", self)
        self.tab_visible = True

        # regroup all our per-channel widgets into an easily-accessible data structure:
        self.channel_widgets = dict()
        self.channels_list
        for widget_name in ["btnResetPhase", "lblPhase", "lblFreq", "lblSNR", "lblPower"]:
            d = dict()
            self.channel_widgets[widget_name] = d
            for channel_id in self.channels_list:
                widget = getattr(self, '%s%d' % (widget_name, channel_id))
                if widget_name.startswith('lbl'):
                    widget.setText('')
                self.channel_widgets[widget_name][channel_id] = widget

        # connect signals to slots:
        for channel_id in self.channel_widgets["btnResetPhase"]:
            reset_this_channel_func = partial(self.resetChannelPhase, channel_id)
            w = self.channel_widgets["btnResetPhase"][channel_id]
            w.clicked.connect(                     reset_this_channel_func)
            self.btnResetAllPhases.clicked.connect(reset_this_channel_func) # resetAllPhases will call these four slots

    def resetChannelPhase(self, channel_id):
        print("resetChannelPhase(%d)" % (channel_id))
        self.sig_reset_phase.emit(channel_id)

    def setVisibility(self, bVisible):
        self.tab_visible = bVisible

    def colorCoding(self, widget, color_name, font_size=None):
        if font_size is not None:
            font_size_text = 'font-size: %dpt;' % font_size
        else:
            font_size_text = ''
        widget.setStyleSheet(font_size_text + self.style_sheets[color_name])

    def newAmplitude(self, channel_id, mean_power_dBm, mean_amplitude):
        w = self.channel_widgets["lblPower"][channel_id]
        w.setText('% 05.1f dBm' % mean_power_dBm)
        self.colorCoding(w, getPowerColorName(mean_power_dBm))

    def newSNR(self, channel_id, filtered_baseband_snr):
        w = self.channel_widgets["lblSNR"][channel_id]
        w.setText('%.1f dB' % filtered_baseband_snr)
        self.colorCoding(w, getSNRcolorName(filtered_baseband_snr))

    def newFreqData(self, channel_id, freq_Hz):
        w = self.channel_widgets["lblFreq"][channel_id]
        w.setText('% .6f Hz' % freq_Hz)

    def newPhasePoint(self, phase_data):
        if phase_data is None:
            return
        if not self.tab_visible:
            return
        for channel_id in self.channels_list:
            self._newPhaseSingleChannel(self.channel_widgets["lblPhase"][channel_id], phase_data[channel_id])

    def _newPhaseSingleChannel(self, widget, phi):
        widget.setText('%.6f cycles' % phi)

        if abs(phi) < 0.1: # these are pretty arbitrary at the moment, would be better if this would be configurable
            color_name = 'ok'
        elif abs(phi) < 0.5:
            color_name = 'warning'
        else:
            color_name = 'bad'
        self.colorCoding(widget, color_name)

class TestWidget(QtWidgets.QWidget):
    """ Used as a top-level widget when testing """
    def __init__(self, gui_test, parent=None):
        super().__init__(parent)
        self.gui_test = gui_test

        self.timer = QtCore.QTimer(self)
        self.timer.timeout.connect(self.timerEvent)
        self.timer.start(1000)

    def timerEvent(self):
        """ Simulate signals coming from test.py and channel_gui.py """
        phase_data = dict()
        for channel_id in [1, 2, 3, 4]:
            self.gui_test.newAmplitude(channel_id, -10 - channel_id, 0.1*channel_id)
            self.gui_test.newSNR(channel_id, filtered_baseband_snr = 30 + channel_id)
            self.gui_test.newFreqData(channel_id, freq_Hz=10e6+1e6*channel_id)
            phase_data[channel_id] = channel_id + 0.01*np.random.randn(1)
        self.gui_test.newPhasePoint(phase_data)

def main():
    # for testing when ran without a parent GUI
    app = QtWidgets.QApplication(sys.argv)
    GUI = SummaryTab()
    GUI.show()

    test_widget = TestWidget(GUI)


    
    app.exec_()

if __name__ == '__main__':
    main()

