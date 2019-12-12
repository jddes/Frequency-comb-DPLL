from __future__ import print_function
import time
from PyQt5 import QtGui, Qt, QtCore, QtWidgets
#import PyQt5.Qwt5 as Qwt
import numpy as np
import math
import sys

import numpy as np
import weakref

# stuff for Python 3 port
import pyqtgraph as pg
from ThermometerWidget import ThermometerWidget # to replace Qwt's thermometer widget

from SLLSystemParameters import SLLSystemParameters
from SuperLaserLand_mock import SuperLaserLand_mock
from SocketErrorLogger import logCommsErrorsAndBreakoutOfFunction

def round_to_N_sig_figs(x, Nsigfigs):
    leading_pos = np.floor(np.log10(np.abs(x)))
    factor = 10**((Nsigfigs-1)-leading_pos)
    return np.round(x * factor)/factor


class SpectrumWidget(QtGui.QWidget):
    def __init__(self, parent, selected_ADC, output_controls, sl, PalNormal=None):
        super(SpectrumWidget, self).__init__()

        if parent is not None:
            self.parent = weakref.proxy(parent)
        else:
            self.parent = None
        self.selected_ADC    = selected_ADC
        self.output_controls = output_controls
        self.sl              = sl
        self.PalNormal       = PalNormal

        self.bDisplayTiming  = False
        self.filtered_baseband_snr = 0.

        self.initUI()
        pass

    def initUI(self):

        ######################################################################
        # Spectrum analyzer/Diagnostics
        ######################################################################
        self.qgroupbox_diagnostics = Qt.QGroupBox('Spectrum analyzer/diagnostics (all computed from raw ADC input)', self)

        # Create the scale which indicates the ADC fill ratio:
        self.qlabel_adc_fill = Qt.QLabel('ADC fill\n[bits]')
        self.qlabel_adc_fill.setAlignment(Qt.Qt.AlignHCenter)
        
        self.qadc0_scale = ThermometerWidget()#Qwt.QwtThermo()
        #self.qadc0_scale.setOrientation(Qt.Qt.Vertical, Qwt.QwtThermo.LeftScale)
        self.qadc0_scale.setRange(0, 16)
        #self.qadc0_scale.setScale(0, 16)
        self.qadc0_scale.setValue(0)
        self.qadc0_scale.setFillColor(Qt.Qt.blue)
        ticksListMajor = [0, 5, 10, 15]
        ticksListMinor = [2.5, 7.5, 12.5]
        ticksLabelMajor = list(map(str, ticksListMajor))
        self.qadc0_scale.setTicks(ticksListMajor, ticksListMinor, ticksLabelMajor)
        
        self.qlabel_adc_fill_value = Qt.QLabel('10 bits')
        self.qlabel_adc_fill_value.setAlignment(Qt.Qt.AlignHCenter)
        
        # Create the scale which indicates the baseband SNR:
        self.qlabel_baseband_snr = Qt.QLabel('SNR\n[dB]')
        self.qlabel_baseband_snr.setAlignment(Qt.Qt.AlignHCenter)       
        
        self.qthermo_baseband_snr = ThermometerWidget()#Qwt.QwtThermo()
        #self.qthermo_baseband_snr.setOrientation(Qt.Qt.Vertical, Qwt.QwtThermo.LeftScale)
        self.qthermo_baseband_snr.setRange(0, 50)
        self.qthermo_baseband_snr.setScale(0, 50)
        self.qthermo_baseband_snr.setValue(0)
        self.qthermo_baseband_snr.setFillColor(Qt.Qt.blue)
        ticksListMajor = [0, 10, 20, 30, 40, 50]
        ticksListMinor = [5, 15, 25, 35, 45]
        ticksLabelMajor = list(map(str, ticksListMajor))
        self.qthermo_baseband_snr.setTicks(ticksListMajor, ticksListMinor, ticksLabelMajor)
        
        
        self.qlabel_baseband_snr_value = Qt.QLabel('20 dB')
        self.qlabel_baseband_snr_value.setAlignment(Qt.Qt.AlignHCenter)
        
        

        # Create the widgets which shows the current dac output and sets the output offset:
        self.qlabel_dac_current       = {}
        self.qlabel_dac_current_value = {}
        self.qthermo_dac_current      = {}
        self.qlabel_dac_offset        = {}
        self.q_dac_offset             = {}
        self.qlabel_dac_offset_value  = {}
        
        
        for k in range(3):
            if self.output_controls[k] == True:
                self.qlabel_dac_current[k] = Qt.QLabel('Output\nDAC %d [V]' % k)
                self.qlabel_dac_current[k].setAlignment(Qt.Qt.AlignHCenter)
                
                self.qthermo_dac_current[k] = ThermometerWidget()#Qwt.QwtThermo()
                #self.qthermo_dac_current[k].setOrientation(Qt.Qt.Vertical, Qwt.QwtThermo.LeftScale)
                self.qthermo_dac_current[k].setRange(self.sl.convertDACCountsToVolts(k, self.sl.DACs_limit_low[k]), self.sl.convertDACCountsToVolts(k, self.sl.DACs_limit_high[k]))
                self.qthermo_dac_current[k].setScale(self.sl.convertDACCountsToVolts(k, self.sl.DACs_limit_low[k]), self.sl.convertDACCountsToVolts(k, self.sl.DACs_limit_high[k]))
                self.qthermo_dac_current[k].setValue(0)
                #self.qthermo_dac_current[k].setFillBrush(Qt.QBrush(Qt.QColor(0, 186, 52)))
                self.qthermo_dac_current[k].setFillColor(Qt.QColor(0, 186, 52))
                if k == 2:
                    ticksListMajor = [0, 1, 2, 3]
                    ticksListMinor = [0.5, 1.5, 2.5]
                else:
                    ticksListMajor = [-1, -0.5, 0, 0.5, 1]
                    ticksListMinor = [-0.75, -0.25, 0.25, 0.75]
                ticksLabelMajor = list(map(str, ticksListMajor))
                self.qthermo_dac_current[k].setTicks(ticksListMajor, ticksListMinor, ticksLabelMajor)
                
                
                self.qlabel_dac_offset[k] = Qt.QLabel('Offset\nDAC %d [V]' % k)
                self.qlabel_dac_offset[k].setAlignment(Qt.Qt.AlignHCenter)
                
                self.q_dac_offset[k] = Qt.QSlider()
                self.q_dac_offset[k].valueChanged.connect(self.setDACOffset_event)
                self.q_dac_offset[k].setSliderPosition(0)
                self.q_dac_offset[k].setOrientation(Qt.Qt.Vertical)
                
                # Units are millionth of the full range available between the min and max DAC value
                self.q_dac_offset[k].setMinimum(0)
                self.q_dac_offset[k].setMaximum(1e6)

        
                self.qlabel_dac_current_value[k] = Qt.QLabel('0 V')
                self.qlabel_dac_current_value[k].setAlignment(Qt.Qt.AlignHCenter)
                
                self.qlabel_dac_offset_value[k] = Qt.QLabel('0 V')
                self.qlabel_dac_offset_value[k].setAlignment(Qt.Qt.AlignHCenter)
            
        
        # Create widgets to set the number of points for the graphs:
        self.qlabel_rawdata_rbw = Qt.QLabel('RBW: 100 kHz; Points:')
        self.qedit_rawdata_length = Qt.QLineEdit('1.73e3')
        self.qedit_rawdata_length.setMaximumWidth(60)
        
        # Plot type select
        self.qlabel_adc_plot_type = Qt.QLabel('Plot type:')
        self.qcombo_adc_plottype = Qt.QComboBox()
        self.qcombo_adc_plottype.addItems(['Spectrum', 'Time: raw input', 'Time: Phase', 'Time: IQ', 'Time: IQ, synced'])

        

        # Input select        
        self.qlabel_adc_plot_input = Qt.QLabel('Input:')
        self.qcombo_adc_plot = Qt.QComboBox()
        self.qcombo_adc_plot.addItems(['ADC0', 'ADC1', 'DAC0', 'DAC1', 'DAC2'])
        self.qcombo_adc_plot.setCurrentIndex(self.selected_ADC)
        
        # Set a few global PyQtGraph settings before creating plots:
        pg.setConfigOption('leftButtonPan', False)
        pg.setConfigOption('background', 'w')
        pg.setConfigOption('foreground', 'k')
        pg.setConfigOption('antialias', True)


        # Create the baseband IQ plot:
        #self.qplt_IQ = Qwt.QwtPlot()
        self.qplt_IQ = pg.PlotWidget()
        #self.qplt_IQ.move(50, 50)
        #self.qplt_IQ.resize(200, 200)
        self.qplt_IQ.setMinimumSize(50, 50)
        self.qplt_IQ.setMaximumSize(200, 200)
        self.qplt_IQ.setFixedSize(100, 100)
