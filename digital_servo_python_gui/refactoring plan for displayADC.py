# Goal is to first write a test so that I can change things safely, and quickly make sure that nothing is broken.
# For this, I need to provide mocks for a few things:
# the GUI can be left as is, and maybe set manually in the testing code.
# the testing code creates a new XEM_GUI_MainWindow instance,
# and provides a mock SuperlaserLand_JD_RP object
# 
# Unfortunately, I am sure that we need to mock up a lot of that object's functions in order to even boot up the GUI,
# but we don't need _that_ many to test say, just displayADC() (see list below)
# 


globals needed:
time
np


outputs:
	

	# GUI-based outputs:
	self.qadc0_scale.setValue(max_abs_in_bits)
	self.qthermo_baseband_snr.setValue(baseband_snr)
	self.qthermo_baseband_snr.setValue(0)

	self.qlabel_adc_fill_value.setText('{:.1f} bits'.format(max_abs_in_bits))
	self.qlabel_rawdata_rbw.setText('RBW: %.1f MHz; Points:' % (round(window_NEB*1e5)/1e5/1e6))
	self.qlabel_rawdata_rbw.setText('RBW: %.1f kHz; Points:' % (round(window_NEB*1e2)/1e2/1e3))
	self.qlabel_rawdata_rbw.setText('RBW: %.0f Hz; Points:' % (round(window_NEB)))
	self.qlabel_baseband_snr_value.setText('{:.2f} dB'.format(self.filtered_baseband_snr))

	self.qplt_IQ.setXRange(-1.5*mean_amplitude, 1.5*mean_amplitude)
	self.qplt_IQ.setYRange(-1.5*mean_amplitude, 1.5*mean_amplitude)
	self.qplt_IQ.replot()

	self.plt_spc.setXRange(frequency_axis[0]/1e6, frequency_axis[last_index_shown]/1e6)
	self.plt_spc.setYRange(-120, 0)
	self.plt_spc.setTitle('Spectrum')
	self.plt_spc.replot()

	self.curve_spc.setData(frequency_axis[0:last_index_shown]/1e6, spc[0:last_index_shown])
	self.curve_filter.setVisible(False)
	self.curve_filter.setData(time_axis, np.imag(complex_basebandr))
	self.curve_DDC0_spc_amplitude_noise.setData(frequency_axis[1:last_index_shown], spc[1:last_index_shown])
	self.curve_DDC0_spc_amplitude_noise.setVisible(True)
	self.curve_IQ.setData(np.real(complex_baseband), np.imag(complex_baseband))
	self.curve_IQ.setData(empty_array, empty_array)

	# internal state output variables
	self.raw_adc_samples

	# This should be refactored into its own little class (an IIR filter class, with initialization that skips the initial transient)
persistent internal variables:
	self.filtered_baseband_snr + (1-filter_alpha)*baseband_snr

inputs:
self.sl
	self.sl.bDDR2InUse
	self.sl.setup_ADC0_write, # this should be refactored into a single function with a parameter (can be a string)
	self.sl.setup_ADC1_write,
	self.sl.setup_DAC0_write,
	self.sl.setup_DAC1_write,
	self.sl.setup_DAC2_write
	self.sl.trigger_write()
	self.sl.wait_for_write()
	self.sl.read_adc_samples_from_DDR2()
	self.sl.get_ddc0_ref_freq()
	self.sl.get_ddc1_ref_freq()
	self.sl.fs
	self.sl.convertADCCountsToVolts(self.selected_ADC, 1)
	self.sl.convertADCCountsToVolts(self.selected_ADC, samples_out)
	self.sl.convertDACCountsToVolts(DAC_number, samples_out)
	self.sl.frontend_DDC_processing(samples_out, ref_exp0, self.selected_ADC)
	self.sl.get_frontend_filter_response(frequency_axis, self.selected_ADC)

	# GUI-based inputs:
	self.qedit_rawdata_length.text()
	self.qcombo_adc_plot.currentIndex()
	self.qcombo_adc_plottype.currentIndex()
	self.qcombo_ddc_plot.currentIndex()

	# Internal switches-based inputs:
	self.bDisplayTiming == True:
	self.selected_ADC



