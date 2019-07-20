


Moving code outside of the MainWindow into separate Widget classes:

Spectrum analyzer/diagnostics (all computed from raw ADC input):
3 thermometers
a few labels
2 combo for choosing plot type
1 textbox and label for number of points
1 baseband IQ plot
1 spectrum (and other types) plot)

Stuff that stays in MainWindow:
self.output_controls: gets passed down to SpectrumWidget


State from elsewhere in the GUI that is needed in the plot thingy
qedit_vco_gain



Functions that need to move:
updateScaleDisplays


setDACOffset_event()

displayDAC()
    needs to be refactored so that it receives the samples already
    required:
    self.qedit_vco_gain
    outputs:
    self.qthermo_dac_current[k]
    self.qlabel_dac_current_value[k]

getDACoffset()


self.qlabel_adc_fill
self.qadc0_scale
self.qlabel_adc_fill_value
self.qlabel_baseband_snr
self.qthermo_baseband_snr
self.qlabel_baseband_snr_value





self.qlabel_dac_current
self.qthermo_dac_current
self.qlabel_dac_current_value
self.qlabel_dac_offset
self.q_dac_offset
self.qlabel_dac_offset_value


self.output_controls: stays in MainWindow, will need to be read

self.lblplt_IQ_title
self.qplt_IQ
self.qplt_IQ

self.plt_spc
self.qlabel_adc_plot_input
self.qlabel_adc_plot_type
self.qlabel_rawdata_rbw
self.qcombo_adc_plot
self.qcombo_adc_plottype
self.qedit_rawdata_length
self.qgroupbox_diagnostics




        # Put all the widgets into a grid layout
        grid = QtGui.QGridLayout()
        grid.setSpacing(5)
        grid.addWidget(self.qlabel_adc_fill,        0, 0)
        grid.addWidget(self.qadc0_scale,            1, 0, 3, 1)
        grid.addWidget(self.qlabel_adc_fill_value,  4, 0, 1, 1)
        grid.addWidget(self.qlabel_baseband_snr,    0, 1)
        grid.addWidget(self.qthermo_baseband_snr,   1, 1, 3, 1)
        grid.addWidget(self.qlabel_baseband_snr_value,  4, 1, 1, 1)
#        grid.addWidget(self.qlabel_ddc0_error,      0, 2)
#        grid.addWidget(self.qddc0_error_scale,      1, 2, 4, 1)
        

        
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
                
        #FEATURE         
        #if self.output_controls[0] == True:
            #grid.addWidget(self.qlabel_pwm0,       0, 3+N_dac_controls, 1, 1)
            #grid.addWidget(self.q_pwm0_value,      1, 3+N_dac_controls, 3, 1)
            #grid.addWidget(self.qlabel_pwm0_value, 4, 3+N_dac_controls, 1, 1)
            #N_dac_controls = N_dac_controls + 2
            
                
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

        self.qgroupbox_diagnostics.setLayout(grid)    
        self.qgroupbox_diagnostics.setPalette(PalNormal)
        self.qgroupbox_diagnostics.setAutoFillBackground(True)