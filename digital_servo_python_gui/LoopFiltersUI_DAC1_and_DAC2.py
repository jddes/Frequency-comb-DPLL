# -*- coding: utf-8 -*-
"""
Created on Wed Dec 04 20:48:43 2013

Description: Provides a graphical user interface (GUI) for setting the loop filters parameters of the loop filter for DAC1 and the two integrators for DAC2 implemented in the XEM6010 module.
@author: JD Deschenes
"""

from PyQt4 import QtGui, Qt, QtCore
import PyQt4.Qwt5 as Qwt
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
        super(Qt.QWidget, self).__init__()
#        super(LoopFiltersUI_DAC1_and_DAC2, self).__init__(sl, filter_number, pll)
        
        # Create the widget which will control the DAC1 loop filters:
        bDisplayLockChkBox = False   # true for debug only
        self.bDisplayLockChkBox = bDisplayLockChkBox
        self.dac1_ui = LoopFiltersUI(sl, filter_number, pll, bDisplayLockChkBox)
#        print('LoopFiltersUI::__init__(): Entering')        
        
        # We need sl here because we need to pass it to the pll object, and we need fs to set the correct loop filter gain, because the integrators transfer function depends on that fs
        self.sl = weakref.proxy(sl)
        self.filter_number = filter_number
        # All the gains here are normalized to the DC, open-loop gain of the overall system:
        self.kc = 1

#        if type(pll) == type(0):
#            # For debugging only:
#            self.kp_min = 1e-6
#            self.kp_max = 1e6
#            self.ki_min = 1e-6
#            self.ki_max = 1e6
#            self.kii_min = 1e-6
#            self.kii_max = 1e6
#        else:
#            # Keep a local reference to the related PLL object
#            self.pll = pll
#            self.getLimits()
        
        # Init our GUI
        self.initUI()
        
#        print('LoopFiltersUI::__init__() Exiting')
#        print('LoopFiltersUI::__init__()')
#        self.updateGraph()
        
#    def __del__(self):
#        print('LoopFiltersUI destructor called')

    def loadParameters(self, sp):
        # TODO: Do something...
        self.dac1_ui.loadParameters(sp)
        
    def updateGraph(self):
        # this call is meant for the underlying LoopFilterUI() object:
        self.dac1_ui.updateGraph()
        # However, that could also mean that we need to re-update our settings based on a new value of kc:
        self.setIntegratorGainEvent()
        
    def setIntegratorGainEvent(self):
#        print('LoopFiltersUI_DAC1_and_DAC2::setIntegratorGainEvent(): TODO!')
        
        gain1_in_bits = int(self.qwtknob_int1_gain.value())
        # Limit is -21, below that it goes nuts
        
        
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
        

        gain2_in_bits = int(self.qwtknob_int2_gain.value())
        # Limit is -27
        
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
            
        # For testing: 
        # integrate for 1 sec then hold
#        time.sleep(2)
#        hold1 = 1
#        self.sl.set_integrator_settings(1, hold1, flipsign1, lock_integrator1, gain1_in_bits)
        
        # Predict the closed-loop BW based on the chosen gain:
        # First case: integrator 1, which integrates the frequency error [in DDC counts] and outputs a signal on DAC2 HV
        
        # Gain of the integrator as a function of frequency is 2^gain1_in_bits * self.sl.fs /(2*pi*f)
        # We want the unity gain frequency where G_integrator*Kc = 1 = Kc*2^gain1_in_bits * self.sl.fs /(2*pi*f)
        # so that f = Kc*2^gain1_in_bits * self.sl.fs /(2*pi)
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
            
            
##        self.qlabel_fll0_gain.setText(('Closed-loop BW: %.1e Hz' % closedloop_BW))
#        self.qlabel_fll0_gain.resize(self.qlabel_fll0_gain.sizeHint())
#        self.updateTransferFunctionDisplay()
        
        
    def updateSettings(self):
        
        # Need to also call an update on PLL1 loop settings...
        if self.qradio_mode_fast.isChecked() or self.qradio_mode_both.isChecked():
            self.dac1_ui.qchk_lock.setChecked(True)
        else:
            self.dac1_ui.qchk_lock.setChecked(False)
        
        # Pass down the kc setting:
        self.dac1_ui.kc = self.kc
        # might have to call this:
        self.dac1_ui.updateGraph()

        
        # User changed any of the settings:
        self.setIntegratorGainEvent()
        

            
        
    def initUI(self):