# I think I should start by splitting this into two phases:
	# reading from the ADC
	# doing something with the data

	# further splitting the "doing something with the data":
		# what we want to do depends on what input and output type is currently selected


	# I should keep as a goal to be able to split the "reading from the ADC" into a "request" being issued to the device, and a data received event.
	# this way we could more easily split things into multiple threads for example.


	def displayADC(self):
				
		start_time = time.perf_counter()
		
		# Check if another function is currently using the DDR2 logger:
		if self.sl.bDDR2InUse:
			print('displayADC(): DDR2 logger in use, cannot get data from adc')
			return
		# Block access to the DDR2 Logger to any other function until we are done:
		self.sl.bDDR2InUse = True

		try:
			N_points = int(float(self.qedit_rawdata_length.text()))
		except:
			N_points = 4e3
			
		if N_points < 64:
			N_points = 64
	
		currentSelector = self.qcombo_adc_plot.currentIndex()
		# Python doesn't have switch-case statements
		# Apparently the best way is to use a dictionary instead:
		setup_func_dict = {0: self.sl.setup_ADC0_write,
						   1: self.sl.setup_ADC1_write,
						   2: self.sl.setup_DAC0_write,
						   3: self.sl.setup_DAC1_write,
						   4: self.sl.setup_DAC2_write}
		
			
		try:
			# Read from selected source
			setup_func_dict[currentSelector](N_points)
			self.sl.trigger_write()
			self.sl.wait_for_write()
			(samples_out, ref_exp0) = self.sl.read_adc_samples_from_DDR2()

			max_abs = np.max(np.abs(samples_out))

			samples_out = samples_out.astype(dtype=np.float)
			self.raw_adc_samples = samples_out
				
		except:
			# ADC read failed.
			print('Unhandled exception in ADC read')
			del self.sl
			raise
			
		# Signal to other functions that they can use the DDR2 logger
		self.sl.bDDR2InUse = False
		
		if self.bDisplayTiming == True:
			print('Elapsed time (Comm) = %f' % (time.perf_counter()-start_time))
		start_time = time.perf_counter()
		
		# Update the scale which indicates the ADC fill ratio in numbers of bits:
		max_abs = np.max(np.abs(samples_out))
		if max_abs == 0:
			max_abs = 1 # to prevent passing a 0 value to the log function, which throws an exception
		max_abs_in_bits = np.log2(max_abs)
		
		self.qadc0_scale.setValue(max_abs_in_bits)
		self.qlabel_adc_fill_value.setText('{:.1f} bits'.format(max_abs_in_bits))
		
		
		# Compute the baseband IQ data and the spectrum:
		# Read the reference frequency, should contain a negative frequency (encoded as a frequency above Nyquist) if the VCO sign is positive
		if self.selected_ADC == 0:
			f_reference = self.sl.get_ddc0_ref_freq()
		elif self.selected_ADC == 1:
			f_reference = self.sl.get_ddc1_ref_freq()
		f_reference = ((f_reference+self.sl.fs/2) % self.sl.fs)-self.sl.fs/2  # The modulo converts a frequency above Nyquist to the matching negative frequency
			
		# Compute the window function used to display the spectrum:
		N_fft = 2**(int(np.ceil(np.log2(len(samples_out)))))
		frequency_axis = np.linspace(0, (N_fft-1)/float(N_fft)*self.sl.fs, N_fft)
		window_function = np.blackman(len(samples_out))
		last_index_shown = int(np.round(len(frequency_axis)/2))
		window_NEB = np.sum((window_function/np.sum(window_function))**2) * self.sl.fs
		
		# Show the RBW:
		if window_NEB > 1e6:
			self.qlabel_rawdata_rbw.setText('RBW: %.1f MHz; Points:' % (round(window_NEB*1e5)/1e5/1e6))
		elif window_NEB > 1e3:
			self.qlabel_rawdata_rbw.setText('RBW: %.1f kHz; Points:' % (round(window_NEB*1e2)/1e2/1e3))
		else:
			self.qlabel_rawdata_rbw.setText('RBW: %.0f Hz; Points:' % (round(window_NEB)))
			


		if self.qcombo_adc_plottype.currentIndex() == 0:    # Display Spectrum

			if self.bDisplayTiming == True:
				print('Elapsed time (pre-FFT) = %f' % (time.perf_counter()-start_time))
			start_time = time.perf_counter()
			
			# Normalize samples to +/- 1:
			samples_out = samples_out/2**15
			# Apply window function to the data:
			samples_out_windowed = (samples_out-np.mean(samples_out)) * window_function
			
			if self.bDisplayTiming == True:
				print('Elapsed time (pre-FFT2) = %f' % (time.perf_counter()-start_time))
			start_time = time.perf_counter()
			
			# Compute the spectrum of the raw data:
			spc = np.fft.fft(samples_out_windowed, N_fft)
			
			if self.bDisplayTiming == True:
				print('Elapsed time (FFT) = %f' % (time.perf_counter()-start_time))
			start_time = time.perf_counter()
						
			spc = np.real(spc * np.conj(spc))/(np.sum(window_function)**2) # Scale from the modulus square of the FFT to the (double-sided) power spectra
			spc_single_sided_psd = spc*2/window_NEB * (2**15*self.sl.convertADCCountsToVolts(self.selected_ADC, 1))**2
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
			self.curve_spc.setData(frequency_axis[0:last_index_shown]/1e6, spc[0:last_index_shown])
			# self.plt_spc.setXRange(frequency_axis[0]/1e6, frequency_axis[last_index_shown]/1e6)
			# self.plt_spc.setYRange(-120, 0)
			#self.qplt_spc.setAxisScale(Qwt.QwtPlot.xBottom, frequency_axis[0]/1e6, frequency_axis[last_index_shown]/1e6)
			#self.qplt_spc.setAxisScale(Qwt.QwtPlot.yLeft, -120, 0)
			# self.plt_spc.setTitle('Spectrum')
			self.plt_spc.setTitle('Spectrum, noise floor = %.0f nV/sqrt(Hz)' % (round_to_N_sig_figs(1e9*np.sqrt(avg_psd), 2)))
		elif self.qcombo_adc_plottype.currentIndex() == 1:
			# Display time-domain plot instead
			
			if currentSelector == 0 or currentSelector == 1:
				# Convert ADC counts to voltage
				samples_out = self.sl.convertADCCountsToVolts(self.selected_ADC, samples_out)
			else:
				# Convert DAC counts to voltage
				DAC_number = currentSelector-2
				samples_out = self.sl.convertDACCountsToVolts(DAC_number, samples_out)
			time_axis = np.linspace(0, len(samples_out)-1, len(samples_out))/self.sl.fs
			
			self.curve_spc.setData(time_axis, samples_out)
