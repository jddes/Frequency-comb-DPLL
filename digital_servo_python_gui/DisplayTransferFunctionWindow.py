"""
XEM6010 Phase-lock box GUI, Transfer function display window
by JD Deschenes, October 2013

"""

import sys
import time
from PyQt4 import QtGui, Qt
import PyQt4.Qwt5 as Qwt
import numpy as np
import math
from scipy.signal import lfilter
from scipy.signal import decimate
import copy

# For make_sure_path_exists()
import os
import errno

class DisplayTransferFunctionWindow(QtGui.QWidget):

        
    def __init__(self, window_number):
        super(DisplayTransferFunctionWindow, self).__init__()

        self.bClosed = False
        # create empty lists to hold the various traces:
        self.vertical_units_list = []
        self.frequency_axis_list = []
        self.transfer_function_list = []

        self.window_number = window_number
        self.initUI()

    def addCurve(self, frequency_axis, transfer_function, vertical_units):

        transfer_function_uncalibrated = copy.copy(transfer_function) * (10**((-5.06--6.+0.16)/20.))  # adjustment based on low-frequency RedPitaya's transfer function
        self.writeOutputFile(transfer_function_uncalibrated, frequency_axis, vertical_units, bCalibrated=False) # we always save the uncalibrated TF regardless of whether we apply cal or not
        
        # Load and apply calibration data based on the measurement of the Red Pitaya's transfer function:
        if vertical_units == 'V/V':
            # the copy.copy() is not strictly needed since applying the calibration would create a copy, but this potentially avoids a mistake later if I bypass the calibration
            transfer_function_calibrated = self.loadAndApplyCalibration(transfer_function_uncalibrated, frequency_axis)
            self.transfer_function_list.append(transfer_function_calibrated)
            self.writeOutputFile(transfer_function_calibrated, frequency_axis, vertical_units, bCalibrated=True)
        else:
            self.transfer_function_list.append(transfer_function_uncalibrated)


        self.vertical_units_list.append(copy.copy(vertical_units))
        self.frequency_axis_list.append(copy.copy(frequency_axis))

        # create a new curve object in both magnitude and phase plots:
        # magnitude plot
        #TODO: add color cycling according to matlab's color scheme.
        current_color_as_list = self.colors_order[(len(self.transfer_function_list)-1) % len(self.colors_order)]
        R_value = current_color_as_list[0]
        G_value = current_color_as_list[1]
        B_value = current_color_as_list[2]

        current_color = Qt.QColor(R_value, G_value, B_value)
        self.curve_mag_list.append(Qwt.QwtPlotCurve('qplt_freq'))
        self.curve_mag_list[-1].attach(self.qplt_mag)
        self.curve_mag_list[-1].setPen(Qt.QPen(current_color))
        self.curve_mag_list[-1].setSymbol(Qwt.QwtSymbol(Qwt.QwtSymbol.Ellipse,
                                    Qt.QBrush(current_color),
                                    Qt.QPen(current_color),
                                    Qt.QSize(3, 3)))
        self.curve_mag_list[-1].setRenderHint(Qwt.QwtPlotItem.RenderAntialiased);

        # Create the curve in the phase plot
        self.curve_phase_list.append(Qwt.QwtPlotCurve('qplt_freq'))
        self.curve_phase_list[-1].attach(self.qplt_phase)
        self.curve_phase_list[-1].setPen(Qt.QPen(current_color))
        self.curve_phase_list[-1].setSymbol(Qwt.QwtSymbol(Qwt.QwtSymbol.Ellipse,
                                    Qt.QBrush(current_color),
                                    Qt.QPen(current_color),
                                    Qt.QSize(3, 3)))
        self.curve_phase_list[-1].setRenderHint(Qwt.QwtPlotItem.RenderAntialiased);
        

        self.updateGraph()
        return

    def loadAndApplyCalibration(self, transfer_function, frequency_axis):
        print "applying calibration"
        # load data files, the calibration data was measured in two consecutive runs
