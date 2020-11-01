from PyQt5 import QtGui, Qt, QtCore, QtWidgets
import sys

import numpy as np

import common
import text_report
import SuperLaserLand_JD_RP
import initialConfiguration_RP
import SLLSystemParameters

class TestController():
    def __init__(self, sl):
        self.sl = sl
        self.sp = SLLSystemParameters.SLLSystemParameters()
        # these are the "callback-style" functions that the initialConfig dialog will call once the user is ready
        self.pushDefaultValues = self.deviceSelected
        self.getActualValues   = self.deviceSelected
        self.stopCommunication = lambda x, y, z: None # empty function, just to make sure that this wouldn't cause an exception

        # Start Qt:
        self.app = QtWidgets.QApplication(sys.argv)
        self.createInitialConfigDialog()
        # run the event loop until the user chooses a RP to connect to, then the code will continue on as a pure console application
        self.app.exec_()

    def createInitialConfigDialog(self):
        strBroadcastAddress = common.findMostLikelyLANBroadcastIPAddress()
        #strBroadcastAddress = "192.168.0.255"
        strFPGAFirmware=r'red_pitaya_top_extint_clk.bit'
        strCPUFirmware=u'monitor-tcp'
        self.initial_config = initialConfiguration_RP.initialConfiguration(self.sl.dev, self, {},
            strBroadcastAddress, strFPGAFirmware, strCPUFirmware)

    def deviceSelected(self, strSelectedSerial = "000000000000", ip_addr = "192.168.0.150", port=5000):
        QtCore.QCoreApplication.instance().quit() # stop the event loop

        self.mac_address = strSelectedSerial

        self.sl.dev.OpenTCPConnection(ip_addr, port)
        self.sl.resetFrontend()
        # commit the default values, ex for limits etc
        self.sp.loadFromFile('system_parameters_RP_Default.xml')
        self.sp.sendToFPGA(self.sl, bSendToFPGA=True)


def main():
# -sequence of operations:
#     -create all 3 required objects (SL, Scope, mux_board)
    sl = SuperLaserLand_JD_RP.SuperLaserLand_JD_RP()
    controller = TestController(sl)
    # print("avg (volts) = ", np.mean(sl.getADCorDACdata('ADC0', 8e3)))


    report = text_report.TextReport(mac_address=controller.mac_address)
    save = lambda x: report.saveTestResult(x, temperature=sl.readZynqTemperature())
    save({"test_name": "Test start information",
          "mac_address": controller.mac_address,
          "operator name": "JDD"})


    save({"test_name": "Test stop information"})

    # sl.openDevice
#     -connect to all 3 devices
#       -sl: done
#       -scope: TODO
#       -mux board: TODO, also need to write the object that will control it
#     -run each test one after the other

#     -at the end: write to report: "Test start information". this will time-tag and save the last temperature.

    

if __name__ == '__main__':
    main()