#            self.qplt_spc.setAxisScale(Qwt.QwtPlot.yLeft, -120, 0)
#            self.qplt_spc.setAxisAutoScale(Qwt.QwtPlot.yLeft)
			self.curve_filter.setVisible(False)
			# Simply setting a curve to be invisible does not prevent it from being used to compute the axis, so we have to set the axis manually:
			valmin = np.min(samples_out)
			valmax = np.max(samples_out)
			
			# self.qplt_spc.setAxisScale(Qwt.QwtPlot.yLeft, (valmin+valmax)/2-1.1*(valmax-valmin)/2-1/65e3, (valmin+valmax)/2+1.1*(valmax-valmin)/2+1/65e3)
			# self.qplt_spc.setAxisScale(Qwt.QwtPlot.xBottom, time_axis[0], time_axis[-1])

			self.plt_spc.setYRange((valmin+valmax)/2-1.1*(valmax-valmin)/2-1/65e3, (valmin+valmax)/2+1.1*(valmax-valmin)/2+1/65e3)
			self.plt_spc.setXRange(time_axis[0], time_axis[-1])
			
			self.plt_spc.setTitle('Time-domain signal, std = %.2f mV' % (1e3*np.std(samples_out)))
			self.plt_spc.setTitle('Time, std = %.2f mV, ampl = %.2f mVpp' % (1e3*np.std(samples_out), 1e3*np.std(samples_out)*2*np.sqrt(2)))
			

		# If we are handling ADC0 or ADC1 data (as opposed to DAC data)
		if currentSelector == 0 or currentSelector == 1:


			if np.real(ref_exp0) == 0 and np.imag(ref_exp0) == 0:
				print('displayADC(): Invalid complex exponential. Probably because of a version mismatch between the RP firmware and Python GUI.')
				return
		
			# The signal is from ADC0 or ADC1
			N_max_IQ = 10e3 # Max number of points to display in the IQ graph
			complex_baseband = self.sl.frontend_DDC_processing(samples_out, ref_exp0, self.selected_ADC)
			
			if self.bDisplayTiming == True:
				print('Elapsed time (Compute complex baseband) = %f' % (time.perf_counter()-start_time))
			start_time = time.perf_counter()
			
			
			# Compute the SNR on the amplitude of the baseband signal:    
			amplitude = np.abs(complex_baseband)
			mean_amplitude = np.mean(amplitude)
			std_dev_amplitude = np.std(amplitude)
			if mean_amplitude == 0:
				mean_amplitude = 1.	# to avoid a NaN in the log operation
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
			
			
			if self.qcombo_adc_plottype.currentIndex() == 2:
				# show phase error as a function of time
				
				# To mimick as much as possible the processing done in the FPGA, we quantize the complex baseband:
				complex_basebandr = np.round(2**15*complex_baseband * 20/2 /2**4 /2)
				phi = np.unwrap(np.angle(complex_basebandr))
				phi_std = np.std(phi)
				# Set axis
				time_axis = np.linspace(0, len(complex_baseband)-1, len(complex_baseband))/self.sl.fs
				
				self.curve_spc.setData(time_axis, phi-phi[0])
	#            self.qplt_spc.setAxisScale(Qwt.QwtPlot.yLeft, -120, 0)
	#            self.qplt_spc.setAxisAutoScale(Qwt.QwtPlot.yLeft)
				self.curve_filter.setVisible(False)
				# Simply setting a curve to be invisible does not prevent it from being used to compute the axis, so we have to set the axis manually:
				valmin = np.min(phi)-phi[0]
				valmax = np.max(phi)-phi[0]
				
				# self.qplt_spc.setAxisScale(Qwt.QwtPlot.yLeft, valmin, valmax)
				# self.qplt_spc.setAxisScale(Qwt.QwtPlot.xBottom, time_axis[0], time_axis[-1])

				self.plt_spc.setYRange(valmin, valmax)
				self.plt_spc.setXRange(time_axis[0], time_axis[-1])
			
				self.plt_spc.setTitle('Time-domain phase, std = %.2f radrms' % phi_std)
			
	   
			if self.qcombo_adc_plottype.currentIndex() == 3:
				
				# show time-domain I and Q signals
				# To mimick as much as possible the processing done in the FPGA, we quantize the complex baseband:
				complex_basebandr = np.round(2**15*complex_baseband * 20/2 /2**4 /2)
				# Set axis
				time_axis = np.linspace(0, len(complex_basebandr)-1, len(complex_basebandr))/self.sl.fs

				
				self.curve_spc.setData(time_axis, np.real(complex_basebandr))
				self.curve_filter.setData(time_axis, np.imag(complex_basebandr))
	#            self.qplt_spc.setAxisScale(Qwt.QwtPlot.yLeft, -120, 0)
	#            self.qplt_spc.setAxisAutoScale(Qwt.QwtPlot.yLeft)
				self.curve_filter.setVisible(True)
				# Simply setting a curve to be invisible does not prevent it from being used to compute the axis, so we have to set the axis manually:
				valmax1 = np.mean(np.abs(complex_basebandr))
				
				self.plt_spc.setYRange(-1.5*valmax1, 1.5*valmax1)
				self.plt_spc.setXRange(time_axis[0], time_axis[-1])
			
				self.plt_spc.setTitle('Time-domain IQ signals (I: blue, Q: red)')
				
			if self.qcombo_adc_plottype.currentIndex() == 4:
				
				# show time-domain I and Q signals
				# To mimick as much as possible the processing done in the FPGA, we quantize the complex baseband:
				complex_basebandr = np.round(2**15*complex_baseband * 20/2 /2**4 /2)
				# Sync the phase to be equal to 0 at t=0:
				complex_basebandr = complex_basebandr * np.conj(complex_basebandr[0])/np.abs(complex_basebandr[0])
				# Set axis
				time_axis = np.linspace(0, len(complex_basebandr)-1, len(complex_basebandr))/self.sl.fs
				
				self.curve_spc.setData(time_axis, np.real(complex_basebandr))
				self.curve_filter.setData(time_axis, np.imag(complex_basebandr))
	#            self.qplt_spc.setAxisScale(Qwt.QwtPlot.yLeft, -120, 0)
	#            self.qplt_spc.setAxisAutoScale(Qwt.QwtPlot.yLeft)
				self.curve_filter.setVisible(True)
				# Simply setting a curve to be invisible does not prevent it from being used to compute the axis, so we have to set the axis manually:
				valmax1 = np.mean(np.abs(complex_basebandr))
				
				self.plt_spc.setYRange(-1.5*valmax1, 1.5*valmax1)
				self.plt_spc.setXRange(time_axis[0], time_axis[-1])
			
				self.plt_spc.setTitle('Time-domain IQ signals, phase aligned at t=0')
			
			
			complex_baseband = complex_baseband[:int(np.min((len(complex_baseband), N_max_IQ)))]
			self.curve_IQ.setData(np.real(complex_baseband), np.imag(complex_baseband))
			
			self.qplt_IQ.setXRange(-1.5*mean_amplitude, 1.5*mean_amplitude)
			self.qplt_IQ.setYRange(-1.5*mean_amplitude, 1.5*mean_amplitude)
			# Refresh the display:
			# self.qplt_IQ.replot()
			
			if self.bDisplayTiming == True:
				print('Elapsed time (Display IQ) = %f' % (time.perf_counter()-start_time))
			start_time = time.perf_counter()     

			
			if self.qcombo_adc_plottype.currentIndex() == 0:
				# Compute the spectrum of the filter:
				spc_filter = self.sl.get_frontend_filter_response(frequency_axis, self.selected_ADC)
