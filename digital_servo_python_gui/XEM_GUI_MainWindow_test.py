import pytest
import sys
from PyQt5 import QtGui, Qt, QtCore, QtWidgets
import numpy as np

from SuperLaserLand_JD_RP import SuperLaserLand_JD_RP
from SLLSystemParameters import SLLSystemParameters
# from SuperLaserLand_mock import SuperLaserLand_mock
from XEM_GUI_MainWindow import XEM_GUI_MainWindow

import RP_PLL

from TestHelpers import *

def start_qt():
    # Start Qt:
    app = QtCore.QCoreApplication.instance()
    if app is None:
        print("QCoreApplication not running yet. creating.")
        bEventLoopWasRunningAlready = False
        app = QtWidgets.QApplication(sys.argv)
    else:
        bEventLoopWasRunningAlready = True
        print("QCoreApplication already running.")

    return app

# @pytest.mark.skiptest
def test_slowStart100VSwitchingSupply():

    # intercept the calls that are the "output" of the function that we want to test:
    class SuperLaserLand_JD_RP_mock(SuperLaserLand_JD_RP):
        def __init__(self):
            super(SuperLaserLand_JD_RP_mock, self).__init__()
            self.setTestOscillator_calls = 0
            
        def setTestOscillator(self, bEnable=1, bPolarity=1, oscillator_modulus=625, oscillator_modulus_active=62):
            self.setTestOscillator_calls += 1

    app = start_qt()
    sp = SLLSystemParameters()
    sl = SuperLaserLand_JD_RP_mock()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()
    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 0, (True, False, False), sp, '', '')

    xem_gui_mainwindow.slowStart100VSwitchingSupply()
    assert(sl.setTestOscillator_calls == 11)
    
# @pytest.mark.skiptest
def test_slowStart100VSwitchingSupply_with_exception():
    # intercept the calls that are the "output" of the function that we want to test:
    class SuperLaserLand_JD_RP_mock(SuperLaserLand_JD_RP):
        def setTestOscillator(self, bEnable=1, bPolarity=1, oscillator_modulus=625, oscillator_modulus_active=62):
            raise RP_PLL.CommsError('test exception')

    app = start_qt()
    sp = SLLSystemParameters()
    sl = SuperLaserLand_JD_RP_mock()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()
    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 0, (True, False, False), sp, '', '')
    # we simply make sure that the function does not raise an exception:
    xem_gui_mainwindow.slowStart100VSwitchingSupply()

# @pytest.mark.skiptest
def test_setVCOGain_event():
    # intercept the calls that are the "output" of the function that we want to test:
    class SuperLaserLand_JD_RP_mock(SuperLaserLand_JD_RP):
        def __init__(self):
            super(SuperLaserLand_JD_RP_mock, self).__init__()
            self.send_bus_cmd_calls = 0
            self.send_bus_cmd_32bits_calls = 0
            self.openloopgain = [0]*3

        def send_bus_cmd(self, bus_address, data1, data2):
            self.send_bus_cmd_calls += 1

        def send_bus_cmd_32bits(self, bus_address, data_32bits):
            self.send_bus_cmd_32bits_calls += 1

        def save_openLoop_gain(self, dac_number, value):
            self.openloopgain[dac_number] = value

        def read_pll2_mux(self):
            return 0

    app = start_qt()
    sp = SLLSystemParameters()
    sl = SuperLaserLand_JD_RP_mock()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()
    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 0, (True, True, True), sp, '', '')

    setDACOffset_event_calls = count_calls()

    xem_gui_mainwindow.spectrum.setDACOffset_event = setDACOffset_event_calls.calls_counting
    xem_gui_mainwindow.qedit_vco_gain[0].setText('%.1e' % 1e6)

    xem_gui_mainwindow.setVCOGain_event()

    assert(sl.send_bus_cmd_calls == 3)
    assert(sl.send_bus_cmd_32bits_calls == 15)
    assert(setDACOffset_event_calls.calls_number == 1)

    assert(xem_gui_mainwindow.spectrum.q_dac_offset[0].pageStep() == 1e6)
    assert(xem_gui_mainwindow.spectrum.q_dac_offset[0].singleStep() == 83332)
    assert(xem_gui_mainwindow.spectrum.q_dac_offset[1].pageStep() == 2500)
    assert(xem_gui_mainwindow.spectrum.q_dac_offset[1].singleStep() == 83)
    assert(xem_gui_mainwindow.spectrum.q_dac_offset[2].pageStep() == 1515)
    assert(xem_gui_mainwindow.spectrum.q_dac_offset[2].singleStep() == 51)

