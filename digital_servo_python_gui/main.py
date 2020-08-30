from PyQt5 import QtCore, QtGui, QtWidgets, uic
import time
import sys
from datetime import datetime
import os
import inspect
import time
import socket

import numpy as np
import pyqtgraph as pg

import SuperLaserLand_JD_RP
import RP_PLL # for CommsError

import channel_gui
import summary_tab
import connection_widget
import config_widget

from common import tictoc, colorCoding, readFloatFromTextbox
import bin_conv

# Set a few global PyQtGraph settings before creating plots:
pg.setConfigOption('leftButtonPan', False)
pg.setConfigOption('background', 'w')
pg.setConfigOption('foreground', 'k')
pg.setConfigOption('antialias', True)

class perChannelSignalEmitter(QtCore.QObject):
    sig_new_adc_data = QtCore.pyqtSignal(np.ndarray, float, float)
    sig_new_iq_data  = QtCore.pyqtSignal(np.ndarray, float)
    sig_new_freq     = QtCore.pyqtSignal(int, float)
    sig_set_visible  = QtCore.pyqtSignal(bool)

class MainWidget(QtWidgets.QMainWindow):
    """ Used as a top-level widget when testing """
    sig_new_settings = QtCore.pyqtSignal(dict)
    sig_phase_point  = QtCore.pyqtSignal(object)

    def __init__(self, parent=None):
        super().__init__(parent)
        
        self.bDisplayTiming = False
        self.tictoc_last = time.perf_counter()
        self.config = dict()
        self.current_tab = 0

        self.iq_channels_list = list(range(1, 1+4)) # number of channels is set by the hardware, we label everything starting from 1 to avoid confusion wrt to the GUI
        self.adc_channels_list = list(range(1, 1+2)) # number of channels is set by the hardware, we label everything starting from 1 to avoid confusion wrt to the GUI

        self.perChannelEmitters = dict()
        self.pts_settings       = dict()
        for channel_index in self.iq_channels_list:
            self.perChannelEmitters[channel_index] = perChannelSignalEmitter()
            self.pts_settings[channel_index] = {"autorefresh": True, "pts_IQ": 100, "pts_ADC": 100}

        self.sl = SuperLaserLand_JD_RP.SuperLaserLand_JD_RP()
        self.config_done = False # we don't read out values from the device until the config is done, because we need to know all the relevant configuration values to do the post-processing needed
        # self.sl.dev.OpenTCPConnection("192.168.2.34")
        # self.sl.phaseReadoutDriver.startLogging()
        # self.sl.setADCclockPLL( f_ref=25e6, bExternalClock=True)
        # # self.sl.setADCclockPLL( f_ref=200e6, bExternalClock=False)

        self.fastTimer = QtCore.QTimer(self)
        self.fastTimer.timeout.connect(self.fastTimerEvent)

        self.fasterTimer = QtCore.QTimer(self)
        self.fasterTimer.timeout.connect(self.fasterTimerEvent)

        self.slowTimer = QtCore.QTimer(self)
        self.slowTimer.timeout.connect(self.slowTimerEvent)

        self.setupUI()

    def setupUI(self):
        self.resize(1200, 300)

        # Create the "Setup" widget as a composite of the connection and configuration widgets:
        self.setup_widget = QtWidgets.QWidget(self)
        self.connection_widget = connection_widget.ConnectionWidget()
        self.config_widget = config_widget.ConfigWidget(self.iq_channels_list)
        
        vbox = QtWidgets.QVBoxLayout()
        vbox.addWidget(self.connection_widget)
        vbox.addWidget(self.config_widget)
        self.setup_widget.setLayout(vbox)

        self.tab_widget = QtGui.QTabWidget(self)
        self.setCentralWidget(self.tab_widget)

        self.summary_tab_gui = summary_tab.SummaryTab()
        self.summary_tab_gui.sig_reset_phase.connect(self.reset_channel_phase)
        self.summary_tab_gui.show()
        self.tab_widget.addTab(self.setup_widget, "Setup")
        self.tab_widget.addTab(self.summary_tab_gui, "Summary")

        # Connect signals to slots:
        self.connection_widget.btnConnect.clicked.connect(self.connect_clicked)
        self.config_widget.btnCommit.clicked.connect(self.commit)
        self.config_widget.sig_set_status.connect(self.setStatus)

        self.channel_GUIs = dict()
        for channel_id in self.iq_channels_list:
            GUI = channel_gui.ChannelGUI(channel_id)

            # Connect signals to slots
            # channel GUIs to main:
            GUI.sig_set_num_points.connect(self.set_num_points)
            GUI.phaseWidget.sig_reset_phase.connect(self.reset_channel_phase)
            # main to channel GUIs:
            self.perChannelEmitters[channel_id].sig_new_adc_data.connect(GUI.newADCdata)
            self.perChannelEmitters[channel_id].sig_new_iq_data.connect(GUI.newIQdata)
            self.perChannelEmitters[channel_id].sig_new_freq.connect(GUI.newFreqData)
            self.perChannelEmitters[channel_id].sig_set_visible.connect(GUI.setVisibility)
            self.perChannelEmitters[channel_id].sig_new_freq.connect(self.summary_tab_gui.newFreqData) # oddball
            # main to summary tab:
            self.sig_new_settings.connect(GUI.newSettings)
            self.sig_phase_point.connect(GUI.newPhasePoint)
            self.sig_phase_point.connect(self.summary_tab_gui.newPhasePoint)

            # channel GUIs to summary:
            GUI.sig_new_Amplitude.connect(self.summary_tab_gui.newAmplitude)
            GUI.sig_new_SNR.connect(self.summary_tab_gui.newSNR)
            # Trigger a few updates now that the signals have been connected
            GUI.probingSettingsChanged()

            # vbox.addWidget(GUI)
            self.tab_widget.addTab(GUI, "Channel %d" % (channel_id))
            self.channel_GUIs[channel_id] = GUI

        self.tab_widget.currentChanged.connect(self.updateTabVisibility)
        self.setWindowTitle('Frequency counter/phase meter')

        self.enableOrDisableWidgetsRequiringConnection(False)

        self.updateTabVisibility(0)
        self.fasterTimer.start(5)
        self.fastTimer.start(20)
        self.slowTimer.start(100)

        self.show()

    def setStatus(self, field, text, color_name):
        """ Set one of the status-bar entry to "text", and to given color coding """
        print("TODO: status-bar! (field, text, color_name) = ", (field, text, color_name))
        # self.status_bar_fields[field].setText(text)
        # colorCoding(self.status_bar_fields[field], color_name)

    def connect_clicked(self, bConnect):
        self.config_done = False
        if bConnect == False:
            # button was unchecked, disconnect
            if self.sl.dev.valid_socket:
                self.sl.dev.CloseTCPConnection()
            self.config_widget.lblStatus.setText("Uncommitted")
            colorCoding(self.config_widget.lblStatus, "bad")
        else:
            # attempt to establish connection to selected device
            (strMAC, strIP, port) = self.connection_widget.getSelectedHost()
            if strIP is None:
                print("Could not get valid IP address")
                return

            self.sl.dev.OpenTCPConnection(strIP, port)
            self.sl.phaseReadoutDriver.startLogging()
            print("connect_clicked(): TODO: set config file name, enable rest of GUI controls if connection was valid")

        self.enableOrDisableWidgetsRequiringConnection(bConnect)



    def enableOrDisableWidgetsRequiringConnection(self, bEnable):
        self.config_widget.setEnabled(bEnable)
        self.summary_tab_gui.setEnabled(bEnable and self.validDeviceAndConfigKnown())
        for index in range(1, self.tab_widget.count()): # skip first tab which is "Setup"
            self.tab_widget.setTabEnabled(index, bEnable and self.validDeviceAndConfigKnown())

    def commit(self):
        """ Read all the settings from the GUI to our config dict, then push to device """
        try:
            (system_settings, channels_settings) = self.config_widget.readConfigFromGUI()
        except ValueError:
            return # don't commit anything since there is an invalid value somewhere

        self.pushSettingsToDevice(system_settings, channels_settings)
        self.config_widget.lblStatus.setText("Committed")
        colorCoding(self.config_widget.lblStatus, "ok")
        
        self.emit_system_settings()

        self.config_done = True
        print(self.validDeviceAndConfigKnown())
        self.enableOrDisableWidgetsRequiringConnection(self.validDeviceAndConfigKnown())

    def pushSettingsToDevice(self, system_settings, channels_settings):
        """ Push settings to an already-connected device """
        self.sl.setADCclockPLL(         f_ref=system_settings["ref_freq"],
                               bExternalClock=system_settings["adc_use_external_clock"])
        self.sl.phaseReadoutDriver.setOutputRate(system_settings["output_data_rate"])
        system_settings["output_data_rate"]
        for channel_id, channel_settings in channels_settings.items():
            self.setup_LO(system_settings, channel_settings)

    def emit_system_settings(self):
        # TODO: make this cleaner... update at the right times, etc
        d = dict()
        d["type"] = "system"
        d["fs"] = self.sl.fs
        d["n_bits_phase"] = self.sl.phaseReadoutDriver.n_bits_phase
        d["LPF_DECIM"] = self.sl.phaseReadoutDriver.LPF_DECIM
        d["n_cycles"] = self.sl.phaseReadoutDriver.n_cycles # number of decimated samples per integration time
        self.sig_new_settings.emit(d)

    def set_num_points(self, channel_id, d):
        """ Called when the GUI wants to change the number of points being read from the ADC and IQ sources """
        self.pts_settings[channel_id] = dict(d) # just make a local copy

    def reset_channel_phase(self, channel_id):
        """ Qt slot, called when the user presses a channel's "reset phase" button.
        Merely passes the command to the phase readout code """
        self.sl.phaseReadoutDriver.resetChannelPhase(channel_id)

    def setup_LO(self, system_settings, channel_settings):
        """ Called when the GUI wants to change the LO settings
        system_settings must contain at least the following fields:
        system_settings["ref_freq"]
        system_settings["ref_freq_MHz_str"]
        channel_settings must contain at least the following fields:
        channel_settings["channel_id"]
        channel_settings["expected_freq_MHz_str"]
        channel_settings["expected_freq"]
        channel_settings["target_if"]
        channel_settings["upper_sideband"]
        channel_settings["LO_pwr"]
        channel_settings["LO_enable"]
        """
        s = system_settings  # shorthand
        c = channel_settings # shorthand
        print("setup_LO: system_settings=%s, channel_settings=%s" % (str(s), str(c)))
        if c["upper_sideband"]:
            out_freq_target = c["expected_freq"] - c["target_if"]
            sign_str = '+'
        else:
            out_freq_target = c["expected_freq"] + c["target_if"]
            sign_str = '-'

        # TODO: input validation vs actual range accessible?
        print("setup_LO(): channel_id: ", c["channel_id"])
        self.sl.set_expected_freq(c["channel_id"], c["expected_freq_MHz_str"], s["ref_freq_MHz_str"])
        print("setup_LO: FIXME: Refactor where we handle setup_LO")
        a = self.sl.set_adf4351_freq(out_freq_target, s["ref_freq"], s["pfd_target_freq"], c["channel_id"], c["LO_pwr"], c["LO_enable"])
        D = 2**a.reg["RF_DIVIDER_SEL"]
        INT = a.reg["INT"]
        R = a.reg["R"]
        LO_actual = s["ref_freq"] * float(INT / (D*R))
        IF_actual = abs(c["expected_freq"] - LO_actual)

        # Gather all the required information for the channel GUI to operate properly
        result = dict(c) # also copies all the fields from c
        result["chosen_LO"] = LO_actual
        result["chosen_IF"] = IF_actual
        result["chosen_LO_text"] = "%.8f MHz = ref freq * %d/%d" % (LO_actual/1e6, INT, D*R)
        result["chosen_IF_text"] = "%.8f MHz" % (IF_actual/1e6)
        if c["upper_sideband"]:
            result["chosen_IF_text"] += "= input - LO freq"
        else:
            result["chosen_IF_text"] += "= LO freq - input"

        self.sl.set_ddc_ref_freq(IF_actual, c["channel_id"])

        for field in result:
            prefix = "ch%d_" % c["channel_id"]
            self.config[prefix + field] = result[field]

        result["lpf"] = self.sl.get_ddc_filter()
        result["type"] = "LO"
        self.sig_new_settings.emit(result) # needed by the channel_gui's

    def get_approximate_input_freq(self, adc_channel_id):
        field_name = "ch%d_" % adc_channel_id + "expected_freq"
        IF_actual = self.config.get(field_name, None)
        if IF_actual is None:
            IF_actual = 40e6 # not critical, just used to lookup the amplitude calibration curve
        return IF_actual

    def validDeviceAndConfigKnown(self):
        """ Returns True if there is a valid device connected,
        and all the configuration values are known so that we can read-out data
        from the device, and apply the necessary post-processing. """
        return self.sl.dev.valid_socket and self.config_done

    def slowTimerEvent(self):
        """ Reads the slow phase streaming data (100 phase samples/seconds nominal, read every counter gate period).
        Current limitation of the way we do things is that the max counter period is related with
        the filling of the circular buffer inside the FPGA.  Exact value is TBD, but probably good up to 10 secs.
        This function also computes the frequency offset from said phase data, and emits the result as a signal """
        if not self.validDeviceAndConfigKnown():
            return
        # self.bDisplayTiming = True
        tictoc(self)
        self.gate_time_in_samples = 100 # 1 sec gate time, hard-coded for now
        data = self.sl.phaseReadoutDriver.readData(self.gate_time_in_samples)
        if data is None:
            return
        tictoc(self, "read")
        self.handleNewPhaseReadout(data)

    def handleNewPhaseReadout(self, data):
        tictoc(self)
        for field in data.dtype.fields:
            with open('out_%s.bin' % field, 'ab') as f:
                f.write(data[field].tobytes())
        tictoc(self, "write to disk")

        ts = data['timestamp']
        for channel in self.iq_channels_list:
            phi = data['phi%d' % channel]
            freq = self.frequencyCounterFromPhaseData(ts, phi)
            tictoc(self, "freq counter")
            self.perChannelEmitters[channel].sig_new_freq.emit(channel, freq)
            tictoc(self, "emit")
        self.bDisplayTiming = False

    def frequencyCounterFromPhaseData(self, ts, phi):
        """ Compute frequency from least-squares fit to phase data.
        Accuracy is limited to ~1e-15 in frequency offset
        due to doing computations in double-precision floats.
        Gate time is currently fixed at 100 phase samples, thus 1 sec for 100 Hz phase output rate """
        # self.bDisplayTiming = True
        tictoc(self)
        phi = phi - phi[0]
        phi = phi.astype(np.float) # limits accuracy to ~1e-15
        phi = phi/2**self.sl.phaseReadoutDriver.n_bits_phase
        phi = phi/self.sl.phaseReadoutDriver.n_cycles
        # phi is now in cycles
        ts = ts - ts[0]
        ts = ts.astype(np.float)
        freq = 0
        fit = np.polynomial.Polynomial.fit(ts, phi, 1)
        freq = fit.convert().coef[1] # freq is in units of cycles of the IQ waveform/cycles of the ADC clock
        freq_Hz = freq * self.sl.fs
        tictoc(self, "fit")
        # self.bDisplayTiming = False
        return freq_Hz

    def fastTimerEvent(self):
        if not self.validDeviceAndConfigKnown():
            return
        self.updateADCdisplays()
        self.updateIQdisplays()

    def updateADCdisplays(self):
        # each ADC channel is shared by two IQ channels
        adc_channel_to_linked_iq_channels = {
            1: (1, 2),
            2: (3, 4)}
        for adc_channel_id in self.adc_channels_list:
            iq_channel1, iq_channel2 = adc_channel_to_linked_iq_channels[adc_channel_id]
            N1 = self.pts_settings[iq_channel1]["pts_ADC"]
            N2 = self.pts_settings[iq_channel2]["pts_ADC"]
            N_ADC = max(N1, N2) # we grab the longest trace requested, then emit just what was requested by each
            if not self.shouldIQchannelRefresh(iq_channel1) and not self.shouldIQchannelRefresh(iq_channel2):
                continue
            # fs = 125e6
            # adc_data = 0.1*np.cos(2*np.pi*15e6/125e6*np.linspace(0, N-1, N)) + 0.01*np.random.randn(N)
            (timestamp, adc_data) = self.sl.getADCdata(adc_channel_id, N_ADC) # adc numbers are 1-based
            if adc_data is None:
                continue
            scale_factor_adc_to_input = self.sl.scale_factor_adc_to_input(self.get_approximate_input_freq(adc_channel_id))
            # adc_data = self.getIQdata(1, N)
                
            if self.shouldIQchannelRefresh(iq_channel1):
                self.perChannelEmitters[iq_channel1].sig_new_adc_data.emit(adc_data[:N1], self.sl.getADCmaxVoltage(), scale_factor_adc_to_input)
            if self.shouldIQchannelRefresh(iq_channel2):
                self.perChannelEmitters[iq_channel2].sig_new_adc_data.emit(adc_data[:N2], self.sl.getADCmaxVoltage(), scale_factor_adc_to_input)

    def updateIQdisplays(self):
        # IQ channels are independent otherwise
        for iq_channel_id in self.iq_channels_list:
            if not self.shouldIQchannelRefresh(iq_channel_id):
                continue
            N = self.pts_settings[iq_channel_id]["pts_IQ"]
            (timestamp, complex_baseband) = self.sl.getIQdata(iq_channel_id, N) # ids are 1-based here too
            # complex_baseband = 0.1*np.exp(1j*np.linspace(0, 2*np.pi, N)) + 0.01*np.random.randn(N) + 0.01*1j*np.random.randn(N)
            scale_factor_adc_to_input = self.sl.scale_factor_adc_to_input(self.get_approximate_input_freq(iq_channel_id))
            self.perChannelEmitters[iq_channel_id].sig_new_iq_data.emit(complex_baseband, scale_factor_adc_to_input)

    def fasterTimerEvent(self):
        if not self.validDeviceAndConfigKnown():
            return
        phases = self.sl.phaseReadoutDriver.peakLatestPhases()
        self.sig_phase_point.emit(phases)

    def shouldIQchannelRefresh(self, iq_channel_id):
        """ Returns True if this IQ channel must refresh its data """
        if self.current_tab == 1: # Summary tab visible?
            return True
        if self.pts_settings[iq_channel_id]["autorefresh"] and self.isChannelVisible(iq_channel_id):
            return True
        return False

    def isChannelVisible(self, channel_id):
        return self.current_tab-1 == channel_id

    def updateTabVisibility(self, tab_index):
        self.current_tab = tab_index
        for iq_channel_id in self.iq_channels_list:
            self.perChannelEmitters[iq_channel_id].sig_set_visible.emit(self.isChannelVisible(iq_channel_id))

