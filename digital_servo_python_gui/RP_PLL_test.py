from PyQt5 import QtGui, Qt, QtCore, QtWidgets
import sys
import os
import time

import numpy as np

# to start a thread:
        # self.resolveSignsThread = ResolveSignsThread(self)

        # self.resolveSignsThread.signsResolveComplete.connect(self.signsResolveComplete)
        # self.resolveSignsThread.statusUpdate.connect(self.statusUpdate)
        
        # self.newFreqSignal.connect(self.resolveSignsThread.newFreqMeasurement)
        # self.resolveSignsThread.start()

from AsyncSocketComms import AsyncSocketServer
from AsyncSocketComms import AsyncSocketClient

import RP_PLL

class MonitorTCP_mock():
    def __init__(self):
        self.reply_latency = 0

        self.memory_buffer = bytearray(RP_PLL.RP_PLL_device.MAX_SAMPLES_READ_BUFFER)

        self.magic_bytes_to_handler = {
            RP_PLL.RP_PLL_device.MAGIC_BYTES_WRITE_REG: self.write_reg_handler,
            RP_PLL.RP_PLL_device.MAGIC_BYTES_READ_REG: self.read_reg_handler,
            RP_PLL.RP_PLL_device.MAGIC_BYTES_READ_BUFFER: self.read_buf_handler,
        }

    def parse_buffer(self, data_buffer):
        # parse the buffer, similar to what monitor-tcp does!
        # TODO: This needs to consume the buffer, otherwise the data will just accumulate.

        if len(data_buffer) >= 4:
            magic_bytes = struct.unpack('I', data_buffer)
            handler_func = self.magic_bytes_to_handler.get(magic_bytes, None)
            if handler_func is None:
                print("Error: unrecognized magic_bytes 0x%x" % magic_bytes)
            else:
                (data_to_send_back, bytes_consumed_from_buffer) = handler_func(data_buffer)
                
                data_buffer[0:bytes_consumed_from_buffer] = bytearray()
                return data_to_send_back

        return None
        # if len(data_buffer) > 0:
        #     print("in MonitorTCP_mock::parse_buffer(): data_buffer=%s. Clearing." % data_buffer)
        #     data_buffer[:] = bytearray()
        # # return data_buffer # Do we need to return it to be able to modify it? I think not, but I am not sure...

    # Handlers return a tuple containing: (data_to_send_back, bytes_consumed_from_buffer)
    def write_reg_handler(self, data_buffer):
        words_consumed = 3
        bytes_per_word = 4
        bytes_consumed = words_consumed*bytes_per_word

        # Do we have all the required information yet to handle the request?
        if len(data_buffer) < bytes_consumed:
            return (None, 0)

        (magic_bytes, addr, data) = struct.unpack('=III', data_buffer)
        self.regs[addr/4] = data
        return (None, bytes_consumed)

    def read_reg_handler(self, data_buffer):
        words_consumed = 3
        bytes_per_word = 4
        bytes_consumed = words_consumed*bytes_per_word

        # Do we have all the required information yet to handle the request?
        if len(data_buffer) < bytes_consumed:
            return (None, 0)

        (magic_bytes, addr, reserved) = struct.unpack('=III', data_buffer)
        return (self.regs[addr/4], bytes_consumed)

    def read_buf_handler(self, data_buffer):
        words_consumed = 3
        bytes_per_word = 4
        bytes_consumed = words_consumed*bytes_per_word

        # Do we have all the required information yet to handle the request?
        if len(data_buffer) < bytes_consumed:
            return (None, 0)

        return (self.memory_buffer, bytes_consumed)


    # def write_Zynq_register_32bits(self, absolute_addr, data_32bits, bSigned=False):
    #     self.validate_address(absolute_addr)
    #     packet_to_send = struct.pack(self.type_to_format_string[bSigned], self.MAGIC_BYTES_WRITE_REG, absolute_addr, int(data_32bits) & 0xFFFFFFFF)
    #     self.send(packet_to_send)

    # def read_Zynq_register_32bits(self, absolute_addr, bIsAXI=False):
    #     self.validate_address(absolute_addr)
    #     packet_to_send = struct.pack('=III', self.MAGIC_BYTES_READ_REG, absolute_addr, 0)  # last value is reserved
    #     self.send(packet_to_send)
    #     return self.read(4)

    # def read_Zynq_buffer_int16(self, number_of_points):
    #     if number_of_points > self.MAX_SAMPLES_READ_BUFFER:
    #         number_of_points = self.MAX_SAMPLES_READ_BUFFER
    #         print("number of points clamped to %d." % number_of_points)

    #     packet_to_send = struct.pack('=III', self.MAGIC_BYTES_READ_BUFFER, self.FPGA_BASE_ADDR, number_of_points)    # last value is reserved
    #     self.send(packet_to_send)
    #     return self.read(int(2*number_of_points))