#        data_highfreq = np.loadtxt(u'transfer_functions\\09_21_2016_14_40_32_no_004_cal_thru.txt', skiprows=1)
#        data_lowfreq = np.loadtxt(u'transfer_functions\\09_21_2016_14_44_34_no_006_cal_thru.txt', skiprows=1)
#        
        data_highfreq = np.loadtxt(u'transfer_functions\\04_28_2017_16_11_37_no_000_cal_thru_high.txt', skiprows=1)
        data_lowfreq = np.loadtxt(u'transfer_functions\\04_28_2017_16_11_00_no_000_cal_thru_low.txt', skiprows=1)
        
        # convert the data to complex and merge the two sets:
        use_lowfreq = (data_lowfreq[:, 0] < 300e3)
        use_highfreq = (data_highfreq[:, 0] >= 300e3)
        freq_all = np.concatenate((data_lowfreq[use_lowfreq, 0], data_highfreq[use_highfreq, 0]))
        values_all_real = np.concatenate( (
                             data_lowfreq[use_lowfreq , 1],
                            data_highfreq[use_highfreq, 1]
                            ))
        values_all_imag = np.concatenate( (
                            data_lowfreq[use_lowfreq , 2],
                            data_highfreq[use_highfreq, 2]
                            ))
        # interpolate the calibration data to desired frequencies:
        values_interpolated_real = np.interp(frequency_axis, freq_all, values_all_real)
        values_interpolated_imag = np.interp(frequency_axis, freq_all, values_all_imag)
        values_interpolated_complex = values_interpolated_real + 1j*values_interpolated_imag
        # apply calibration, the 0.5 is because the target value for the calibration dataset was an overall transfer function of 50 ohms/(50 ohms+50ohms) = 0.5
        return transfer_function * 0.5/values_interpolated_complex
        
    def writeOutputFile(self, transfer_function, frequency_axis, vertical_units, bCalibrated=False):
        
        
        # Create the subdirectory if it doesn't exist:
        self.make_sure_path_exists('transfer_functions')

        # Open file for output
        self.strNameTemplate = time.strftime("transfer_functions\%m_%d_%Y_%H_%M_%S")
        if bCalibrated:
            strCurrentName1 = self.strNameTemplate + ('_no_%03d_with_cal.txt' % (self.window_number))
        else:
            strCurrentName1 = self.strNameTemplate + ('_no_%03d.txt' % (self.window_number))
        
        
        DAT = np.array([frequency_axis, np.real(transfer_function), np.imag(transfer_function)])
        with open(strCurrentName1, 'w') as f_handle:
            # Write header for the file:
            f_handle.write('Frequency [Hz]\tReal_part [%s]\tImag_part [%s]\n' % (vertical_units, vertical_units))
            # write actual data:
            np.savetxt(f_handle,np.column_stack(DAT), delimiter='\t')
        
