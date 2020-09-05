from PyQt5 import QtCore, QtGui, QtWidgets, uic
import time
import socket
import json
from functools import partial

import UDPRedPitayaDiscovery
from RP_PLL import RP_PLL_device # needed to update FPGA firmware and CPU (Zynq) software
import devicesData

from common import colorCoding, readFloatFromTextbox, freq_text_eng_format

class ConfigWidget(QtWidgets.QWidget):
    sig_user_settings_changed = QtCore.pyqtSignal()
    sig_set_status = QtCore.pyqtSignal(str, str, str)

    def __init__(self, channels_list, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.channels_list = channels_list
        self.setupUI()

        print("ConfigWidget(): TODO: heuristics for choosing target IF in basic config mode")

    def setupUI(self):
        uic.loadUi("config_widget.ui", self)

        self.editExpectedFreq_dict = {k: getattr(self, "editExpectedFreq%d" % k) for k in self.channels_list}
        
        self.controller_widgets = dict()
        self.adv_per_channel = dict()
        for channel_id in self.channels_list:
            self.controller_widgets[channel_id] = getattr(self, "tabBasic%d" % channel_id)

            self.controller_widgets[channel_id].editModulatorNominalFreq.editingFinished.connect(partial(self.updateExpectedFreq, channel_id))
            self.controller_widgets[channel_id].editModulatorGain.editingFinished.connect(partial(self.updateExpectedFreq, channel_id))

            adv_per_channel = getattr(self, "tab%d" % channel_id) # shorthand
            self.adv_per_channel[channel_id] = adv_per_channel

            # default values for target IF:
            if channel_id in (1, 3): # odd channels are low-passed
                self.adv_per_channel[channel_id].editTargetIF.setText('20')
            else: # even channels are highpassed
                self.adv_per_channel[channel_id].editTargetIF.setText('40')

            # connect signals to slots
            getattr(self, 'editExpectedFreq%d' % channel_id).textChanged.connect(self.user_settings_changed)

            # widgets in advanced settings, per channel
            for signal in [adv_per_channel.chkEnableLO.clicked,
                           adv_per_channel.editTargetIF.textChanged,
                           adv_per_channel.radioUpper.clicked,
                           adv_per_channel.radioLower.clicked,
                           adv_per_channel.comboLOpower.currentTextChanged]:
                signal.connect(self.user_settings_changed)

        self.populateLOcombo()

        self.config_files_filter = "Configuration files (*.cfg)"
        self.btnLoadFromFile.clicked.connect(self.loadFromFileClicked)
        self.btnSaveToFile.clicked.connect(self.saveToFileClicked)
        self.btnBrowse.clicked.connect(self.browseClicked)

    def populateLOcombo(self):
        from adf4351 import pwr_map
        for text in pwr_map:
            for channel_id in self.channels_list:
                self.adv_per_channel[channel_id].comboLOpower.addItem(text)

    def populateClosedLoopBW(self, BW_all):
        """ Add to our combobox all possible bandwidths that fall between 1 Hz and 1 MHz """
        BW_default = 12e3
        BW_distance = abs(BW_default-BW_all[0])
        ind_closest = 0
        ind_current = 0
        for BW in BW_all:
            if BW >= 1 and BW <= 1e6:
                if abs(BW - BW_default) <= BW_distance:
                    BW_distance = abs(BW - BW_default)
                    ind_closest = ind_current
                for k, w in self.controller_widgets.items():
                    w.comboTargetBW.addItem(freq_text_eng_format(BW))
                ind_current += 1

        for k, w in self.controller_widgets.items():
            w.comboTargetBW.setCurrentIndex(ind_closest)

    def updateExpectedFreq(self, channel_id):
        """ Set the expected input frequency based on the nominal modulator frequency """
        w = self.controller_widgets[channel_id]
        w.editExpectedFreq.setText(w.editModulatorNominalFreq.text() + "*" + w.editModulatorGain.text())

    def setHardwareType(self, bHasDDS=False):
        """ Handle various versions of the hardware changing the exact GUI that we should present to the user """
        self.bHasDDS = bHasDDS
        widgets_for_counter_only = [self.label_2, self.label_3, self.label_4, self.label_5, self.label_12, self.label_11,
                                    self.editExpectedFreq1, self.editExpectedFreq2, self.editExpectedFreq3, self.editExpectedFreq4]
        for w in widgets_for_counter_only:
            w.setVisible(not bHasDDS)

        self.tabWidgetBasic.setVisible(bHasDDS)
        if bHasDDS:
            for channel_id in self.channels_list:
                self.updateExpectedFreq(channel_id)

    def user_settings_changed(self, *args, **kwargs):
        self.sig_set_status.emit("commit", "Uncommitted", "bad")
        if self.editConfigFile.text() == '':
            self.sig_set_status.emit("config", "No config file selected", "bad")
        else:
            self.sig_set_status.emit("config", "Config file neither loaded nor saved", "bad")

    def readConfigFromGUI(self):
        """ Read all the settings from the GUI to our config dicts,
        returns a tuple of: (system_settings, channels_settings),
        where channel_configs is a dict of dict, with keys equal to channel ids """
        system_settings = dict()

        try:
            system_settings["ref_freq_MHz_str"]       = self.editRefFreq.text()
            system_settings["ref_freq"]               = readFloatFromTextbox(self.editRefFreq)*1e6
            system_settings["adc_use_external_clock"] = (self.comboADCclockSource.currentText() == "Phase-locked to external ref")
            system_settings["pfd_target_freq"]        = readFloatFromTextbox(self.editPFDtargetFreq)*1e6
            system_settings["output_data_rate"]       = readFloatFromTextbox(self.editOutputDataRate)

            # per-channel settings:
            channels_settings = dict()
            for channel_id in self.channels_list:
                c = dict()
                adv_settings = self.adv_per_channel[channel_id] # shorthand
                c["channel_id"]        = channel_id
                c["target_if"]         = readFloatFromTextbox(adv_settings.editTargetIF)*1e6
                c["upper_sideband"]    = adv_settings.radioUpper.isChecked()
                c["LO_pwr"]            = adv_settings.comboLOpower.currentText()
                c["LO_enable"]         = adv_settings.chkEnableLO.isChecked()

                if self.bHasDDS:
                    w = self.controller_widgets[channel_id] # shorthand
                    c["expected_freq_MHz_str"] = w.editExpectedFreq.text()
                    c["expected_freq"]         = readFloatFromTextbox(w.editExpectedFreq)*1e6
                else:
                    c["expected_freq_MHz_str"] = self.editExpectedFreq_dict[channel_id].text()
                    c["expected_freq"]         = readFloatFromTextbox(self.editExpectedFreq_dict[channel_id])*1e6
                print(c)
                channels_settings[channel_id] = c

        except (ValueError, SyntaxError):
            self.sig_set_status.emit("config", "Invalid setting in config", "bad")
            raise

        return (system_settings, channels_settings)

    def loadFromFileClicked(self):
        try:
            with open(self.editConfigFile.text(), 'r') as f:
                config_dict = json.load(f)
        except FileNotFoundError:
            self.sig_set_status.emit("config", 'File "%s" not found' % self.editConfigFile.text(), "bad")
            return

        system_settings = config_dict["system_settings"]

        self.editRefFreq.setText(system_settings["ref_freq_MHz_str"])
        self.editPFDtargetFreq.setText("%f" % (system_settings["pfd_target_freq"]/1e6))
        self.editOutputDataRate.setText("%f" % (system_settings["output_data_rate"]))
        if system_settings["adc_use_external_clock"]:
            self.comboADCclockSource.setCurrentText("Phase-locked to external ref")
        else:
            self.comboADCclockSource.setCurrentText("Phase-locked to internal ref (limited accuracy)")

        # per-channel settings:
        for channel_id in self.channels_list:
            c = config_dict["ch%d_settings" % channel_id]
            self.editExpectedFreq_dict[channel_id].setText(c["expected_freq_MHz_str"])
            adv_settings = self.adv_per_channel[channel_id] # shorthand
            adv_settings.editTargetIF.setText("%f" % (c["target_if"]/1e6))
            adv_settings.radioUpper.setChecked(c["upper_sideband"])
            adv_settings.comboLOpower.setCurrentText(c["LO_pwr"])
            adv_settings.chkEnableLO.setChecked(c["LO_enable"])

        self.user_settings_changed()
        self.sig_set_status.emit("config", "Config loaded from %s" % self.editConfigFile.text(), "ok")

    def saveToFileClicked(self):
        fileName = QtWidgets.QFileDialog.getSaveFileName(self, 'Select File', filter = self.config_files_filter)
        if not fileName[0]:
            return

        self.editConfigFile.setText(fileName[0])

        (system_settings, channels_settings) = self.readConfigFromGUI()
        # put everything into one big dict, so we can let the json module do the work
        config_dict = dict()
        config_dict["system_settings"] = system_settings
        for channel_id in self.channels_list:
            config_dict["ch%d_settings" % (channel_id)] = channels_settings[channel_id]
        with open(self.editConfigFile.text(), 'w') as f:
            json.dump(config_dict, f, sort_keys=True, indent=4)

        self.sig_set_status.emit("config", "Config saved to %s" % self.editConfigFile.text(), "ok")

    def browseClicked(self):
        fileName = QtWidgets.QFileDialog.getOpenFileName(self, 'Select File', filter=self.config_files_filter)
        
        if fileName[0]:
            self.editConfigFile.setText(fileName[0])
        self.user_settings_changed()