#        self.qplt_IQ.setsetHeightForWidth(True)
        # qPolicy = Qt.QSizePolicy(Qt.QSizePolicy.Preferred, Qt.QSizePolicy.Preferred)
        qPolicy = Qt.QSizePolicy(Qt.QSizePolicy.Fixed, Qt.QSizePolicy.Fixed)
        # qPolicy.setHeightForWidth(True)
        self.qplt_IQ.setSizePolicy(qPolicy)
        
       # self.qplt_IQ.setSizePolicy(Qt.QSizePolicy.setHeightForWidth(True))
        
#        print(self.qplt_IQ.sizeHint())
        #self.qplt_IQ.setTitle('', fill=None)
        # self.qplt_IQ.setTitle('Baseband IQ')

        #self.qplt_IQ.setCanvasBackground(Qt.Qt.white)
        #self.qplt_IQ.enableAxis(Qwt.QwtPlot.yLeft, False)
        #self.qplt_IQ.enableAxis(Qwt.QwtPlot.xBottom, False)
        self.qplt_IQ.hideAxis('left')
        self.qplt_IQ.hideAxis('bottom')

        self.lblplt_IQ_title = Qt.QLabel('Baseband IQ:')
        
        # Create the curves in the plot
        self.curve_IQ = self.qplt_IQ.getPlotItem().plot(pen = None, symbol = 'o', symbolPen=None, symbolSize=3, symbolBrush='b')
        # self.curve_IQ = Qwt.QwtPlotCurve('Spectrum')
        # self.curve_IQ.attach(self.qplt_IQ)
        # self.curve_IQ.setPen(Qt.QPen(Qt.Qt.NoPen))
        # self.curve_IQ.setSymbol(Qwt.QwtSymbol(Qwt.QwtSymbol.Ellipse,
        #                             Qt.QBrush(Qt.Qt.blue),
        #                             Qt.QPen(Qt.Qt.blue),
        #                             Qt.QSize(3, 3)))
        # self.curve_IQ.setRenderHint(Qwt.QwtPlotItem.RenderAntialiased);
        
        # Create the frequency domain plot:
        # self.qplt_spc = Qwt.QwtPlot()
        # self.qplt_spc.setTitle('Spectrum')
        # self.qplt_spc.setCanvasBackground(Qt.Qt.white)
        self.plt_spc = pg.PlotWidget()
        
        
        # Create the curves in the plot
        # self.curve_spc = Qwt.QwtPlotCurve('Spectrum')
        # self.curve_spc.attach(self.qplt_spc)
        # self.curve_spc.setPen(Qt.QPen(Qt.Qt.blue))
        # self.curve_filter = Qwt.QwtPlotCurve('Spectrum')
        # self.curve_filter.attach(self.qplt_spc)
        # self.curve_filter.setPen(Qt.QPen(Qt.Qt.red))
        self.curve_spc = self.plt_spc.getPlotItem().plot(title='Spectrum', pen='b')
        self.curve_filter = self.plt_spc.getPlotItem().plot(pen='r')
        
        # Put all the widgets into a grid layout
        grid = QtGui.QGridLayout()
        grid.setSpacing(5)
        grid.addWidget(self.qlabel_adc_fill,        0, 0)
        grid.addWidget(self.qadc0_scale,            1, 0, 3, 1)
        grid.addWidget(self.qlabel_adc_fill_value,  4, 0, 1, 1)
        grid.addWidget(self.qlabel_baseband_snr,    0, 1)
        grid.addWidget(self.qthermo_baseband_snr,   1, 1, 3, 1)
        grid.addWidget(self.qlabel_baseband_snr_value,  4, 1, 1, 1)

        

        
        N_dac_controls = 0
        for k in range(3):
            if self.output_controls[k] == True:
                grid.addWidget(self.qlabel_dac_current[k],     0, 2+N_dac_controls)
                grid.addWidget(self.qthermo_dac_current[k],    1, 2+N_dac_controls, 3, 1)
                grid.addWidget(self.qlabel_dac_current_value[k],4, 2+N_dac_controls, 1, 1)
                grid.addWidget(self.qlabel_dac_offset[k],      0, 3+N_dac_controls)
                grid.addWidget(self.q_dac_offset[k],           1, 3+N_dac_controls, 3, 1)
                grid.addWidget(self.qlabel_dac_offset_value[k],4, 3+N_dac_controls, 1, 1)
                
                
                N_dac_controls = N_dac_controls + 2
                
                
        grid.setRowStretch(1, 1)

        # The plots:
        qhoriz = Qt.QHBoxLayout()
        qhoriz.addWidget(self.lblplt_IQ_title)
        qhoriz.addWidget(self.qplt_IQ)
        qhoriz.addStretch(1)
        
        grid.addLayout(qhoriz,                      0, 2+N_dac_controls, 2, 2)

        #grid.addWidget(self.qplt_IQ,                0, 2+N_dac_controls, 2, 2)
        grid.addWidget(self.plt_spc,                0, 4+N_dac_controls, 5, 1)        
        grid.setColumnStretch(4+N_dac_controls, 1)