#        f_handle = open(strCurrentName1, 'w')
#        np.savetxt(f_handle,np.column_stack(DAT))
#        f_handle.close()
            
    def closeEvent(self, event):
        self.bClosed = True
        event.accept()

    def initUI(self):

        # Add a first QwtPlot to the UI:
        self.qplt_mag = Qwt.QwtPlot()
        self.qplt_mag.setTitle('Magnitude response')
        self.qplt_mag.setCanvasBackground(Qt.Qt.white)
        self.qplt_mag.setAxisScaleEngine(Qwt.QwtPlot.xBottom, Qwt.QwtLog10ScaleEngine())
        
        plot_grid = Qwt.QwtPlotGrid()
        plot_grid.setMajPen(Qt.QPen(Qt.Qt.black, 0, Qt.Qt.DotLine))
        plot_grid.attach(self.qplt_mag)
        
        self.colors_order = [
[  0.0000e+000,   114.0000e+000,   189.0000e+000],
[217.0000e+000,    83.0000e+000,    25.0000e+000],
[237.0000e+000,   177.0000e+000,    32.0000e+000],
[126.0000e+000,    47.0000e+000,   142.0000e+000],
[119.0000e+000,   172.0000e+000,    48.0000e+000],
[ 77.0000e+000,   190.0000e+000,   238.0000e+000],
[162.0000e+000,    20.0000e+000,    47.0000e+000],]
        
        # Add a second QwtPlot to the UI:
        
        self.qplt_phase = Qwt.QwtPlot()
        self.qplt_phase.setTitle('Phase response')
        self.qplt_phase.setCanvasBackground(Qt.Qt.white)
        self.qplt_phase.setAxisScaleEngine(Qwt.QwtPlot.xBottom, Qwt.QwtLog10ScaleEngine())
        
        plot_grid = Qwt.QwtPlotGrid()
        plot_grid.setMajPen(Qt.QPen(Qt.Qt.black, 0, Qt.Qt.DotLine))
        plot_grid.attach(self.qplt_phase)
        
        # create the lists to hold the curve objects as they get added to the plots:
        self.curve_mag_list = []
        self.curve_phase_list = []
        
        
        ######################################################################
        # Controls to adjust the model
        ######################################################################
        
        # Units select
        units_label = Qt.QLabel('Units:')
        self.qcombo_units = Qt.QComboBox()
        self.qcombo_units.addItems(['dB', 'Linear', 'real part', 'imag part', 'Ohms, 50*Vin/Vout', 'Ohms, shunt DUT, 50 ohms probe', 'Ohms, Shunt DUT, high-Z probe + Series source impedance'])
        self.qcombo_units.setCurrentIndex(0)
#        self.qcombo_units.changeEvent.connect(self.updateGraph)
        self.qcombo_units.currentIndexChanged.connect(self.updateGraph)
        
        self.qlabel_SeriesImpedance = Qt.QLabel('Series Impedance [Ohms]:')
        self.qedit_SeriesImpedance = Qt.QLineEdit('100e3')
        self.qedit_SeriesImpedance.editingFinished.connect(self.updateGraph)
        
        self.qchk_display_model = Qt.QCheckBox('Display model')
        self.qchk_display_model.setChecked(False)
        
        self.qchk_DDCFilter = Qt.QCheckBox('DDC sinc filter')
        self.qchk_DDCFilter.clicked.connect(self.updateGraph)
        
        self.qradio_signp = Qt.QRadioButton('+ Sign')
        self.qradio_signp.setChecked(True)
        self.qradio_signn = Qt.QRadioButton('- Sign')
        button_group = Qt.QButtonGroup()
        button_group.addButton(self.qradio_signp)
        button_group.addButton(self.qradio_signn)
        
        self.qradio_signp.clicked.connect(self.updateGraph)
        self.qradio_signn.clicked.connect(self.updateGraph)
        
        # set the default DC gain to the value of the transfer function at the lowest frequency:
        
        self.qlabel_k = Qt.QLabel('DC Gain [dB]')
        self.qedit_k = Qt.QLineEdit(str(0))
        self.qedit_k.setMaximumWidth(60)
        self.qedit_k.textChanged.connect(self.updateGraph)
        
        
        self.qlabel_f1 = Qt.QLabel('1st order poles')
        self.qedit_f1 = Qt.QLineEdit('20e3,600e3')
        self.qedit_f1.setMaximumWidth(120)
        self.qedit_f1.textChanged.connect(self.updateGraph)
        
        
        

        
        self.qlabel_f0 = Qt.QLabel('2nd order poles')
        self.qedit_f0 = Qt.QLineEdit('1.5e6')
        self.qedit_f0.setMaximumWidth(120)
        self.qedit_f0.textChanged.connect(self.updateGraph)
        
        self.qlabel_zeta = Qt.QLabel('zeta')
        self.qedit_zeta = Qt.QLineEdit('0.1')
        self.qedit_zeta.setMaximumWidth(120)
        self.qedit_zeta.textChanged.connect(self.updateGraph)
        
        self.qlabel_T = Qt.QLabel('Pure delay')
        self.qedit_T = Qt.QLineEdit('570e-9')
        self.qedit_T.setMaximumWidth(60)
        self.qedit_T.textChanged.connect(self.updateGraph)
        
        
        
        self.qchk_controller = Qt.QCheckBox('Closed-loop prediction')
        self.qchk_controller.clicked.connect(self.updateGraph)
        
        
        self.qlabel_pgain = Qt.QLabel('P gain [dB]')
        self.qedit_pgain = Qt.QLineEdit('-100')
        self.qedit_pgain.setMaximumWidth(60)
        self.qedit_pgain.textChanged.connect(self.updateGraph)
        
        self.qlabel_icorner = Qt.QLabel('I corner [Hz]')
        self.qedit_icorner = Qt.QLineEdit('0')
        self.qedit_icorner.setMaximumWidth(60)
        self.qedit_icorner.textChanged.connect(self.updateGraph)
        
        
        
        self.qedit_comment = Qt.QTextEdit('')
