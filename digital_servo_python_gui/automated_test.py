from PyQt5 import QtGui, Qt, QtCore, QtWidgets
import sys

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

        self.sl.dev.OpenTCPConnection(ip_addr, port)
        self.sl.resetFrontend()
        # commit the default values, ex for limits etc
        self.sp.loadFromFile('system_parameters_RP_Default.xml')
        self.sp.sendToFPGA(self.sl, bSendToFPGA=True)


def main():
# -sequence of operations:
#     -create all 3 required objects (SL, Scope, mux_board)
    sl = SuperLaserLand_JD_RP.SuperLaserLand_JD_RP()
    print("before TestController's constructor")
    controller = TestController(sl)
    print("after TestController's constructor")
    # sl.openDevice
#     -connect to all 3 devices
#         -SL needs to create the list, connect to the first one.
#         -this _might_ require quite a bit of refactoring, so maybe we could make this manual for now?
#         -the user could find the IP and MAC addresses using the normal GUI, then enter them as command line arguments for example.
#         -look at the code, I could maybe re-use the normal initialConfiguration_RP.py dialog for the connection.
#         -this would be the only GUI element, then everything would happen in the console.
#         -I just have to reimplement the same interface as the "controller" object, at least the shared portion with initialConfiguration_RP
#         -then I stop the Qt event loop and the program continues in the console.
#         -Let's do that!
#         -(This also gives me the buttons to program the FPGA and firmware for free!)

#     -create a unique folder for the report (use device MAC address & date-time string down to seconds)
#     -create the object that will write the text report
#     -first entry in the test report is "Test start information":
#         -contains operator name ("JDD"). this will time-tag the start of the test.
#         -could save starting temperature at this point too.

#     -run each test one after the other

#     -at the end: write to report: "Test start information". this will time-tag and save the last temperature.

    
    report = text_report.TextReport(mac_address = "00000000")


if __name__ == '__main__':
    main()