# @pytest.mark.skiptest
def test_setVCOGain_event_exception():
    # intercept the calls that are the "output" of the function that we want to test:
    class SuperLaserLand_JD_RP_mock(SuperLaserLand_JD_RP):
        def __init__(self):
            super(SuperLaserLand_JD_RP_mock, self).__init__()
            self.send_bus_cmd_calls = 0
            self.send_bus_cmd_32bits_calls = 0
            self.openloopgain = [0]*3

        def send_bus_cmd(self, bus_address, data1, data2):
            raise RP_PLL.CommsError('test exception')

        def send_bus_cmd_32bits(self, bus_address, data_32bits):
            self.send_bus_cmd_32bits_calls += 1

        def save_openLoop_gain(self, dac_number, value):
            self.openloopgain[dac_number] = value

    app = start_qt()
    sp = SLLSystemParameters()
    sl = SuperLaserLand_JD_RP_mock()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()
    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 0, (True, True, True), sp, '', '')

    xem_gui_mainwindow.setVCOGain_event()

# @pytest.mark.skiptest
def test_getVCOGain():
    # intercept the calls that are the "output" of the function that we want to test:
    class SuperLaserLand_JD_RP_mock(SuperLaserLand_JD_RP):
        def __init__(self):
            super(SuperLaserLand_JD_RP_mock, self).__init__()
            self.send_bus_cmd_calls = 0
            self.send_bus_cmd_32bits_calls = 0
            self.openloopgain = [0]*3

        def get_openLoop_gain(self, dac_number):
            return float(dac_number)

        def send_bus_cmd_32bits(self, bus_address, data_32bits):
            self.send_bus_cmd_32bits_calls += 1

        def save_openLoop_gain(self, dac_number, value):
            self.openloopgain[dac_number] = value

        def read_pll2_mux(self):
            return 0

    app = start_qt()
    sp = SLLSystemParameters()
    sl = SuperLaserLand_JD_RP_mock()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()

    # "outputs" are:
    # 
    # self.qloop_filters[k].kc
    # self.qloop_filters[k].checkFirmwareLimits() gets called once
    # self.qloop_filters[k].updateGraph() gets called once
    # self.qloop_filters[1].kc_dac2 = VCO_gain_in_counts_per_counts
    # self.spectrum.setSliderStepSize(k, VCO_gain_in_Hz_per_Volts)


    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 0, (True, False, False), sp, '', '')
    checkFirmwareLimits_counting = [0]*3
    updateGraph_counting = [0]*3
    for k in range(1):
        checkFirmwareLimits_counting[k] = count_calls()
        updateGraph_counting[k] = count_calls()
        xem_gui_mainwindow.qloop_filters[k].checkFirmwareLimits = checkFirmwareLimits_counting[k].calls_counting
        xem_gui_mainwindow.qloop_filters[k].updateGraph = updateGraph_counting[k].calls_counting

    xem_gui_mainwindow.getVCOGain()
    for k in range(1):
        print("xem_gui_mainwindow.spectrum.q_dac_offset[%d].setSingleStep(small_step) = %f" % (k, xem_gui_mainwindow.spectrum.q_dac_offset[k].singleStep()))
        print("xem_gui_mainwindow.spectrum.q_dac_offset[%d].setPageStep(large_step) = %f" % (k, xem_gui_mainwindow.spectrum.q_dac_offset[k].pageStep()))
        print('xem_gui_mainwindow.qedit_vco_gain[%d] = %s' % (k, xem_gui_mainwindow.qedit_vco_gain[k].text()))

    assert( xem_gui_mainwindow.spectrum.q_dac_offset[0].singleStep() == 1e6)
    assert( xem_gui_mainwindow.spectrum.q_dac_offset[0].pageStep() == 1e6)
    assert( xem_gui_mainwindow.qedit_vco_gain[0].text() == '1.0e+00' )



    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 1, (False, True, True), sp, '', '')
    checkFirmwareLimits_counting = [0]*3
    updateGraph_counting = [0]*3
    for k in [1, 2]:
        checkFirmwareLimits_counting[k] = count_calls()
        updateGraph_counting[k] = count_calls()
        if k == 1:
            xem_gui_mainwindow.qloop_filters[k].checkFirmwareLimits = checkFirmwareLimits_counting[k].calls_counting
            xem_gui_mainwindow.qloop_filters[k].updateGraph = updateGraph_counting[k].calls_counting
    xem_gui_mainwindow.getVCOGain()

    assert( xem_gui_mainwindow.spectrum.q_dac_offset[1].singleStep() == 21)
    assert( xem_gui_mainwindow.spectrum.q_dac_offset[1].pageStep() == 625)

    assert( xem_gui_mainwindow.spectrum.q_dac_offset[2].singleStep() == 10)
    assert( xem_gui_mainwindow.spectrum.q_dac_offset[2].pageStep() == 313)

    assert( xem_gui_mainwindow.qedit_vco_gain[1].text() == '4.0e+09' )
    assert( xem_gui_mainwindow.qedit_vco_gain[2].text() == '4.8e+09' )

    for k in [1, 2]:
        print("xem_gui_mainwindow.spectrum.q_dac_offset[%d].setSingleStep(small_step) = %f" % (k, xem_gui_mainwindow.spectrum.q_dac_offset[k].singleStep()))
        print("xem_gui_mainwindow.spectrum.q_dac_offset[%d].setPageStep(large_step) = %f" % (k, xem_gui_mainwindow.spectrum.q_dac_offset[k].pageStep()))
        print('xem_gui_mainwindow.qedit_vco_gain[%d] = %s' % (k, xem_gui_mainwindow.qedit_vco_gain[k].text()))

    # assert(1 == 0)