#        self.qedit_comment.setMaximumWidth(80)
        #self.qedit_comment.textChanged.connect(self.updateGraph)



        # Put all the widgets into a grid layout
        grid = Qt.QGridLayout()
        

        grid.addWidget(units_label, 0, 0)
        grid.addWidget(self.qcombo_units, 0, 1)
        
        grid.addWidget(self.qlabel_SeriesImpedance, 1, 0)
        grid.addWidget(self.qedit_SeriesImpedance , 1, 1)
        
        
        grid.addWidget(self.qchk_display_model    , 2, 1)
        
        
        grid.addWidget(self.qradio_signp          , 3, 0)
        grid.addWidget(self.qradio_signn          , 3, 1)
        
        grid.addWidget(self.qlabel_k              , 4, 0)
        grid.addWidget(self.qedit_k               , 4, 1)
        grid.addWidget(self.qlabel_f1             , 5, 0)
        grid.addWidget(self.qedit_f1              , 5, 1)
        grid.addWidget(self.qlabel_f0             , 6, 0)
        grid.addWidget(self.qedit_f0              , 6, 1)

        grid.addWidget(self.qlabel_zeta           , 7, 0)
        grid.addWidget(self.qedit_zeta            , 7, 1)
        
        grid.addWidget(self.qlabel_T              , 8, 0)
        grid.addWidget(self.qedit_T               , 8, 1)
        
        grid.addWidget(self.qchk_controller       , 9, 0, 1, 2)        
        
        grid.addWidget(self.qlabel_pgain          , 10, 0)
        grid.addWidget(self.qedit_pgain           , 10, 1)
        
        grid.addWidget(self.qlabel_icorner        , 12, 0)
        grid.addWidget(self.qedit_icorner         , 12, 1)
        grid.addWidget(self.qchk_DDCFilter        , 13, 0, 1, 2)
        
        grid.addWidget(self.qedit_comment         , 14, 0, 1, 2)
        grid.setRowStretch(15, 0)
#        grid.addWidget(Qt.QLabel(''), 12, 0, 1, 2)
#        grid.setRowStretch(14, 1)

        vbox = Qt.QVBoxLayout()
        vbox.addWidget(self.qplt_mag)
        vbox.addWidget(self.qplt_phase)
        
        
        hbox = Qt.QHBoxLayout()
        hbox.addLayout(grid)
        hbox.addLayout(vbox, 1)
#        hbox.setStretch(2, 1)
        
        self.setLayout(hbox)

        # Adjust the size and position of the window
        self.resize(1200, 500)
        self.center()
        self.setWindowTitle('Transfer function #%d' % self.window_number)    
        self.show()
        
    def center(self):
        
        qr = self.frameGeometry()
        cp = QtGui.QDesktopWidget().availableGeometry().center()
