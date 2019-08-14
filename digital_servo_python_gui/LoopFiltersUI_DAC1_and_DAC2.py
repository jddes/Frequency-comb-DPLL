# -*- coding: utf-8 -*-
"""
Created on Wed Dec 04 20:48:43 2013

Description: Provides a graphical user interface (GUI) for setting the loop filters parameters of the loop filter for DAC1 and the two integrators for DAC2 implemented in the XEM6010 module.
@author: JD Deschenes
"""
from __future__ import print_function
from PyQt5 import QtGui, Qt, QtCore
import numpy as np
import weakref

import traceback
import time

from LoopFiltersUI import LoopFiltersUI

class LoopFiltersUI_DAC1_and_DAC2(Qt.QWidget):
    
    MINIMUM_GAIN_DISPLAY = 10**(-120/20)
    kc = 1
    kc_dac2 = 1
    
    def __init__(self, sl, filter_number=0, pll=0):
        super(LoopFiltersUI_DAC1_and_DAC2, self).__init__()
        
        # Create the widget which will control the DAC1 loop filters:
        bDisplayLockChkBox = False   # true for debug only
        self.bDisplayLockChkBox = bDisplayLockChkBox
        self.dac1_ui = LoopFiltersUI(sl, filter_number, bDisplayLockChkBox)

        # We need sl here because we need to pass it to the pll object, and we need fs to set the correct loop filter gain, because the integrators transfer function depends on that fs
        self.sl = weakref.proxy(sl)
        self.filter_number = filter_number
        # All the gains here are normalized to the DC, open-loop gain of the overall system:
        self.kc = 1

        
        # Init our GUI
        self.initUI()
        
    def checkFirmwareLimits(self):
        self.dac1_ui.checkFirmwareLimits()
    
    def updateFilterSettings(self):
        self.dac1_ui.updateFilterSettings()

    def getValues(self):
        self.dac1_ui.kc = self.kc
        self.dac1_ui.getValues()
        self.getIntegratorGainEvent()

    def loadParameters(self, sp):
        slowDAC_number = 2
        self.dac1_ui.loadParameters(sp)

        try:
            strPLL = 'PLL{:01d}_settings'.format(slowDAC_number)
            LoopFilter = int(sp.getValue(strPLL, 'LoopFilter'))
            flipsign1 = bool(sp.getValue(strPLL, 'flip_acquisition').lower() == 'true')
            flipsign2 = bool(sp.getValue(strPLL, 'flip_lock').lower() == 'true')
            gain1_in_bits = int(sp.getValue(strPLL, 'AcqGain'))
            gain2_in_bits = int(sp.getValue(strPLL, 'LockGain'))
        except:
            # the xml file was not modified to contain the infos of the 3rd DAC
            print('Cannot load values from xml file')
            LoopFilter = 0
            flipsign1 = False
            flipsign2 = False
            gain1_in_bits = -20
            gain2_in_bits = -20

        loop_filter_mode_to_radio = {0: self.qradio_mode_off,   # mode off
                                     1: self.qradio_mode_slow,  # mode slow
                                     2: self.qradio_mode_fast,  # mode fast
                                     3: self.qradio_mode_both   # mode both
                                     }
        def checkWithoutSignals(target_radio):
            target_radio.blockSignals(True)
            target_radio.setChecked(True)
            target_radio.blockSignals(False)

        checkWithoutSignals(target_radio = loop_filter_mode_to_radio[LoopFilter])

        self.qchk_flip1.blockSignals(True)
        self.qchk_flip1.setChecked(flipsign1)
        self.qchk_flip1.blockSignals(False)
        self.qcombo_int1_gain.blockSignals(True)
        self.qcombo_int1_gain.setCurrentIndex(gain1_in_bits+32)
        self.qcombo_int1_gain.blockSignals(False)

        self.qchk_flip2.blockSignals(True)
        self.qchk_flip2.setChecked(flipsign2)
        self.qchk_flip2.blockSignals(False)
        self.qcombo_int2_gain.blockSignals(True)
        self.qcombo_int2_gain.setCurrentIndex(gain2_in_bits+32)
        self.qcombo_int2_gain.blockSignals(False)

        self.updateSettings()



        
    def updateGraph(self):
        # this call is meant for the underlying LoopFilterUI() object:
        self.dac1_ui.updateGraph()
        # However, that could also mean that we need to re-update our settings based on a new value of kc:
        #self.setIntegratorGainEvent()
        
    def getIntegratorGainEvent(self):
        (hold1, flipsign1, lock_integrator1, gain1_in_bits) = self.sl.get_integrator_settings(integrator_number = 1)
        (hold2, flipsign2, lock_integrator2, gain2_in_bits) = self.sl.get_integrator_settings(integrator_number = 2)
        
        if (lock_integrator1 == 0) & (lock_integrator2 == 0):
            #mode off
            self.qradio_mode_off.blockSignals(True)
            self.qradio_mode_off.setChecked(True)
            self.qradio_mode_off.blockSignals(False)
        elif (hold1 == 1) & (hold2 == 1):
            # mode fase
            self.qradio_mode_fast.blockSignals(True)
            self.qradio_mode_fast.setChecked(True)
            self.qradio_mode_fast.blockSignals(False)
        elif hold2 == 1:
            #mode slow
            self.qradio_mode_slow.blockSignals(True)
            self.qradio_mode_slow.setChecked(True)
            self.qradio_mode_slow.blockSignals(False)
        elif hold1 == 1:
            #mode both (this was selected either by checking the lock button or by selecting the radio button)
            self.qradio_mode_both.blockSignals(True)
            self.qradio_mode_both.setChecked(True)
            self.qradio_mode_both.blockSignals(False)

        self.qchk_flip1.blockSignals(True)
        self.qchk_flip1.setChecked(flipsign1)
        self.qchk_flip1.blockSignals(False)
        self.qcombo_int1_gain.blockSignals(True)
        self.qcombo_int1_gain.setCurrentIndex(gain1_in_bits+32)
        self.qcombo_int1_gain.blockSignals(False)

        self.qchk_flip2.blockSignals(True)
        self.qchk_flip2.setChecked(flipsign2)
        self.qchk_flip2.blockSignals(False)
        self.qcombo_int2_gain.blockSignals(True)
        self.qcombo_int2_gain.setCurrentIndex(gain2_in_bits+32)
        self.qcombo_int2_gain.blockSignals(False)

        self.updateSettings() #to makes sure the GUI contains all the infos relative to the previous parameters



    def setIntegratorGainEvent(self):