# @pytest.mark.skiptest
def test_getVCOGain_with_exception():
    # intercept the calls that are the "output" of the function that we want to test:
    class SuperLaserLand_JD_RP_mock(SuperLaserLand_JD_RP):
        def __init__(self):
            super(SuperLaserLand_JD_RP_mock, self).__init__()
            self.send_bus_cmd_calls = 0
            self.send_bus_cmd_32bits_calls = 0
            self.openloopgain = [0]*3

        def get_openLoop_gain(self, dac_number):
            raise RP_PLL.CommsError('test exception')

        def send_bus_cmd_32bits(self, bus_address, data_32bits):
            self.send_bus_cmd_32bits_calls += 1

        def save_openLoop_gain(self, dac_number, value):
            self.openloopgain[dac_number] = value

        def read_pll2_mux(self):
            return 0

    app = start_qt()
    sp = SLLSystemParameters()
    sl = SuperLaserLand_JD_RP_mock()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()

    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 0, (True, False, False), sp, '', '')
    xem_gui_mainwindow.getVCOGain()

    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 1, (False, True, True), sp, '', '')
    xem_gui_mainwindow.getVCOGain()

# @pytest.mark.skiptest
def test_setVCOFreq_event():
    # intercept the calls that are the "output" of the function that we want to test:
    class SuperLaserLand_JD_RP_mock(SuperLaserLand_JD_RP):
        def __init__(self):
            super(SuperLaserLand_JD_RP_mock, self).__init__()
            self.set_ddc0_ref_freq_called = 0
            self.set_ddc1_ref_freq_called = 0

        def set_ddc0_ref_freq(self, dac_number):
            self.set_ddc0_ref_freq_called += 1

        def set_ddc1_ref_freq(self, dac_number):
            self.set_ddc1_ref_freq_called += 1

    app = start_qt()
    sp = SLLSystemParameters()
    sl = SuperLaserLand_JD_RP_mock()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()
    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 0, (True, False, False), sp, '', '')
    xem_gui_mainwindow.setVCOFreq_event()
    assert(xem_gui_mainwindow.sl.set_ddc0_ref_freq_called == 1)
    assert(xem_gui_mainwindow.sl.set_ddc1_ref_freq_called == 0)

    sl = SuperLaserLand_JD_RP_mock()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()
    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 1, (False, True, True), sp, '', '')
    xem_gui_mainwindow.setVCOFreq_event()
    assert(xem_gui_mainwindow.sl.set_ddc0_ref_freq_called == 0)
    assert(xem_gui_mainwindow.sl.set_ddc1_ref_freq_called == 1)

