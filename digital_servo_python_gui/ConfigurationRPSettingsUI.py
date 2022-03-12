# -*- coding: utf-8 -*-
"""
June 2017

Description: Provides a graphical user interface (GUI) to configure the RP 
@author: Alex Tourigny-Plante
"""

from PyQt5 import QtGui, Qt, QtCore, QtWidgets
#import PyQt4.Qwt5 as Qwt
import numpy as np
import weakref
import sys

import time

import traceback

from user_friendly_QLineEdit import user_friendly_QLineEdit

from SuperLaserLand_JD_RP import SuperLaserLand_JD_RP
from SocketErrorLogger import logCommsErrorsAndBreakoutOfFunction
import DataLoggingDisplayWidget


class ConfigRPSettingsUI(Qt.QWidget):
    """docstring for ConfigRP"""
    def __init__(self, sl, sp, controller, custom_style_sheet='', custom_shorthand=''):
        super(ConfigRPSettingsUI, self).__init__()  
        self.sl = weakref.proxy(sl)
        self.sp = sp
        self.setObjectName('MainWindow')
        self.setStyleSheet(custom_style_sheet)
        self.custom_shorthand = custom_shorthand
        self.f_ext = 10e6 # TODO: make this configurable from the gui and xml file

        self.controller = weakref.proxy(controller) #link to the top class

        self.initUI()
        self.loadParameters()

    def loadParameters(self):
        #print("ConfigurationRPSettingsUI::loadParameters()")
        # Load the default parameters from the selected xml file (select by the devices_data dictionnary in the controller class)
        fan_state = int((self.sp.getValue('RP_settings', "Fan_state")))
        mux_pll2 = int((self.sp.getValue('RP_settings', "PLL2_connection")))
        mux_vco = int((self.sp.getValue('VCO_settings', "VCO_connection")))
        vco_amplitude = float((self.sp.getValue('VCO_settings', "VCO_amplitude")))
        vco_offset = float((self.sp.getValue('VCO_settings', "VCO_offset")))
        clk_select = int((self.sp.getValue('RP_settings', "Clock_select")))

        #print("ConfigurationRPSettingsUI::loadParameters(): after read GUI")

        if clk_select > 0:
            self.qradio_internal_clk.setChecked(True)
        else:
            self.qradio_external_clk.setChecked(True)

        if fan_state > 0:
            self.qradio_fan_on.setChecked(True)
        else:
            self.qradio_fan_off.setChecked(True)

        if mux_pll2 == 1:
            self.qradio_ddc1_to_pll2.setChecked(True)
        elif mux_pll2 == 2:
            self.qradio_pll1_to_pll2.setChecked(True)
        else:
            self.qradio_ddc2_to_pll2.setChecked(True)

        if mux_vco == 1:
            self.qradio_VCO_to_DAC0.setChecked(True)
        elif mux_vco == 2:
            self.qradio_VCO_to_DAC1.setChecked(True)
        else:
            self.qradio_no_VCO.setChecked(True)

        self.qedit_int_vco_amplitude.blockSignals(True)
        self.qedit_int_vco_amplitude.setText('{:.3f}'.format(vco_amplitude))
        self.qedit_int_vco_amplitude.blockSignals(False)

        self.qedit_int_vco_offset.blockSignals(True)
        self.qedit_int_vco_offset.setText('{:.3f}'.format(vco_offset))
        self.qedit_int_vco_offset.blockSignals(False)

        #print("ConfigurationRPSettingsUI::loadParameters(): end")

    def pushDefaultValues(self):
        # Push the values from the xml file to the red pitaya (load + send)
        self.loadParameters()
        self.pushValues()
        self.startTimers()

    def pushValues(self):
        # Send the values in the different fields to the RP
        self.mux_vco_Action()
        self.mux_pll2_Action()
        self.setInternalVCO_amplitude()
        self.setFan()
        self.setClkSelect()

    @logCommsErrorsAndBreakoutOfFunction()
    def getValues(self):
        #get value from the memory of the red pitaya 

        #get value for the VCO connection
        mux_vco = self.sl.get_mux_vco()
        if mux_vco == 1:
            self.qradio_VCO_to_DAC0.setChecked(True)
        elif mux_vco == 2:
            self.qradio_VCO_to_DAC1.setChecked(True)
        else:
            self.qradio_no_VCO.setChecked(True)

        #get value for the VCO amplitude
        amplitude = self.sl.get_internal_VCO_amplitude()
        self.qedit_int_vco_amplitude.blockSignals(True)
        self.qedit_int_vco_amplitude.setText('{:.3f}'.format(amplitude))
        self.qedit_int_vco_amplitude.blockSignals(False)

        #get value for the VCO offset
        offset = self.sl.get_internal_VCO_offset()
        self.qedit_int_vco_offset.blockSignals(True)
        self.qedit_int_vco_offset.setText('{:.3f}'.format(offset))
        self.qedit_int_vco_offset.blockSignals(False)

        #get value for the pll2 connection
        mux_pll2 = self.sl.read_pll2_mux()
        if mux_pll2 == 0:
            self.qradio_ddc2_to_pll2.setChecked(True)
        elif mux_pll2 == 1:
            self.qradio_ddc1_to_pll2.setChecked(True)
        elif mux_pll2 == 2:
            self.qradio_pll1_to_pll2.setChecked(True)
        
        # # clock source
        print("FIXME: read out current clock settings!")
        # self.sl.deprecated_readADCclockSettings(f_external=self.f_ext)
        # if self.sl.bExternalClock:
        #     self.qradio_external_clk.setChecked(True)
        # else:
        #     self.qradio_internal_clk.setChecked(True)


        self.startTimers()

    def startTimers(self):
    # This gets called when we have a valid connection to a device.
        self.timerXADC.start(500)

    def killTimers(self):
    # This gets called by the controller object in XEM_GUI3.py when we lose connection to a device.
        self.timerXADC.stop()


    def initUI(self):

        ###################################################################################

        self.qgroupbox_clkselect = Qt.QGroupBox('Clock source')
        self.qgroupbox_clkselect.setAutoFillBackground(True)
        grid = Qt.QGridLayout()

        self.qradio_internal_clk = Qt.QRadioButton('Internal clock')
        self.qradio_external_clk = Qt.QRadioButton('External clock')
        self.qradio_internal_clk.setChecked(True)
        self.qradio_internal_clk.clicked.connect(self.setClkSelect)
        self.qradio_external_clk.clicked.connect(self.setClkSelect)
        self.lblExtClkFreq = Qt.QLabel('Ext clk freq = %.6f MHz' % 0.0)
        self.lblDinFreq    = Qt.QLabel('Din freq     = %.6f MHz' % 0.0)

        grid.addWidget(self.qradio_internal_clk, 0, 0)
        grid.addWidget(self.qradio_external_clk, 1, 0)
        grid.addWidget(self.lblExtClkFreq,       2, 0)
        grid.addWidget(self.lblDinFreq,          3, 0)

        #grid.setRowStretch(2, 2)

        self.qgroupbox_clkselect.setLayout(grid)

        ###################################################################################

        self.qgroupbox_xadc = Qt.QGroupBox('XADC inputs')
        self.qgroupbox_xadc.setAutoFillBackground(True)
        grid = Qt.QGridLayout()

        self.time_start = time.perf_counter()
        self.qplots = DataLoggingDisplayWidget.DataLoggingDisplayWidget(numPlots=1, numCurvesPerPlot=1)
        self.qplots.pltItemsList[0].setLabel('left', 'Temp [degC]')
        # self.qplots.show()


        self.qlbl_Temp   = Qt.QLabel('Zynq temperature: %.2f degC' % 0.)
        self.qlbl_vccint = Qt.QLabel('Vccint = %.2f V' % 0.)
        self.qlbl_vccaux = Qt.QLabel('Vccaux = %.2f V' % 0.)
        self.qbtn_OpenTempGraph = Qt.QPushButton('Open temperature display window')
        self.qbtn_OpenTempGraph.clicked.connect(self.qplots.show)

        grid.addWidget(self.qlbl_Temp, 0, 0, 1, 2)
        grid.addWidget(self.qlbl_vccint, 1, 0)
        grid.addWidget(self.qlbl_vccaux, 2, 0)
        grid.addWidget(self.qbtn_OpenTempGraph, 2, 1)

        #grid.setRowStretch(2, 2)

        self.qgroupbox_xadc.setLayout(grid)

        # polling timer for the xadc values:
        self.timerXADC = Qt.QTimer(self)
        self.timerXADC.timeout.connect(self.timerXADCEvent)

        ###################################################################################

        self.qgroupbox_MUX_vco = Qt.QGroupBox('Select VCO connection')
        self.qgroupbox_MUX_vco.setAutoFillBackground(True)
        MUX_vco = Qt.QGridLayout()

        self.qradio_VCO_to_DAC0 = Qt.QRadioButton('PLL A -> VCO -> DAC A')
        self.qradio_VCO_to_DAC1 = Qt.QRadioButton('PLL B -> VCO -> DAC B')
        self.qradio_no_VCO = Qt.QRadioButton('VCO not used')
        self.qradio_no_VCO.setChecked(True)
        self.qradio_VCO_to_DAC0.clicked.connect(self.mux_vco_Action)
        self.qradio_VCO_to_DAC1.clicked.connect(self.mux_vco_Action)
        self.qradio_no_VCO.clicked.connect(self.mux_vco_Action)

        self.qlabel_int_vco_amplitude = Qt.QLabel('Internal VCO Amplitude [0-1]')
        self.qedit_int_vco_amplitude = user_friendly_QLineEdit('0.5')
        self.qedit_int_vco_amplitude.returnPressed.connect(self.setInternalVCO_amplitude)
        self.qedit_int_vco_amplitude.setMaximumWidth(100)

        self.qlabel_int_vco_offset = Qt.QLabel('Internal VCO offset [0-1]')
        self.qedit_int_vco_offset = user_friendly_QLineEdit('0.0')
        self.qedit_int_vco_offset.returnPressed.connect(self.setInternalVCO_offset)
        self.qedit_int_vco_offset.setMaximumWidth(60)

        MUX_vco.addWidget(self.qradio_VCO_to_DAC0,     0, 0)    
        MUX_vco.addWidget(self.qradio_VCO_to_DAC1,     1, 0)
        MUX_vco.addWidget(self.qradio_no_VCO,          2, 0)
        MUX_vco.addWidget(self.qlabel_int_vco_offset, 1,1)
        MUX_vco.addWidget(self.qedit_int_vco_offset, 1,2)
        MUX_vco.addWidget(self.qlabel_int_vco_amplitude, 2,1)
        MUX_vco.addWidget(self.qedit_int_vco_amplitude, 2,2)
        MUX_vco.addItem(Qt.QSpacerItem(0, 0, Qt.QSizePolicy.MinimumExpanding, Qt.QSizePolicy.Minimum), 2, 0)
        MUX_vco.setRowStretch(2, 2)

        self.qgroupbox_MUX_vco.setLayout(MUX_vco)

        ###################################################################################
        self.qgroupbox_MUX_pll2 = Qt.QGroupBox('Select connection to PLL 2')
        self.qgroupbox_MUX_pll2.setAutoFillBackground(True)
        MUX_pll2 = Qt.QGridLayout()

        self.qradio_ddc1_to_pll2 = Qt.QRadioButton('DDC_a output to PLL_b input')
        self.qradio_pll1_to_pll2 = Qt.QRadioButton('DAC_a output to PLL_b input (cascade lock)')
        self.qradio_ddc2_to_pll2 = Qt.QRadioButton('DDC_b output to PLL_b input')
        self.qradio_ddc2_to_pll2.setChecked(True)
        self.qradio_pll1_to_pll2.clicked.connect(self.mux_pll2_Action)
        self.qradio_ddc1_to_pll2.clicked.connect(self.mux_pll2_Action)
        self.qradio_ddc2_to_pll2.clicked.connect(self.mux_pll2_Action)

        MUX_pll2.addWidget(self.qradio_ddc1_to_pll2,     0, 0)
        MUX_pll2.addWidget(self.qradio_pll1_to_pll2,     1, 0)
        MUX_pll2.addWidget(self.qradio_ddc2_to_pll2,     2, 0)
        MUX_pll2.setRowStretch(2, 0)

        self.qgroupbox_MUX_pll2.setLayout(MUX_pll2)


        ###################################################################################
        self.qgroupbox_read_data = Qt.QGroupBox('Read data from dpll (channel 2)')
        self.qgroupbox_read_data.setAutoFillBackground(True)
        read_data = Qt.QGridLayout()

        self.qlabel_addr = Qt.QLabel('Address: 0x')
        self.qedit_addr = user_friendly_QLineEdit('9000')
        self.qedit_addr.setMaximumWidth(100)

        self.qlabel_data = Qt.QLabel('Data:')
        self.qedit_data = user_friendly_QLineEdit('0')
        self.qedit_data.setMaximumWidth(300)

        self.qbtn_1 = QtGui.QPushButton('Read data')
        self.qbtn_1.clicked.connect(self.read_RP)


        read_data.addWidget(self.qlabel_addr,     0, 0)
        read_data.addWidget(self.qedit_addr,     0, 1)
        read_data.addWidget(self.qlabel_data,     1, 0)
        read_data.addWidget(self.qedit_data,     1, 1, 1, 2)
        read_data.addWidget(self.qbtn_1,         0, 2)

        read_data.setRowStretch(1, 2)

        self.qgroupbox_read_data.setLayout(read_data)

        ###################################################################################

        self.qgroupbox_fanUI = Qt.QGroupBox('Turn fan on/off')
        self.qgroupbox_fanUI.setAutoFillBackground(True)
        fanUI = Qt.QGridLayout()

        self.qradio_fan_on  = Qt.QRadioButton('Fan on')
        self.qradio_fan_off = Qt.QRadioButton('Fan off')
        self.qradio_fan_on.setChecked(True)
        self.qradio_fan_on.clicked.connect(self.setFan)
        self.qradio_fan_off.clicked.connect(self.setFan)

        fanUI.addWidget(self.qradio_fan_on,     0, 0)
        fanUI.addWidget(self.qradio_fan_off,     1, 0)

        #fanUI.setRowStretch(2, 2)

        self.qgroupbox_fanUI.setLayout(fanUI)

        ###################################################################################

        self.qbtn_reconnect = QtGui.QPushButton('Open communication menu')
        self.qbtn_reconnect.clicked.connect(self.communication_menu)


        ###################################################################################
            
        self.group = Qt.QGroupBox('RP configuration')
        self.group.setAutoFillBackground(True)
        group = Qt.QGridLayout()

        group.addWidget(self.qgroupbox_clkselect, 0, 0, 1, 1)
        group.addWidget(self.qgroupbox_xadc,      0, 1, 1, 2)
        group.addWidget(self.qgroupbox_MUX_vco,   1, 0, 1, 3)
        group.addWidget(self.qgroupbox_MUX_pll2,  2, 0, 1, 3)
        group.addWidget(self.qgroupbox_read_data, 3, 0, 1, 3)
        group.addWidget(self.qgroupbox_fanUI,     4, 0, 1, 1)
        group.addWidget(self.qbtn_reconnect,      4, 1, 1, 1)

        #vbox = Qt.QVBoxLayout()
        #vbox.addStretch(1)
        self.group.setLayout(group)

        grid = Qt.QGridLayout()
        grid.addWidget(self.group)
        self.setLayout(grid)





        #self.center()
        self.setWindowTitle(self.custom_shorthand + ': RP Configuration')    
        #self.show()
        #self.show()

    @logCommsErrorsAndBreakoutOfFunction()
    def timerXADCEvent(self):
        # read from xadc registers:
        # print(self.qplots.isVisible())

        if not self.sl.dev.valid_socket:
            return
        try:
            (Vccint, Vccaux, Vbram) = self.sl.readZynqXADCsupply()
            ZynqTempInDegC          = self.sl.readZynqTemperature()
            # print('Zynq temperature (max 85 degC operating): %.2f degC' % ZynqTempInDegC)
            self.qlbl_Temp.setText('Zynq temperature (max 85 degC operating): %.2f degC' % ZynqTempInDegC)
            self.qlbl_vccint.setText('Vccint = %.2f V' % Vccint)
            self.qlbl_vccaux.setText('Vccaux = %.2f V' % Vccaux)

            self.qplots.addDataPoint(time.perf_counter()-self.time_start, [ZynqTempInDegC])
        except:
            self.qlbl_Temp          = Qt.QLabel('Zynq temperature: N/A degC')
            self.qlbl_vccint        = Qt.QLabel('Vccint = N/A V')
            self.qlbl_vccaux        = Qt.QLabel('Vccaux = N/A V')


        # read ext clk frequency:
        try:
            self.lblExtClkFreq.setText('Ext clk freq = %.8f MHz' % (self.sl.getExtClockFreq()/1e6))

        except:
            self.lblExtClkFreq.setText('Ext clk freq = N/A MHz')

        freq = self.sl.getDin1Freq()
        if freq is not None:
            self.lblDinFreq.setText('Din freq     = %.8f MHz' % (freq/1e6))

    #Function to read the value in the RAM Block (channel 2) to an address
    #The data we should read are the data sent to dpll_wrapper module (channel 0)
    @logCommsErrorsAndBreakoutOfFunction()
    def read_RP(self, checked=False):
        addr = int(self.qedit_addr.text(),16)
        bus_address = (2 << 20) + addr*4
        value = str(self.sl.dev.read_Zynq_register_uint32(bus_address))
        self.qedit_data.blockSignals(True)
        self.qedit_data.setText(value)
        self.qedit_data.blockSignals(False)
    
        # bus_address = (2 << 20) + 0x9001*4
        # value = str(self.sl.dev.read_Zynq_register_uint32(bus_address))
        # print(value)

        # bus_address = (2 << 20) + 0x9000*4
        # value = str(self.sl.dev.read_Zynq_register_uint32(bus_address))
        # print(value)        


    def communication_menu(self):
        # Open the initial menu in which we select the RP and if we want to reconnect to one. We can open a new connection without closing the GUI
        self.controller.connectionGUI()
        

    def center(self):
        qr = self.frameGeometry()
        cp = QtGui.QDesktopWidget().availableGeometry().center()
        qr.moveCenter(cp)
        #self.move(qr.topLeft())
        #self.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(50, 50))

    @logCommsErrorsAndBreakoutOfFunction()
    def setFan(self, checked=False):
        # Set the output of 2 IO pins (0 or 3.3V) for the activation of the fan
        self.sl.setFan(self.qradio_fan_on.isChecked())

    @logCommsErrorsAndBreakoutOfFunction()
    def setClkSelect(self, checked=False):
        if self.qradio_external_clk.isChecked():
            # Valid VCO range is 600 MHz-1600 MHz according to DS181

            CLKFBOUT_MULT  = 5
            CLKOUT0_DIVIDE = 8
            # # For self.f_ext=200 MHz external clock input, these settings should yield 125 MHz ADC clock, 1000 MHz VCO

            # CLKFBOUT_MULT  = 62
            # CLKOUT0_DIVIDE = 5
            # For self.f_ext=10 MHz external clock input, these settings should yield 124 MHz ADC clock, 620 MHz VCO

            # # For self.f_ext=25 MHz external clock input, these settings should yield 125 MHz ADC clock, 1000 MHz VCO
            # CLKFBOUT_MULT  = 40
            # CLKOUT0_DIVIDE = 8

            self.sl.setADCclockPLL(self.f_ext, self.qradio_external_clk.isChecked(), CLKFBOUT_MULT, CLKOUT0_DIVIDE)

        else:
            # For 200 MHz clock (internal), these settings should yield 125 MHz ADC clock, 1000 MHz VCO
            f_int          = 200e6
            CLKFBOUT_MULT  = 5
            CLKOUT0_DIVIDE = 8

            self.sl.setADCclockPLL(f_int, self.qradio_external_clk.isChecked(), CLKFBOUT_MULT, CLKOUT0_DIVIDE)


        # make sure to update the lockpoint frequencies, in case the ADC clock frequency changed:
        self.controller.xem_gui_mainwindow.setVCOFreq_event()
        self.controller.xem_gui_mainwindow2.setVCOFreq_event()

    @logCommsErrorsAndBreakoutOfFunction()
    def mux_vco_Action(self, checked=False):
        if self.qradio_VCO_to_DAC0.isChecked():
            data = 1
        elif self.qradio_VCO_to_DAC1.isChecked():
            data = 2
        else:  # no VCO is checked
            data = 0
        self.sl.set_mux_vco(data)

    @logCommsErrorsAndBreakoutOfFunction()
    def setInternalVCO_offset(self):
        try:
            int_vco_offset = float(self.qedit_int_vco_offset.text())
        except:
            int_vco_offset = 0.0
        if int_vco_offset < -1.0 or int_vco_offset > 1.0:
            int_vco_offset = 0.0
        
        self.sl.set_internal_VCO_offset(int_vco_offset)

    @logCommsErrorsAndBreakoutOfFunction()
    def setInternalVCO_amplitude(self):
        try:
            int_vco_amplitude = float(self.qedit_int_vco_amplitude.text())
        except:
            int_vco_amplitude = 0.5
        if int_vco_amplitude < -1 or int_vco_amplitude > 1:
            int_vco_amplitude = 0.5
            self.qedit_int_vco_amplitude.blockSignals(True)
            self.qedit_int_vco_amplitude.setText('{:.3f}'.format(int_vco_amplitude))
            self.qedit_int_vco_amplitude.blockSignals(False)
        
        self.sl.set_internal_VCO_amplitude(int_vco_amplitude)
      
    @logCommsErrorsAndBreakoutOfFunction()
    def mux_pll2_Action(self, checked=False):
        if self.qradio_ddc1_to_pll2.isChecked():
            data = 1
        elif self.qradio_pll1_to_pll2.isChecked():
            data = 2
        else: #self.qradio_ddc2_to_pll2.isChecked()
            data = 0
        self.sl.set_mux_pll2(data)


    