#        print('initUI()')
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
        self.qchk_flip2 = Qt.QCheckBox('Flip sign on lock')
        
        
        
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
        #vbox.addWidget(self.qchk_flip1)
        #vbox.addWidget(self.qchk_flip2)
        #vbox.addWidget(self.qchk_hold)
        vbox.addWidget(self.qlabel_int1_state)
        vbox.addWidget(self.qlabel_int2_state)
        
        vbox.addStretch(1)
        
        ## The slow PZT integrators BW controls:
        # The label to indicate the predicted closed-loop BW
        self.qlabel_int1_gain = Qt.QLabel('Acquisition BW : 10 Hz')
        self.qlabel_int1_gain.setAlignment(Qt.Qt.AlignHCenter)
        
        # The knob to set the open-loop gain, and thus closed-loop BW
        self.qwtknob_int1_gain = Qwt.QwtKnob()
        self.qwtknob_int1_gain.setRange(-31, 31, 1)
        self.qwtknob_int1_gain.setScale(-31, 31, 4)
        self.qwtknob_int1_gain.setValue(-9)
        self.qwtknob_int1_gain.valueChanged.connect(self.setIntegratorGainEvent)
        
        self.qlabel_int2_gain = Qt.QLabel('Lock BW : 1 kHz')
        self.qlabel_int2_gain.setAlignment(Qt.Qt.AlignHCenter)
        
        # The knob to set the open-loop gain, and thus closed-loop BW
        self.qwtknob_int2_gain = Qwt.QwtKnob()
        self.qwtknob_int2_gain.setRange(-31, 31, 1)
        self.qwtknob_int2_gain.setScale(-31, 31, 4)
        self.qwtknob_int2_gain.setValue(-17)
        self.qwtknob_int2_gain.valueChanged.connect(self.setIntegratorGainEvent)
        
        self.qgroupbox_integrators = Qt.QGroupBox('Slow PZT integrators (DAC2/DAC2HV)')
        
        vbox_int = Qt.QVBoxLayout()
        vbox_int.addWidget(self.qlabel_int1_gain)
        vbox_int.addWidget(self.qwtknob_int1_gain)
        vbox_int.addWidget(self.qlabel_int2_gain)
        vbox_int.addWidget(self.qwtknob_int2_gain)
        
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
#        hbox.addWidget(self.qgroupbox_integrators)
        hbox.addWidget(self.qgroupbox_pll)
#        hbox.addWidget(self.dac1_ui)
        hbox.setStretch(2, 1)
 
        self.setLayout(hbox)       
#
#        qPolicy = Qt.QSizePolicy(Qt.QSizePolicy.MinimumExpanding, Qt.QSizePolicy.MinimumExpanding)
##        qPolicy.setHeightForWidth(True)
#        self.setSizePolicy(qPolicy)
        