# @pytest.mark.skiptest
def test_setVCOFreq_event_with_exception():
    # intercept the calls that are the "output" of the function that we want to test:
    class SuperLaserLand_JD_RP_mock(SuperLaserLand_JD_RP):
        def __init__(self):
            super(SuperLaserLand_JD_RP_mock, self).__init__()
            self.set_ddc0_ref_freq_called = 0
            self.set_ddc1_ref_freq_called = 0

        def set_ddc0_ref_freq(self, dac_number):
            raise RP_PLL.CommsError()
            self.set_ddc0_ref_freq_called += 1

        def set_ddc1_ref_freq(self, dac_number):
            raise RP_PLL.CommsError()
            self.set_ddc1_ref_freq_called += 1

    app = start_qt()
    sp = SLLSystemParameters()
    sl = SuperLaserLand_JD_RP_mock()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()
    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 0, (True, False, False), sp, '', '')
    xem_gui_mainwindow.setVCOFreq_event()

    sl = SuperLaserLand_JD_RP_mock()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()
    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 1, (False, True, True), sp, '', '')
    xem_gui_mainwindow.setVCOFreq_event()


# @pytest.mark.skiptest
def test_getVCOFreq():
    class SuperLaserLand_JD_RP_mock(SuperLaserLand_JD_RP):
        def __init__(self):
            super(SuperLaserLand_JD_RP_mock, self).__init__()

        # intercept inputs
        def get_ddc0_ref_freq_from_RAM(self):
            return 25e6
        def get_ddc1_ref_freq_from_RAM(self):
            return -20e6

    app = start_qt()
    sp = SLLSystemParameters()
    sl = SuperLaserLand_JD_RP_mock()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()
    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 0, (True, False, False), sp, '', '')
    xem_gui_mainwindow.qsign_positive = count_calls_obj()
    xem_gui_mainwindow.qsign_negative = count_calls_obj()
    xem_gui_mainwindow.qedit_ref_freq = count_calls_obj()
    xem_gui_mainwindow.getVCOFreq()
    print(xem_gui_mainwindow.qsign_positive.calls)
    print(xem_gui_mainwindow.qsign_negative.calls)
    print(xem_gui_mainwindow.qedit_ref_freq.calls)
    for obj in [xem_gui_mainwindow.qsign_positive, xem_gui_mainwindow.qsign_negative, xem_gui_mainwindow.qedit_ref_freq]:
        obj.mode = 'checking'
    assert(len(xem_gui_mainwindow.qsign_positive.calls) == 0)
    assert(len(xem_gui_mainwindow.qsign_negative.calls) == 1)
    assert(xem_gui_mainwindow.qsign_negative.calls[0] == xem_gui_mainwindow.qsign_positive.setChecked(True))
    assert(len(xem_gui_mainwindow.qedit_ref_freq.calls) == 3)
    assert(xem_gui_mainwindow.qedit_ref_freq.calls[0] == xem_gui_mainwindow.qedit_ref_freq.blockSignals(True))
    assert(xem_gui_mainwindow.qedit_ref_freq.calls[1] == xem_gui_mainwindow.qedit_ref_freq.setText('2.50e+07'))
    assert(xem_gui_mainwindow.qedit_ref_freq.calls[2] == xem_gui_mainwindow.qedit_ref_freq.blockSignals(False))

    sl = SuperLaserLand_JD_RP_mock()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()
    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 1, (False, True, True), sp, '', '')
    xem_gui_mainwindow.qsign_positive = count_calls_obj()
    xem_gui_mainwindow.qsign_negative = count_calls_obj()
    xem_gui_mainwindow.qedit_ref_freq = count_calls_obj()
    xem_gui_mainwindow.getVCOFreq()
    print(xem_gui_mainwindow.qsign_positive.calls)
    print(xem_gui_mainwindow.qsign_negative.calls)
    print(xem_gui_mainwindow.qedit_ref_freq.calls)
    for obj in [xem_gui_mainwindow.qsign_positive, xem_gui_mainwindow.qsign_negative, xem_gui_mainwindow.qedit_ref_freq]:
        obj.mode = 'checking'

    assert(len(xem_gui_mainwindow.qsign_positive.calls) == 1)
    assert(len(xem_gui_mainwindow.qsign_negative.calls) == 0)
    assert(xem_gui_mainwindow.qsign_positive.calls[0] == xem_gui_mainwindow.qsign_positive.setChecked(True))
    assert(len(xem_gui_mainwindow.qedit_ref_freq.calls) == 3)
    assert(xem_gui_mainwindow.qedit_ref_freq.calls[0] == xem_gui_mainwindow.qedit_ref_freq.blockSignals(True))
    assert(xem_gui_mainwindow.qedit_ref_freq.calls[1] == xem_gui_mainwindow.qedit_ref_freq.setText('2.00e+07'))
    assert(xem_gui_mainwindow.qedit_ref_freq.calls[2] == xem_gui_mainwindow.qedit_ref_freq.blockSignals(False))


