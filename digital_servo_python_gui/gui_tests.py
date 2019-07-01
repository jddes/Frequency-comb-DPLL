# -*- coding: utf-8 -*-
"""
Phase-lock box main GUI script,
by JD Deschenes, October 2013
---
-- Ported to Red Pitaya platform - JDD 2017

"""
from __future__ import print_function
import sys
from PyQt5 import QtGui, Qt, QtCore, QtWidgets
import numpy as np


from SLLSystemParameters import SLLSystemParameters
from SuperLaserLand_mock import SuperLaserLand_mock
from XEM_GUI_MainWindow import XEM_GUI_MainWindow


import time
import pdb


#sys._excepthook = sys.excepthook
#def exception_hook(exctype, value, traceback):
#   print("exception_hook(): type = %s, value = %s" % (exctype, value))
#   
#   sys._excepthook(exctype, value, traceback)
#   sys.exit(1)
#sys.excepthook = exception_hook


class PlotWindowIntercept():
    # intercept the 'outputs' of various functions for testing
    def __init__(self, obj_to_replace):
        self.obj = obj_to_replace
        self.bVisible = -1
        pass
    def setData(self, x, y):
        self.x = x
        self.y = y
        self.obj.setData(x, y)

    def setVisible(self, bVisible):
        self.bVisible = bVisible
        self.obj.setVisible(bVisible)

class PlotWidgetIntercept():
    # intercept the 'outputs' of various functions for testing
    def __init__(self, obj_to_replace):
        self.obj = obj_to_replace
        self.bReplotCalls = 0
        self.xmin_val = -1
        self.xmax_val = -1
        self.ymin_val = -1
        self.ymax_val = -1
        pass
    def setXRange(self, min_val, max_val):
        self.xmin_val = min_val
        self.xmax_val = max_val
        self.obj.setXRange(min_val, max_val)
    def setYRange(self, min_val, max_val):
        self.ymin_val = min_val
        self.ymax_val = max_val
        self.obj.setYRange(min_val, max_val)

    def replot(self):
        self.bReplotCalls += 1
        self.obj.replot()

    def setTitle(self, strTitle):
        self.strTitle = strTitle
        self.obj.setTitle(strTitle)


