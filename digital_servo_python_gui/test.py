from PyQt5 import QtCore, QtGui, QtWidgets, uic
import time
import sys
from datetime import datetime
import os
import inspect
import time

import numpy as np
import pyqtgraph as pg

import SuperLaserLand_JD_RP
import RP_PLL # for CommsError
import channel_gui
from common import tictoc
import bin_conv

# Set a few global PyQtGraph settings before creating plots:
pg.setConfigOption('leftButtonPan', False)
pg.setConfigOption('background', 'w')
pg.setConfigOption('foreground', 'k')
pg.setConfigOption('antialias', True)

class perChannelSignalEmitter(QtCore.QObject):
    sig_new_adc_data = QtCore.pyqtSignal(np.ndarray, float)
    sig_new_iq_data  = QtCore.pyqtSignal(np.ndarray)

class Test(QtWidgets.QWidget):
    """ Used as a top-level widget when testing """
    sig_new_settings = QtCore.pyqtSignal(dict)

    def __init__(self, parent=None):
        super().__init__(parent)
        
        self.bDisplayTiming = False
        self.tictoc_last = time.perf_counter()
        self.pfd_target_freq = 10e6
        self.ref_freq = 25e6 # this should be changeable via a signal
        self.num_iq_channels = 4 # set by the hardware...
        self.num_adc_channels = 2 # set by the hardware...

        self.perChannelEmitters = list()
        self.pts_settings = list()
        for channel_index in range(self.num_iq_channels):
            self.perChannelEmitters.append(perChannelSignalEmitter())
            self.pts_settings.append({"autorefresh": True, "pts_IQ": 100, "pts_ADC": 100})

        self.sl = SuperLaserLand_JD_RP.SuperLaserLand_JD_RP()
        self.sl.dev.OpenTCPConnection("192.168.2.34")
        self.sl.phaseReadoutDriver.startLogging()
        self.setupADCclock()

        self.fastTimer = QtCore.QTimer(self)
        self.fastTimer.timeout.connect(self.fastTimerEvent)

        self.slowTimer = QtCore.QTimer(self)
        self.slowTimer.timeout.connect(self.slowTimerEvent)

    def set_num_points(self, channel_id, d):
        """ Called when the GUI wants to change the number of points being read from the ADC and IQ sources """
        print("set_num_points(): channel_id=", channel_id)
        self.pts_settings[channel_id-1] = dict(d) # just make a local copy

    def setup_LO(self, d):
        """ Called when the GUI wants to change the LO settings
        d must contain the following fields:
        d["channel_id"]
        d["expected_freq"]
        d["target_if"]
        d["upper_sideband"]
        """
        print("setup_LO: %s " % str(d))
        if d["upper_sideband"]:
            out_freq_target = d["expected_freq"] - d["target_if"]
            sign_str = '+'
        else:
            out_freq_target = d["expected_freq"] + d["target_if"]
            sign_str = '-'

        # TODO: input validation vs actual range accessible?
        print("setup_LO(): channel_id: ", d["channel_id"])
        a = self.sl.set_adf4351_freq(out_freq_target, self.ref_freq, self.pfd_target_freq, d["channel_id"])
        D = 2**a.reg["RF_DIVIDER_SEL"]
        INT = a.reg["INT"]
        R = a.reg["R"]
        LO_actual = self.ref_freq * float(INT / (D*R))
        IF_actual = abs(d["expected_freq"] - LO_actual)

        result = dict(d) # also copies all the fields from d
        result["chosen_LO"] = LO_actual
        result["chosen_IF"] = IF_actual
        result["chosen_LO_text"] = "%.8f MHz = ref freq * %d/%d" % (LO_actual/1e6, INT, D*R)
        if d["upper_sideband"]:
            result["chosen_IF_text"] = "%.8f MHz = input - LO freq" % (IF_actual/1e6)
        else:
            result["chosen_IF_text"] = "%.8f MHz = LO freq - input" % (IF_actual/1e6)

        self.sl.set_ddc_ref_freq(IF_actual, d["channel_id"])

        result["lpf"] = self.sl.get_ddc_filter()
        result["type"] = "LO"
        self.sig_new_settings.emit(result)

    def slowTimerEvent(self):
        data = self.sl.phaseReadoutDriver.readData()
        if data is None:
            return
        for field in data.dtype.fields:
            with open('out_%s.bin' % field, 'ab') as f:
                f.write(data[field].tobytes())

    def fastTimerEvent(self):
        # each ADC channel is shared by two IQ channels
        adc_channel_to_linked_iq_channels = {
            1: (1, 2),
            2: (3, 4)}
        for adc_channel_id in range(self.num_adc_channels):
            iq_channel1, iq_channel2 = adc_channel_to_linked_iq_channels[adc_channel_id+1]
            N1 = self.pts_settings[iq_channel1-1]["pts_ADC"]
            N2 = self.pts_settings[iq_channel2-1]["pts_ADC"]
            N_ADC = max(N1, N2) # we grab the longest trace requested, then emit just what was requested by each
            bAutoRefresh1 = self.pts_settings[iq_channel1-1]["autorefresh"]
            bAutoRefresh2 = self.pts_settings[iq_channel2-1]["autorefresh"]
            if not bAutoRefresh1 and not bAutoRefresh2:
                continue
            # fs = 125e6
            # adc_data = 0.1*np.cos(2*np.pi*15e6/125e6*np.linspace(0, N-1, N)) + 0.01*np.random.randn(N)
            adc_data = self.getADCdata(adc_channel_id+1, N_ADC) # adc numbers are 1-based
            # adc_data = self.getIQdata(1, N)
            if adc_data is not None:
                if bAutoRefresh1:
                    self.perChannelEmitters[iq_channel1-1].sig_new_adc_data.emit(adc_data[:N1], 1.0)
                if bAutoRefresh2:
                    self.perChannelEmitters[iq_channel2-1].sig_new_adc_data.emit(adc_data[:N2], 1.0)


        # IQ channels are independent otherwise
        for iq_channel_id in range(self.num_iq_channels):
            if not self.pts_settings[iq_channel_id]["autorefresh"]:
                continue
            N = self.pts_settings[iq_channel_id]["pts_IQ"]
            complex_baseband = self.getIQdata(iq_channel_id+1, N) # ids are 1-based here too
            # complex_baseband = 0.1*np.exp(1j*np.linspace(0, 2*np.pi, N)) + 0.01*np.random.randn(N) + 0.01*1j*np.random.randn(N)
            self.perChannelEmitters[iq_channel_id].sig_new_iq_data.emit(complex_baseband)

    def getADCdata(self, adc_number, N_samples):
        return self.getDataSafe(self.sl.LOGGER_MUX['ADC%d' % adc_number], int(N_samples))

    def getIQdata(self, iq_channel, N_samples):
        raw_data = self.getDataSafe(self.sl.LOGGER_MUX['IQ%d' % iq_channel], int(N_samples))
        if raw_data is None:
            return None
        with open("out_raw.bin", "wb") as f:
            f.write(raw_data.tobytes())
        sync_bytes = bin_conv.interpret_as_signed(0xABCD, 16)
        sync_counts0 = np.sum(raw_data[0::3] == sync_bytes)
        sync_counts1 = np.sum(raw_data[1::3] == sync_bytes)
        sync_counts2 = np.sum(raw_data[2::3] == sync_bytes)
        if sync_counts0 >= sync_counts1 and sync_counts0 >= sync_counts2:
            data_real = raw_data[1::3]
            data_imag = raw_data[2::3]
        elif sync_counts1 >= sync_counts2:
            data_real = raw_data[2::3]
            data_imag = raw_data[3::3]
        else: # sync is in raw_data[2]
            data_real = raw_data[0::3]
            data_imag = raw_data[1::3]
        # make sure real and imag are the same size:
        N_min = min(len(data_real), len(data_imag))
        data_complex = data_real[:N_min] + 1j*data_imag[:N_min]
        # return data_real
        # return data_imag
        return data_complex

    def getDataSafe(self, selector, N_samples):
        tictoc(self)
        try:
            data = self.sl.getDataFromLogger(selector, int(N_samples))
            return data
        except RP_PLL.CommsLoggeableError as e:
            print('RP_PLL.CommsLoggeableError')
            # log exception (TODO)
            # logging.error("Exception occurred", exc_info=True)
            return None

        except RP_PLL.CommsError as e:
            print('RP_PLL.CommsError')
            # do not log exception (because it's simply an obvious follow-up to a previous one, and we don't want to fill up the log with repeated information)
            return None

        finally:
            # Tear-down, whether or not an exception occured: Signal to other functions that they can use the DDR2 logger
            tictoc(self, '')
            pass

    def setupADCclock(self):
        # Valid VCO range is 600 MHz-1600 MHz according to DS181
        
        # # For 200 MHz clock (internal), these settings should yield 125 MHz ADC clock, 1000 MHz VCO
        # f_ref          = 200e6
        # CLKFBOUT_MULT  = 5
        # CLKOUT0_DIVIDE = 8
        # ext_clk = False

        # # For 200 MHz external clock input, these settings should yield 125 MHz ADC clock, 1000 MHz VCO
        # f_ext          = 200e6
        # CLKFBOUT_MULT  = 5
        # CLKOUT0_DIVIDE = 8
        # ext_clk = True

        # # For 10 MHz external clock input, these settings should yield 124 MHz ADC clock, 620 MHz VCO
        # f_ext          = 10e6
        # CLKFBOUT_MULT  = 62
        # CLKOUT0_DIVIDE = 5
        # ext_clk = True

        # For 25 MHz external clock input, these settings should yield 125 MHz ADC clock, 1250 MHz VCO
        f_ref          = 25e6
        CLKFBOUT_MULT  = 50
        CLKOUT0_DIVIDE = 10
        ext_clk = True

        self.sl.setADCclockPLL(f_ref, ext_clk, CLKFBOUT_MULT, CLKOUT0_DIVIDE)