# @pytest.mark.skiptest
def test_getVCOFreq_with_exception():
    class SuperLaserLand_JD_RP_mock(SuperLaserLand_JD_RP):
        def __init__(self):
            super(SuperLaserLand_JD_RP_mock, self).__init__()

        # intercept inputs, this time throwing an exception:
        def get_ddc0_ref_freq_from_RAM(self):
            raise RP_PLL.CommsError()
        def get_ddc1_ref_freq_from_RAM(self):
            raise RP_PLL.CommsError()


    app = start_qt()
    sp = SLLSystemParameters()
    sl = SuperLaserLand_JD_RP_mock()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()
    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 0, (True, False, False), sp, '', '')
    xem_gui_mainwindow.qsign_positive = count_calls_obj()
    xem_gui_mainwindow.qsign_negative = count_calls_obj()
    xem_gui_mainwindow.qedit_ref_freq = count_calls_obj()
    xem_gui_mainwindow.getVCOFreq()
    print(xem_gui_mainwindow.qsign_positive.calls)
    print(xem_gui_mainwindow.qsign_negative.calls)
    print(xem_gui_mainwindow.qedit_ref_freq.calls)
    for obj in [xem_gui_mainwindow.qsign_positive, xem_gui_mainwindow.qsign_negative, xem_gui_mainwindow.qedit_ref_freq]:
        obj.mode = 'checking'
    assert(len(xem_gui_mainwindow.qsign_positive.calls) == 0)
    assert(len(xem_gui_mainwindow.qsign_negative.calls) == 0)
    assert(len(xem_gui_mainwindow.qedit_ref_freq.calls) == 0)

    sl = SuperLaserLand_JD_RP_mock()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()
    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 1, (False, True, True), sp, '', '')
    xem_gui_mainwindow.qsign_positive = count_calls_obj()
    xem_gui_mainwindow.qsign_negative = count_calls_obj()
    xem_gui_mainwindow.qedit_ref_freq = count_calls_obj()
    xem_gui_mainwindow.getVCOFreq()
    print(xem_gui_mainwindow.qsign_positive.calls)
    print(xem_gui_mainwindow.qsign_negative.calls)
    print(xem_gui_mainwindow.qedit_ref_freq.calls)
    for obj in [xem_gui_mainwindow.qsign_positive, xem_gui_mainwindow.qsign_negative, xem_gui_mainwindow.qedit_ref_freq]:
        obj.mode = 'checking'
    assert(len(xem_gui_mainwindow.qsign_positive.calls) == 0)
    assert(len(xem_gui_mainwindow.qsign_negative.calls) == 0)
    assert(len(xem_gui_mainwindow.qedit_ref_freq.calls) == 0)

    
    # def getVCOFreq(self):
    #     if self.selected_ADC == 0:
    #         frequency_in_hz = self.sl.get_ddc0_ref_freq_from_RAM()
    #     elif self.selected_ADC == 1:
    #         frequency_in_hz = self.sl.get_ddc1_ref_freq_from_RAM()
    #     # If the VCO has positive sign, we need to put a negative reference frequency to make the
    #     # total loop sign be negative so that it's stable when we close the loop
    #     if frequency_in_hz < 0:
    #         self.qsign_positive.setChecked(True)
    #     else:
    #         self.qsign_negative.setChecked(True)
            
    #     self.qedit_ref_freq.blockSignals(True)
    #     self.qedit_ref_freq.setText('%.2e' % abs(frequency_in_hz))
    #     self.qedit_ref_freq.blockSignals(False)

