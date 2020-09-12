from PyQt5 import QtCore, QtGui, QtWidgets, uic
import time
import sys
from datetime import datetime
import os
import inspect

import numpy as np
import pyqtgraph as pg

from common import tictoc, round_to_N_sig_figs, getSNRcolorName, getPowerColorName, colorCoding
from common import freq_text_eng_format, freq_value_from_text

# Set a few global PyQtGraph settings before creating plots:
pg.setConfigOption('leftButtonPan', False)
pg.setConfigOption('background', 'w')
pg.setConfigOption('foreground', 'k')
pg.setConfigOption('antialias', True)

class ChannelGUI(QtWidgets.QWidget):
    sig_set_num_points    = QtCore.pyqtSignal(int, dict)
    sig_update_lock_state = QtCore.pyqtSignal(int, bool)
    # these signals will be connected to the summary tab:
    sig_new_Amplitude     = QtCore.pyqtSignal(int, float, float)
    sig_new_SNR           = QtCore.pyqtSignal(int, float)

    def __init__(self, channel_id=1, parent=None):
        super().__init__(parent)
        self.channel_id = channel_id
        self.bDisplayTiming = False # set this to True to print profiling information
        self.tictoc_last = time.perf_counter()
        self.last_amplitude_update = time.perf_counter()
        self.fs = 125e6 # default, will get updated via signals
        self.settings = None
        self.IQ_decim = 6 # decimation of the IQ data compared to ADC rate

        self.setupUI()
        self.tests()

    def setupUI(self):
        uic.loadUi("channel.ui", self)
        self.populateRBWcombo()
        self.tab_visible = True

        self.phaseWidget = PhaseDisplayWidget(self, self.channel_id)
        self.gridLayout.addWidget(self.phaseWidget, 2, 1)

        # Setup IQ plot
        self.plot_IQ.hideAxis('left')
        self.plot_IQ.hideAxis('bottom')
        grayscale = 0.5
        pen = QtGui.QPen(QtGui.QColor(grayscale*255, grayscale*255, grayscale*255))
        pen.setCosmetic(True)
        theta = np.linspace(0, 2*np.pi, 1e3)
        self.plot_IQ.getPlotItem().plot(np.cos(theta), np.sin(theta), pen=pen)
        self.plot_IQ.getPlotItem().plot(np.linspace(0, 1.1, 2), np.zeros(2), pen=pen)
        self.curve_IQ = self.plot_IQ.getPlotItem().plot(pen = None,
                                                        symbol = 'o',
                                                        symbolPen=None,
                                                        symbolSize=3,
                                                        symbolBrush='b')
        # Setup spectrum plot
        self.curve_spc = self.plot_spc.getPlotItem().plot(title='Spectrum', pen='b')
        self.curve_filter = self.plot_spc.getPlotItem().plot(pen='r')

        self.lblCurrentFreq.setAlignment(QtCore.Qt.AlignRight)

        self.chkAutorefresh.clicked.connect(self.probingSettingsChanged)
        self.comboRBW.currentTextChanged.connect(self.probingSettingsChanged)
        self.comboPlotType.currentTextChanged.connect(self.probingSettingsChanged)

        self.chkLock.clicked.connect(self.chkLock_clicked)

    def chkLock_clicked(self, is_checked):
        self.sig_update_lock_state.emit(self.channel_id, is_checked)

    def setVisibility(self, bVisible):
        self.tab_visible = bVisible

    def newSettings(self, d):
        if d["type"] == "LO" and d["channel_id"] == self.channel_id:
            self.settings = dict(d)
            self.lblExpectedFreq.setText(d["expected_freq_MHz_str"])
            self.lblIFfreq.setText('%f' % (d["chosen_IF"]/1e6))
            
        if d["type"] == "system":
            self.system_settings = dict(d)

        if d["type"] == "lock" and d["channel_id"] == self.channel_id:
            if "mode" in d:
                if d["mode"] == "PLL":
                    self.chkLock.setVisible(True)
                else:
                    self.chkLock.setVisible(False)
            if "bLock" in d:
                self.chkLock.setChecked(d["bLock"])

    def systemSettingsUpdated(self, fs):
        self.fs = fs

    def probingSettingsChanged(self):
        d = dict()
        d["channel_id"] = self.channel_id
        d["pts_ADC"] = self.RBW_to_pts(freq_value_from_text(self.comboRBW.currentText()))
        if self.comboPlotType.currentText() == 'IQ timeseries':
            d["pts_IQ"] = d["pts_ADC"]
        else:
            d["pts_IQ"] = int(1e3) # hard-coded for now, this will need to change when we add the option to plot the time domain phase or phase PSD
        d["autorefresh"] = bool(self.chkAutorefresh.isChecked())
        self.sig_set_num_points.emit(self.channel_id, d)

        # Set some reasonable range for the plot based on the plot type
        plot_type = self.comboPlotType.currentText()
        if plot_type == "RF spectrum":
            self.plot_spc.setYRange(-110, 0)
        elif plot_type == "Baseband spectrum":
            self.plot_spc.setYRange(-100, 10)
        elif plot_type == "Baseband timeseries":
            self.plot_spc.setYRange(-1, 1)
        elif plot_type == "IQ timeseries":
            self.plot_spc.setYRange(-1, 1)

    def groupBoxSettings_clicked(self, checked=False):
        self.widgetSettings.setVisible(checked)

    def populateRBWcombo(self):
        self.comboRBW.clear()
        for value in [10e3, 30e3, 100e3, 300e3, 1e6]:
            self.comboRBW.addItem(freq_text_eng_format(value))
             #print("For RBW=%f Hz, pts required = %d" % (value, self.RBW_to_pts(value)))
        self.comboRBW.setCurrentText(freq_text_eng_format(100e3))

    def RBW_to_pts(self, rbw):
        """ Returns the number of points required in the FFT to reach a given RBW for the default window.
        Approach is to compute the RBW for a fixed number of points, then scale back to the desired RBW """
        test_pts = int(1e3)
        test_NEB = self.computeNEB(self.computeWindowFunction(int(test_pts)), self.fs)
        required_pts = int(round(test_pts * test_NEB/rbw))
        return required_pts

    def newADCdata(self, data, data_max, scale_factor_adc_to_input):
        """ data must be in volts, refered at the ADC input
        data_max must be in the same units as data,
        and must equal the peak value allowed by the ADC (so we can compute fill %) """
        plot_type = self.comboPlotType.currentText()
        if plot_type == "RF spectrum":
            # scale to input-refered amplitudes
            self.plotSpectrum(data/scale_factor_adc_to_input, self.fs, plot_type)
        elif plot_type == "Baseband spectrum":
            self.plotSpectrum(data, self.fs, plot_type)
        elif plot_type == "Baseband timeseries":
            self.plotADCTimeseries(data, self.fs, plot_type)
        elif plot_type == "IQ timeseries":
            # in this case, we don't do anything with the ADC data
            pass

        self.updateADCFill(np.max(np.abs(data)), data_max)

    def newIQdata(self, complex_baseband, scale_factor_adc_to_input):
        complex_baseband /= scale_factor_adc_to_input # scale to input-referred amplitude
        amplitude = np.abs(complex_baseband)
        mean_amplitude = np.mean(amplitude)
        std_dev_amplitude = np.std(amplitude)

        self.updateAmplitudeDisplay(mean_amplitude)
        self.updateSNRdisplay(mean_amplitude, std_dev_amplitude)
        if not self.tab_visible:
            return # skip costly updates if we are not visible
        self.updateIQdisplay(complex_baseband, mean_amplitude)

        plot_type = self.comboPlotType.currentText()
        if plot_type == "IQ timeseries":
            self.plotIQTimeseries(complex_baseband*scale_factor_adc_to_input, self.fs/self.IQ_decim, plot_type) # this is adc-referred
        if plot_type == "IQ spectrum":
            self.plotSpectrum(complex_baseband*scale_factor_adc_to_input, self.fs/self.IQ_decim, plot_type)

    def newPhasePoint(self, phase_data):
        if phase_data is None:
            return
        if not self.tab_visible:
            return
        self.phaseWidget.newPhasePoint(phase_data[self.channel_id])

    def newFreqData(self, channel_id, freq_Hz):
        if not self.tab_visible:
            return
        if channel_id != self.channel_id:
            return
        self.lblCurrentFreq.setText('%.6f Hz' % freq_Hz)

    def updateWindowFunction(self, data_len, fs):
        """ Compute window function for a given size if needed """
        if not hasattr(self, 'window_function') or len(self.window_function) != data_len:
            self.window_function = self.computeWindowFunction(data_len)
            self.window_NEB = self.computeNEB(self.window_function, fs)

    def computeWindowFunction(self, N):
        return np.blackman(N)

    def computeNEB(self, window_function, fs):
        return np.sum((window_function/np.sum(window_function))**2) * fs

    def plotADCTimeseries(self, data, fs, plot_type):
        time_axis = np.linspace(0, len(data)-1, len(data)) / fs
        self.curve_spc.setData(time_axis, data)
        self.curve_filter.setVisible(False)
        self.plot_spc.setTitle('Time series at ADC input')
        self.plot_spc.setLabel('left', 'ADC data [V]')
        self.plot_spc.setLabel('bottom', 'Time [s]')

    def plotIQTimeseries(self, data, fs, plot_type):
        time_axis = np.linspace(0, len(data)-1, len(data)) / fs
        self.curve_spc.setData(time_axis, data.real)
        self.curve_filter.setData(time_axis, data.imag)
        self.plot_spc.setTitle('Time series')
        self.curve_filter.setVisible(True)

        self.plot_spc.setLabel('left', 'Baseband data [V]')
        self.plot_spc.setLabel('bottom', 'Time [s]')

    def plotSpectrum(self, data, fs, plot_type):
        """ Data must contain ADC sample values scaled in volts """
        if self.settings is None:
            self.plot_spc.setTitle('Spectrum: commit settings first')
            return # can't compute a proper frequency axis if we have never committed the settings

        tictoc(self)
        self.updateWindowFunction(len(data), fs)
        # Apply window function to the data:
        data_windowed = (data-np.mean(data)) * self.window_function
        tictoc(self, "windowing")
        
        # Compute the spectrum of the raw data:
        N_fft = 2**(int(np.ceil(np.log2(len(data_windowed)))))
        spc = np.fft.fft(data_windowed, N_fft)
        tictoc(self, "FFT")

        spc = np.real(spc * np.conj(spc))/(np.sum(self.window_function)**2) # Scale from the modulus square of the FFT to the (double-sided) power spectra in Volts squared
        impedance = 50 # ohms
        spc = spc / impedance # now in double-sided PSD in Watts
        spc = spc*2. # scale to single-sided power spectrum
        spc = 10*np.log10(spc + 1e-16) + 30 # now in dBm
        tictoc(self, "10log10 abs(FFT)**2")
        
        # Update the graph data:
        frequency_axis_baseband = self.fftFrequencyAxis(N_fft, fs)
        if plot_type in ["RF spectrum", "Baseband spectrum"]:
            last_index_shown = int(np.round(N_fft/2))
            frequency_axis_baseband = frequency_axis_baseband[:last_index_shown]
        else:
            last_index_shown = len(spc)
        beat_sign = 1 if self.settings["upper_sideband"] else -1
        frequency_axis_rf = beat_sign * frequency_axis_baseband + self.settings["chosen_LO"]
        if plot_type == "RF spectrum":
            self.curve_spc.setData(frequency_axis_rf/1e6, spc[:last_index_shown])
            self.plot_spc.setLabel('bottom', 'RF Frequency [MHz]')
        elif plot_type == "Baseband spectrum":
            self.curve_spc.setData(frequency_axis_baseband/1e6, spc[:last_index_shown])
            self.plot_spc.setLabel('bottom', 'Baseband Frequency [MHz]')
        elif plot_type == "IQ spectrum":
            self.curve_spc.setData(frequency_axis_baseband/1e6, spc[:last_index_shown])
            self.plot_spc.setLabel('bottom', 'Baseband Frequency [MHz]')
        tictoc(self, "setData")
        # self.plot_spc.setTitle('Spectrum, noise floor = %.0f nV/sqrt(Hz)' % (round_to_N_sig_figs(1e9*np.sqrt(avg_psd), 2)))
        self.plot_spc.setTitle('Spectrum')
        self.plot_spc.setLabel('left', 'Power [dBm]')
        
        tictoc(self, "setTitle")

        f_ddc = self.settings["chosen_IF"]/fs
        self.updateFilterSpcDisplay(f_ddc, N_fft, frequency_axis_baseband, frequency_axis_rf, plot_type)

    def updateFilterSpcDisplay(self, f_ddc, N_fft, f_axis_baseband, f_axis_rf, plot_type):
        lpf = self.settings["lpf"]
        k_axis = np.linspace(0, len(lpf)-1, len(lpf))
        lpf_shifted = np.multiply(lpf, np.exp(1j*2*np.pi*f_ddc*k_axis)) # inverse of the shift down in ddc_mixer.vhd
        spc = np.fft.fft(lpf_shifted, N_fft)
        spc = spc[:len(f_axis_baseband)]
        spc = np.real(spc * np.conj(spc))
        spc = spc / np.max(spc)
        spc = 10*np.log10(spc + 1e-12)

        if plot_type == "RF spectrum":
            self.curve_filter.setData(f_axis_rf/1e6, spc) # TODO: decide on the amplitude scaling!
        elif plot_type == "Baseband spectrum":
            self.curve_filter.setData(f_axis_baseband/1e6, spc) # TODO: decide on the amplitude scaling!
        elif plot_type == "IQ spectrum":
            self.curve_filter.setData(f_axis_baseband/1e6, spc) # TODO: decide on the amplitude scaling!
        self.curve_filter.setVisible(True)

    def fftFrequencyAxis(self, N_fft, fs):
        return np.linspace(0, (N_fft-1)/float(N_fft)*fs, N_fft)

    def tests(self):
        """ Runs a few simple unit tests """
        # test that freq_text_eng_format()/freq_value_from_text() pair are truly inverses of each other
        for k in range(self.comboRBW.count()):
            text = self.comboRBW.itemText(k)
            assert freq_text_eng_format(freq_value_from_text(text)) == text

    def updateIQdisplay(self, complex_baseband, mean_amplitude, N_max_IQ = 10e3):
        """ N_max_IQ is the max number of points to display in the IQ graph.
        Returns the mean amplitude in Volts """
        t = tictoc(self)

        N_show = int(np.min((len(complex_baseband), N_max_IQ)))
        complex_baseband = complex_baseband[:N_show]
        if mean_amplitude == 0:
            mean_amplitude = 1e-6 # just to avoid a divide by zero warning

        minimum_amplitude_for_agc = 1e-3 # Volts
        if mean_amplitude >= minimum_amplitude_for_agc:
            # normal case: IQ display has unity amplitude
            display_scale_factor = 1/mean_amplitude
        else:
            # at very low input levels, we clamp the max gain
            display_scale_factor = 1/minimum_amplitude_for_agc

        self.curve_IQ.setData(np.real(complex_baseband)*display_scale_factor, np.imag(complex_baseband)*display_scale_factor)
        self.plot_IQ.setXRange(-1.5, 1.5)
        self.plot_IQ.setYRange(-1.5, 1.5)

        tictoc(self, 'Display IQ')

    def updateAmplitudeDisplay(self, mean_amplitude):
        # input signal is A*cos(), baseband signal is A*exp(),
        # mean_amplitude = A
        # average power in input signal is thus A**2/2/Z
        impedance = 50
        mean_power_W = mean_amplitude**2/2/impedance
        mean_power_dBm = 10*np.log10(mean_power_W * 1e3)
        if time.perf_counter() - self.last_amplitude_update >= 0.3: # limit updates so that the text is actually readable
            self.last_amplitude_update = time.perf_counter()
            self.lblAmplitude_value.setText('% 05.1f dBm, %.0f mV'% (mean_power_dBm, 1e3*mean_amplitude))
            self.sig_new_Amplitude.emit(self.channel_id, mean_power_dBm, mean_amplitude)

            color_name = getPowerColorName(mean_power_dBm)
            colorCoding(self.lblAmplitude_value, color_name)
            colorCoding(self.lblAmplitude, color_name)

    def updateSNRdisplay(self, mean_amplitude, std_dev_amplitude):
        """ Compute and display the SNR on the amplitude of the baseband IQ signal """
        if mean_amplitude == 0:
            mean_amplitude = 1. # to avoid a NaN in the log operation
            std_dev_amplitude = 1e3
        baseband_snr = 20*np.log10(mean_amplitude/std_dev_amplitude)
        # to get a more stable reading of the SNR without resorting to rounding:
        # we put a simple first-order IIR filter:
        filter_alpha = np.exp(-1./10.)
        if hasattr(self, 'filtered_baseband_snr'):
            temp_filtered_baseband_snr = filter_alpha * self.filtered_baseband_snr + (1-filter_alpha)*baseband_snr
        else:
            temp_filtered_baseband_snr = baseband_snr
        
        # Sometimes, the average of the SNR is NaN, so we only accept the new SNR if it is not(NaN)
        if not(np.isnan(temp_filtered_baseband_snr)):
            self.filtered_baseband_snr = temp_filtered_baseband_snr
        else:
            print("Error 'nan' in filtered_baseband_snr")

        self.lblSNR_value.setText('%.2f dB in %.0f MHz' % (self.filtered_baseband_snr, self.getFrontendFilterBW()/1e6))
        self.sig_new_SNR.emit(self.channel_id, self.filtered_baseband_snr)

        color_name = getSNRcolorName(self.filtered_baseband_snr)
        colorCoding(self.lblSNR_value, color_name)
        colorCoding(self.lblSNR, color_name)

    def updateADCFill(self, max_abs, adc_max):
        percentage = round_to_N_sig_figs(100*max_abs/adc_max, 2)
        self.lblADCFill_value.setText('%.1f%%' % percentage)
        if percentage < 75:
            colorCoding(self.lblADCFill, 'ok')
            colorCoding(self.lblADCFill_value, 'ok')
        else:
            colorCoding(self.lblADCFill, 'bad')
            colorCoding(self.lblADCFill_value, 'bad')

    def getFrontendFilterBW(self):
        """ Returns the noise-equivalent bandwidth of the front-end filter, in Hz """
        if self.settings is None:
            return 22e6
        lpf = self.settings["lpf"]
        lpf = lpf/np.sum(lpf)
        return 2*np.sum(lpf**2)*self.fs # factor of two is because the filter is effectively a bandpass