class ServerThread(QtCore.QThread):
    statusUpdate = QtCore.pyqtSignal(str)
    dataReceived = QtCore.pyqtSignal(str)

    def __init__(self, parent=None):
        super(ServerThread, self).__init__(parent)

        self.statusUpdate.emit("thread started")
        print("ServerThread::__init__()")

        self.server = AsyncSocketServer(port_number=5000, bStartListening=False)
        self.monitor_tcp = MonitorTCP_mock()
        self.bReadEnable = False

    def run(self):
        print("ServerThread::run()")

        while 1:
            if self.bReadEnable:
                self.server.run(bParseBufferIntoLines=False)

                if len(self.server.read_buffer) > 0:
                    self.monitor_tcp.parse_buffer(self.server.read_buffer)
                    print("in ServerThread::run(): self.server.read_buffer=%s" % self.server.read_buffer)
                else:
                    self.monitor_tcp.parse_buffer(self.server.read_buffer)
                # # if we can reply, observe self.monitor_tcp.reply_latency setting!
                # if (we can reply):
                #     time.sleep(self.monitor_tcp.reply_latency)
                #     # do the actual reply!

            print(".")
            time.sleep(100e-3)
        pass

    @QtCore.pyqtSlot()
    def startListening(self):
        self.server.startListening()

    @QtCore.pyqtSlot()
    def closeConnection(self):
        self.server.sock_conn = None


    @QtCore.pyqtSlot(float)
    def setReplyLatency(self, latency_in_seconds):
        self.monitor_tcp.reply_latency = latency_in_seconds



    @QtCore.pyqtSlot(bool)
    def setReadLoopState(self, bReadEnable):
        self.bReadEnable = bReadEnable


def start_qt():
    # Start Qt:
    app = QtCore.QCoreApplication.instance()
    if app is None:
        # print("QCoreApplication not running yet. creating.")
        bEventLoopWasRunningAlready = False
        app = QtWidgets.QApplication(sys.argv)
    else:
        bEventLoopWasRunningAlready = True
        # print("QCoreApplication already running.")

    return app


class objSocketMock(QtCore.QObject):
    startListening = QtCore.pyqtSignal()
    closeConnection = QtCore.pyqtSignal()
    setReplyLatency = QtCore.pyqtSignal(float)
    setReadLoopState = QtCore.pyqtSignal(bool)

    statusUpdate = QtCore.pyqtSignal(str)
    dataReceived = QtCore.pyqtSignal(str)

    @QtCore.pyqtSlot()
    def statusUpdate(self, strUpdate):
        # could do something else with this...
        print(strUpdate)

    def __init__(self):
        super().__init__()

        # create thread object
        self.thread = ServerThread()
        # connect signals to slots in new thread
        self.startListening.connect(self.thread.startListening)
        self.closeConnection.connect(self.thread.closeConnection)
        self.setReplyLatency.connect(self.thread.setReplyLatency)
        self.setReadLoopState.connect(self.thread.setReadLoopState)

        self.startListening.emit()
        self.setReadLoopState.emit(True)

        self.thread.start()

    def timerQuit(self):
        print("timer")
        self.thread.exit()
        QtCore.QCoreApplication.instance().quit()

def test_socketMock():
    # print("creating socket")


    app = start_qt()

    print("before objSocketMock()")
    server_thread = objSocketMock()
    print("after objSocketMock()")


    timer = QtCore.QTimer()
    timer.singleShot(3000, server_thread.timerQuit)

    # thread = ServerThread()
    # thread.start()

    # print("before server_thread.thread.run()")
    # server_thread.thread.start()
    # print("after server_thread.thread.run()")

    client = AsyncSocketClient(5000)
    print("client connected.")

    for k in range(10):
        client.send_text('test')
        print("sent test")
        time.sleep(0.2)


    app.exec_()
    assert(0)


def test1():
    app = start_qt()
    server_thread = objSocketMock()

    # Timeout timer for the whole test:
    timer = QtCore.QTimer()
    timer.singleShot(3000, server_thread.timerQuit)

    client = AsyncSocketClient(5000)
    print("client connected.")

    for k in range(10):
        client.send_text('test')
        print("sent test")
        time.sleep(0.2)


    app.exec_()
    assert(0)

if __name__ == '__main__':
    # server = ServerThread()
    # server.startListening()
    # server.bReadEnable = True
    # server.server.bVerbose = False
    # server.run()

    test_socketMock()

    pass