# @pytest.mark.skiptest
def test_grabAndExportData():
    # override some GUI stuff:
    QtGui.QInputDialog.getItem = lambda *args, **kwargs : ('ADC0', True)
    QtGui.QInputDialog.getText = lambda *args, **kwargs : ('1e3', True)

    class SuperLaserLand_JD_RP_mock(SuperLaserLand_JD_RP):
        def __init__(self):
            super(SuperLaserLand_JD_RP_mock, self).__init__()

        def read_adc_samples_from_DDR2(self):
            self.samples_returned = np.random.randn(self.Num_samples_read)
            return (self.samples_returned, 1+1j*0)

    app = start_qt()
    sp = SLLSystemParameters()
    # also override some comms stuff:
    sl = SuperLaserLand_JD_RP_mock()
    sl.dev = count_calls_obj()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()
    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 0, (True, False, False), sp, '', '')

    # actual test call:
    xem_gui_mainwindow.grabAndExportData(bSyncReadOnNextTimeQuantization=False)

    # actual output is writing out the samples to file, (after converting to normalized units?)
    # we don't bother checking it

# @pytest.mark.skiptest
def test_grabAndExportData_with_exception():
    # override some GUI stuff:
    QtGui.QInputDialog.getItem = lambda *args, **kwargs : ('ADC0', True)
    QtGui.QInputDialog.getText = lambda *args, **kwargs : ('1e3', True)

    class SuperLaserLand_JD_RP_mock(SuperLaserLand_JD_RP):
        def __init__(self):
            super(SuperLaserLand_JD_RP_mock, self).__init__()

        # intercept inputs, this time throwing an exception:
        def read_adc_samples_from_DDR2(self):
            raise RP_PLL.CommsError()

    app = start_qt()
    sp = SLLSystemParameters()
    # also override some comms stuff:
    sl = SuperLaserLand_JD_RP_mock()
    sl.dev = count_calls_obj()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()
    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 0, (True, False, False), sp, '', '')

    # actual test call:
    xem_gui_mainwindow.grabAndExportData(bSyncReadOnNextTimeQuantization=False)

    assert(xem_gui_mainwindow.sl.bDDR2InUse == False)