#                spc_filter = np.sin(np.pi * (abs(frequency_axis-abs(f_reference))+10)*N_filter/self.sl.fs)/ (np.pi*(abs(frequency_axis-abs(f_reference))+10)*N_filter/self.sl.fs)
#                spc_filter = 20*np.log10(np.abs(spc_filter) + 1e-7)
				# Update the graph
				self.curve_filter.setData(frequency_axis[0:last_index_shown]/1e6, spc_filter[0:last_index_shown])
				self.curve_filter.setVisible(True)
			
			# If the phase noise spectrum is selected, we add the spectrum of the amplitude noise:
			if self.qcombo_ddc_plot.currentIndex() == 1 and True:
#                print('showing amplitude noise')
				# Normalize the amplitude to the carrier and remove DC:
				amplitude = amplitude / np.mean(amplitude) - 1
				
				# Decimate the signal since
				N_decimation = 10
				fs_new = self.sl.fs/N_decimation
#				amplitude = decimate(amplitude, N_decimation)
				amplitude = decimate(amplitude, N_decimation, zero_phase=False)
				
				N_fft = 2**(int(np.ceil(np.log2(len(amplitude)))))
				frequency_axis = np.linspace(0, (N_fft-1)/float(N_fft)*fs_new, N_fft)
				window_function = np.blackman(len(amplitude))