def test_displayADC(sl, gui_mainwindow, bPrintAllOutputState=False):

    # shorthand:
    g = gui_mainwindow

    # set GUI-based inputs:
    g.qedit_rawdata_length.setText("100") # only use 100 pts so that the outputs are easier to check
    # Possible values: 'Spectrum', 'Time: raw input', 'Time: Phase', 'Time: IQ', 'Time: IQ, synced'
    g.qcombo_adc_plottype.setCurrentIndex(g.qcombo_adc_plottype.findText('Spectrum'))
    # possible values: 'ADC 0', 'ADC 1', 'DAC 0', 'DAC 1', 'DAC 2'
    g.qcombo_adc_plot.setCurrentIndex(g.qcombo_adc_plot.findText('ADC 0'))
    # possible values: 'Freq', 'Phase', 'Freq: time domain', 'Phase: time domain'
    g.qcombo_ddc_plot.setCurrentIndex(g.qcombo_ddc_plot.findText('Phase'))
    g.bDisplayTiming = False

    # replace the PyQtGraph objects that are acted on with our interceptors so that we can verify the correct outputs without requiring knowledge of the internal structure of the objects in PyQtGraph:
    g.curve_spc                      = PlotWindowIntercept(g.curve_spc)
    g.curve_filter                   = PlotWindowIntercept(g.curve_filter)
    g.curve_DDC0_spc_amplitude_noise = PlotWindowIntercept(g.curve_DDC0_spc_amplitude_noise)
    g.curve_IQ                       = PlotWindowIntercept(g.curve_IQ)
    g.qplt_IQ = PlotWidgetIntercept(g.qplt_IQ)
    g.plt_spc = PlotWidgetIntercept(g.plt_spc)

    g.displayADC()

    # this is used to determine what the "true" outputs should be
    if bPrintAllOutputState:
        print("g.filtered_baseband_snr = %f" % g.filtered_baseband_snr)

        # GUI-based outputs:
        print("g.qadc0_scale.value = %f" % g.qadc0_scale.value)
        print("g.qthermo_baseband_snr.value = %f" % g.qthermo_baseband_snr.value)
        print("g.qthermo_baseband_snr.value = %f" % g.qthermo_baseband_snr.value)

        print("g.qlabel_adc_fill_value.text() = %s" % g.qlabel_adc_fill_value.text())
        print("g.qlabel_rawdata_rbw.text() = %s" % g.qlabel_rawdata_rbw.text())
        print("g.qlabel_baseband_snr_value.text() = %s" % g.qlabel_baseband_snr_value.text())

        # "outputs" that were really calls to the plotting library (that we intercepted):
        print("g.qplt_IQ.xmin_val = %f" % g.qplt_IQ.xmin_val)
        print("g.qplt_IQ.xmax_val = %f" % g.qplt_IQ.xmax_val)
        print("g.qplt_IQ.ymin_val = %f" % g.qplt_IQ.ymin_val)
        print("g.qplt_IQ.ymax_val = %f" % g.qplt_IQ.ymax_val)
        print("g.qplt_IQ.bReplotCalls = %d" % g.qplt_IQ.bReplotCalls)

        print("g.plt_spc.xmin_val = %f" % g.plt_spc.xmin_val)
        print("g.plt_spc.xmax_val = %f" % g.plt_spc.xmax_val)
        print("g.plt_spc.ymin_val = %f" % g.plt_spc.ymin_val)
        print("g.plt_spc.ymax_val = %f" % g.plt_spc.ymax_val)
        print("g.plt_spc.bReplotCalls = %d" % g.plt_spc.bReplotCalls)
        print("g.plt_spc.strTitle = %s" % g.plt_spc.strTitle)

        decimals = 5
        print("g.curve_spc.x = %s" % np.round(g.curve_spc.x, decimals=decimals).tolist())
        print("g.curve_filter.x = %s" % np.round(g.curve_filter.x, decimals=decimals).tolist())
        print("g.curve_DDC0_spc_amplitude_noise.x = %s" % np.round(g.curve_DDC0_spc_amplitude_noise.x, decimals=decimals).tolist())
        print("g.curve_IQ.x = %s" % np.round(g.curve_IQ.x, decimals=decimals).tolist())

        print("g.curve_spc.y = %s" % np.round(g.curve_spc.y, decimals=decimals).tolist())
        print("g.curve_filter.y = %s" % np.round(g.curve_filter.y, decimals=decimals).tolist())
        print("g.curve_DDC0_spc_amplitude_noise.y = %s" % np.round(g.curve_DDC0_spc_amplitude_noise.y, decimals=decimals).tolist())
        print("g.curve_IQ.y = %s" % np.round(g.curve_IQ.y, decimals=decimals).tolist())

        print("g.curve_spc.bVisible = %d" % g.curve_spc.bVisible)
        print("g.curve_filter.bVisible = %d" % g.curve_filter.bVisible)
        print("g.curve_DDC0_spc_amplitude_noise.bVisible = %d" % g.curve_DDC0_spc_amplitude_noise.bVisible)
        print("g.curve_IQ.bVisible = %d" % g.curve_IQ.bVisible)

        # internal state output variables
        print("raw_adc_samples = %s" % repr(g.raw_adc_samples.tolist()))

        

    # Check the outputs against the expected:
    check_displayADC_outputs(g)

    
# finds the value of a field in a string, delimited between strStartToken and strStopToken
# Example: strInput = "some field = whatever\nsome other field = nothing"
# strStartToken = "some field", strStopToken = "\n"
# output: "whatever"
def find_field(strInput, strStartToken, strStopToken="\n"):
    field_start_ind = strInput.find(strStartToken)
    field_stop_ind = strInput.find(strStopToken, field_start_ind + 1)
    if field_stop_ind == -1:
        # end token not found: we output the value until the end of string
        field_stop_ind = len(strInput)
    result = strInput[field_start_ind+len(strStartToken):field_stop_ind]

    return result

