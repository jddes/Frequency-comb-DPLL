from PyQt5 import QtCore, QtGui, QtWidgets, uic
import time
import socket
import logging

import UDPRedPitayaDiscovery
from RP_PLL import RP_PLL_device # needed to update FPGA firmware and CPU (Zynq) software
import devicesData

class ConnectionWidget(QtWidgets.QWidget):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.logger = logging.getLogger(__name__)
        self.logger_name = ':ConnectionWidget'

        self.devices_data = devicesData.getDevicesData()

        self.setupUI()
        self.udp_discovery = UDPRedPitayaDiscovery.UDPRedPitayaDiscovery(self.editBroadcastAddress.text())
        self.reset_list_and_send_broadcast()

        self.timer = QtCore.QTimer(self)
        self.timer.timeout.connect(self.timerEvent)
        self.timer.start(20)

    def setupUI(self):
        uic.loadUi("connection_widget.ui", self)
        self.editBroadcastAddress.setText(findMostLikelyLANBroadcastIPAddress())

        self.btnUpdateFPGA.clicked.connect(self.programFPGAClicked)
        self.btnUpdateCPU.clicked.connect(self.programCPUClicked)

    def reset_list_and_send_broadcast(self):
        self.strSerialList = list()
        self.comboFPGAs.clear()
        
        # we need to reconnect the UDP discovery socket everytime we change our broadcast address
        try:
            self.udp_discovery.broadcast_address = self.qedit_broadcast.text()
            self.udp_discovery.connectClientSocket()
        except AttributeError:
            pass
        # send a broadcast packet to start building the list:
        try:
            self.udp_discovery.send_broadcast()
        except Exception as e:
            print('Exception when sending UDP broadcast packet')
            print(e)

    def MAC_to_display_string(self, strMAC, strIP):
        # build the string that we will display to the user in the combo box:
        strDisplay = ''
        #print('MAC_to_display_string: %s, %s' % (strMAC, strIP))
        #print(self.devices_data)

        try:
            box_name = self.devices_data[strMAC.replace(':', '')]['name']
        except KeyError:
            box_name = ''
            pass
        
        try:
            box_color = self.devices_data[strMAC.replace(':', '')]['color']
        except KeyError:
            box_color = ''
            pass
        
        strDisplay = 'Name = %s, IP = %s, MAC = %s, Color = %s' % (box_name, strIP, strMAC, box_color)
        return strDisplay
        
    def timerEvent(self):
        # check if there are any answers to the broadcast packet
        try:
            (strIP, strMAC) = self.udp_discovery.check_answers()
        except AttributeError:
            return
        except Exception as e:
            print('Exception when checking answers to broadcast packet')
            print(e)
            return

        # iterate over answers
        while (strIP is not None):
            # build the string that we will display to the user in the combo box:
            strDisplay = self.MAC_to_display_string(strMAC, strIP)
            
            self.strSerialList.append((strIP, strMAC))
            self.comboFPGAs.addItem(strDisplay)
            # for the next iteration:
            # check if there are any answers to the broadcast packet
            (strIP, strMAC) = self.udp_discovery.check_answers()
            
            time.sleep(0.01)


    def getSelectedHost(self):
        """ Returns a tuple of the MAC address (if available, empty string otherwise), the IP and Port number that is currently selected in the GUI.
        Can also return a tuple of three None if no device was selected """
        try:
            port = int(self.editPort.text())
            if self.radioUseList.isChecked():
                (strIP, strMAC) = self.strSerialList[self.comboFPGAs.currentIndex()]
            else:
                # use manual entry IP address
                # we don't have a good way of populating the MAC and serial number yet using this manual connection
                strIP = str(self.editIP.text())
                strMAC = ""
                
        except IndexError:
            # nothing bad happened, we probably simply had an empty list
            print("Error: no selected RedPitaya.")
            strMAC = None
            strIP  = None
            port   = None
        except:
            strMAC = None
            strIP  = None
            port   = None

        return (strMAC, strIP, port)

    def programFPGAClicked(self):
        fileName = QtWidgets.QFileDialog.getOpenFileName(self, 'Select bitfile', filter="*.bit")
        if not fileName[0]:
            return

        (strMAC, strIP, port) = self.getSelectedHost()
        if strIP is None:
            print("Could not get valid IP address")
            return

        self.logger.info('Red_Pitaya_GUI{}: Programming FPGA ({}) with new bitfile'.format(self.logger_name, strIP))

        # connect to the selected RedPitaya, send new bitfile, then send programming command to the shell:
        self.dev = RP_PLL_device()
        self.dev.OpenTCPConnection(strIP, port)
        self.dev.write_file_on_remote(strFilenameLocal=fileName[0], strFilenameRemote='/opt/red_pitaya_top.bit')
        time.sleep(2) # to handle slow SD cards
        print("File written to remote host at /opt/red_pitaya_top.bit.")

        self.dev.send_shell_command('cat /opt/red_pitaya_top.bit > /dev/xdevcfg')
        print("Program FPGA firmware command sent.")
        
        # disconnect:
        self.dev.sock.shutdown(socket.SHUT_RDWR)
        self.dev.sock.close()
        print("Disconnected from remote host.  You can now reconnect to the updated host.")
        
        
    def programCPUClicked(self):
        fileName = QtWidgets.QFileDialog.getOpenFileName(self, 'Select monitor-tcp program', filter="*")
        if not fileName[0]:
            return

        (strMAC, strIP, port) = self.getSelectedHost()
        if strIP is None:
            print("Could not get valid IP address")
            return

        self.logger.info('Red_Pitaya_GUI{}: Programming CPU ({}) with new file'.format(self.logger_name, strIP))

        # connect to the selected RedPitaya
        self.dev = RP_PLL_device()
        self.dev.OpenTCPConnection(strIP, port)
        # send new monitor-tcp version
        self.dev.write_file_on_remote(strFilenameLocal=fileName[0], strFilenameRemote='/opt/monitor-tcp-new')
        print("CPU software update sent. Rebooting server using new version")
        
        # set executable permissions
        self.dev.send_shell_command('chmod +x /opt/monitor-tcp-new')
        # copy over old file
        self.dev.send_shell_command('mv /opt/monitor-tcp-new /opt/monitor-tcp')
        
        # send "reboot monitor-tcp" command
        self.dev.send_reboot_command()
        self.dev.sock.shutdown(socket.SHUT_RDWR)
        self.dev.sock.close()
        
        time.sleep(1) # give some time for tcp server to come back up
        print("CPU software update complete.")
        pass