#        
        # The controls below the IQ plot:
        grid.addWidget(self.qlabel_adc_plot_input,  2, 2+N_dac_controls)
        grid.addWidget(self.qlabel_adc_plot_type,   3, 2+N_dac_controls)
        grid.addWidget(self.qlabel_rawdata_rbw,     4, 2+N_dac_controls)
        
        grid.addWidget(self.qcombo_adc_plot,        2, 3+N_dac_controls)
        grid.addWidget(self.qcombo_adc_plottype,    3, 3+N_dac_controls)
        grid.addWidget(self.qedit_rawdata_length,   4, 3+N_dac_controls)
        
#        grid.addItem(spacerItem, 9, 0, 1, 2)

        if self.PalNormal is not None:
            self.qgroupbox_diagnostics.setPalette(self.PalNormal)
        self.qgroupbox_diagnostics.setLayout(grid)    
        self.qgroupbox_diagnostics.setAutoFillBackground(True)

        vbox = Qt.QVBoxLayout()
        vbox.addWidget(self.qgroupbox_diagnostics)
        self.setLayout(vbox)


    def setDacOffset(self, k, slider_units):
        self.q_dac_offset[k].blockSignals(True)
        self.q_dac_offset[k].setValue(slider_units)
        self.q_dac_offset[k].blockSignals(False)

    # Update the scale which indicates the ADC fill ratio in numbers of bits:
    # samples must be in integer units (same as raw ADC data)
    def updateScaleDisplays(self, samples):
        
        max_abs = np.max(np.abs(samples))
        if max_abs == 0:
            max_abs = 1 # to prevent passing a 0 value to the log function, which throws an exception
        max_abs_in_bits = np.log2(max_abs)
        
        self.qadc0_scale.setValue(max_abs_in_bits)
        self.qlabel_adc_fill_value.setText('{:.1f} bits'.format(max_abs_in_bits))



    def computeNEB(self, window_function, fs):
        return np.sum((window_function/np.sum(window_function))**2) * fs

    def updateNEBdisplay(self, window_NEB):
        
        # Show the RBW:
        if window_NEB > 1e6:
            self.qlabel_rawdata_rbw.setText('RBW: %.1f MHz; Points:' % (round(window_NEB*1e5)/1e5/1e6))
        elif window_NEB > 1e3:
            self.qlabel_rawdata_rbw.setText('RBW: %.1f kHz; Points:' % (round(window_NEB*1e2)/1e2/1e3))
        else:
            self.qlabel_rawdata_rbw.setText('RBW: %.0f Hz; Points:' % (round(window_NEB)))
        



    def getGUIsettingsForADCdata(self):
        # Get settings from the GUI:
        input_select = str(self.qcombo_adc_plot.currentText())
        plot_type    = self.qcombo_adc_plottype.currentIndex()
        try:
            N_samples = int(float(self.qedit_rawdata_length.text()))
        except:
            N_samples = 4e3

        N_samples = max(N_samples, 64) # apply limit
        return (input_select, plot_type, N_samples)



    def plotADCdata(self, input_select, plot_type, samples_out, ref_exp0):

        if plot_type == 0:    # Display Spectrum
            self.plotADCorDACspectrum(samples_out, input_select)

        elif plot_type == 1:
            self.plotADCorDACtimeDomain(samples_out, input_select)


        if not input_select.startswith('ADC'):
            # Not sure what to put in the baseband IQ plot.  For now we simply don't update it
            self.qthermo_baseband_snr.setValue(0)
            return
        
        # If we are handling ADC0 or ADC1 data (as opposed to DAC data), we can compute stuff based on the complex baseband signal
        start_time = time.perf_counter()
        complex_baseband = self.sl.frontend_DDC_processing(samples_out, ref_exp0, self.selected_ADC)
        if self.bDisplayTiming == True:
            print('Elapsed time (Compute complex baseband) = %f' % (time.perf_counter()-start_time))

        self.handleComplexBaseband(complex_baseband, plot_type)
        
    def handleComplexBaseband(self, complex_baseband, plot_type):


        start_time = time.perf_counter()

        self.updateIQdisplay(complex_baseband)
        self.updateSNRdisplay(complex_baseband)

        
        if plot_type == 2 or plot_type == 3 or plot_type == 4:
            # NEB doesn't make that much sense here, but we still plot 1/Total time
            self.updateNEBdisplay(self.sl.fs/len(complex_baseband)) 
            
        if plot_type == 2:
            self.plotPhaseData(complex_baseband)
        elif plot_type == 3 or plot_type == 4:
            self.plotIQData(complex_baseband, bPhaseAligned=(plot_type==4))

        
        if self.bDisplayTiming == True:
            print('Elapsed time (complex baseband plots) = %f' % (time.perf_counter()-start_time))
        start_time = time.perf_counter()


    def plotADCorDACspectrum(self, samples_out, input_select):

        start_time = time.perf_counter()

        # Normalize samples to +/- 1:
        samples_out = samples_out/2**15
        
        # Compute window function:
        window_function = np.blackman(len(samples_out))
        window_NEB = self.computeNEB(window_function, self.sl.fs)
        self.updateNEBdisplay(window_NEB)


        # Apply window function to the data:
        samples_out_windowed = (samples_out-np.mean(samples_out)) * window_function
        
        if self.bDisplayTiming == True:
            print('Elapsed time (pre-FFT2) = %f' % (time.perf_counter()-start_time))
        start_time = time.perf_counter()
        
        # Compute the spectrum of the raw data:
        N_fft = 2**(int(np.ceil(np.log2(len(samples_out)))))
        spc = np.fft.fft(samples_out_windowed, N_fft)
        last_index_shown = int(np.round(N_fft/2))
        
        if self.bDisplayTiming == True:
            print('Elapsed time (FFT) = %f' % (time.perf_counter()-start_time))
        start_time = time.perf_counter()
                    
        spc = np.real(spc * np.conj(spc))/(np.sum(window_function)**2) # Scale from the modulus square of the FFT to the (double-sided) power spectra
        spc_single_sided_psd = spc*2/self.computeNEB(window_function, self.sl.fs) * (2**15*self.sl.convertADCCountsToVolts(self.selected_ADC, 1))**2
        # Measure average PSD level by looking at out-of-band noise and rejecting outliers:
        index_from_freq = lambda freq: round(freq*N_fft/self.sl.fs)# f_axis = index/N_fft*fs
        ind_min_psd = index_from_freq(10e6)
        ind_max_psd = index_from_freq(20e6)
        spc_single_sided_psd = spc_single_sided_psd[ind_min_psd:ind_max_psd] # slice out an out-of-band section
        # reject the biggest outlier (biases the result, but by a very small amount, and avoids the large error if there is a spur in the chosen bandwidth)
        worst_outlier_index = np.argmax(spc_single_sided_psd)
        spc_single_sided_psd = np.delete(spc_single_sided_psd, worst_outlier_index)
        avg_psd = np.mean(spc_single_sided_psd) # compute the mean
        # 
        spc = spc*4. # scale relative to 0 dBFS sine wave
        spc = 10*np.log10(spc + 1e-12)
        
        
        if self.bDisplayTiming == True:
            print('Elapsed time (10log10 abs(FFT) = %f' % (time.perf_counter()-start_time))
        start_time = time.perf_counter()
        
        # Update the graph data:
        frequency_axis = self.fftFrequencyAxis(N_fft, self.sl.fs)
        self.curve_spc.setData(frequency_axis[0:last_index_shown]/1e6, spc[0:last_index_shown])
        self.plt_spc.setTitle('Spectrum, noise floor = %.0f nV/sqrt(Hz)' % (round_to_N_sig_figs(1e9*np.sqrt(avg_psd), 2)))

        if input_select.startswith('ADC'):
            self.updateFilterSpcDisplay(frequency_axis[0:last_index_shown])

    def plotADCorDACtimeDomain(self, samples_out, input_select):
        samples_out = self.scaleDataToVolts(samples_out, input_select)


        self.updateNEBdisplay(self.sl.fs/len(samples_out)) # NEB doesn't make that much sense here, but we still plot 1/Total time
        
        time_axis = np.linspace(0, len(samples_out)-1, len(samples_out))/self.sl.fs
        
        self.curve_spc.setData(time_axis, samples_out)
        self.curve_filter.setVisible(False)
        # Simply setting a curve to be invisible does not prevent it from being used to compute the axis, so we have to set the axis manually:
        valmin = np.min(samples_out)
        valmax = np.max(samples_out)
        
        self.plt_spc.setYRange((valmin+valmax)/2-1.1*(valmax-valmin)/2-1/65e3, (valmin+valmax)/2+1.1*(valmax-valmin)/2+1/65e3)
        self.plt_spc.setXRange(time_axis[0], time_axis[-1])
        
        self.plt_spc.setTitle('Time-domain signal, std = %.2f mV' % (1e3*np.std(samples_out)))
        self.plt_spc.setTitle('Time, std = %.2f mV, ampl = %.2f mVpp' % (1e3*np.std(samples_out), 1e3*np.std(samples_out)*2*np.sqrt(2)))
        


    def updateFilterSpcDisplay(self, frequency_axis):
        start_time = time.perf_counter()
        # Compute the spectrum of the filter:
        spc_filter = self.sl.get_frontend_filter_response(frequency_axis, self.selected_ADC)
        self.curve_filter.setData(frequency_axis/1e6, spc_filter)
        self.curve_filter.setVisible(True)
        
        if self.bDisplayTiming == True:
            print('Elapsed time (Spectrum of filter) = %f' % (time.perf_counter()-start_time))
        


    def fftFrequencyAxis(self, N_fft, fs):
        return np.linspace(0, (N_fft-1)/float(N_fft)*fs, N_fft)


    # N_max_IQ is the max number of points to display in the IQ graph
    def updateIQdisplay(self, complex_baseband, N_max_IQ = 10e3):
        start_time = time.perf_counter()

        complex_baseband = complex_baseband[:int(np.min((len(complex_baseband), N_max_IQ)))]
        mean_amplitude = np.mean(np.abs(complex_baseband))
        self.curve_IQ.setData(np.real(complex_baseband), np.imag(complex_baseband))

        self.qplt_IQ.setXRange(-1.5*mean_amplitude, 1.5*mean_amplitude)
        self.qplt_IQ.setYRange(-1.5*mean_amplitude, 1.5*mean_amplitude)
        
        if self.bDisplayTiming == True:
            print('Elapsed time (Display IQ) = %f' % (time.perf_counter()-start_time))

    # Compute the SNR on the amplitude of the baseband signal:    
    def updateSNRdisplay(self, complex_baseband):
        amplitude = np.abs(complex_baseband)
        mean_amplitude = np.mean(amplitude)
        std_dev_amplitude = np.std(amplitude)
        if mean_amplitude == 0:
            mean_amplitude = 1. # to avoid a NaN in the log operation
            std_dev_amplitude = 1e3
        baseband_snr = 20*np.log10(mean_amplitude/std_dev_amplitude)
        # to get a more stable reading of the SNR without resorting to rounding:
        # we put a simple first-order IIR filter:
        filter_alpha = np.exp(-1./10.)
        temp_filtered_baseband_snr = filter_alpha * self.filtered_baseband_snr + (1-filter_alpha)*baseband_snr
        
        # Sometimes, the average of the amplitude is NaN, so we only accept the new SNR if it is not(NaN)
        if not(np.isnan(temp_filtered_baseband_snr)):
            self.filtered_baseband_snr = temp_filtered_baseband_snr
        else:
            print("Error 'nan' in filtered_baseband_snr")

        self.qthermo_baseband_snr.setValue(baseband_snr)
        self.qlabel_baseband_snr_value.setText('{:.2f} dB'.format(self.filtered_baseband_snr))
        

    def scaleDataToVolts(self, samples_out, input_select):
        if input_select.startswith('ADC'):
            # Convert ADC counts to voltage
            return self.sl.convertADCCountsToVolts(input_select, samples_out)
        else:
            # Convert DAC counts to voltage
            DAC_number = int(input_select[3])
            return self.sl.convertDACCountsToVolts(DAC_number, samples_out)

    def plotPhaseData(self, complex_baseband):
        phi = np.unwrap(np.angle(complex_baseband))
        time_axis = np.linspace(0, len(complex_baseband)-1, len(complex_baseband))/self.sl.fs
        
        self.curve_spc.setData(time_axis, phi-phi[0])
        self.curve_filter.setVisible(False)
        # Simply setting a curve to be invisible does not prevent it from being used to compute the axis, so we have to set the axis manually:
        valmin = np.min(phi)-phi[0]
        valmax = np.max(phi)-phi[0]
        
        self.plt_spc.setYRange(valmin, valmax)
        self.plt_spc.setXRange(time_axis[0], time_axis[-1])
    
        self.plt_spc.setTitle('Time-domain phase, std = %.2f radrms' % np.std(phi))

    def plotIQData(self, complex_baseband, bPhaseAligned):

        if bPhaseAligned:
            # Sync the phase to be equal to 0 at t=0:
            complex_baseband = complex_baseband * np.conj(complex_baseband[0])/np.abs(complex_baseband[0])

        # Set axis
        time_axis = np.linspace(0, len(complex_baseband)-1, len(complex_baseband))/self.sl.fs

        
        self.curve_spc.setData(time_axis, np.real(complex_baseband))
        self.curve_filter.setData(time_axis, np.imag(complex_baseband))
        self.curve_filter.setVisible(True)
        # Simply setting a curve to be invisible does not prevent it from being used to compute the axis, so we have to set the axis manually:
        mean_amplitude = np.mean(np.abs(complex_baseband))
        
        self.plt_spc.setYRange(-1.5*mean_amplitude, 1.5*mean_amplitude)
        self.plt_spc.setXRange(time_axis[0], time_axis[-1])
    
        if bPhaseAligned:
            self.plt_spc.setTitle('Time-domain IQ signals, phase aligned at t=0')
        else:
            self.plt_spc.setTitle('Time-domain IQ signals (I: blue, Q: red)')


    @logCommsErrorsAndBreakoutOfFunction()
    def setDACOffset_event(self, value=0):
        for k in range(3):
            if self.output_controls[k] == True:
                # We need to convert between the units of the slider (0 to 1e6 integers) to counts.
                # 0 corresponds to the DAC lowest limit and 1e6 to the DAC highest limit:
