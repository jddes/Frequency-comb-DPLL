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
        self.x = np.array([-1])
        self.y = np.array([-1])
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


def test_displayADC(sl, gui_mainwindow, test_number, bPrintAllOutputState=False):
    # shorthand:
    g = gui_mainwindow

    # set GUI-based inputs:
    g.qedit_rawdata_length.setText("100") # only use 100 pts so that the outputs are easier to check
    g.bDisplayTiming = False
    if test_number == 0:
        # Possible values: 'Spectrum', 'Time: raw input', 'Time: Phase', 'Time: IQ', 'Time: IQ, synced'
        g.qcombo_adc_plottype.setCurrentIndex(g.qcombo_adc_plottype.findText('Spectrum'))
    elif test_number == 1:
        # Possible values: 'Spectrum', 'Time: raw input', 'Time: Phase', 'Time: IQ', 'Time: IQ, synced'
        g.qcombo_adc_plottype.setCurrentIndex(g.qcombo_adc_plottype.findText('Time: raw input'))
    elif test_number == 2:
        # Possible values: 'Spectrum', 'Time: raw input', 'Time: Phase', 'Time: IQ', 'Time: IQ, synced'
        g.qcombo_adc_plottype.setCurrentIndex(g.qcombo_adc_plottype.findText('Time: Phase'))
    elif test_number == 3:
        # Possible values: 'Spectrum', 'Time: raw input', 'Time: Phase', 'Time: IQ', 'Time: IQ, synced'
        g.qcombo_adc_plottype.setCurrentIndex(g.qcombo_adc_plottype.findText('Time: IQ'))
    elif test_number == 4:
        # Possible values: 'Spectrum', 'Time: raw input', 'Time: Phase', 'Time: IQ', 'Time: IQ, synced'
        g.qcombo_adc_plottype.setCurrentIndex(g.qcombo_adc_plottype.findText('Time: IQ, synced'))
    else:
        print("Error: unknown test number (%d)" % test_number)
        return


    # possible values: 'ADC 0', 'ADC 1', 'DAC 0', 'DAC 1', 'DAC 2'
    g.qcombo_adc_plot.setCurrentIndex(g.qcombo_adc_plot.findText('ADC 0'))
    # possible values: 'Freq', 'Phase', 'Freq: time domain', 'Phase: time domain'
    g.qcombo_ddc_plot.setCurrentIndex(g.qcombo_ddc_plot.findText('Phase'))


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
        print("--------------------- Output state -------------------")
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

        print("g.curve_spc.bVisible = %d" % g.curve_spc.bVisible)
        print("g.curve_filter.bVisible = %d" % g.curve_filter.bVisible)
        print("g.curve_DDC0_spc_amplitude_noise.bVisible = %d" % g.curve_DDC0_spc_amplitude_noise.bVisible)
        print("g.curve_IQ.bVisible = %d" % g.curve_IQ.bVisible)

        decimals = 5
        print("g.curve_spc.x = %s" % np.round(g.curve_spc.x, decimals=decimals).tolist())
        print("g.curve_filter.x = %s" % np.round(g.curve_filter.x, decimals=decimals).tolist())
        print("g.curve_DDC0_spc_amplitude_noise.x = %s" % np.round(g.curve_DDC0_spc_amplitude_noise.x, decimals=decimals).tolist())
        print("g.curve_IQ.x = %s" % np.round(g.curve_IQ.x, decimals=decimals).tolist())

        print("g.curve_spc.y = %s" % np.round(g.curve_spc.y, decimals=decimals).tolist())
        print("g.curve_filter.y = %s" % np.round(g.curve_filter.y, decimals=decimals).tolist())
        print("g.curve_DDC0_spc_amplitude_noise.y = %s" % np.round(g.curve_DDC0_spc_amplitude_noise.y, decimals=decimals).tolist())
        print("g.curve_IQ.y = %s" % np.round(g.curve_IQ.y, decimals=decimals).tolist())

        # internal state output variables
        print("raw_adc_samples = %s" % repr(g.raw_adc_samples.tolist()))
        print("------------------ End output state -------------------")
        

    # Check the outputs against the expected:
    return check_displayADC_outputs(g, test_number)

    
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

# helper comparison function, which automatically handles either Python scalars or numpy arrays, including a little bit of slop:
def close_enough(x, y):
    if isinstance(x, np.ndarray):
        if x.shape != y.shape:
            print(x)
            print(y)
            print(type(x))
            print(type(y))
            print(str(x.shape))
            print(str(y.shape))
            print(type(x.shape))
            print(type(y.shape))
            print("close_enough(): incorrect shape: %s vs %s" % (x.shape, y.shape))
            return False
        else:
            return np.max(np.abs(x - y)) < 1e-3
    elif isinstance(x, float):
        return bool(np.abs(float(x)-float(y)) < 1e-6)
    else:
        return (x == y)

# use this to hold various fields for comparison purposes:
class simple_struct:
    pass

def compare_struct_fields(actual, expected, parent_name=""):
    bPass = True
    strFailedFields = ''

    for current_field in expected.__dict__.keys():
        # we support nested objects through recursion:
        if isinstance(expected.__dict__[current_field], simple_struct):
            (bPassNew, strFailedFieldsNew) = compare_struct_fields(actual.__dict__[current_field], expected.__dict__[current_field], parent_name+'.'+current_field)
            bPass = bPass and bPassNew
            strFailedFields += strFailedFieldsNew
            continue

        # Apply the comparison function:
        if not close_enough(actual.__dict__[current_field], expected.__dict__[current_field]):
            bPass = False
            strFailedFields += ('%s, ' % (parent_name+'.'+current_field))

    return (bPass, strFailedFields)


def compare_text_fields(actual, expected_outputs_as_text):
    # print("compare_text_fields:")
    bPass = True
    strFailedFields = ''
    for line in expected_outputs_as_text.split('\n'):
        full_field_name = line.split('=')[0]
        field_value_str = find_field(expected_outputs_as_text, full_field_name + '=')
        field_sub_name = full_field_name[len('g.'):].strip()
        # print("line = '%s'" % line)
        # print("full_field_name = '%s'" % full_field_name)
        # print("field_sub_name = '%s'" % field_sub_name)
        # print("field_value_str = '%s'" % field_value_str)
        # interpret the value as a float for comparison purposes (if possible)
        try:
            field_value = float(field_value_str)
        except ValueError:
            field_value = field_value_str[1:] # keep the comparison as string, removing the excess space character before the field

        # print("field_value = '%s'" % field_value)

        # compare against expected
        if not close_enough(eval('actual.' + field_sub_name), field_value):
            bPass = False
            strFailedFields += full_field_name
            print("Failed test: %s: actual : '%s', expected: '%s'" % (full_field_name, eval('actual.' + field_sub_name), field_value))
    return (bPass, strFailedFields)