class MyScrollArea(QtWidgets.QScrollArea):
    """ Just a normal scrollarea,
    except that we re-implement viewportSizeHint()
    to give a sensible starting value """
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def viewportSizeHint(self):
        return QtCore.QSize(1500, 600)

def amplitude_calibration(main_widget):
    """ Measures received amplitude at various frequencies.
    Requires a Siglent SSA-3021X with tracking generator option,
    and prior calibration of said generator using amplitude_calibration.py """
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(1.0)
    s.connect(("192.168.2.17", 5025))

    freq_axis = np.linspace(40e6, 2e9, 1000)
    # freq_axis = np.tile(freq_axis, 3)
    # freq_axis = freq_axis[np.array((0, 28, 57))]
    print(freq_axis)
    amplitude = 0*freq_axis
    for index, freq in enumerate(freq_axis):
        print("Setting freq = %f MHz" % (freq/1e6))
        s.sendall((':FREQ:CENT %.3f MHz\n' % (freq/1e6)).encode('ascii'))

        d = dict()
        d["channel_id"] = 1
        d["expected_freq"] = freq
        d["target_if"] = 20e6
        d["upper_sideband"] = False
        main_widget.setup_LO(d)

        time.sleep(200e-3)
        (timestamp, complex_baseband) = main_widget.sl.getIQdata(d["channel_id"], int(1e3))
        mean_amplitude = np.mean(np.abs(complex_baseband))
        # input signal is A*cos(), baseband signal is A*exp(),
        # average power in input signal is thus A**2/2/Z
        impedance = 50
        mean_power_W = mean_amplitude**2/2/impedance
        mean_power_dBm = 10*np.log10(mean_power_W * 1e3)
        print("f=%f MHz, pwr=%f dBm" % (freq/1e6, mean_power_dBm))
        amplitude[index] = mean_power_dBm

    print(amplitude)
    with open("output_amplitude.bin", "wb") as f:
        f.write(amplitude.tobytes())

    with open("output_freq.bin", "wb") as f:
        f.write(freq_axis.tobytes())

def main():
    # for testing when ran without a parent GUI
    app = QtWidgets.QApplication(sys.argv)
    main_widget = MainWidget()

    if len(sys.argv) > 1 and sys.argv[1] == '-amplitude_calibration':
        print("Running amplitude calibration...")
        amplitude_calibration(main_widget)
        print("Amplitude calibration complete! Data saved to disk.")
    
    app.exec_()

if __name__ == '__main__':
    main()