#                print 'k = %d, self.sl.DACs_limit_low[k] = %d, self.sl.DACs_limit_high[k] = %d' % (k, self.sl.DACs_limit_low[k], self.sl.DACs_limit_high[k])
                counts_offset = int(self.sl.DACs_limit_low[k] + float(self.sl.DACs_limit_high[k] - self.sl.DACs_limit_low[k]) * float(self.q_dac_offset[k].value())/1e6) #counts_offset is 16 bits signed
                self.sl.set_dac_offset(k, counts_offset)
                
                VCO_gain_in_Hz_per_Volts = self.parent.getVCOGainFromUI(k)
                    
                # Update the display:                
                current_output_in_volts = self.sl.convertDACCountsToVolts(k, counts_offset)
                current_output_in_hz = current_output_in_volts * VCO_gain_in_Hz_per_Volts
                self.qlabel_dac_offset_value[k].setText('{:.4f} V\n{:.0f} MHz'.format(current_output_in_volts, current_output_in_hz/1e6))

    @logCommsErrorsAndBreakoutOfFunction()
    def getDACoffset(self):
        for k in range(3):
            if self.output_controls[k] == True:
                self.sl.get_dac_limits(k)
                counts_offset = self.sl.get_dac_offset(k)
                q_dac_offset = float(counts_offset-self.sl.DACs_limit_low[k])*1e6/float(self.sl.DACs_limit_high[k] - self.sl.DACs_limit_low[k])

                self.q_dac_offset[k].blockSignals(True)
                self.q_dac_offset[k].setValue(q_dac_offset)
                self.q_dac_offset[k].blockSignals(False)

                VCO_gain_in_Hz_per_Volts = self.parent.getVCOGainFromUI(k)

                # Update the display:                
                current_output_in_volts = self.sl.convertDACCountsToVolts(k, counts_offset)
                current_output_in_hz = current_output_in_volts * VCO_gain_in_Hz_per_Volts
                self.qlabel_dac_offset_value[k].setText('{:.4f} V\n{:.0f} MHz'.format(current_output_in_volts, current_output_in_hz/1e6))

    @logCommsErrorsAndBreakoutOfFunction()
    def setSliderStepSize(self, output_number, VCO_gain_in_Hz_per_Volts):
        # Units for the slider are millionth of fullscale (goes from 0 to 1e6), which maps to [DAC_limit_low, DAC_limit_high]
        # The times three is because the scroll wheel actually does 3 small_steps (this is settings in Windows and can change from one computer to the next..)
        if output_number == 1 and self.sl.read_pll2_mux() == 2:
            print('Cascade lock operation: slider step size is hardcoded here!')
            VCO_gain_in_Hz_per_Volts = 700e6    # use hard-coded value because the textbox is used for a different setting (gain ratio instead of VCO gain)
            small_step = int(round(1e6/3. * (0.5e6 / float(VCO_gain_in_Hz_per_Volts) / float(self.sl.getDACGainInVoltsPerCounts(output_number))) / float(self.sl.DACs_limit_high[output_number] - self.sl.DACs_limit_low[output_number])))
            large_step = int(round(1e6    * (5e6   / float(VCO_gain_in_Hz_per_Volts) / float(self.sl.getDACGainInVoltsPerCounts(output_number))) / float(self.sl.DACs_limit_high[output_number] - self.sl.DACs_limit_low[output_number])))
        else:
            # Normal operation
            small_step = int(round(1e6/3. * (0.5e6 / float(VCO_gain_in_Hz_per_Volts) / float(self.sl.getDACGainInVoltsPerCounts(output_number))) / float(self.sl.DACs_limit_high[output_number] - self.sl.DACs_limit_low[output_number])))
            large_step = int(round(1e6    * (5e6   / float(VCO_gain_in_Hz_per_Volts) / float(self.sl.getDACGainInVoltsPerCounts(output_number))) / float(self.sl.DACs_limit_high[output_number] - self.sl.DACs_limit_low[output_number])))

        if small_step < 1:
            small_step = 1
        if small_step > 1e6:
            small_step = 1e6
        if large_step < 1:
            large_step = 1
        if large_step > 1e6:
            large_step = 1e6

        self.q_dac_offset[output_number].setSingleStep(small_step)
        self.q_dac_offset[output_number].setPageStep(large_step)