#        print('LoopFiltersUI_DAC1_and_DAC2::setIntegratorGainEvent(): TODO!')
        
        gain1_in_bits = int(self.qcombo_int1_gain.currentIndex()) - 32
        
        
#        print(gain1_in_bits)
        if self.qradio_mode_off.isChecked():
            # All off
            lock_integrator1 = 0
            lock_integrator2 = 0
            hold1 = 0
            hold2 = 0
        elif self.qradio_mode_slow.isChecked():
            # Only first integrator
            lock_integrator1 = 1
            lock_integrator2 = 1
            hold1 = 0
            hold2 = 1
            
        elif self.qradio_mode_fast.isChecked():
            # Only fast PZT, hold both
            lock_integrator1 = 1
            lock_integrator2 = 1
            hold1 = 1
            hold2 = 1
            
        elif self.qradio_mode_both.isChecked():
            # Only integrator 2, hold integrator 1
            lock_integrator1 = 1
            lock_integrator2 = 1
            hold1 = 1
            hold2 = 0
        

        gain2_in_bits = int(self.qcombo_int2_gain.currentIndex()) - 32
        
        flipsign1 = int(self.qchk_flip1.isChecked())
        flipsign2 = int(self.qchk_flip2.isChecked())
        # Override for both hold signals:
        if self.qchk_hold.isChecked():
            hold1 = 1
            hold2 = 1