def findMostLikelyLANBroadcastIPAddress():
    """ list all possible IPv4 addresses and choose the most likely candidate for the subnet on which the red pitaya is
     heuristics used:
       -prefer if the address starts with 192.168
       -choose the subnet that has the lowest third byte: eg if there are both 192.168.1.10 and 192.168.2.10, chooose 129.168.1.10 as the correct one
    """
    addrCandidate = '192.168.0.255'

    try:
        listAddr = socket.getaddrinfo(socket.gethostname(), None)
        min_third_byte = 255

        for addr_tuple in listAddr:
            (family, _, _, _, sockaddr) = addr_tuple
            if family == socket.AF_INET:
                # this is IPv4
                # print('IP candidate: %s' % sockaddr[0])
                third_byte = int(sockaddr[0].split('.')[2])
                if third_byte <= min_third_byte:
                    min_third_byte = third_byte
                    addrCandidate = sockaddr[0]
        # print('Chosen local IP: %s' % addrCandidate)

    except:
        print("findMostLikelyLANBroadcastIPAddress():Exception trying to find correct broadcast automatically.")
        #pass

    # Take this machine's IP address and transform into broadcast address for the whole subnet (change last byte to 255)
    addrSplit = addrCandidate.split('.')
    addrSplit[3] = '255'
    strBroadCastAddress = '.'.join(addrSplit)

    return strBroadCastAddress