if __name__ == '__main__':

    # Start Qt:
    app = QtCore.QCoreApplication.instance()
    if app is None:
        print("QCoreApplication not running yet. creating.")
        bEventLoopWasRunningAlready = False
        app = QtWidgets.QApplication(sys.argv)
    else:
        bEventLoopWasRunningAlready = True
        print("QCoreApplication already running.")

        
    sp = SLLSystemParameters()
    sl = SuperLaserLand_mock()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()
    bPass = True

    sw = SpectrumWidget(None, 0, (1, 0, 0), sl)
    sw.show()

    # for test_case in range(5):
    #     xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 0, (True, False, False), sp, '', '')
    #     bPass = bPass and test_grabAndDisplayADC(sl, xem_gui_mainwindow, test_number=test_case, bPrintAllOutputState=False)
    #     del xem_gui_mainwindow

    print(bEventLoopWasRunningAlready)

    if bPass:
        print("All tests PASSED")
    else:
        print("Some tests FAILED")

    # This code here is to handle weird interaction between IPython's event handler:
    # Depending on the setting for the graphical backend in Spyder (Tools/Preferences/IPython Console/Graphics/Backend = (Automatic or Inline),
    # the Qt event loop might be already running, so the proper way to teardown our application,
    # for example to enable re-using the same console to run another instance afterwards,
    # is different.
    if bEventLoopWasRunningAlready == False:
        # del xem_gui_mainwindow
        del sl
    