#        print('integrator 1, flipsign = %d, lock = %d, gain1 = %d' % (flipsign1, lock_integrator1, gain1_in_bits))
#        print('integrator 2, flipsign = %d, lock = %d, gain1 = %d' % (flipsign2, lock_integrator2, gain2_in_bits))
        self.sl.set_integrator_settings(1, hold1, flipsign1, lock_integrator1, gain1_in_bits)
        self.sl.set_integrator_settings(2, hold2, flipsign2, lock_integrator2, gain2_in_bits)
        
    
        if lock_integrator1 and hold1:
            self.qlabel_int1_state.setText('Integrator 1 state: On, hold')
        elif lock_integrator1:
            self.qlabel_int1_state.setText('Integrator 1 state: On')
        else:
            self.qlabel_int1_state.setText('Integrator 1 state: Off')
            
                 
        if lock_integrator2 and hold2:
            self.qlabel_int2_state.setText('Integrator 2 state: On, hold')
        elif lock_integrator2:
            self.qlabel_int2_state.setText('Integrator 2 state: On')
        else:
            self.qlabel_int2_state.setText('Integrator 2 state: Off')
            
        closedloop_BW = self.kc_dac2*2**gain1_in_bits * self.sl.fs /(2*np.pi)
        
        if closedloop_BW > 1e6:
            self.qlabel_int1_gain.setText('Acquisition BW: %.1f MHz' % (round(closedloop_BW*1e5)/1e5/1e6))
        elif closedloop_BW > 1e3:
            self.qlabel_int1_gain.setText('Acquisition BW: %.1f kHz' % (round(closedloop_BW*1e2)/1e2/1e3))
        elif closedloop_BW > 1:
            self.qlabel_int1_gain.setText('Acquisition BW: %.1f Hz' % (round(closedloop_BW)))
        else:
            self.qlabel_int1_gain.setText('Acquisition BW: %.3f Hz' % ((closedloop_BW)))
            
        # Predict the closed-loop BW based on the chosen gain:
        # Second case: integrator 2, which integrates the DAC 1 output and outputs a signal on DAC2 HV.
        # The plant model in this case has a DC gain equal to the ratio of the VCO gain seen at DAC2 HV / VCO gain seen at DAC 1 HV:
        
        # Gain of the integrator as a function of frequency is 2^gain1_in_bits * self.sl.fs /(2*pi*f)
        # We want the unity gain frequency where G_integrator*Kc = 1 = Kc*2^gain1_in_bits * self.sl.fs /(2*pi*f)
        # so that f = Kc*2^gain1_in_bits * self.sl.fs /(2*pi)
        closedloop_BW = self.kc_dac2/self.kc *2**gain2_in_bits * self.sl.fs /(2*np.pi)
        
        if closedloop_BW > 1e6:
            self.qlabel_int2_gain.setText('Lock BW: %.1f MHz' % (round(closedloop_BW*1e5)/1e5/1e6))
        elif closedloop_BW > 1e3:
            self.qlabel_int2_gain.setText('Lock BW: %.1f kHz' % (round(closedloop_BW*1e2)/1e2/1e3))
        elif closedloop_BW > 1:
            self.qlabel_int2_gain.setText('Lock BW: %.1f Hz' % (round(closedloop_BW)))
        else:
            self.qlabel_int2_gain.setText('Lock BW: %.3f Hz' % ((closedloop_BW)))
            
        
        
    def updateSettings(self):
        
        # Need to also call an update on PLL1 loop settings...
        if self.qradio_mode_fast.isChecked() or self.qradio_mode_both.isChecked():
            self.dac1_ui.qchk_lock.setChecked(True)
            self.qchk_lock.setChecked(True)
        else:
            self.dac1_ui.qchk_lock.setChecked(False)
            self.qchk_lock.setChecked(False)
        
        # Pass down the kc setting:
        self.dac1_ui.kc = self.kc
        # might have to call this:
        self.dac1_ui.updateFilterSettings()
        self.dac1_ui.updateGraph()

        # User changed any of the settings:
        self.setIntegratorGainEvent()
            
        
    def initUI(self):
#        print('initUI()')
        
        self.qchk_lock = Qt.QCheckBox('Lock On') # Not displayed, for status reading only (to act like the other LoopFilter)
        self.qchk_lock.setChecked(False)

        # first column: contains the radio buttons to select the mode
        vbox = Qt.QVBoxLayout()
        
        self.qradio_mode_off = Qt.QRadioButton('Off')
        self.qradio_mode_off.setChecked(True)
        self.qradio_mode_slow = Qt.QRadioButton('Acquisition on slow PZT only')
        self.qradio_mode_fast = Qt.QRadioButton('Lock on fast PZT only')
        self.qradio_mode_both = Qt.QRadioButton('Lock on both PZTs')
        