def check_displayADC_outputs(g):
    bPass = True
    strFailedFields = ''

    outputs = """g.filtered_baseband_snr = 4.090108
g.qadc0_scale.value = 11.705200
g.qthermo_baseband_snr.value = 42.980217
g.qthermo_baseband_snr.value = 42.980217
g.qlabel_adc_fill_value.text() = 11.7 bits
g.qlabel_rawdata_rbw.text() = RBW: 2.2 MHz; Points:
g.qlabel_baseband_snr_value.text() = 4.09 dB
g.qplt_IQ.xmin_val = -0.068774
g.qplt_IQ.xmax_val = 0.068774
g.qplt_IQ.ymin_val = -0.068774
g.qplt_IQ.ymax_val = 0.068774
g.plt_spc.xmin_val = -1.000000
g.plt_spc.xmax_val = -1.000000
g.plt_spc.ymin_val = -1.000000
g.plt_spc.ymax_val = -1.000000
g.plt_spc.strTitle = Spectrum, noise floor = 130 nV/sqrt(Hz)"""



    float_close_enough = lambda x, y : bool(np.abs(float(x)-float(y)) < 1e-6)

    # Check float outputs:
    if not float_close_enough(g.filtered_baseband_snr, find_field(outputs, "g.filtered_baseband_snr = ")):
        bPass = False
        strFailedFields += 'g.filtered_baseband_snr, '
    if not float_close_enough(g.qadc0_scale.value, find_field(outputs, "g.qadc0_scale.value = ")):
        bPass = False
        strFailedFields += "g.qadc0_scale.value, "
    if not float_close_enough(g.qthermo_baseband_snr.value, find_field(outputs, "g.qthermo_baseband_snr.value = ")):
        bPass = False
        strFailedFields += "g.qthermo_baseband_snr.value, "
    if not float_close_enough(g.qthermo_baseband_snr.value, find_field(outputs, "g.qthermo_baseband_snr.value = ")):
        bPass = False
        strFailedFields += "g.qthermo_baseband_snr.value, "
    if not float_close_enough(g.qplt_IQ.xmin_val, find_field(outputs, "g.qplt_IQ.xmin_val = ")):
        bPass = False
        strFailedFields += "g.qplt_IQ.xmin_val, "
    if not float_close_enough(g.qplt_IQ.xmax_val, find_field(outputs, "g.qplt_IQ.xmax_val = ")):
        bPass = False
        strFailedFields += "g.qplt_IQ.xmax_val, "
    if not float_close_enough(g.qplt_IQ.ymin_val, find_field(outputs, "g.qplt_IQ.ymin_val = ")):
        bPass = False
        strFailedFields += "g.qplt_IQ.ymin_val, "
    if not float_close_enough(g.qplt_IQ.ymax_val, find_field(outputs, "g.qplt_IQ.ymax_val = ")):
        bPass = False
        strFailedFields += "g.qplt_IQ.ymax_val, "
    if not float_close_enough(g.plt_spc.xmin_val, find_field(outputs, "g.plt_spc.xmin_val = ")):
        bPass = False
        strFailedFields += "g.plt_spc.xmin_val, "
    if not float_close_enough(g.plt_spc.xmax_val, find_field(outputs, "g.plt_spc.xmax_val = ")):
        bPass = False
        strFailedFields += "g.plt_spc.xmax_val, "
    if not float_close_enough(g.plt_spc.ymin_val, find_field(outputs, "g.plt_spc.ymin_val = ")):
        bPass = False
        strFailedFields += "g.plt_spc.ymin_val, "
    if not float_close_enough(g.plt_spc.ymax_val, find_field(outputs, "g.plt_spc.ymax_val = ")):
        bPass = False
        strFailedFields += "g.plt_spc.ymax_val, "

    # Compare string outputs:
    if g.qlabel_adc_fill_value.text() != find_field(outputs, "g.qlabel_adc_fill_value.text() = "):
        bPass = False
        strFailedFields += "g.qlabel_adc_fill_value.text(), "
    if g.qlabel_rawdata_rbw.text() != find_field(outputs, "g.qlabel_rawdata_rbw.text() = "):
        bPass = False
        strFailedFields += "g.qlabel_rawdata_rbw.text(), "
    if g.qlabel_baseband_snr_value.text() != find_field(outputs, "g.qlabel_baseband_snr_value.text() = "):
        bPass = False
        strFailedFields += "g.qlabel_baseband_snr_value.text(), "
    if g.plt_spc.strTitle != find_field(outputs, "g.plt_spc.strTitle = "):
        bPass = False
        strFailedFields += "g.plt_spc.strTitle, "

    array_close_enough = lambda x, y: np.max(np.abs(x - y)) < 1e-3


    if not array_close_enough(g.raw_adc_samples, np.array([3335.0, 1026.0, -2619.0, -2578.0, 1074.0, 3245.0, 1044.0, -2656.0, -2654.0, 1026.0, 3282.0, 1060.0, -2626.0, -2647.0, 1027.0, 3288.0, 1062.0, -2658.0, -2641.0, 985.0, 3193.0, 1034.0, -2623.0, -2675.0, 1087.0, 3229.0, 1014.0, -2657.0, -2601.0, 1061.0, 3282.0, 1025.0, -2680.0, -2716.0, 1001.0, 3282.0, 1053.0, -2612.0, -2664.0, 1003.0, 3242.0, 966.0, -2707.0, -2587.0, 996.0, 3262.0, 972.0, -2626.0, -2704.0, 1006.0, 3247.0, 1025.0, -2668.0, -2690.0, 1012.0, 3291.0, 1015.0, -2641.0, -2672.0, 1001.0, 3255.0, 1001.0, -2678.0, -2708.0, 1018.0, 3264.0, 959.0, -2636.0, -2681.0, 1014.0, 3301.0, 1017.0, -2614.0, -2691.0, 1026.0, 3254.0, 984.0, -2670.0, -2661.0, 1014.0, 3239.0, 1042.0, -2636.0, -2701.0, 1061.0, 3339.0, 1051.0, -2657.0, -2686.0, 1047.0, 3264.0, 1053.0, -2644.0, -2619.0, 1024.0, 3300.0, 1013.0, -2592.0, -2647.0, 1026.0])):
        bPass = False
        strFailedFields += 'raw_adc_samples, '

    if not array_close_enough(g.raw_adc_samples, np.array([3335.0, 1026.0, -2619.0, -2578.0, 1074.0, 3245.0, 1044.0, -2656.0, -2654.0, 1026.0, 3282.0, 1060.0, -2626.0, -2647.0, 1027.0, 3288.0, 1062.0, -2658.0, -2641.0, 985.0, 3193.0, 1034.0, -2623.0, -2675.0, 1087.0, 3229.0, 1014.0, -2657.0, -2601.0, 1061.0, 3282.0, 1025.0, -2680.0, -2716.0, 1001.0, 3282.0, 1053.0, -2612.0, -2664.0, 1003.0, 3242.0, 966.0, -2707.0, -2587.0, 996.0, 3262.0, 972.0, -2626.0, -2704.0, 1006.0, 3247.0, 1025.0, -2668.0, -2690.0, 1012.0, 3291.0, 1015.0, -2641.0, -2672.0, 1001.0, 3255.0, 1001.0, -2678.0, -2708.0, 1018.0, 3264.0, 959.0, -2636.0, -2681.0, 1014.0, 3301.0, 1017.0, -2614.0, -2691.0, 1026.0, 3254.0, 984.0, -2670.0, -2661.0, 1014.0, 3239.0, 1042.0, -2636.0, -2701.0, 1061.0, 3339.0, 1051.0, -2657.0, -2686.0, 1047.0, 3264.0, 1053.0, -2644.0, -2619.0, 1024.0, 3300.0, 1013.0, -2592.0, -2647.0, 1026.0])):
        bPass = False
        strFailedFields += 'raw_adc_samples, '

    if not array_close_enough(g.raw_adc_samples, np.array([3335.0, 1026.0, -2619.0, -2578.0, 1074.0, 3245.0, 1044.0, -2656.0, -2654.0, 1026.0, 3282.0, 1060.0, -2626.0, -2647.0, 1027.0, 3288.0, 1062.0, -2658.0, -2641.0, 985.0, 3193.0, 1034.0, -2623.0, -2675.0, 1087.0, 3229.0, 1014.0, -2657.0, -2601.0, 1061.0, 3282.0, 1025.0, -2680.0, -2716.0, 1001.0, 3282.0, 1053.0, -2612.0, -2664.0, 1003.0, 3242.0, 966.0, -2707.0, -2587.0, 996.0, 3262.0, 972.0, -2626.0, -2704.0, 1006.0, 3247.0, 1025.0, -2668.0, -2690.0, 1012.0, 3291.0, 1015.0, -2641.0, -2672.0, 1001.0, 3255.0, 1001.0, -2678.0, -2708.0, 1018.0, 3264.0, 959.0, -2636.0, -2681.0, 1014.0, 3301.0, 1017.0, -2614.0, -2691.0, 1026.0, 3254.0, 984.0, -2670.0, -2661.0, 1014.0, 3239.0, 1042.0, -2636.0, -2701.0, 1061.0, 3339.0, 1051.0, -2657.0, -2686.0, 1047.0, 3264.0, 1053.0, -2644.0, -2619.0, 1024.0, 3300.0, 1013.0, -2592.0, -2647.0, 1026.0])):
        bPass = False
        strFailedFields += 'raw_adc_samples, '

    if not array_close_enough(g.raw_adc_samples, np.array([3335.0, 1026.0, -2619.0, -2578.0, 1074.0, 3245.0, 1044.0, -2656.0, -2654.0, 1026.0, 3282.0, 1060.0, -2626.0, -2647.0, 1027.0, 3288.0, 1062.0, -2658.0, -2641.0, 985.0, 3193.0, 1034.0, -2623.0, -2675.0, 1087.0, 3229.0, 1014.0, -2657.0, -2601.0, 1061.0, 3282.0, 1025.0, -2680.0, -2716.0, 1001.0, 3282.0, 1053.0, -2612.0, -2664.0, 1003.0, 3242.0, 966.0, -2707.0, -2587.0, 996.0, 3262.0, 972.0, -2626.0, -2704.0, 1006.0, 3247.0, 1025.0, -2668.0, -2690.0, 1012.0, 3291.0, 1015.0, -2641.0, -2672.0, 1001.0, 3255.0, 1001.0, -2678.0, -2708.0, 1018.0, 3264.0, 959.0, -2636.0, -2681.0, 1014.0, 3301.0, 1017.0, -2614.0, -2691.0, 1026.0, 3254.0, 984.0, -2670.0, -2661.0, 1014.0, 3239.0, 1042.0, -2636.0, -2701.0, 1061.0, 3339.0, 1051.0, -2657.0, -2686.0, 1047.0, 3264.0, 1053.0, -2644.0, -2619.0, 1024.0, 3300.0, 1013.0, -2592.0, -2647.0, 1026.0])):
        bPass = False
        strFailedFields += 'raw_adc_samples, '


    if not array_close_enough(g.curve_spc.x, np.array([0.0, 0.97656, 1.95312, 2.92969, 3.90625, 4.88281, 5.85938, 6.83594, 7.8125, 8.78906, 9.76562, 10.74219, 11.71875, 12.69531, 13.67188, 14.64844, 15.625, 16.60156, 17.57812, 18.55469, 19.53125, 20.50781, 21.48438, 22.46094, 23.4375, 24.41406, 25.39062, 26.36719, 27.34375, 28.32031, 29.29688, 30.27344, 31.25, 32.22656, 33.20312, 34.17969, 35.15625, 36.13281, 37.10938, 38.08594, 39.0625, 40.03906, 41.01562, 41.99219, 42.96875, 43.94531, 44.92188, 45.89844, 46.875, 47.85156, 48.82812, 49.80469, 50.78125, 51.75781, 52.73438, 53.71094, 54.6875, 55.66406, 56.64062, 57.61719, 58.59375, 59.57031, 60.54688, 61.52344])):
        bPass = False
        strFailedFields += 'g.curve_spc.x, '
    if not array_close_enough(g.curve_filter.x, np.array([0.0, 0.97656, 1.95312, 2.92969, 3.90625, 4.88281, 5.85938, 6.83594, 7.8125, 8.78906, 9.76562, 10.74219, 11.71875, 12.69531, 13.67188, 14.64844, 15.625, 16.60156, 17.57812, 18.55469, 19.53125, 20.50781, 21.48438, 22.46094, 23.4375, 24.41406, 25.39062, 26.36719, 27.34375, 28.32031, 29.29688, 30.27344, 31.25, 32.22656, 33.20312, 34.17969, 35.15625, 36.13281, 37.10938, 38.08594, 39.0625, 40.03906, 41.01562, 41.99219, 42.96875, 43.94531, 44.92188, 45.89844, 46.875, 47.85156, 48.82812, 49.80469, 50.78125, 51.75781, 52.73438, 53.71094, 54.6875, 55.66406, 56.64062, 57.61719, 58.59375, 59.57031, 60.54688, 61.52344])):
        bPass = False
        strFailedFields += 'g.curve_filter.x, '
    if not array_close_enough(g.curve_DDC0_spc_amplitude_noise.x, np.array([781250.0, 1562500.0, 2343750.0, 3125000.0, 3906250.0, 4687500.0, 5468750.0])):
        bPass = False
        strFailedFields += 'g.curve_DDC0_spc_amplitude_noise.x, '
    if not array_close_enough(g.curve_IQ.x, np.array([-0.02084, -0.00677, 0.00726, 0.02126, 0.03232, 0.04045, 0.04448, 0.04441, 0.04036, 0.03232, 0.02137, 0.00749, -0.00648, -0.02055, -0.03191, -0.04056, -0.04503, -0.04534, -0.04114, -0.03243, -0.02096, -0.00672, 0.00739, 0.02137, 0.03253, 0.04088, 0.04514, 0.04531, 0.0411, 0.03254, 0.02123, 0.0072, -0.00687, -0.02099, -0.03238, -0.04106, -0.04533, -0.0452, -0.04086, -0.03234, -0.02105, -0.007, 0.00705, 0.0211, 0.0324, 0.04095, 0.04523, 0.04525, 0.041, 0.03246, 0.02126, 0.00739, -0.00661, -0.02072, -0.03224, -0.04117, -0.04551, -0.04526, -0.04079, -0.03211, -0.02091, -0.00718, 0.00671, 0.02078, 0.03211, 0.04071, 0.04497, 0.04487, 0.04067, 0.03236, 0.02117, 0.00711, -0.00707, -0.02136, -0.03273, -0.04117, -0.04531, -0.04515, -0.0408, -0.03226, -0.02101, -0.00706, 0.00692, 0.02092])):
        bPass = False
        strFailedFields += 'g.curve_IQ.x, '
    if not array_close_enough(g.curve_spc.y, np.array([-64.22699, -64.83509, -67.84623, -75.48803, -81.5468, -76.74014, -74.71705, -76.16352, -73.42712, -71.75851, -78.83173, -74.59189, -72.21241, -72.91381, -71.28263, -70.15879, -71.3752, -71.02669, -66.36323, -66.0372, -71.00377, -71.49449, -73.7469, -40.6583, -27.02014, -20.94037, -20.41725, -25.32163, -37.17166, -64.94342, -74.56989, -69.63431, -70.95632, -70.83889, -71.07941, -71.37079, -70.22647, -71.51792, -73.06263, -76.93013, -80.461, -74.31023, -71.7724, -72.32836, -75.68827, -81.08281, -79.89384, -73.33646, -75.58199, -81.94307, -69.98806, -68.79773, -77.28515, -72.98241, -73.7475, -79.45892, -74.27932, -73.732, -73.52134, -72.6101, -70.61511, -67.73285, -67.34467, -69.11381])):
        bPass = False
        strFailedFields += 'g.curve_spc.y, '
    if not array_close_enough(g.curve_filter.y, np.array([-132.77712, -37.15543, -30.38523, -26.15526, -22.98854, -20.42147, -18.24703, -16.35441, -14.67717, -13.17224, -11.81004, -10.56937, -9.43444, -8.39321, -7.43626, -6.55608, -5.7466, -5.00284, -4.32066, -3.69662, -3.12781, -2.61177, -2.14641, -1.72996, -1.36091, -1.03799, -0.76013, -0.52643, -0.33617, -0.18877, -0.0838, -0.02093, 0.0, -0.02093, -0.0838, -0.18877, -0.33617, -0.52643, -0.76013, -1.03799, -1.36091, -1.72996, -2.14641, -2.61177, -3.12781, -3.69662, -4.32066, -5.00284, -5.7466, -6.55608, -7.43626, -8.39321, -9.43444, -10.56937, -11.81004, -13.17224, -14.67717, -16.35441, -18.24703, -20.42147, -22.98854, -26.15526, -30.38523, -37.15543])):
        bPass = False
        strFailedFields += 'g.curve_filter.y, '
    if not array_close_enough(g.curve_DDC0_spc_amplitude_noise.y, np.array([-116.77674, -118.33694, -120.09619, -120.23793, -119.30698, -119.16533, -120.1264])):
        bPass = False
        strFailedFields += 'g.curve_DDC0_spc_amplitude_noise.y, '
    if not array_close_enough(g.curve_IQ.y, np.array([0.04103, 0.0453, 0.04534, 0.04097, 0.03219, 0.02075, 0.00667, -0.00735, -0.02132, -0.03248, -0.04086, -0.04501, -0.04494, -0.04077, -0.0325, -0.02134, -0.0073, 0.00693, 0.02134, 0.03285, 0.04146, 0.04556, 0.04517, 0.04062, 0.03193, 0.02076, 0.00711, -0.00657, -0.02026, -0.03149, -0.04025, -0.0447, -0.04485, -0.04062, -0.03201, -0.02075, -0.00682, 0.00719, 0.02129, 0.03267, 0.04131, 0.04554, 0.04535, 0.04089, 0.03215, 0.02084, 0.00695, -0.00707, -0.02122, -0.03261, -0.04125, -0.04543, -0.04515, -0.04072, -0.03214, -0.02088, -0.00694, 0.00709, 0.02122, 0.03256, 0.04109, 0.04532, 0.04524, 0.04092, 0.03238, 0.02103, 0.00687, -0.0073, -0.02147, -0.03294, -0.0417, -0.046, -0.04583, -0.04137, -0.03263, -0.02118, -0.00703, 0.00704, 0.02102, 0.0323, 0.04087, 0.04511, 0.045, 0.04062])):
        bPass = False
        strFailedFields += 'g.curve_IQ.y, '


    if not g.curve_spc.bVisible == -1:
        bPass = False
        strFailedFields += 'g.curve_spc.bVisible, '
    if not g.curve_filter.bVisible == 1:
        bPass = False
        strFailedFields += 'g.curve_filter.bVisibl, '
    if not g.curve_DDC0_spc_amplitude_noise.bVisible == 1:
        bPass = False
        strFailedFields += 'g.curve_DDC0_spc_amplitude_noise.bVisibl, '
    if not g.curve_IQ.bVisible == -1:
        bPass = False
        strFailedFields += 'g.curve_IQ.bVisible, '


    if bPass:
        print("All tests PASSED")
    else:
        print("FAILED test(s): %s" % strFailedFields)






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

        
    sp                 = SLLSystemParameters()
    sl                 = SuperLaserLand_mock()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()
    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 0, (True, False, False), sp, '', '')
    # xem_gui_mainwindow.show()



    test_displayADC(sl, xem_gui_mainwindow)

    # This code here is to handle weird interaction between IPython's event handler:
    # Depending on the setting for the graphical backend in Spyder (Tools/Preferences/IPython Console/Graphics/Backend = (Automatic or Inline),
    # the Qt event loop might be already running, so the proper way to teardown our application,
    # for example to enable re-using the same console to run another instance afterwards,
    # is different.
    if bEventLoopWasRunningAlready == False:
        del xem_gui_mainwindow
        del sl
    