from PyQt5 import QtCore, QtGui, QtWidgets, uic
import time
import sys
from datetime import datetime
import os
import inspect
import time
import socket
from collections import OrderedDict
import pprint
import winsound

import numpy as np
import pyqtgraph as pg

import SuperLaserLand_JD_RP
import RP_PLL # for CommsError

import channel_gui
import summary_tab
import connection_widget
import config_widget
import controller_settings_widget
import checkboxes_collection_widget

from common import tictoc, colorCoding, readFloatFromTextbox, getExtClkColorName
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

        self.fastTimer = QtCore.QTimer(self)
        self.fastTimer.timeout.connect(self.fastTimerEvent)

        self.fasterTimer = QtCore.QTimer(self)
        self.fasterTimer.timeout.connect(self.fasterTimerEvent)

        self.slowTimer = QtCore.QTimer(self)
        self.slowTimer.timeout.connect(self.slowTimerEvent)

        self.setupUI()

    def setupUI(self):
        self.resize(1200, 300)

        self.connection_widget = connection_widget.ConnectionWidget()
        self.config_widget = config_widget.ConfigWidget(self.iq_channels_list)
        self.summary_tab_gui = summary_tab.SummaryTab()

        self.tab_widget = QtGui.QTabWidget(self)
        self.setCentralWidget(self.tab_widget)
        self.tab_widget.addTab(self.connection_widget, "Connection")
        self.tab_widget.addTab(self.config_widget, "Config")
        self.tab_widget.addTab(self.summary_tab_gui, "Summary")

        self.populateClosedLoopBW()
        # Connect signals to slots:
        self.connection_widget.btnConnect.clicked.connect(self.connect_clicked)
        self.config_widget.btnCommit.clicked.connect(self.commit)
        self.config_widget.sig_set_status.connect(self.setStatus)
        self.summary_tab_gui.sig_reset_phase.connect(self.reset_channel_phase)

        self.channel_GUIs = dict()
        for channel_id in self.iq_channels_list:
            GUI = channel_gui.ChannelGUI(channel_id)

            # Connect signals to slots
            GUI.sig_set_num_points.connect(self.set_num_points)
            GUI.phaseWidget.sig_reset_phase.connect(self.reset_channel_phase)
            GUI.sig_update_lock_state.connect(self.updateLockState)
            self.perChannelEmitters[channel_id].sig_new_adc_data.connect(GUI.newADCdata)
            self.perChannelEmitters[channel_id].sig_new_iq_data.connect(GUI.newIQdata)
            self.perChannelEmitters[channel_id].sig_new_freq.connect(GUI.newFreqData)
            self.perChannelEmitters[channel_id].sig_set_visible.connect(GUI.setVisibility)
            self.perChannelEmitters[channel_id].sig_new_freq.connect(self.summary_tab_gui.newFreqData) # oddball
            self.sig_new_settings.connect(GUI.newSettings)
            self.sig_new_settings.connect(self.config_widget.newSettings)
            self.sig_phase_point.connect(GUI.newPhasePoint)
            self.sig_phase_point.connect(self.summary_tab_gui.newPhasePoint)

            # channel GUIs to summary:
            GUI.sig_new_Amplitude.connect(self.summary_tab_gui.newAmplitude)
            GUI.sig_new_SNR.connect(self.summary_tab_gui.newSNR)
            # Trigger a few updates now that the signals have been connected
            GUI.probingSettingsChanged()

            GUI.IQ_decim = self.sl.LPF_DECIM # make sure that these values are the same

            # vbox.addWidget(GUI)
            self.tab_widget.addTab(GUI, "Channel %d" % (channel_id))
            self.channel_GUIs[channel_id] = GUI

        for k, w in self.config_widget.adv_per_channel.items():
            w.power_code_to_dBm = lambda x: 10*np.log10(1e3*self.sl.getAD9912outputPower(x))
            w.spinDDSpower_valueChanged(w.spinDDSpower.value())

        self.tab_widget.currentChanged.connect(self.updateTabVisibility)
        self.setWindowTitle('FNC-100 Digital PLL/Frequency counter/phase meter')

        self.enableOrDisableWidgetsRequiringConnection(False)
        self.createStatusBar()
        self.clearLossOfClockEvents()

        self.updateTabVisibility(0)
        self.fasterTimer.start(5)
        self.fastTimer.start(20)
        self.slowTimer.start(100)

        self.show()

    def populateClosedLoopBW(self):
        (gain_combined, gain_fine, gain_coarse) = self.sl.getAllPossiblePgains()
        BW_all = self.sl.getClosedLoopBW(gain_combined)
        self.config_widget.populateClosedLoopBW(BW_all)

    def createStatusBar(self):
        self.status_bar_fields = OrderedDict()
        self.status_bar_fields["connection"] = QtWidgets.QLabel('Disconnected.')
        self.status_bar_fields["commit"]     = QtWidgets.QLabel('No config committed')
        self.status_bar_fields["clock"]      = QtWidgets.QLabel('')
        self.status_bar_fields["clock_loss"] = QtWidgets.QLabel('')
        self.status_bar_fields["spacer"]     = QtWidgets.QLabel('')
        self.status_bar_fields["config"]     = QtWidgets.QLabel('No config file selected')



        self.setStatus("connection", "Disconnected.", "bad")
        self.setStatus("config", "No config file selected", "bad")
        self.setStatus("commit", "Uncommitted", "bad")
        # self.statusBar = QtWidgets.QStatusBar()
        for k, w in self.status_bar_fields.items():
            if k == "spacer":
                stretch = 1
            else:
                stretch = 0
            self.statusBar().addPermanentWidget(w, stretch)

    def setStatus(self, field, text, color_name):
        """ Set one of the status-bar entry to "text", and to given color coding """
        target_widgets = [self.status_bar_fields[field]]

        # also show relevant status directly next to the pushbutton that controls it:
        if field == "connection":
            target_widgets.append(self.connection_widget.lblStatus)
        elif field == "commit":
            target_widgets.append(self.config_widget.lblStatus)

        for w in target_widgets:
            w.setText(text)
            colorCoding(w, color_name)

    def freq_sweep(self):
        self.sl.setDDSclockPLL(10e6)
        # self.sl.set_dds_limits(1, 0, 499e6)
        self.sl.set_dds_unlimited(1)


        frequency_in_hz = 0
        for k in range(300):
            frequency_in_hz += 500e6/300
            print("freq [MHz] = ", frequency_in_hz/1e6)
            self.sl.set_dds_offset_freq(1, frequency_in_hz)
            time.sleep(1)

        pass

    def connect_clicked(self, bConnect):
        self.config_done = False
        self.setStatus('commit', 'Uncommitted', 'bad')
        if bConnect == False:
            # button was unchecked, disconnect
            if self.sl.dev.valid_socket:
                self.sl.dev.CloseTCPConnection()
            self.setStatus('connection', 'Disconnected.', 'bad')
            self.connection_widget.btnConnect.setText('Connect to device')
        else:
            # attempt to establish connection to selected device
            (strMAC, strIP, port) = self.connection_widget.getSelectedHost()
            if strIP is None:
                bConnect = False
                self.connection_widget.btnConnect.setChecked(False)

                self.setStatus('connection', 'No IP selected', 'bad')
            else:
                self.sl.dev.OpenTCPConnection(strIP, port)
                if self.sl.dev.valid_socket:
                    # self.freq_sweep()
                    # self.sl.setupDither(1, 0.1, 1e3, 100e3/1e9, 1)


                    # self.sl.sendHardwareDescription(bHasMixerBoard=True, bHasDDS=True) # use this once when upgrading a given RP with extra hardware
                    self.hw_description = self.sl.getHardwareDescription()
                    # Handle various versions of the hardware changing the exact GUI that we should present to the user:
                    bHasDDS = self.hw_description.get("has_dds", False)
                    # bHasDDS = False # force to false for testing
                    self.config_widget.setHardwareType(bHasDDS)

                    self.sl.phaseReadoutDriver.startLogging()
                    self.connection_widget.btnConnect.setText('Disconnect from device')
                    self.setStatus('connection', 'Connected to %s' % strIP, 'ok')

                else:
                    bConnect = False
                    self.connection_widget.btnConnect.setChecked(False)
                    self.setStatus('connection', 'Error attempting to connect to %s' % strIP, 'bad')

            print("connect_clicked(): TODO: set config file name")

        self.enableOrDisableWidgetsRequiringConnection(bConnect)

    def enableOrDisableWidgetsRequiringConnection(self, bEnable):
        self.config_widget.setEnabled(bEnable)
        self.summary_tab_gui.setEnabled(bEnable and self.validDeviceAndConfigKnown())
        self.tab_widget.setTabEnabled(1, bEnable) # 2nd tab is "config"
        for index in range(2, self.tab_widget.count()): # skip first tab which is "Setup", and 2nd tab which is "config"
            self.tab_widget.setTabEnabled(index, bEnable and self.validDeviceAndConfigKnown())

        for w in [self.connection_widget.btnUpdateFPGA, self.connection_widget.btnUpdateCPU]:
            w.setEnabled(not bEnable)

    def commit(self):
        """ Read all the settings from the GUI to our config dict, then push to device """
        try:
            (system_settings, channels_settings) = self.config_widget.readConfigFromGUI()
        except (ValueError, SyntaxError):
            return # don't commit anything since there is an invalid value somewhere
        self.pushSettingsToDevice(system_settings, channels_settings)
        self.clearLossOfClockEvents()
        self.setStatus('commit', 'Committed', 'ok')
        
        self.emit_system_settings()

        self.config_done = True
        self.enableOrDisableWidgetsRequiringConnection(self.validDeviceAndConfigKnown())

    def pushSettingsToDevice(self, system_settings, channels_settings):
        """ Push settings to an already-connected device """
        self.sl.setADCclockPLL(         f_ref=system_settings["ref_freq"],
                               bExternalClock=system_settings["adc_use_external_clock"])
        self.sl.setDDSclockPLL(system_settings["ref_freq"])

        self.sl.phaseReadoutDriver.setOutputRate(system_settings["output_data_rate"])
        for channel_id, channel_settings in channels_settings.items():
            self.setup_LO(system_settings, channel_settings)
            if "DDS_output_current_word" in channel_settings:
                self.sl.setAD9912current(channel_settings["channel_id"], channel_settings["DDS_output_current_word"])
                self.sl.setAD9912powerState(channel_settings["channel_id"], channel_settings["DDS_output_enable"])

            self.setup_controller(system_settings, channel_settings) # needs to happen after setDDSclockPLL()
        self.sl.commit_controller_settings()

        # for testing only:
        # self.sl.setAD9912enable((False, False, False, False))
        # self.sl.setAD9912enable((True, True, True, True))
        # self.sl.set_dds_limits(1, 0, 0)
        # self.sl.set_dds_limits(2, 0, 0)
        # self.sl.set_dds_limits(3, 0, 0)
        # self.sl.set_dds_limits(4, 0, 0)
        
        # SPI_wire_names = ["freq_updates",
        #                   "DIO0_P_SDIO2",
        #                   "DIO0_N_SDIO1",
        #                   "DIO1_P_CSB",
        #                   "DIO1_N_SCLK_P",
        #                   "DIO2_P_SCLK_P",
        #                   "DIO2_N_SCLK_N",
        #                   "DIO4_P_SDIO3",
        #                   "DIO4_N_CSB",
        #                   "DIO6_P_SCLK_P",
        #                   "DIO6_N_SCLK_N",
        #                   "DIO7_P_SDIO4",
        #                   "DIO7_N_CSB"]
        # self.spi_debug_widget = checkboxes_collection_widget.CheckboxesCollectionWidget(SPI_wire_names)
        # self.spi_debug_widget.sig_new_state.connect(self.sl.setAD9912enable)
        # self.spi_debug_widget.setWindowTitle('SPI debug')
        # self.spi_debug_widget.show()

        # pprint.pprint(self.sl.user_inputs)
        # pprint.pprint(self.sl.reg_values)

    def setup_controller(self, system_settings, channel_settings):
        if channel_settings["mode"] == "PLL":
            self.sl.setup_controller(channel_settings["channel_id"],
                                     channel_settings["nominal_output_freq"],
                                     channel_settings["target_BW"],
                                     channel_settings["loop_sign"],
                                     channel_settings["bLock"])
        else:
            self.sl.setup_controller(channel_settings["channel_id"],
                                     0,
                                     1e3,
                                     1,
                                     False)

        self.emit_lock_settings(channel_settings)

    def emit_system_settings(self):
        """ This is used to notify the channel GUIs of the system settings,
        so that the GUIs can do proper scaling calculations, etc """
        d = dict()
        d["type"] = "system"
        d["fs"] = self.sl.fs
        d["LPF_DECIM"] = self.sl.phaseReadoutDriver.LPF_DECIM
        self.sig_new_settings.emit(d)

    def emit_lock_settings(self, channel_settings):
        """ Used to notify the channel GUIs of the lock settings for a single channel """
        d = dict(channel_settings)
        d["type"] = "lock"
        self.sig_new_settings.emit(d)

    def updateLockState(self, channel_id, bLock):
        """ Called when the GUI wants to update the lock state for a single channel,
        after all the rest of the config has been done """
        self.sl.updateLockState(channel_id, bLock)
        self.sl.commit_controller_settings(channel_id)
        # self.sig_new_settings.emit({"channel_id": channel_id, "bLock": bLock}) # not useful because the text box has already changed state...

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
        channel_settings["mode"]
        """
        s = system_settings  # shorthand
        c = channel_settings # shorthand
        k = channel_settings["channel_id"] # shorthand
        # print("setup_LO: system_settings=%s, channel_settings=%s" % (str(s), str(c)))
        if c["upper_sideband"]:
            out_freq_target = c["expected_freq"] - c["target_if"]
        else:
            out_freq_target = c["expected_freq"] + c["target_if"]

        # TODO: input validation vs actual range accessible?
        self.sl.set_expected_freq(k, c["expected_freq_MHz_str"], s["ref_freq_MHz_str"], c["mode"])
        print("setup_LO: FIXME: Refactor where we handle setup_LO")
        a = self.sl.set_adf4351_freq(out_freq_target, s["ref_freq"], s["pfd_target_freq"], k, c["LO_pwr"], c["LO_enable"])
        D = 2**a.reg["RF_DIVIDER_SEL"]
        INT = a.reg["INT"]
        R = a.reg["R"]
        LO_actual = s["ref_freq"] * float(INT / (D*R))
        IF_actual = abs(c["expected_freq"] - LO_actual)
        self.sl.set_ddc_ref_freq(k, IF_actual)

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

        for field in result:
            prefix = "ch%d_" % k
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
        from the device, and apply the necessary post-processing if any. """
        return self.sl.dev.valid_socket and self.config_done

    def updateExtClkFreq(self):
        ext_clk_freq = self.sl.getExtClockFreq()
        self.config_widget.lblRefFreq.setText('%.8f' % (ext_clk_freq/1e6))
        colorCoding(self.config_widget.lblRefFreq, getExtClkColorName(ext_clk_freq))

        self.validateExtClkFreq(ext_clk_freq)

    def clearLossOfClockEvents(self):
        # reading this register will clear the flag inside the FPGA
        if self.sl.dev.valid_socket:
            (loss_of_clk_detected, clk_ext_good, clk_int_or_ext_actual, clk_int_or_ext_desired) = self.sl.getClkStatus()
        self.loss_of_clock_events = 0
        self.loss_of_clk_detected = False
        self.setStatus("clock_loss", "No loss of clock event", "ok")

    def updateClkStatus(self):
        (loss_of_clk_detected, clk_ext_good, clk_int_or_ext_actual, clk_int_or_ext_desired) = self.sl.getClkStatus()
        # clk_int_or_ext_desired = True means internal clock
        # clk_int_or_ext_actual = True means internal clock

        if clk_int_or_ext_desired == True:
            self.setStatus("clock", "Internal clock mode", "warning")
        else:
            # external clock desired
            if clk_int_or_ext_actual == False:
                self.setStatus("clock", "External clock mode", "ok")
            else:
                self.setStatus("clock", "Internal clock mode", "bad")

        if loss_of_clk_detected and not self.loss_of_clk_detected:
            if self.loss_of_clock_events == 0:
                self.loss_of_clock_time = datetime.now().strftime("%m/%d/%Y, %H:%M:%S")
            self.loss_of_clock_events += 1
            event_str = 'event' if self.loss_of_clock_events == 1 else 'events'
            self.setStatus("clock_loss", "%d loss of ext clock %s since %s " % (self.loss_of_clock_events, event_str, self.loss_of_clock_time), "bad")

        self.loss_of_clk_detected = loss_of_clk_detected

    def validateExtClkFreq(self, ext_clk_freq_measured):
        """ validate that the measured ref clk and given ref clk agree """
        try:
            ext_clk_freq_given = 1e6*readFloatFromTextbox(self.config_widget.editRefFreq)
        except:
            return

        if abs(ext_clk_freq_measured - ext_clk_freq_given) < 1e5:
            colorCoding(self.config_widget.editRefFreq, "ok")
        elif abs(ext_clk_freq_measured - ext_clk_freq_given) < 1e6:
            colorCoding(self.config_widget.editRefFreq, "warning")
        else:
            colorCoding(self.config_widget.editRefFreq, "bad")

    def slowTimerEvent(self):
        """ Reads the slow phase streaming data (100 phase samples/seconds nominal, read every counter gate period).
        Current limitation of the way we do things is that the max counter period is related with
        the filling of the circular buffer inside the FPGA.  Exact value is TBD, but probably good up to 10 secs.
        This function also computes the frequency offset from said phase data, and emits the result as a signal """
        if not self.sl.dev.valid_socket:
            return
        self.updateExtClkFreq()
        self.updateClkStatus()
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
        fit_conv = fit.convert()
        if len(fit_conv) == 1:
            # this is kind of weird, but if the y values sent to the fit function are exactly constant,
            # the fit object simply doesn't have a coefficient for the slope (instead of simply putting 0)
            freq = 0.
        else:
            freq = fit_conv.coef[1] # freq is in units of cycles of the IQ waveform/cycles of the ADC clock
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
            with open("adc_data.bin", "wb") as f:
                f.write(adc_data.tobytes())
            scale_factor_adc_to_input = self.sl.scale_factor_adc_to_input(self.get_approximate_input_freq(adc_channel_id))

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
            # with open("iq.bin", "wb") as f:
            #     f.write(complex_baseband.tobytes())
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
        if self.tab_widget.tabText(self.current_tab) == "Summary":
            return True
        if self.pts_settings[iq_channel_id]["autorefresh"] and self.isChannelVisible(iq_channel_id):
            return True
        return False

    def isChannelVisible(self, channel_id):
        return self.tab_widget.tabText(self.current_tab) == "Channel %d" % (channel_id)

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