class MyScrollArea(QtWidgets.QScrollArea):
    """ Just a normal scrollarea,
    except that we re-implement viewportSizeHint()
    to give a sensible starting value """
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def viewportSizeHint(self):
        return QtCore.QSize(1500, 600)

def main():
    # for testing when ran without a parent GUI
    app = QtWidgets.QApplication(sys.argv)
    test_widget = Test()
    main_widget = QtWidgets.QWidget()
    vbox = QtWidgets.QVBoxLayout()

    GUIs = list()
    for channel_id in range(4):
        GUI = channel_gui.ChannelGUI(channel_id+1) # 1-based IDs used here

        # Connect signals to slots
        GUI.sig_set_num_points.connect(test_widget.set_num_points)
        GUI.sig_setup_LO.connect(test_widget.setup_LO)
        test_widget.perChannelEmitters[channel_id].sig_new_adc_data.connect(GUI.newADCdata)
        test_widget.perChannelEmitters[channel_id].sig_new_iq_data.connect(GUI.newIQdata)
        test_widget.sig_new_settings.connect(GUI.newSettings)

        # Trigger a few updates now that the signals have been connected
        GUI.comboRBW_currentTextChanged()

        vbox.addWidget(GUI)
        GUIs.append(GUI)
    
    main_widget.setLayout(vbox)
    # main_widget.show()
    scrollarea = MyScrollArea() # need a scrollarea since 4 channel is too big...
    scrollarea.setWidget(main_widget)
    scrollarea.setHorizontalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
    scrollarea.show()

    test_widget.fastTimer.start(20)
    test_widget.slowTimer.start(1000)
    
    app.exec_()

if __name__ == '__main__':
    main()
