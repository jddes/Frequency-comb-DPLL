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

class MonitorTCP_mock():
    def __init__(self):
        self.reply_latency = 0
    def parse_buffer(self, data_buffer):
        # parse the buffer, similar to what monitor-tcp does!
        # TODO: This needs to consume the buffer, otherwise the data will just accumulate.
        # Need to check if passing the data this way gives us a chance to modify the buffer itself
        # or if we'll just end up modifying a copy

        if len(data_buffer) > 0:
            print("in MonitorTCP_mock::parse_buffer(): data_buffer=%s. Clearing." % data_buffer)
            data_buffer[:] = bytearray()
        # return data_buffer # Do we need to return it to be able to modify it? I think not, but I am not sure...


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

if __name__ == '__main__':
    # server = ServerThread()
    # server.startListening()
    # server.bReadEnable = True
    # server.server.bVerbose = False
    # server.run()

    test_socketMock()

    pass