#        self.qradio_mode_off.setEnabled(self.bDisplayLockChkBox)
#        self.qradio_mode_slow.setEnabled(self.bDisplayLockChkBox)
#        self.qradio_mode_fast.setEnabled(self.bDisplayLockChkBox)
#        self.qradio_mode_both.setEnabled(self.bDisplayLockChkBox)
        
        # Two checkboxes to flip the sign
        self.qchk_flip1 = Qt.QCheckBox('Flip sign on acquisition')
        self.qchk_flip1.clicked.connect(self.setIntegratorGainEvent)
        self.qchk_flip2 = Qt.QCheckBox('Flip sign on lock')
        self.qchk_flip2.clicked.connect(self.setIntegratorGainEvent)
        
        
        self.qradio_mode_off.clicked.connect(self.updateSettings)
        self.qradio_mode_slow.clicked.connect(self.updateSettings)
        self.qradio_mode_fast.clicked.connect(self.updateSettings)
        self.qradio_mode_both.clicked.connect(self.updateSettings)
        
        self.qgroup_mode = Qt.QButtonGroup(self)
        self.qgroup_mode.addButton(self.qradio_mode_off)
        self.qgroup_mode.addButton(self.qradio_mode_slow)
        self.qgroup_mode.addButton(self.qradio_mode_fast)
        self.qgroup_mode.addButton(self.qradio_mode_both)
        
        self.qchk_hold = Qt.QCheckBox('Hold both')
        self.qchk_hold.clicked.connect(self.updateSettings)
        
        self.qlabel_int1_state = Qt.QLabel('Integrator 1 state: Off')
        self.qlabel_int2_state = Qt.QLabel('Integrator 2 state: Off')
        
        vbox.addWidget(self.qradio_mode_off)
        vbox.addWidget(self.qradio_mode_slow)
        vbox.addWidget(self.qradio_mode_fast)
        vbox.addWidget(self.qradio_mode_both)
        #FEATURE
        vbox.addWidget(self.qchk_flip1)
        vbox.addWidget(self.qchk_flip2)
        #vbox.addWidget(self.qchk_hold)
        vbox.addWidget(self.qlabel_int1_state)
        vbox.addWidget(self.qlabel_int2_state)
        
        vbox.addStretch(1)
        
        ## The slow PZT integrators BW controls:
        # The label to indicate the predicted closed-loop BW
        self.qlbl_acquisition = Qt.QLabel('Acq gain:')
        self.qlabel_int1_gain = Qt.QLabel('BW : 10 Hz')
        self.qlabel_int1_gain.setAlignment(Qt.Qt.AlignHCenter)
        
        # The knob to set the open-loop gain, and thus closed-loop BW
        self.qcombo_int1_gain = Qt.QComboBox()
        gainsList = range(-31, 31)
        gainsList = list(map(str, gainsList))
        self.qcombo_int1_gain.addItems(gainsList)
        self.qcombo_int1_gain.setCurrentIndex(32-17)    # this has to be overridden if we load the register settings (TODO)
        self.qcombo_int1_gain.currentIndexChanged.connect(self.setIntegratorGainEvent)
        
        self.qlbl_lock_gain = Qt.QLabel('Lock gain:')
        self.qlabel_int2_gain = Qt.QLabel('BW : 1 kHz')
        self.qlabel_int2_gain.setAlignment(Qt.Qt.AlignHCenter)
        
        # The knob to set the open-loop gain, and thus closed-loop BW
        self.qcombo_int2_gain = Qt.QComboBox()
        gainsList = range(-31, 31)
        gainsList = list(map(str, gainsList))
        self.qcombo_int2_gain.addItems(gainsList)
        self.qcombo_int2_gain.setCurrentIndex(32-17)    # this has to be overridden if we load the register settings (TODO)
        self.qcombo_int2_gain.currentIndexChanged.connect(self.setIntegratorGainEvent)
        
        self.qgroupbox_integrators = Qt.QGroupBox('Slow PZT (DAC2)')
        
        vbox_int = Qt.QVBoxLayout()
        vbox_int.addWidget(self.qlbl_acquisition)
        vbox_int.addWidget(self.qcombo_int1_gain)
        vbox_int.addWidget(self.qlabel_int1_gain)
        vbox_int.addWidget(self.qlbl_lock_gain)
        vbox_int.addWidget(self.qcombo_int2_gain)
        vbox_int.addWidget(self.qlabel_int2_gain)
        vbox_int.addStretch(1)
        
        self.qgroupbox_integrators.setLayout(vbox_int)
        
        # The controls for the fast PZT's loop filter settings, contains only one (composite) widget:
        self.qgroupbox_pll = Qt.QGroupBox('Fast PZT (DAC1)', self)
#        self.dac1_ui.setParent(self.qgroupbox_pll)
        vbox3 = Qt.QVBoxLayout()
        vbox3.addWidget(self.dac1_ui)
        self.qgroupbox_pll.setLayout(vbox3)
        
        # Put all the vboxes and groupboxes into a single layout:
        hbox = Qt.QHBoxLayout()
        hbox.addLayout(vbox)
        hbox.addWidget(self.qgroupbox_integrators)
        hbox.addWidget(self.qgroupbox_pll)
        hbox.setStretch(2, 1)
 
        self.setLayout(hbox)       