#                window_function = np.blackman(len(amplitude))
				window_NEB = np.sum((window_function/np.sum(window_function))**2) * fs_new
#                frequency_axis = np.linspace(0, (len(amplitude)-1)/float(len(amplitude))*(fs_new), len(amplitude))
				last_index_shown = int(np.round(len(frequency_axis)/2))
				
#                amplitude.resize(len(window_function))  # to match the window size
				spc = np.fft.fft(amplitude * window_function, N_fft)
				spc = np.real(spc*np.conj(spc))/(sum(window_function)**2) # Spectrum is now scaled in power (Hz^2 per bin)
				last_index_shown = int(np.round(len(frequency_axis)/2))
				# Scale the spectrum to be a single-sided power spectral density in Hz^2/Hz:
				spc[1:last_index_shown] = 2*spc[1:last_index_shown] / window_NEB
				spc = 10*np.log10(spc + 1e-20)
				
#                self.curve_DDC0_spc_amplitude_noise.setData(frequency_axis[1:last_index_shown], spc[1:last_index_shown])
				self.curve_DDC0_spc_amplitude_noise.setData(frequency_axis[1:last_index_shown], spc[1:last_index_shown])
				self.curve_DDC0_spc_amplitude_noise.setVisible(True)
				
			else:
				# turn off amplitude noise curve:
				self.curve_DDC0_spc_amplitude_noise.setVisible(False)
				
			if self.bDisplayTiming == True:
				print('Elapsed time (Spectrum of amplitude noise) = %f' % (time.perf_counter()-start_time))
			start_time = time.perf_counter()
			
			

			
		else:
			# The signal is from DAC0 or DAC1:
			# Not sure what to put in the baseband IQ plot.  For now we put nothing
			self.qthermo_baseband_snr.setValue(0)
#                empty_array = np.array(0)
#                self.curve_IQ.setData(empty_array, empty_array)
#                self.curve_DDC0_spc_amplitude_noise.setData(empty_array, empty_array)
#                self.curve_filter.setData(empty_array, empty_array)
			pass

		
		
		if self.bDisplayTiming == True:
			print('Elapsed time (self.plt_spc.replot()) = %f' % (time.perf_counter()-start_time))
		start_time = time.perf_counter()
		
#        self.bDisplayTiming = False