class SquarePlot(pg.PlotWidget):
    """ Plot widget with fixed square aspect ratio """
    def __init__(self, parent=None):
        super().__init__(parent)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Preferred, QtWidgets.QSizePolicy.Preferred)
        sizePolicy.setHeightForWidth(True)
        self.setSizePolicy(sizePolicy)
        self.plotItem.vb.setAspectLocked(1.0)

    def sizeHint(self):
        return QtCore.QSize(300, 300)

    def minimumSizeHint(self):
        return QtCore.QSize(100, 100)

    def heightForWidth(self, width):
        return width

    def hasHeightForWidth(self):
        return True

class TestWidget(QtWidgets.QWidget):
    """ Used as a top-level widget when testing """
    def __init__(self, gui_test, parent=None):
        super().__init__(parent)
        self.gui_test = gui_test
        self.N_IQ = int(1e3)
        self.N_ADC = int(2e3)
        self.autorefresh = False

        self.gui_test.sig_set_num_points.connect(self.set_num_points)
        self.gui_test.probingSettingsChanged()

        self.timer = QtCore.QTimer(self)
        self.timer.timeout.connect(self.timerEvent)
        self.timer.start(20)

    def set_num_points(self, d):
        """ Called when the GUI wants to change the number of points being read from the ADC and IQ sources """
        self.N_IQ  = d["pts_IQ"] 
        self.N_ADC = d["pts_ADC"]
        self.autorefresh = d["autorefresh"]

    def timerEvent(self):
        if not self.autorefresh:
            return
        complex_baseband = 0.1*np.exp(1j*np.linspace(0, 2*np.pi, self.N_IQ)) + 0.01*np.random.randn(self.N_IQ) + 0.01*1j*np.random.randn(self.N_IQ)
        self.gui_test.newIQdata(complex_baseband)

        fs = 125e6
        adc_data = 0.1*np.cos(2*np.pi*15e6/125e6*np.linspace(0, self.N_ADC-1, self.N_ADC)) + 0.01*np.random.randn(self.N_ADC)
        self.gui_test.newADCdata(adc_data, 1.0)

class PhaseDisplayWidget(QtWidgets.QWidget):
    sig_reset_phase = QtCore.pyqtSignal(int)

    def __init__(self, parent=None, channel_id=1, *args, **kwargs):
        super().__init__(parent, *args, **kwargs)

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

        for line_index, bar in enumerate(self.bars):
            phi_scaled = ((self.scale_factors[line_index] * phi + 0.5) % 1.0) - 0.5
            bar.setValue(50+int(round(phi_scaled*100)))

        self.lblPhase.setText('%.6f cycles' % phi)

    def resetPhase(self):
        self.sig_reset_phase.emit(self.channel_id)

def main():
    # for testing when ran without a parent GUI
    app = QtWidgets.QApplication(sys.argv)
    GUI = ChannelGUI()
    GUI.show()

    test_widget = TestWidget(GUI)


    
    app.exec_()

if __name__ == '__main__':
    main()