#        print()
#        5435sdfsf
        qr.moveCenter(cp)
        self.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(800+100, 50))
        
    def timerEvent(self, e):
        
#        print('timerEvent, timerID = %d' % self.timerID)
        self.displayFreqCounter()
        
        return
        
    def updateGraph(self):

        if self.qcombo_units.currentIndex() == 0:
            bGraphIndBs = True
        else:
            bGraphIndBs = False
        # System sign:
        if self.qradio_signp.isChecked():
            sign = 1
        else:
            sign = -1

        # add looping over many curves...
        print "updateGraph: %d curves in list." % (len(self.curve_mag_list))
        for kCurve in range(len(self.curve_mag_list)):
            print "updateGraph: curve %d of %d." % (kCurve, len(self.curve_mag_list))
            


            self.curve_phase_list[kCurve].setData(self.frequency_axis_list[kCurve], np.angle(sign*(self.transfer_function_list[kCurve])))  # phase graph is usually just the phase of the transfer function, except for a few scalings
            
            if bGraphIndBs == True:
                self.curve_mag_list[kCurve].setData(self.frequency_axis_list[kCurve], 20*np.log10(np.abs(self.transfer_function_list[kCurve])))
                self.qplt_mag.setAxisTitle(Qwt.QwtPlot.yLeft, 'dB[(%s)^2]' % self.vertical_units_list[kCurve])
                self.qplt_mag.setAxisScaleEngine(Qwt.QwtPlot.yLeft, Qwt.QwtLinearScaleEngine())
            else:
                if self.qcombo_units.currentIndex() == 2:
                    # Linear real part
                    self.curve_mag_list[kCurve].setData(self.frequency_axis_list[kCurve], (np.real(self.transfer_function_list[kCurve])))
                    self.qplt_mag.setAxisTitle(Qwt.QwtPlot.yLeft, '%s' % self.vertical_units_list[kCurve])
                    self.qplt_mag.setAxisScaleEngine(Qwt.QwtPlot.yLeft, Qwt.QwtLinearScaleEngine())
                elif self.qcombo_units.currentIndex() == 3:
                    # Linear imag part
                    self.curve_mag_list[kCurve].setData(self.frequency_axis_list[kCurve], (np.imag(self.transfer_function_list[kCurve])))
                    self.qplt_mag.setAxisTitle(Qwt.QwtPlot.yLeft, '%s' % self.vertical_units_list[kCurve])
                    self.qplt_mag.setAxisScaleEngine(Qwt.QwtPlot.yLeft, Qwt.QwtLinearScaleEngine())
                elif self.qcombo_units.currentIndex() == 1:
                    # linear magnitude and phase
                    self.curve_mag_list[kCurve].setData(self.frequency_axis_list[kCurve], (np.abs(self.transfer_function_list[kCurve])))
                    self.qplt_mag.setAxisTitle(Qwt.QwtPlot.yLeft, '%s' % self.vertical_units_list[kCurve])
                    self.qplt_mag.setAxisScaleEngine(Qwt.QwtPlot.yLeft, Qwt.QwtLinearScaleEngine())
                elif self.qcombo_units.currentIndex() == 4:
                    # 'Ohms, 50*Vin/Vout'
                    Zsource = 50
                    test_impedance = (Zsource/(self.transfer_function_list[kCurve]))
                    self.curve_mag_list[kCurve].setData(self.frequency_axis_list[kCurve], np.abs(test_impedance))
                    self.qplt_mag.setAxisTitle(Qwt.QwtPlot.yLeft, 'Ohms')
                    self.qplt_mag.setAxisScaleEngine(Qwt.QwtPlot.yLeft, Qwt.QwtLog10ScaleEngine())
                    self.curve_phase_list[kCurve].setData(self.frequency_axis_list[kCurve], np.angle(-sign*(test_impedance)))
                elif self.qcombo_units.currentIndex() == 5:
                    # 'Ohms, shunt DUT'])
                    Zsource = 50.
                    Zinput = 50.
                    load_impedance = (Zsource*(self.transfer_function_list[kCurve]/(1-self.transfer_function_list[kCurve])))
                    # load impedance consists of the impedance that we want to measure in parallel with 50 ohms so we need to invert this too
                    load_admittance = 1/load_impedance
                    unknown_admittance = load_admittance-1/Zinput
                    unknown_impedance = 1/unknown_admittance
                    print load_admittance[0]
                    print load_impedance[0]
                    print unknown_admittance[0]
                    print unknown_impedance[0]
                    self.curve_mag_list[kCurve].setData(self.frequency_axis_list[kCurve], np.abs(unknown_impedance))
                    self.qplt_mag.setAxisTitle(Qwt.QwtPlot.yLeft, 'Ohms')
                    self.qplt_mag.setAxisScaleEngine(Qwt.QwtPlot.yLeft, Qwt.QwtLog10ScaleEngine())
                    self.curve_phase_list[kCurve].setData(self.frequency_axis_list[kCurve], np.angle(sign*(unknown_impedance)))
                    
                    print kCurve
                    print len(self.curve_mag_list)-1
                    if kCurve == len(self.curve_mag_list)-1:
                        strNotes = ''
                        for kFreq in range(len(self.frequency_axis_list[kCurve])):
                            strNotes += '%.2e Hz: Z = %.2e + j*%.2e\n' % (self.frequency_axis_list[kCurve][kFreq], np.real(unknown_impedance[kFreq]), np.imag(unknown_impedance[kFreq]))
                        self.qedit_comment.setText(strNotes)
                        print strNotes
                        
                elif self.qcombo_units.currentIndex() == 6:
                    # 'Ohms, Shunt DUT, high-Z probe + Series source impedance'
                    try:
                        Zsource = float(self.qedit_SeriesImpedance.text())
                    except:
                        Zsource = 100e3+50.
                        pass
                    
    #                load_impedance = (Zsource*(10.*self.transfer_function_list[kCurve]/(1-10.*self.transfer_function_list[kCurve])))
                    load_impedance = (-Zsource*(10.*self.transfer_function_list[kCurve]/(10.*self.transfer_function_list[kCurve]-1.)))
                    self.curve_mag_list[kCurve].setData(self.frequency_axis_list[kCurve], np.abs(load_impedance))
                    self.qplt_mag.setAxisTitle(Qwt.QwtPlot.yLeft, 'Ohms')
                    
                    self.qplt_mag.setAxisScaleEngine(Qwt.QwtPlot.yLeft, Qwt.QwtLog10ScaleEngine())
                    self.curve_phase_list[kCurve].setData(self.frequency_axis_list[kCurve], np.angle(sign*(load_impedance)))
                    
                    if kCurve == len(self.curve_mag_list)-1:
                        strNotes = ''
                        for kFreq in range(len(self.frequency_axis_list[kCurve])):
                            strNotes += '%.2e Hz: Z = %.2e + j*%.2e\n' % (self.frequency_axis_list[kCurve][kFreq], np.real(load_impedance[kFreq]), np.imag(load_impedance[kFreq]))
                        self.qedit_comment.setText(strNotes)
                
            print "update curve complete."

        self.qplt_phase.setAxisTitle(Qwt.QwtPlot.yLeft, 'Phase [rad]')
        self.qplt_mag.replot()
        self.qplt_phase.replot()
        
    # From: http://stackoverflow.com/questions/273192/create-directory-if-it-doesnt-exist-for-file-write
    def make_sure_path_exists(self, path):
        try:
            os.makedirs(path)
        except OSError as exception:
            if exception.errno != errno.EEXIST:
                raise
                