if __name__ == '__main__':

    #app = QApplication(sys.argv)
    app = QtCore.QCoreApplication.instance()
    if app is None:
        app = QtWidgets.QApplication(sys.argv)

    sl = SuperLaserLand_JD_RP()
    w = ConfigRPSettingsUI(sl)
    w.show()
    w.resize(800, 300)


    app.exec_()


    #####################################################################
    # Reference code for interacting with the new ADC PLL settings:
    #####################################################################
    # def setADCclockPLL(self, f_ref, bExternalClock):
    #     """ Computes and commits closest integer-N solution for the ADC clock.
    #     In internal clock mode, f_ref is ignored (overriden by the 200 MHz internal clock) """
    #     print("setADCclockPLL(): f_ref=", f_ref)
    #     self.user_inputs["bExternalClock"] = bExternalClock
    #     if bExternalClock:
    #         (M, N) = zynq_mmcm.get_integer_N_solution(f_ref, f_target_adc=125e6)
    #         self.user_inputs["adc_f_ref_hz"]   = f_ref
    #         self.user_inputs["CLKFBOUT_MULT"]  = M
    #         self.user_inputs["CLKOUT0_DIVIDE"] = N
    #         self._setADCclockPLL()
    #     else:
    #         # we are not even using the MMCM
    #         self.user_inputs["adc_f_ref_hz"]   = 125e6
    #         self.user_inputs["CLKFBOUT_MULT"]  = 1
    #         self.user_inputs["CLKOUT0_DIVIDE"] = 1
    #         self._setClkSelectAndReset(False, bExternalClock)

    # def _setADCclockPLL(self):
    #     """ f_ref is the frequency of the clock connected to GPIO_P[5] in external clock mode """

    #     # From PG065:
    #     # "You should first write all the required clock configuration registers and then check for the
    #     # status register. If status register value is 0x1, start the reconfiguration by writing Clock
    #     # Configuration Register 23 with 0x7. The next write should be 0x2 before the Locked goes
    #     # High. If the original configuration is needed at any time, then writing this register with value
    #     # 0x4 and then 0x0 restores the original settings."

    #     # Clock configuration register 0 (table 4-2 in PG065)
    #     DIVCLK_DIVIDE = 1
    #     reg  = (DIVCLK_DIVIDE & ((1<<8)-1)) << 0
    #     reg |= (self.user_inputs["CLKFBOUT_MULT"] & ((1<<8)-1)) << 8
    #     self.write("clkw_reg0", reg)
    #     # Clock configuration register 2 (table 4-2 in PG065)
    #     reg = (self.user_inputs["CLKOUT0_DIVIDE"] & ((1<<8)-1)) << 0
    #     self.write("clkw_reg2", reg)

    #     # check status register:
    #     if not self._waitForReg("clkw_status", 0x1, timeout=1.0):
    #         print("Error: timed out waiting for status_reg to become 0x1 (PLL locked)")
    #         return

    #     self._setClkSelectAndReset(True, self.user_inputs["bExternalClock"]) # assert reset on the incoming ADC clock
    #     self.write("clkw_reg23", 0x7)
    #     self.write("clkw_reg23", 0x2) # this needs to happen before the locked status goes high according to the datasheet.  Not sure what the impact is if we don't honor this requirement

    #     self.fs = self.user_inputs["adc_f_ref_hz"] * self.user_inputs["CLKFBOUT_MULT"]/self.user_inputs["CLKOUT0_DIVIDE"]
    #     time.sleep(0.1)
    #     self._setClkSelectAndReset(False, self.user_inputs["bExternalClock"]) # de-assert reset on the incoming ADC clock

    # def _waitForReg(self, reg_name, desired_value, timeout=1.):
    #     """ Read a register in a loop, until it either becomes a desired value or we hit a timeout.
    #     Returns True if the register reached the desired value, False if we timed out """
    #     time_start = time.perf_counter()
    #     reg_value = self.read(reg_name)
    #     while reg_value != desired_value and time.perf_counter()-time_start < timeout: # read in a loop until we timeout
    #         reg_value = self.read(reg_name)
    #         time.sleep(1e-3)
    #     return reg_value == desired_value

    # def _setClkSelectAndReset(self, bReset, bExternalClock):
    #     """ Select external or internal clock source, and also sets the reset """
    #     reg_clk_sel_and_reset = int(not bExternalClock) | (int(bReset)<<1)
    #     self.write("clk_sel_and_reset", reg_clk_sel_and_reset)


    # def getClkStatus(self):
    #     """ Returns four boolean flags:
    #     (loss_of_clk_detected, clk_ext_good, clk_int_or_ext_actual, clk_int_or_ext_desired)
    #     loss_of_clk_detected is True if the user set external clock mode, but the system fell back to internal clock mode
    #     at any point since the last reading of this flag.
    #     clk_int_or_ext_desired = True means internal clock
    #     clk_int_or_ext_actual = True means internal clock
    #     """
    #     reg_value = self.read("ext_clk_status")
    #     loss_of_clk_detected   = bool((reg_value>>3) & 0x1)
    #     clk_ext_good           = bool((reg_value>>2) & 0x1)
    #     clk_int_or_ext_actual  = bool((reg_value>>1) & 0x1)
    #     clk_int_or_ext_desired = bool((reg_value>>0) & 0x1)
    #     return (loss_of_clk_detected, clk_ext_good, clk_int_or_ext_actual, clk_int_or_ext_desired)

    # def getHardwareDescription(self):
    #     """ Returns a dictionary with various flags describing the hardware on the connected device """
    #     d = dict()
    #     f = self.dev.read_file_from_remote("/opt/hardware.txt")
    #     f = f.decode('ascii')
    #     # f = "has_dds=1\nhas_mixer_board=1\n" # for testing
    #     for line in f.split('\n'):
    #         if line == '':
    #             continue
    #         key, value = line.split('=')
    #         d[key] = bool(int(value))

    #     f = self.dev.read_file_from_remote("/opt/macaddress.txt")
    #     f = f.decode('ascii')
    #     if f == '':
    #         self.dev.send_shell_command('ifconfig | grep eth0 > /opt/macaddress.txt')
    #         time.sleep(0.1)
    #         f = self.dev.read_file_from_remote("/opt/macaddress.txt")
    #         f = f.decode('ascii')

    #     mac_token = 'HWaddr '
    #     ind = f.find(mac_token)
    #     if ind != -1:
    #         d["mac"] = f[ind+len(mac_token):].strip()
    #     return d

    # def sendHardwareDescription(self, bHasMixerBoard=False, bHasDDS=False):
    #     """ Creates a file that describes various add-ons to the RP,
    #     and sends it to the currently-connected device.
    #     To be used only once when upgrading a given RP """
    #     description = "has_mixer_board=%d\n" % int(bool(bHasMixerBoard))
    #     description += "has_dds=%d\n" % int(bool(bHasDDS))
    #     file_data = description.encode('ascii')
    #     self.dev.write_file_on_remote("", strFilenameRemote="/opt/hardware.txt", file_data=file_data)