def test_timerDitherEvent():
# timerDitherEvent:
# need to check: self.VCO_detected_gain_in_Hz_per_Volts[k]
# need to mock: 
# samples[k] = self.dev.read_Zynq_register_int64(BASE_ADDR_REAL_LSB*4, BASE_ADDR_REAL_MSB*4)

    class SuperLaserLand_JD_RP_mock(SuperLaserLand_JD_RP):
        def __init__(self):
            super(SuperLaserLand_JD_RP_mock, self).__init__()


    app = start_qt()
    sp = SLLSystemParameters()
    sl = SuperLaserLand_JD_RP_mock()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()

    class mock_dev():
        def read_Zynq_register_int64(self, address_uint32_lsb, address_uint32_msb):
            if address_uint32_lsb==4*sl.BUS_ADDR_DITHER0_LOCKIN_REAL_LSB:
                return np.frombuffer(np.array((10000, 0), np.dtype(np.uint32)), np.dtype(np.int64) )
                np.frombuffer(results, np.dtype(np.int64) )
            elif address_uint32_lsb==4*sl.BUS_ADDR_DITHER1_LOCKIN_REAL_LSB:
                return np.frombuffer(np.array((20000, 0), np.dtype(np.uint32)), np.dtype(np.int64) )
            else:
                print(address_uint32_lsb)
                raise Exception

    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 0, (True, False, False), sp, '', '')
    sl.dev = mock_dev()
    sl.dither_enable = [True, False, False]
    sl.dither_amplitude = [1e-3, 1e-3, 1e-3]
    sl.modulation_period_divided_by_4_minus_one = 3*[round(0.1*100e6/4-1)]
    sl.N_periods_integration_minus_one = 3*[10]

    # actual test call:
    xem_gui_mainwindow.timerDitherEvent()

    print(xem_gui_mainwindow.VCO_detected_gain_in_Hz_per_Volts)
    assert(abs(xem_gui_mainwindow.VCO_detected_gain_in_Hz_per_Volts[0] - -3.636e8)/3.636e8 < 1e-3)
    assert(abs(xem_gui_mainwindow.VCO_detected_gain_in_Hz_per_Volts[1] - 1)/1 < 1e-3)
    assert(abs(xem_gui_mainwindow.VCO_detected_gain_in_Hz_per_Volts[2] - 1)/1 < 1e-3)


    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 1, (False, True, True), sp, '', '')
    sl.dev = mock_dev()
    sl.dither_enable = (False, True, False)
    sl.dither_amplitude = [1e-3, 1e-3, 1e-3]
    sl.modulation_period_divided_by_4_minus_one = 3*[round(0.1*100e6/4-1)]
    sl.N_periods_integration_minus_one = 3*[10]
    # actual test call:
    xem_gui_mainwindow.timerDitherEvent()

    print(xem_gui_mainwindow.VCO_detected_gain_in_Hz_per_Volts)
    assert(abs(xem_gui_mainwindow.VCO_detected_gain_in_Hz_per_Volts[0] - -3.636e8)/3.636e8 < 1e-3)
    assert(abs(xem_gui_mainwindow.VCO_detected_gain_in_Hz_per_Volts[1] - -7.2725e8)/7.2725e8 < 1e-3)
    assert(abs(xem_gui_mainwindow.VCO_detected_gain_in_Hz_per_Volts[2] - 1)/1 < 1e-3)



def test_timerDitherEvent_with_exception():

    class SuperLaserLand_JD_RP_mock(SuperLaserLand_JD_RP):
        def __init__(self):
            super(SuperLaserLand_JD_RP_mock, self).__init__()

    app = start_qt()
    sp = SLLSystemParameters()
    sl = SuperLaserLand_JD_RP_mock()
    sl.initSubModules() # this should definitely be moved to SuperLaserLand_JD_RP.__init__()

    class mock_dev():
        def read_Zynq_register_int64(self, address_uint32_lsb, address_uint32_msb):
            raise RP_PLL.CommsError()

    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 0, (True, False, False), sp, '', '')
    sl.dev = mock_dev()
    sl.dither_enable = [True, False, False]
    sl.dither_amplitude = [1e-3, 1e-3, 1e-3]
    sl.modulation_period_divided_by_4_minus_one = 3*[round(0.1*100e6/4-1)]
    sl.N_periods_integration_minus_one = 3*[10]

    # actual test call:
    xem_gui_mainwindow.timerDitherEvent()


    xem_gui_mainwindow = XEM_GUI_MainWindow(sl, 'Testing window', 1, (False, True, True), sp, '', '')
    sl.dev = mock_dev()
    sl.dither_enable = (False, True, False)
    sl.dither_amplitude = [1e-3, 1e-3, 1e-3]
    sl.modulation_period_divided_by_4_minus_one = 3*[round(0.1*100e6/4-1)]
    sl.N_periods_integration_minus_one = 3*[10]
    # actual test call:
    xem_gui_mainwindow.timerDitherEvent()


# timerEvent(self, e):
# need to mock:
# (LED_G0, LED_R0, LED_G1, LED_R1, LED_G2, LED_R2) = self.sl.readLEDs()