def check_displayADC_outputs(g, test_number=0):
    bPass = True
    strFailedFields = ''
    print("check_displayADC_outputs(): test_number=%d" % test_number)

    expected = simple_struct()
    expected.curve_spc                      = simple_struct()
    expected.curve_filter                   = simple_struct()
    expected.curve_DDC0_spc_amplitude_noise = simple_struct()
    expected.curve_IQ                       = simple_struct()

    if test_number == 0:

        expected_outputs_as_text = """g.filtered_baseband_snr = 4.090108
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
g.qplt_IQ.bReplotCalls = 0
g.plt_spc.xmin_val = -1.000000
g.plt_spc.xmax_val = -1.000000
g.plt_spc.ymin_val = -1.000000
g.plt_spc.ymax_val = -1.000000
g.plt_spc.bReplotCalls = 0
g.plt_spc.strTitle = Spectrum, noise floor = 130 nV/sqrt(Hz)
g.curve_spc.bVisible = -1
g.curve_filter.bVisible = 1
g.curve_DDC0_spc_amplitude_noise.bVisible = 1
g.curve_IQ.bVisible = -1"""

        expected.raw_adc_samples                  = np.array([3335.0, 1026.0, -2619.0, -2578.0, 1074.0, 3245.0, 1044.0, -2656.0, -2654.0, 1026.0, 3282.0, 1060.0, -2626.0, -2647.0, 1027.0, 3288.0, 1062.0, -2658.0, -2641.0, 985.0, 3193.0, 1034.0, -2623.0, -2675.0, 1087.0, 3229.0, 1014.0, -2657.0, -2601.0, 1061.0, 3282.0, 1025.0, -2680.0, -2716.0, 1001.0, 3282.0, 1053.0, -2612.0, -2664.0, 1003.0, 3242.0, 966.0, -2707.0, -2587.0, 996.0, 3262.0, 972.0, -2626.0, -2704.0, 1006.0, 3247.0, 1025.0, -2668.0, -2690.0, 1012.0, 3291.0, 1015.0, -2641.0, -2672.0, 1001.0, 3255.0, 1001.0, -2678.0, -2708.0, 1018.0, 3264.0, 959.0, -2636.0, -2681.0, 1014.0, 3301.0, 1017.0, -2614.0, -2691.0, 1026.0, 3254.0, 984.0, -2670.0, -2661.0, 1014.0, 3239.0, 1042.0, -2636.0, -2701.0, 1061.0, 3339.0, 1051.0, -2657.0, -2686.0, 1047.0, 3264.0, 1053.0, -2644.0, -2619.0, 1024.0, 3300.0, 1013.0, -2592.0, -2647.0, 1026.0])
        expected.curve_spc.x                      = np.array([0.0, 0.97656, 1.95312, 2.92969, 3.90625, 4.88281, 5.85938, 6.83594, 7.8125, 8.78906, 9.76562, 10.74219, 11.71875, 12.69531, 13.67188, 14.64844, 15.625, 16.60156, 17.57812, 18.55469, 19.53125, 20.50781, 21.48438, 22.46094, 23.4375, 24.41406, 25.39062, 26.36719, 27.34375, 28.32031, 29.29688, 30.27344, 31.25, 32.22656, 33.20312, 34.17969, 35.15625, 36.13281, 37.10938, 38.08594, 39.0625, 40.03906, 41.01562, 41.99219, 42.96875, 43.94531, 44.92188, 45.89844, 46.875, 47.85156, 48.82812, 49.80469, 50.78125, 51.75781, 52.73438, 53.71094, 54.6875, 55.66406, 56.64062, 57.61719, 58.59375, 59.57031, 60.54688, 61.52344])
        expected.curve_filter.x                   = np.array([0.0, 0.97656, 1.95312, 2.92969, 3.90625, 4.88281, 5.85938, 6.83594, 7.8125, 8.78906, 9.76562, 10.74219, 11.71875, 12.69531, 13.67188, 14.64844, 15.625, 16.60156, 17.57812, 18.55469, 19.53125, 20.50781, 21.48438, 22.46094, 23.4375, 24.41406, 25.39062, 26.36719, 27.34375, 28.32031, 29.29688, 30.27344, 31.25, 32.22656, 33.20312, 34.17969, 35.15625, 36.13281, 37.10938, 38.08594, 39.0625, 40.03906, 41.01562, 41.99219, 42.96875, 43.94531, 44.92188, 45.89844, 46.875, 47.85156, 48.82812, 49.80469, 50.78125, 51.75781, 52.73438, 53.71094, 54.6875, 55.66406, 56.64062, 57.61719, 58.59375, 59.57031, 60.54688, 61.52344])
        expected.curve_DDC0_spc_amplitude_noise.x = np.array([781250.0, 1562500.0, 2343750.0, 3125000.0, 3906250.0, 4687500.0, 5468750.0])
        expected.curve_IQ.x                       = np.array([-0.02084, -0.00677, 0.00726, 0.02126, 0.03232, 0.04045, 0.04448, 0.04441, 0.04036, 0.03232, 0.02137, 0.00749, -0.00648, -0.02055, -0.03191, -0.04056, -0.04503, -0.04534, -0.04114, -0.03243, -0.02096, -0.00672, 0.00739, 0.02137, 0.03253, 0.04088, 0.04514, 0.04531, 0.0411, 0.03254, 0.02123, 0.0072, -0.00687, -0.02099, -0.03238, -0.04106, -0.04533, -0.0452, -0.04086, -0.03234, -0.02105, -0.007, 0.00705, 0.0211, 0.0324, 0.04095, 0.04523, 0.04525, 0.041, 0.03246, 0.02126, 0.00739, -0.00661, -0.02072, -0.03224, -0.04117, -0.04551, -0.04526, -0.04079, -0.03211, -0.02091, -0.00718, 0.00671, 0.02078, 0.03211, 0.04071, 0.04497, 0.04487, 0.04067, 0.03236, 0.02117, 0.00711, -0.00707, -0.02136, -0.03273, -0.04117, -0.04531, -0.04515, -0.0408, -0.03226, -0.02101, -0.00706, 0.00692, 0.02092])
        expected.curve_spc.y                      = np.array([-64.22699, -64.83509, -67.84623, -75.48803, -81.5468, -76.74014, -74.71705, -76.16352, -73.42712, -71.75851, -78.83173, -74.59189, -72.21241, -72.91381, -71.28263, -70.15879, -71.3752, -71.02669, -66.36323, -66.0372, -71.00377, -71.49449, -73.7469, -40.6583, -27.02014, -20.94037, -20.41725, -25.32163, -37.17166, -64.94342, -74.56989, -69.63431, -70.95632, -70.83889, -71.07941, -71.37079, -70.22647, -71.51792, -73.06263, -76.93013, -80.461, -74.31023, -71.7724, -72.32836, -75.68827, -81.08281, -79.89384, -73.33646, -75.58199, -81.94307, -69.98806, -68.79773, -77.28515, -72.98241, -73.7475, -79.45892, -74.27932, -73.732, -73.52134, -72.6101, -70.61511, -67.73285, -67.34467, -69.11381])
        expected.curve_filter.y                   = np.array([-132.77712, -37.15543, -30.38523, -26.15526, -22.98854, -20.42147, -18.24703, -16.35441, -14.67717, -13.17224, -11.81004, -10.56937, -9.43444, -8.39321, -7.43626, -6.55608, -5.7466, -5.00284, -4.32066, -3.69662, -3.12781, -2.61177, -2.14641, -1.72996, -1.36091, -1.03799, -0.76013, -0.52643, -0.33617, -0.18877, -0.0838, -0.02093, 0.0, -0.02093, -0.0838, -0.18877, -0.33617, -0.52643, -0.76013, -1.03799, -1.36091, -1.72996, -2.14641, -2.61177, -3.12781, -3.69662, -4.32066, -5.00284, -5.7466, -6.55608, -7.43626, -8.39321, -9.43444, -10.56937, -11.81004, -13.17224, -14.67717, -16.35441, -18.24703, -20.42147, -22.98854, -26.15526, -30.38523, -37.15543])
        expected.curve_DDC0_spc_amplitude_noise.y = np.array([-116.77674, -118.33694, -120.09619, -120.23793, -119.30698, -119.16533, -120.1264])
        expected.curve_IQ.y                       = np.array([0.04103, 0.0453, 0.04534, 0.04097, 0.03219, 0.02075, 0.00667, -0.00735, -0.02132, -0.03248, -0.04086, -0.04501, -0.04494, -0.04077, -0.0325, -0.02134, -0.0073, 0.00693, 0.02134, 0.03285, 0.04146, 0.04556, 0.04517, 0.04062, 0.03193, 0.02076, 0.00711, -0.00657, -0.02026, -0.03149, -0.04025, -0.0447, -0.04485, -0.04062, -0.03201, -0.02075, -0.00682, 0.00719, 0.02129, 0.03267, 0.04131, 0.04554, 0.04535, 0.04089, 0.03215, 0.02084, 0.00695, -0.00707, -0.02122, -0.03261, -0.04125, -0.04543, -0.04515, -0.04072, -0.03214, -0.02088, -0.00694, 0.00709, 0.02122, 0.03256, 0.04109, 0.04532, 0.04524, 0.04092, 0.03238, 0.02103, 0.00687, -0.0073, -0.02147, -0.03294, -0.0417, -0.046, -0.04583, -0.04137, -0.03263, -0.02118, -0.00703, 0.00704, 0.02102, 0.0323, 0.04087, 0.04511, 0.045, 0.04062])
    elif test_number == 1:

        expected_outputs_as_text = """g.filtered_baseband_snr = 4.090108
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
g.qplt_IQ.bReplotCalls = 0
g.plt_spc.xmin_val = 0.000000
g.plt_spc.xmax_val = 0.000001
g.plt_spc.ymin_val = -0.092140
g.plt_spc.ymax_val = 0.111153
g.plt_spc.bReplotCalls = 0
g.plt_spc.strTitle = Time, std = 70.74 mV, ampl = 200.09 mVpp
g.curve_spc.bVisible = -1
g.curve_filter.bVisible = 0
g.curve_DDC0_spc_amplitude_noise.bVisible = 1
g.curve_IQ.bVisible = -1"""

        expected.curve_spc.x = np.array([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
        expected.curve_filter.x = np.array([-1])
        expected.curve_DDC0_spc_amplitude_noise.x = np.array([781250.0, 1562500.0, 2343750.0, 3125000.0, 3906250.0, 4687500.0, 5468750.0])
        expected.curve_IQ.x = np.array([-0.02084, -0.00677, 0.00726, 0.02126, 0.03232, 0.04045, 0.04448, 0.04441, 0.04036, 0.03232, 0.02137, 0.00749, -0.00648, -0.02055, -0.03191, -0.04056, -0.04503, -0.04534, -0.04114, -0.03243, -0.02096, -0.00672, 0.00739, 0.02137, 0.03253, 0.04088, 0.04514, 0.04531, 0.0411, 0.03254, 0.02123, 0.0072, -0.00687, -0.02099, -0.03238, -0.04106, -0.04533, -0.0452, -0.04086, -0.03234, -0.02105, -0.007, 0.00705, 0.0211, 0.0324, 0.04095, 0.04523, 0.04525, 0.041, 0.03246, 0.02126, 0.00739, -0.00661, -0.02072, -0.03224, -0.04117, -0.04551, -0.04526, -0.04079, -0.03211, -0.02091, -0.00718, 0.00671, 0.02078, 0.03211, 0.04071, 0.04497, 0.04487, 0.04067, 0.03236, 0.02117, 0.00711, -0.00707, -0.02136, -0.03273, -0.04117, -0.04531, -0.04515, -0.0408, -0.03226, -0.02101, -0.00706, 0.00692, 0.02092])
        expected.curve_spc.y = np.array([0.10178, 0.03131, -0.07993, -0.07867, 0.03278, 0.09903, 0.03186, -0.08105, -0.08099, 0.03131, 0.10016, 0.03235, -0.08014, -0.08078, 0.03134, 0.10034, 0.03241, -0.08112, -0.0806, 0.03006, 0.09744, 0.03156, -0.08005, -0.08163, 0.03317, 0.09854, 0.03094, -0.08109, -0.07938, 0.03238, 0.10016, 0.03128, -0.08179, -0.08289, 0.03055, 0.10016, 0.03214, -0.07971, -0.0813, 0.03061, 0.09894, 0.02948, -0.08261, -0.07895, 0.0304, 0.09955, 0.02966, -0.08014, -0.08252, 0.0307, 0.09909, 0.03128, -0.08142, -0.08209, 0.03088, 0.10043, 0.03098, -0.0806, -0.08154, 0.03055, 0.09933, 0.03055, -0.08173, -0.08264, 0.03107, 0.09961, 0.02927, -0.08044, -0.08182, 0.03094, 0.10074, 0.03104, -0.07977, -0.08212, 0.03131, 0.0993, 0.03003, -0.08148, -0.08121, 0.03094, 0.09885, 0.0318, -0.08044, -0.08243, 0.03238, 0.1019, 0.03207, -0.08109, -0.08197, 0.03195, 0.09961, 0.03214, -0.08069, -0.07993, 0.03125, 0.10071, 0.03091, -0.0791, -0.08078, 0.03131])
        expected.curve_filter.y = np.array([-1])
        expected.curve_DDC0_spc_amplitude_noise.y = np.array([-116.77674, -118.33694, -120.09619, -120.23793, -119.30698, -119.16533, -120.1264])
        expected.curve_IQ.y = np.array([0.04103, 0.0453, 0.04534, 0.04097, 0.03219, 0.02075, 0.00667, -0.00735, -0.02132, -0.03248, -0.04086, -0.04501, -0.04494, -0.04077, -0.0325, -0.02134, -0.0073, 0.00693, 0.02134, 0.03285, 0.04146, 0.04556, 0.04517, 0.04062, 0.03193, 0.02076, 0.00711, -0.00657, -0.02026, -0.03149, -0.04025, -0.0447, -0.04485, -0.04062, -0.03201, -0.02075, -0.00682, 0.00719, 0.02129, 0.03267, 0.04131, 0.04554, 0.04535, 0.04089, 0.03215, 0.02084, 0.00695, -0.00707, -0.02122, -0.03261, -0.04125, -0.04543, -0.04515, -0.04072, -0.03214, -0.02088, -0.00694, 0.00709, 0.02122, 0.03256, 0.04109, 0.04532, 0.04524, 0.04092, 0.03238, 0.02103, 0.00687, -0.0073, -0.02147, -0.03294, -0.0417, -0.046, -0.04583, -0.04137, -0.03263, -0.02118, -0.00703, 0.00704, 0.02102, 0.0323, 0.04087, 0.04511, 0.045, 0.04062])
        raw_adc_samples = np.array([3335.0, 1026.0, -2619.0, -2578.0, 1074.0, 3245.0, 1044.0, -2656.0, -2654.0, 1026.0, 3282.0, 1060.0, -2626.0, -2647.0, 1027.0, 3288.0, 1062.0, -2658.0, -2641.0, 985.0, 3193.0, 1034.0, -2623.0, -2675.0, 1087.0, 3229.0, 1014.0, -2657.0, -2601.0, 1061.0, 3282.0, 1025.0, -2680.0, -2716.0, 1001.0, 3282.0, 1053.0, -2612.0, -2664.0, 1003.0, 3242.0, 966.0, -2707.0, -2587.0, 996.0, 3262.0, 972.0, -2626.0, -2704.0, 1006.0, 3247.0, 1025.0, -2668.0, -2690.0, 1012.0, 3291.0, 1015.0, -2641.0, -2672.0, 1001.0, 3255.0, 1001.0, -2678.0, -2708.0, 1018.0, 3264.0, 959.0, -2636.0, -2681.0, 1014.0, 3301.0, 1017.0, -2614.0, -2691.0, 1026.0, 3254.0, 984.0, -2670.0, -2661.0, 1014.0, 3239.0, 1042.0, -2636.0, -2701.0, 1061.0, 3339.0, 1051.0, -2657.0, -2686.0, 1047.0, 3264.0, 1053.0, -2644.0, -2619.0, 1024.0, 3300.0, 1013.0, -2592.0, -2647.0, 1026.0])



    elif test_number == 2:

        expected_outputs_as_text = """g.filtered_baseband_snr = 4.090108
g.qadc0_scale.value = 11.705200
g.qthermo_baseband_snr.value = 42.980217
g.qthermo_baseband_snr.value = 42.980217
g.qlabel_adc_fill_value.text() = 11.7 bits
g.qlabel_rawdata_rbw.text() = RBW: 2.2 MHz; Points:
g.qlabel_baseband_snr_value.text() = 4.09 dB
g.qplt_IQ.xmin_val = -2253.596044
g.qplt_IQ.xmax_val = 2253.596044
g.qplt_IQ.ymin_val = -2253.596044
g.qplt_IQ.ymax_val = 2253.596044
g.qplt_IQ.bReplotCalls = 0
g.plt_spc.xmin_val = 0.000000
g.plt_spc.xmax_val = 0.000001
g.plt_spc.ymin_val = -26.078289
g.plt_spc.ymax_val = 0.000000
g.plt_spc.bReplotCalls = 0
g.plt_spc.strTitle = Time-domain phase, std = 7.62 radrms
g.curve_spc.bVisible = -1
g.curve_filter.bVisible = 0
g.curve_DDC0_spc_amplitude_noise.bVisible = 1
g.curve_IQ.bVisible = -1"""

        expected.curve_spc.x = np.array([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
        expected.curve_filter.x = np.array([-1])
        expected.curve_DDC0_spc_amplitude_noise.x = np.array([781250.0, 1562500.0, 2343750.0, 3125000.0, 3906250.0, 4687500.0, 5468750.0])
        expected.curve_IQ.x = np.array([-682.75, -221.75, 238.0, 696.5, 1058.9375, 1325.3125, 1457.375, 1455.125, 1322.375, 1059.125, 700.1875, 245.5625, -212.25, -673.25, -1045.5, -1329.0, -1475.6875, -1485.5625, -1347.9375, -1062.8125, -686.9375, -220.3125, 242.0625, 700.1875, 1066.0625, 1339.6875, 1479.1875, 1484.5625, 1346.875, 1066.125, 695.8125, 235.9375, -225.25, -687.75, -1061.1875, -1345.5625, -1485.5, -1481.0, -1339.0625, -1059.6875, -689.8125, -229.4375, 231.0, 691.5, 1061.75, 1341.75, 1482.125, 1482.875, 1343.4375, 1063.8125, 696.6875, 242.0625, -216.4375, -678.8125, -1056.375, -1349.125, -1491.3125, -1482.9375, -1336.5625, -1052.1875, -685.125, -235.375, 219.9375, 680.8125, 1052.1875, 1334.0625, 1473.4375, 1470.3125, 1332.625, 1060.375, 693.8125, 232.9375, -231.6875, -700.0625, -1072.5625, -1349.1875, -1484.875, -1479.625, -1337.0, -1057.0, -688.4375, -231.3125, 226.6875, 685.5625])
        expected.curve_spc.y = np.array([0.0, -0.32159, -0.62871, -0.94844, -1.25728, -1.56661, -1.89185, -2.2048, -2.52664, -2.82857, -3.1296, -3.44648, -3.75461, -4.07825, -4.38763, -4.69784, -5.02162, -5.33394, -5.66077, -5.97397, -6.28488, -6.60655, -6.91518, -7.23732, -7.54787, -7.85409, -8.1677, -8.46776, -8.78181, -9.09287, -9.40915, -9.73494, -10.04675, -10.37159, -10.68583, -10.99763, -11.31616, -11.62331, -11.94581, -12.25587, -12.56495, -12.88368, -13.19046, -13.51269, -13.82549, -14.13627, -14.45465, -14.76211, -15.08471, -15.39473, -15.70189, -16.01663, -16.3231, -16.64843, -16.96478, -17.2793, -17.59721, -17.90403, -18.2284, -18.54094, -18.84873, -19.16223, -19.46673, -19.78921, -20.10066, -20.41349, -20.73869, -21.05149, -21.37599, -21.68448, -21.99119, -22.30769, -22.6141, -22.93768, -23.24797, -23.55666, -23.8779, -24.18644, -24.50759, -24.8179, -25.12781, -25.44738, -25.75514, -26.07829])
        expected.curve_filter.y = np.array([-1])
        expected.curve_DDC0_spc_amplitude_noise.y = np.array([-116.77674, -118.33694, -120.09619, -120.23793, -119.30698, -119.16533, -120.1264])
        expected.curve_IQ.y = np.array([1344.5, 1484.4375, 1485.8125, 1342.5625, 1054.6875, 680.0, 218.5, -241.0, -698.5, -1064.4375, -1338.8125, -1474.875, -1472.625, -1336.0, -1065.0, -699.375, -239.125, 227.0625, 699.1875, 1076.3125, 1358.4375, 1493.0, 1480.0, 1331.0625, 1046.1875, 680.125, 232.875, -215.125, -663.875, -1031.75, -1318.75, -1464.6875, -1469.5625, -1331.0, -1049.0, -679.8125, -223.4375, 235.75, 697.75, 1070.375, 1353.625, 1492.1875, 1486.0625, 1339.875, 1053.625, 682.875, 227.625, -231.8125, -695.4375, -1068.6875, -1351.5625, -1488.5, -1479.5, -1334.375, -1053.125, -684.1875, -227.5625, 232.3125, 695.4375, 1066.8125, 1346.4375, 1484.9375, 1482.3125, 1341.0, 1061.0, 689.0, 225.0, -239.1875, -703.5625, -1079.3125, -1366.4375, -1507.25, -1501.75, -1355.75, -1069.25, -694.125, -230.375, 230.625, 688.875, 1058.4375, 1339.3125, 1478.0625, 1474.6875, 1330.875])
        expected.raw_adc_samples = np.array([3335.0, 1026.0, -2619.0, -2578.0, 1074.0, 3245.0, 1044.0, -2656.0, -2654.0, 1026.0, 3282.0, 1060.0, -2626.0, -2647.0, 1027.0, 3288.0, 1062.0, -2658.0, -2641.0, 985.0, 3193.0, 1034.0, -2623.0, -2675.0, 1087.0, 3229.0, 1014.0, -2657.0, -2601.0, 1061.0, 3282.0, 1025.0, -2680.0, -2716.0, 1001.0, 3282.0, 1053.0, -2612.0, -2664.0, 1003.0, 3242.0, 966.0, -2707.0, -2587.0, 996.0, 3262.0, 972.0, -2626.0, -2704.0, 1006.0, 3247.0, 1025.0, -2668.0, -2690.0, 1012.0, 3291.0, 1015.0, -2641.0, -2672.0, 1001.0, 3255.0, 1001.0, -2678.0, -2708.0, 1018.0, 3264.0, 959.0, -2636.0, -2681.0, 1014.0, 3301.0, 1017.0, -2614.0, -2691.0, 1026.0, 3254.0, 984.0, -2670.0, -2661.0, 1014.0, 3239.0, 1042.0, -2636.0, -2701.0, 1061.0, 3339.0, 1051.0, -2657.0, -2686.0, 1047.0, 3264.0, 1053.0, -2644.0, -2619.0, 1024.0, 3300.0, 1013.0, -2592.0, -2647.0, 1026.0])


    elif test_number == 3:

        expected_outputs_as_text = """g.filtered_baseband_snr = 4.090108
g.qadc0_scale.value = 11.705200
g.qthermo_baseband_snr.value = 42.980217
g.qthermo_baseband_snr.value = 42.980217
g.qlabel_adc_fill_value.text() = 11.7 bits
g.qlabel_rawdata_rbw.text() = RBW: 2.2 MHz; Points:
g.qlabel_baseband_snr_value.text() = 4.09 dB
g.qplt_IQ.xmin_val = -2253.596044
g.qplt_IQ.xmax_val = 2253.596044
g.qplt_IQ.ymin_val = -2253.596044
g.qplt_IQ.ymax_val = 2253.596044
g.qplt_IQ.bReplotCalls = 0
g.plt_spc.xmin_val = 0.000000
g.plt_spc.xmax_val = 0.000001
g.plt_spc.ymin_val = -23076823.490631
g.plt_spc.ymax_val = 23076823.490631
g.plt_spc.bReplotCalls = 0
g.plt_spc.strTitle = Time-domain IQ signals (I: blue, Q: red)
g.curve_spc.bVisible = -1
g.curve_filter.bVisible = 1
g.curve_DDC0_spc_amplitude_noise.bVisible = 1
g.curve_IQ.bVisible = -1"""

        expected.curve_spc.x = np.array([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
        expected.curve_filter.x = np.array([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
        expected.curve_DDC0_spc_amplitude_noise.x = np.array([781250.0, 1562500.0, 2343750.0, 3125000.0, 3906250.0, 4687500.0, 5468750.0])
        expected.curve_IQ.x = np.array([-682.75, -221.75, 238.0, 696.5, 1058.9375, 1325.3125, 1457.375, 1455.125, 1322.375, 1059.125, 700.1875, 245.5625, -212.25, -673.25, -1045.5, -1329.0, -1475.6875, -1485.5625, -1347.9375, -1062.8125, -686.9375, -220.3125, 242.0625, 700.1875, 1066.0625, 1339.6875, 1479.1875, 1484.5625, 1346.875, 1066.125, 695.8125, 235.9375, -225.25, -687.75, -1061.1875, -1345.5625, -1485.5, -1481.0, -1339.0625, -1059.6875, -689.8125, -229.4375, 231.0, 691.5, 1061.75, 1341.75, 1482.125, 1482.875, 1343.4375, 1063.8125, 696.6875, 242.0625, -216.4375, -678.8125, -1056.375, -1349.125, -1491.3125, -1482.9375, -1336.5625, -1052.1875, -685.125, -235.375, 219.9375, 680.8125, 1052.1875, 1334.0625, 1473.4375, 1470.3125, 1332.625, 1060.375, 693.8125, 232.9375, -231.6875, -700.0625, -1072.5625, -1349.1875, -1484.875, -1479.625, -1337.0, -1057.0, -688.4375, -231.3125, 226.6875, 685.5625])
        expected.curve_spc.y = np.array([-6991360.0, -2270720.0, 2437120.0, 7132160.0, 10843520.0, 13571200.0, 14923520.0, 14900480.0, 13541120.0, 10845440.0, 7169920.0, 2514560.0, -2173440.0, -6894080.0, -10705920.0, -13608960.0, -15111040.0, -15212160.0, -13802880.0, -10883200.0, -7034240.0, -2256000.0, 2478720.0, 7169920.0, 10916480.0, 13718400.0, 15146880.0, 15201920.0, 13792000.0, 10917120.0, 7125120.0, 2416000.0, -2306560.0, -7042560.0, -10866560.0, -13778560.0, -15211520.0, -15165440.0, -13712000.0, -10851200.0, -7063680.0, -2349440.0, 2365440.0, 7080960.0, 10872320.0, 13739520.0, 15176960.0, 15184640.0, 13756800.0, 10893440.0, 7134080.0, 2478720.0, -2216320.0, -6951040.0, -10817280.0, -13815040.0, -15271040.0, -15185280.0, -13686400.0, -10774400.0, -7015680.0, -2410240.0, 2252160.0, 6971520.0, 10774400.0, 13660800.0, 15088000.0, 15056000.0, 13646080.0, 10858240.0, 7104640.0, 2385280.0, -2372480.0, -7168640.0, -10983040.0, -13815680.0, -15205120.0, -15151360.0, -13690880.0, -10823680.0, -7049600.0, -2368640.0, 2321280.0, 7020160.0])
        expected.curve_filter.y = np.array([13767680.0, 15200640.0, 15214720.0, 13747840.0, 10800000.0, 6963200.0, 2237440.0, -2467840.0, -7152640.0, -10899840.0, -13709440.0, -15102720.0, -15079680.0, -13680640.0, -10905600.0, -7161600.0, -2448640.0, 2325120.0, 7159680.0, 11021440.0, 13910400.0, 15288320.0, 15155200.0, 13630080.0, 10712960.0, 6964480.0, 2384640.0, -2202880.0, -6798080.0, -10565120.0, -13504000.0, -14998400.0, -15048320.0, -13629440.0, -10741760.0, -6961280.0, -2288000.0, 2414080.0, 7144960.0, 10960640.0, 13861120.0, 15280000.0, 15217280.0, 13720320.0, 10789120.0, 6992640.0, 2330880.0, -2373760.0, -7121280.0, -10943360.0, -13840000.0, -15242240.0, -15150080.0, -13664000.0, -10784000.0, -7006080.0, -2330240.0, 2378880.0, 7121280.0, 10924160.0, 13787520.0, 15205760.0, 15178880.0, 13731840.0, 10864640.0, 7055360.0, 2304000.0, -2449280.0, -7204480.0, -11052160.0, -13992320.0, -15434240.0, -15377920.0, -13882880.0, -10949120.0, -7107840.0, -2359040.0, 2361600.0, 7054080.0, 10838400.0, 13714560.0, 15135360.0, 15100800.0, 13628160.0])
        expected.curve_DDC0_spc_amplitude_noise.y = np.array([-116.77674, -118.33694, -120.09619, -120.23793, -119.30698, -119.16533, -120.1264])
        expected.curve_IQ.y = np.array([1344.5, 1484.4375, 1485.8125, 1342.5625, 1054.6875, 680.0, 218.5, -241.0, -698.5, -1064.4375, -1338.8125, -1474.875, -1472.625, -1336.0, -1065.0, -699.375, -239.125, 227.0625, 699.1875, 1076.3125, 1358.4375, 1493.0, 1480.0, 1331.0625, 1046.1875, 680.125, 232.875, -215.125, -663.875, -1031.75, -1318.75, -1464.6875, -1469.5625, -1331.0, -1049.0, -679.8125, -223.4375, 235.75, 697.75, 1070.375, 1353.625, 1492.1875, 1486.0625, 1339.875, 1053.625, 682.875, 227.625, -231.8125, -695.4375, -1068.6875, -1351.5625, -1488.5, -1479.5, -1334.375, -1053.125, -684.1875, -227.5625, 232.3125, 695.4375, 1066.8125, 1346.4375, 1484.9375, 1482.3125, 1341.0, 1061.0, 689.0, 225.0, -239.1875, -703.5625, -1079.3125, -1366.4375, -1507.25, -1501.75, -1355.75, -1069.25, -694.125, -230.375, 230.625, 688.875, 1058.4375, 1339.3125, 1478.0625, 1474.6875, 1330.875])
        expected.raw_adc_samples = np.array([3335.0, 1026.0, -2619.0, -2578.0, 1074.0, 3245.0, 1044.0, -2656.0, -2654.0, 1026.0, 3282.0, 1060.0, -2626.0, -2647.0, 1027.0, 3288.0, 1062.0, -2658.0, -2641.0, 985.0, 3193.0, 1034.0, -2623.0, -2675.0, 1087.0, 3229.0, 1014.0, -2657.0, -2601.0, 1061.0, 3282.0, 1025.0, -2680.0, -2716.0, 1001.0, 3282.0, 1053.0, -2612.0, -2664.0, 1003.0, 3242.0, 966.0, -2707.0, -2587.0, 996.0, 3262.0, 972.0, -2626.0, -2704.0, 1006.0, 3247.0, 1025.0, -2668.0, -2690.0, 1012.0, 3291.0, 1015.0, -2641.0, -2672.0, 1001.0, 3255.0, 1001.0, -2678.0, -2708.0, 1018.0, 3264.0, 959.0, -2636.0, -2681.0, 1014.0, 3301.0, 1017.0, -2614.0, -2691.0, 1026.0, 3254.0, 984.0, -2670.0, -2661.0, 1014.0, 3239.0, 1042.0, -2636.0, -2701.0, 1061.0, 3339.0, 1051.0, -2657.0, -2686.0, 1047.0, 3264.0, 1053.0, -2644.0, -2619.0, 1024.0, 3300.0, 1013.0, -2592.0, -2647.0, 1026.0])


    elif test_number == 4:

        expected_outputs_as_text = """g.filtered_baseband_snr = 4.090108
g.qadc0_scale.value = 11.705200
g.qthermo_baseband_snr.value = 42.980217
g.qthermo_baseband_snr.value = 42.980217
g.qlabel_adc_fill_value.text() = 11.7 bits
g.qlabel_rawdata_rbw.text() = RBW: 2.2 MHz; Points:
g.qlabel_baseband_snr_value.text() = 4.09 dB
g.qplt_IQ.xmin_val = -2253.596044
g.qplt_IQ.xmax_val = 2253.596044
g.qplt_IQ.ymin_val = -2253.596044
g.qplt_IQ.ymax_val = 2253.596044
g.qplt_IQ.bReplotCalls = 0
g.plt_spc.xmin_val = 0.000000
g.plt_spc.xmax_val = 0.000001
g.plt_spc.ymin_val = -23076823.490631
g.plt_spc.ymax_val = 23076823.490631
g.plt_spc.bReplotCalls = 0
g.plt_spc.strTitle = Time-domain IQ signals, phase aligned at t=0
g.curve_spc.bVisible = -1
g.curve_filter.bVisible = 1
g.curve_DDC0_spc_amplitude_noise.bVisible = 1
g.curve_IQ.bVisible = -1"""

        expected.curve_spc.x = np.array([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
        expected.curve_filter.x = np.array([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
        expected.curve_DDC0_spc_amplitude_noise.x = np.array([781250.0, 1562500.0, 2343750.0, 3125000.0, 3906250.0, 4687500.0, 5468750.0])
        expected.curve_IQ.x = np.array([-682.75, -221.75, 238.0, 696.5, 1058.9375, 1325.3125, 1457.375, 1455.125, 1322.375, 1059.125, 700.1875, 245.5625, -212.25, -673.25, -1045.5, -1329.0, -1475.6875, -1485.5625, -1347.9375, -1062.8125, -686.9375, -220.3125, 242.0625, 700.1875, 1066.0625, 1339.6875, 1479.1875, 1484.5625, 1346.875, 1066.125, 695.8125, 235.9375, -225.25, -687.75, -1061.1875, -1345.5625, -1485.5, -1481.0, -1339.0625, -1059.6875, -689.8125, -229.4375, 231.0, 691.5, 1061.75, 1341.75, 1482.125, 1482.875, 1343.4375, 1063.8125, 696.6875, 242.0625, -216.4375, -678.8125, -1056.375, -1349.125, -1491.3125, -1482.9375, -1336.5625, -1052.1875, -685.125, -235.375, 219.9375, 680.8125, 1052.1875, 1334.0625, 1473.4375, 1470.3125, 1332.625, 1060.375, 693.8125, 232.9375, -231.6875, -700.0625, -1072.5625, -1349.1875, -1484.875, -1479.625, -1337.0, -1057.0, -688.4375, -231.3125, 226.6875, 685.5625])
        expected.curve_spc.y = np.array([15441118.06936, 14581390.23891, 12462349.6888, 9028644.36677, 4719864.95313, 63853.1834, -4762047.83343, -8946959.06368, -12508556.86297, -14629114.52104, -15470037.44919, -14604487.14129, -12461332.55375, -9076523.98854, -4876322.41516, -223654.69177, 4658641.1901, 8960827.4762, 12633352.41547, 14754632.8697, 15587785.73917, 14652903.02433, 12390444.73447, 8906549.85639, 4609223.45133, -1654.09121, -4731932.63554, -8847198.86966, -12306014.77955, -14363124.89863, -15266577.75844, -14466847.31433, -12373097.7328, -8963644.70473, -4657504.79157, 31746.26403, 4847366.64087, 9018992.72496, 12579079.46434, 14685933.28077, 15557176.19199, 14687792.05104, 12497087.1957, 9027288.96482, 4697124.14351, 13891.43759, -4793485.85865, -8991735.71263, -12578250.13745, -14689651.24574, -15570220.47683, -14712659.12493, -12504687.90873, -9035897.26332, -4717479.78948, 8318.7344, 4836653.61768, 8996590.60666, 12546374.74205, 14618633.65844, 15469819.40073, 14649126.59479, 12514139.22184, 9087112.23071, 4808795.40702, 105456.61716, -4777173.8179, -9000826.15819, -12602301.9966, -14770722.29943, -15692703.01798, -14841543.69616, -12637130.2244, -9132532.09609, -4789652.76834, -82123.20382, 4781127.86939, 8965825.18932, 12488486.00632, 14564480.71354, 15420124.61839, 14567520.76532, 12413225.33395, 8972645.59657])
        expected.curve_filter.y = np.array([0.0, -4857847.71568, -9061848.53145, -12583894.14409, -14558324.10735, -15253181.51898, -14319234.87398, -12168256.32574, -8835054.89683, -4734880.05651, -185578.12552, 4596098.20737, 8765602.16534, 12341189.65665, 14483449.66193, 15376679.9219, 14582058.49642, 12510777.98627, 9065259.00034, 4713490.29848, -26387.25894, -4910671.7852, -9071990.91493, -12564243.04399, -14583967.45497, -15385008.20586, -14585036.68822, -12556995.02833, -9219281.74707, -4950344.72083, -238651.54486, 4636743.18287, 8870096.18609, 12450395.96457, 14552497.49176, 15437199.45737, 14598915.07474, 12428842.3784, 8990893.01635, 4712487.06335, 22174.94469, -4823591.29476, -8999095.98876, -12525782.58512, -14579076.69701, -15416589.47459, -14587515.54374, -12464217.4781, -9041559.52024, -4757973.24517, -94507.93186, 4691225.26953, 8835710.42159, 12384442.40684, 14527683.47102, 15490010.26361, 14671109.80539, 12462469.90724, 8978789.15169, 4660527.54801, 12701.24316, -4735766.46859, -8880706.18006, -12433419.16781, -14525962.42674, -15374798.8693, -14496026.01797, -12315325.28959, -8905167.92786, -4677326.08618, 708.25959, 4861471.56435, 9078106.88241, 12677563.41171, 14750241.44801, 15536655.3385, 14625373.84933, 12440049.96309, 9013210.14349, 4743296.83313, 75979.6487, -4740982.65459, -8906982.55791, -12429844.02193])
        expected.curve_DDC0_spc_amplitude_noise.y = np.array([-116.77674, -118.33694, -120.09619, -120.23793, -119.30698, -119.16533, -120.1264])
        expected.curve_IQ.y = np.array([1344.5, 1484.4375, 1485.8125, 1342.5625, 1054.6875, 680.0, 218.5, -241.0, -698.5, -1064.4375, -1338.8125, -1474.875, -1472.625, -1336.0, -1065.0, -699.375, -239.125, 227.0625, 699.1875, 1076.3125, 1358.4375, 1493.0, 1480.0, 1331.0625, 1046.1875, 680.125, 232.875, -215.125, -663.875, -1031.75, -1318.75, -1464.6875, -1469.5625, -1331.0, -1049.0, -679.8125, -223.4375, 235.75, 697.75, 1070.375, 1353.625, 1492.1875, 1486.0625, 1339.875, 1053.625, 682.875, 227.625, -231.8125, -695.4375, -1068.6875, -1351.5625, -1488.5, -1479.5, -1334.375, -1053.125, -684.1875, -227.5625, 232.3125, 695.4375, 1066.8125, 1346.4375, 1484.9375, 1482.3125, 1341.0, 1061.0, 689.0, 225.0, -239.1875, -703.5625, -1079.3125, -1366.4375, -1507.25, -1501.75, -1355.75, -1069.25, -694.125, -230.375, 230.625, 688.875, 1058.4375, 1339.3125, 1478.0625, 1474.6875, 1330.875])
        expected.raw_adc_samples = np.array([3335.0, 1026.0, -2619.0, -2578.0, 1074.0, 3245.0, 1044.0, -2656.0, -2654.0, 1026.0, 3282.0, 1060.0, -2626.0, -2647.0, 1027.0, 3288.0, 1062.0, -2658.0, -2641.0, 985.0, 3193.0, 1034.0, -2623.0, -2675.0, 1087.0, 3229.0, 1014.0, -2657.0, -2601.0, 1061.0, 3282.0, 1025.0, -2680.0, -2716.0, 1001.0, 3282.0, 1053.0, -2612.0, -2664.0, 1003.0, 3242.0, 966.0, -2707.0, -2587.0, 996.0, 3262.0, 972.0, -2626.0, -2704.0, 1006.0, 3247.0, 1025.0, -2668.0, -2690.0, 1012.0, 3291.0, 1015.0, -2641.0, -2672.0, 1001.0, 3255.0, 1001.0, -2678.0, -2708.0, 1018.0, 3264.0, 959.0, -2636.0, -2681.0, 1014.0, 3301.0, 1017.0, -2614.0, -2691.0, 1026.0, 3254.0, 984.0, -2670.0, -2661.0, 1014.0, 3239.0, 1042.0, -2636.0, -2701.0, 1061.0, 3339.0, 1051.0, -2657.0, -2686.0, 1047.0, 3264.0, 1053.0, -2644.0, -2619.0, 1024.0, 3300.0, 1013.0, -2592.0, -2647.0, 1026.0])

    else:
        expected_outputs_as_text = """g.filtered_baseband_snr = 4.090108
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
g.qplt_IQ.bReplotCalls = 0
g.plt_spc.xmin_val = 0.000000
g.plt_spc.xmax_val = 0.000001
g.plt_spc.ymin_val = -0.092140
g.plt_spc.ymax_val = 0.111153
g.plt_spc.bReplotCalls = 0
g.plt_spc.strTitle = Time, std = 70.74 mV, ampl = 200.09 mVpp
g.curve_spc.bVisible = -1
g.curve_filter.bVisible = 0
g.curve_DDC0_spc_amplitude_noise.bVisible = 1
g.curve_IQ.bVisible = -1"""

        expected.curve_spc.x = np.array([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
        expected.curve_filter.x = np.array([])
        expected.curve_DDC0_spc_amplitude_noise.x = np.array([781250.0, 1562500.0, 2343750.0, 3125000.0, 3906250.0, 4687500.0, 5468750.0])
        expected.curve_IQ.x = np.array([-0.02084, -0.00677, 0.00726, 0.02126, 0.03232, 0.04045, 0.04448, 0.04441, 0.04036, 0.03232, 0.02137, 0.00749, -0.00648, -0.02055, -0.03191, -0.04056, -0.04503, -0.04534, -0.04114, -0.03243, -0.02096, -0.00672, 0.00739, 0.02137, 0.03253, 0.04088, 0.04514, 0.04531, 0.0411, 0.03254, 0.02123, 0.0072, -0.00687, -0.02099, -0.03238, -0.04106, -0.04533, -0.0452, -0.04086, -0.03234, -0.02105, -0.007, 0.00705, 0.0211, 0.0324, 0.04095, 0.04523, 0.04525, 0.041, 0.03246, 0.02126, 0.00739, -0.00661, -0.02072, -0.03224, -0.04117, -0.04551, -0.04526, -0.04079, -0.03211, -0.02091, -0.00718, 0.00671, 0.02078, 0.03211, 0.04071, 0.04497, 0.04487, 0.04067, 0.03236, 0.02117, 0.00711, -0.00707, -0.02136, -0.03273, -0.04117, -0.04531, -0.04515, -0.0408, -0.03226, -0.02101, -0.00706, 0.00692, 0.02092])
        expected.curve_spc.y = np.array([0.10178, 0.03131, -0.07993, -0.07867, 0.03278, 0.09903, 0.03186, -0.08105, -0.08099, 0.03131, 0.10016, 0.03235, -0.08014, -0.08078, 0.03134, 0.10034, 0.03241, -0.08112, -0.0806, 0.03006, 0.09744, 0.03156, -0.08005, -0.08163, 0.03317, 0.09854, 0.03094, -0.08109, -0.07938, 0.03238, 0.10016, 0.03128, -0.08179, -0.08289, 0.03055, 0.10016, 0.03214, -0.07971, -0.0813, 0.03061, 0.09894, 0.02948, -0.08261, -0.07895, 0.0304, 0.09955, 0.02966, -0.08014, -0.08252, 0.0307, 0.09909, 0.03128, -0.08142, -0.08209, 0.03088, 0.10043, 0.03098, -0.0806, -0.08154, 0.03055, 0.09933, 0.03055, -0.08173, -0.08264, 0.03107, 0.09961, 0.02927, -0.08044, -0.08182, 0.03094, 0.10074, 0.03104, -0.07977, -0.08212, 0.03131, 0.0993, 0.03003, -0.08148, -0.08121, 0.03094, 0.09885, 0.0318, -0.08044, -0.08243, 0.03238, 0.1019, 0.03207, -0.08109, -0.08197, 0.03195, 0.09961, 0.03214, -0.08069, -0.07993, 0.03125, 0.10071, 0.03091, -0.0791, -0.08078, 0.03131])
        expected.curve_filter.y = np.array([])
        expected.curve_DDC0_spc_amplitude_noise.y = np.array([-116.77674, -118.33694, -120.09619, -120.23793, -119.30698, -119.16533, -120.1264])
        expected.curve_IQ.y = np.array([0.04103, 0.0453, 0.04534, 0.04097, 0.03219, 0.02075, 0.00667, -0.00735, -0.02132, -0.03248, -0.04086, -0.04501, -0.04494, -0.04077, -0.0325, -0.02134, -0.0073, 0.00693, 0.02134, 0.03285, 0.04146, 0.04556, 0.04517, 0.04062, 0.03193, 0.02076, 0.00711, -0.00657, -0.02026, -0.03149, -0.04025, -0.0447, -0.04485, -0.04062, -0.03201, -0.02075, -0.00682, 0.00719, 0.02129, 0.03267, 0.04131, 0.04554, 0.04535, 0.04089, 0.03215, 0.02084, 0.00695, -0.00707, -0.02122, -0.03261, -0.04125, -0.04543, -0.04515, -0.04072, -0.03214, -0.02088, -0.00694, 0.00709, 0.02122, 0.03256, 0.04109, 0.04532, 0.04524, 0.04092, 0.03238, 0.02103, 0.00687, -0.0073, -0.02147, -0.03294, -0.0417, -0.046, -0.04583, -0.04137, -0.03263, -0.02118, -0.00703, 0.00704, 0.02102, 0.0323, 0.04087, 0.04511, 0.045, 0.04062])
        raw_adc_samples = np.array([3335.0, 1026.0, -2619.0, -2578.0, 1074.0, 3245.0, 1044.0, -2656.0, -2654.0, 1026.0, 3282.0, 1060.0, -2626.0, -2647.0, 1027.0, 3288.0, 1062.0, -2658.0, -2641.0, 985.0, 3193.0, 1034.0, -2623.0, -2675.0, 1087.0, 3229.0, 1014.0, -2657.0, -2601.0, 1061.0, 3282.0, 1025.0, -2680.0, -2716.0, 1001.0, 3282.0, 1053.0, -2612.0, -2664.0, 1003.0, 3242.0, 966.0, -2707.0, -2587.0, 996.0, 3262.0, 972.0, -2626.0, -2704.0, 1006.0, 3247.0, 1025.0, -2668.0, -2690.0, 1012.0, 3291.0, 1015.0, -2641.0, -2672.0, 1001.0, 3255.0, 1001.0, -2678.0, -2708.0, 1018.0, 3264.0, 959.0, -2636.0, -2681.0, 1014.0, 3301.0, 1017.0, -2614.0, -2691.0, 1026.0, 3254.0, 984.0, -2670.0, -2661.0, 1014.0, 3239.0, 1042.0, -2636.0, -2701.0, 1061.0, 3339.0, 1051.0, -2657.0, -2686.0, 1047.0, 3264.0, 1053.0, -2644.0, -2619.0, 1024.0, 3300.0, 1013.0, -2592.0, -2647.0, 1026.0])


    (bPass, strFailedFields)       = compare_struct_fields(g, expected)
    (bPassNew, strFailedFieldsNew) = compare_text_fields(g, expected_outputs_as_text)
    # Combine the results of both types of comparisons:
    bPass = bPass and bPassNew
    strFailedFields += strFailedFieldsNew



    if bPass:
        print("Test #%d PASSED" % test_number)
    else:
        print("Test #%d FAILED: %s" % (test_number, strFailedFields))

    return bPass



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
    bPass = True
    for test_case in range(5):
        xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 0, (True, False, False), sp, '', '')
        bPass = bPass and test_displayADC(sl, xem_gui_mainwindow, test_number=test_case, bPrintAllOutputState=False)
        del xem_gui_mainwindow

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
        del xem_gui_mainwindow
        del sl
    