#        
#    def loadParameters(self, sp):
##        print('loadParameters(): Entering')
#        
##        self.root.append(Element('PLL0_settings', kp='-60', fi='1e3', fii='0', chkKp='True', chkLock='False', chkKpCrossing='True'))
#        strPLL = 'PLL{:01d}_settings'.format(self.filter_number)
#        kp = float(sp.getValue(strPLL, 'kp'))
#        fi = float(sp.getValue(strPLL, 'fi'))
#        fii = float(sp.getValue(strPLL, 'fii'))
#        bKp = bool(sp.getValue(strPLL, 'chkKp').lower() == 'true')
#        bLock = bool(sp.getValue(strPLL, 'chkLock').lower() == 'true')
#        kKpCrossing = bool(sp.getValue(strPLL, 'chkKpCrossing').lower() == 'true')
##        print('loadParameters(): kp = %f, fi = %f, fii = %f' % (kp, fi, fii))
#        
#        # Update the values in the UI to reflect the internal values:
#        # We block the signals first because otherwise the edit box event handler will try to change the values.
#        # We instead call textboxChanged() explicitely at the end
#        self.qedit_kp.blockSignals(True)
#        self.qedit_fi.blockSignals(True)
#        self.qedit_fii.blockSignals(True)
#        
#        self.qedit_kp.setText('{:.3}'.format(kp))
#        self.qedit_fi.setText('{:.3e}'.format(fi))
#        self.qedit_fii.setText('{:.3e}'.format(fii))
#        
#        self.qedit_kp.blockSignals(False)
#        self.qedit_fi.blockSignals(False)
#        self.qedit_fii.blockSignals(False)
##        print('self.qedit_kp = %s' % self.qedit_kp.text())
#        
#        self.qchk_kp.setChecked(bKp)
#        self.qchk_lock.setChecked(bLock)
#        self.qchk_bKpCrossing.setChecked(kKpCrossing)
#        
##        print('loadParameters(): Calling textboxChanged()')
#        self.textboxChanged()
#        
##        print('loadParameters(): Calling updateGraph()')
##        self.updateGraph()
#        
##        print('loadParameters(): Exiting')
#        
#    def getSettings(self):
#        
#        if self.qchk_lock.isChecked():
#            bLock = 1
#        else:
#            bLock = 0
#            
#        if self.qchk_kp.isChecked():
#            try:
#                kp = float(self.qedit_kp.text())
#            except:
#                kp = -20.0
#
#        else:
#            # Kp is off: put -120 dB right now to indicate 0 gain
#            kp = -120
#            
#        try:
#            fi = float(self.qedit_fi.text())
#        except:
#            fi = 1e3
#            
#        try:
#            fii = float(self.qedit_fii.text())
#        except:
#            fii = 0.0
#            
#        # TODO: make this changeable from the UI:
#        try:
#            fmin = 1.0
#        except:
#            fmin = 1.0
#        try:
#            fmax = 1e6
#        except:
#            fmax = 1e6
#            
#        gain_min = -40
#        gain_max = 60
#            
#        return (kp, fi, fii, fmin, fmax, gain_min, gain_max, bLock)
#        
#    def kpSliderEvent(self):
##        print('kpSliderEvent()')
#        # Read the setting from the slider, apply limits, then update the textbox and the graph:
#        sliderValue = self.qslider_kp.value()
#        
#        self.qedit_kp.blockSignals(True)
#        self.qedit_kp.setText('%.2e' % (sliderValue/10.))
#        self.qedit_kp.blockSignals(False)
#        
#        self.checkFirmwareLimits()
#        self.updateGraph()
#        
#    def fiSliderEvent(self):
##        print('fiSliderEvent()')
#        # Read the setting from the slider, apply limits, then update the textbox and the graph:
#        # The fi and fii sliders will contain the value in 100*log10(f) units
#        sliderValue = self.qslider_fi.value()
#        
#        
#        self.qedit_fi.blockSignals(True)
#        self.qedit_fi.setText('%.2e' % 10**(sliderValue/100.))
#        self.qedit_fi.blockSignals(False)
#        
#        self.checkFirmwareLimits()
#        self.updateGraph()
#        
##        self.updateGraph()
#        
#        
#    def fiiSliderEvent(self):
##        print('fiiSliderEvent()')
#        # Read the setting from the slider, apply limits, then update the textbox and the graph:
#        sliderValue = self.qslider_fii.value()
#        
#        
#        self.qedit_fii.blockSignals(True)
#        self.qedit_fii.setText('%.2e' % 10**(sliderValue/100.))
#        self.qedit_fii.blockSignals(False)
#        
#        self.checkFirmwareLimits()
#        self.updateGraph()
#        
#    def textboxChanged(self):
##        print('textboxChanged()')
##        traceback.print_stack()
#    
#        # Read the settings from the textboxes
#        (kp, fi, fii, fmin, fmax, gain_min, gain_max, bLock) = self.getSettings()
#        # Update the sliders to match:
#        # We block the signals from the sliders so we don't cause infinite recursion
##        self.qslider_fi.setValue((100*np.log10(fi)))
#        self.qslider_fi.blockSignals(True)
#        self.qslider_fi.setValue((100*np.log10(np.max((fi, fmin)))))
#        self.qslider_fi.blockSignals(False)
#        self.qslider_fii.blockSignals(True)
#        self.qslider_fii.setValue((100*np.log10(np.max((fii, fmin)))))
#        self.qslider_fii.blockSignals(False)
#        self.qslider_kp.blockSignals(True)
#        self.qslider_kp.setValue(np.max((10*kp, 10*gain_min)))
#        self.qslider_kp.blockSignals(False)
#        
#        # Update the display:
#        self.checkFirmwareLimits()
#        self.updateGraph()
#        
#    def checkFirmwareLimits(self):
##        traceback.print_stack()
#        (P_gain, I_gain, II_gain, bLock) = self.getActualControllerDesign()
#        
#        # Read the firmware gain limits to check if the values are within range:
#        self.getLimits()
#        
#        
#        if self.kp_min <= P_gain and P_gain <= self.kp_max:
#            self.qedit_kp.setStyleSheet("background-color: %s" % Qt.QColor(QtCore.Qt.white).name())
#        else:
#            # red background
#            self.qedit_kp.setStyleSheet("color: white; background-color: %s" % Qt.QColor(QtCore.Qt.red).name())
#
#        if self.ki_min <= I_gain and I_gain <= self.ki_max:
#            self.qedit_fi.setStyleSheet("background-color: %s" % Qt.QColor(QtCore.Qt.white).name())
#        else:
#            # red background
#            self.qedit_fi.setStyleSheet("color: white; background-color: %s" % Qt.QColor(QtCore.Qt.red).name())
#            
#        if self.kii_min <= II_gain and II_gain <= self.kii_max:
#            self.qedit_fii.setStyleSheet("background-color: %s" % Qt.QColor(QtCore.Qt.white).name())
#        else:
#            # red background
#            self.qedit_fii.setStyleSheet("color: white; background-color: %s" % Qt.QColor(QtCore.Qt.red).name())
#        
#    def getLimits(self):
#        
#        (kp_min, kp_max) = self.pll.get_p_limits()
#        self.kp_min = kp_min
#        self.kp_max = kp_max
#        (ki_min, ki_max) = self.pll.get_i_limits()
#        self.ki_min = ki_min
#        self.ki_max = ki_max
#        (kii_min, kii_max) = self.pll.get_ii_limits()
#        self.kii_min = kii_min
#        self.kii_max = kii_max
#        
#    def updateTooltips(self):
#        
#        # Get the firmware gain limits and show them in the tooltips
#        self.getLimits()
#        (kp, fi, fii, fmin, fmax, gain_min, gain_max, bLock) = self.getSettings()
#        
#        # to prevent divides by zero:
#        if fi == 0.0:
#            fi = 1e-12
#        
#        if self.qchk_bKpCrossing.isChecked() == False:
#            if self.kp_min * self.kc == 0.0:
#                kp_min_dB = float('-inf')
#            else:
#                kp_min_dB = 20*np.log10(self.kp_min * self.kc)
#                
#            kp_max_dB = 20*np.log10(self.kp_max * self.kc)
#            fi_min = self.ki_min * self.kc / (2*np.pi/self.sl.fs)
#            fi_max = self.ki_max * self.kc / (2*np.pi/self.sl.fs)
#            fii_min = self.kii_min *self.kc / fi / (2*np.pi/self.sl.fs)**2
#            fii_max = self.kii_max *self.kc / fi / (2*np.pi/self.sl.fs)**2
#        else:
#            
#            if self.kp_min * self.kc == 0.0:
#                kp_min_dB = float('-inf')
#            else:
#                kp_min_dB = 20*np.log10(self.kp_min * self.kc)
#            kp_max_dB = 20*np.log10(self.kp_max * self.kc)
#            fi_min = self.ki_min * self.kc/10**(kp/20) / (2*np.pi/self.sl.fs)
#            fi_max = self.ki_max * self.kc/10**(kp/20) / (2*np.pi/self.sl.fs)
#            fii_min = self.kii_min *self.kc/10**(kp/20) / fi / (2*np.pi/self.sl.fs)**2
#            fii_max = self.kii_max *self.kc/10**(kp/20) / fi / (2*np.pi/self.sl.fs)**2
#            
#        self.qedit_kp.setToolTip('Proportional gain in dB: [{:.2f}, {:.2f}]'.format(kp_min_dB, kp_max_dB))
#        self.qedit_fi.setToolTip('Integrator cross-over frequency in Hz: [{:.2e}, {:.2e}]'.format(fi_min, fi_max))
#        self.qedit_fii.setToolTip('Double integrator cross-over frequency in Hz: [{:.2e}, {:.2e}]'.format(fii_min, fii_max))
#    def getActualControllerDesign(self):
#        (kp, fi, fii, fmin, fmax, gain_min, gain_max, bLock) = self.getSettings()
#        
#        if self.qchk_bKpCrossing.isChecked() == False:
#            # I is relative to 1/kc
#            # all the values here are relative to the open-loop DC gain of the system, self.kc:
#            P_gain = 10**(kp/20)/self.kc
#            I_gain = 1/self.kc * fi * (2*np.pi/self.sl.fs)
#            II_gain = 1/self.kc * fi * fii * (2*np.pi/self.sl.fs)**2
#        else:
#            # I is relative to kp/kc
#            # all the values here are relative to the open-loop DC gain of the system, self.kc:
#            P_gain = 10**(kp/20)/self.kc
#            I_gain = 10**(kp/20)/self.kc * fi * (2*np.pi/self.sl.fs)
#            II_gain = 10**(kp/20)/self.kc * fi * fii * (2*np.pi/self.sl.fs)**2
#        
#        if self.qchk_kp.isChecked() == False:
#            P_gain = 0
#            
#        return (P_gain, I_gain, II_gain, bLock)
#        
#    def updateFilterSettings(self):
##        print('LoopFiltersUI::updateFilterSettings(): Entering')
##        traceback.print_stack()
#
#        (P_gain, I_gain, II_gain, bLock) = self.getActualControllerDesign()
#        
#        self.pll.set_pll_settings(self.sl, P_gain, I_gain, II_gain, bLock)
#        
##        print('LoopFiltersUI::updateFilterSettings(): Exiting')
#        
#    def updateGraph(self):
##        print('LoopFiltersUI::updateGraph(): Entering')
#        self.updateFilterSettings()
#        self.updateTooltips()
#        self.checkFirmwareLimits()
#        # Read the settings from the textboxes
#        (kp, fi, fii, fmin, fmax, gain_min, gain_max, bLock) = self.getSettings()
#        
#        
#        # Draw a first line at 0 dB
#        f_array = np.array((fmin, fmax))
#        gain_array = np.array((1, 1))
#
#        self.curve_0dB.setData(f_array, 20*np.log10(gain_array))
#        
#        # Draw the P gain curve:
#        gain_array = 10**(kp/20) + 0*f_array
##        print(20*np.log10(gain_array))
#        self.curve_kp.setData(f_array, 20*np.log10(gain_array))
#        # Draw the I gain curve:
#        if fi == 0.0:
#            gain_array = 10**(gain_min/20 - 1) + 0*f_array
#        else:
#            if self.qchk_bKpCrossing.isChecked() == False:
#                # fi relative to 0 dB crossing
#                gain_array = fi/f_array
#            else:
#                # fi relative to kp dB crossing
#                gain_array = 10**(kp/20) * fi/f_array
##        print(20*np.log10(gain_array))
#        self.curve_fi.setData(f_array, 20*np.log10(gain_array + self.MINIMUM_GAIN_DISPLAY))
#        # Draw the II gain curve:
#        if fii == 0.0:
#            gain_array = 10**(gain_min/20 - 1) + 0*f_array
#        else:
#            if self.qchk_bKpCrossing.isChecked() == False:
#                # fi relative to 0 dB crossing
#                gain_array = fi/f_array * fii/f_array
#            else:
#                # fi relative to kp dB crossing
#                gain_array = 10**(kp/20) * fi/f_array * fii/f_array
##        print(20*np.log10(gain_array))
#        self.curve_fii.setData(f_array, 20*np.log10(gain_array + self.MINIMUM_GAIN_DISPLAY))
#        
#
#
#        f_array = np.logspace(np.log10(fmin), np.log10(fmax), 100)
#        actual_gain_array = np.abs(self.pll.get_current_transfer_function(f_array, self.sl.fs) * self.kc)
#        self.curve_actual.setData(f_array, 20*np.log10(actual_gain_array + self.MINIMUM_GAIN_DISPLAY))
#
#        
#        self.qplot_tf.setAxisScale(Qwt.QwtPlot.xBottom, fmin, fmax)
#        self.qplot_tf.setAxisScale(Qwt.QwtPlot.yLeft, gain_min, gain_max)
#        
#        self.qplot_tf.replot()
#        
#        print('LoopFiltersUI::updateGraph(): Exiting')
        
        
#def main():
#    
#    app = QtGui.QApplication(sys.argv)
#    w = LoopFiltersUI()
#    w.show()
#    w.resize(800, 300)
#    
##    sys.exit(app.exec_())
#    app.exec_()
#
#if __name__ == '__main__':
#    main()    
#    
