from PyQt5 import QtWidgets, QtGui, QtCore, QtWidgets, uic
import time
import sys

import subprocess
import datetime
import os
import sys
import functools
import collections
import time

import win32con, win32gui, win32process

comp_name = os.environ['COMPUTERNAME']

# These paths must be specified per PC
strCombLocksFolder = {
    'JDBUREAU':    'D:\\Repo\\dpll\\digital_servo_python_gui\\',
    # '686MAUNALOA': 'C:\\comb_control\\digital_servo_python_gui\\' # placeholder, this is not the correct path!
    }

# this can be just 'python' if the correct version is on the PATH, otherwise specify the correct interpreter using an absolute path
python_interpreter = 'python'

subprocesses = collections.OrderedDict()
subprocesses['Comb lock GUI 1']  = ([python_interpreter, '-u', strCombLocksFolder[comp_name]+'XEM_GUI3.py'], strCombLocksFolder[comp_name])
subprocesses['Comb lock GUI 2']  = ([python_interpreter, '-u', strCombLocksFolder[comp_name]+'XEM_GUI3.py'], strCombLocksFolder[comp_name])

# if comp_name == 'JDBUREAU':
#     # Set a bunch of scripts for testing only:
#     # the "-u" argument means unbuffered stdout/stderr.
#     subprocesses = collections.OrderedDict()
#     subprocesses['Infinite'] =           ([python_interpreter, '-u', 'Launcher.py', 'produce_infinite'], None)
#     subprocesses['Infinite (locking)'] = ([python_interpreter, '-u', 'Launcher.py', 'produce_infinite_lock'], None)
#     subprocesses['Limited'] =            ([python_interpreter, '-u', 'Launcher.py', 'produce_limited'], None)
#     subprocesses['stderr'] =             ([python_interpreter, '-u', 'Launcher.py', 'produce_stderr'], None)
#     subprocesses['Notepad'] =            (['notepad'], None)

# From timgolden.me.uk/python/win32_how_do_i/find-the-window-for-my-subprocess.html
def get_hwnds_for_pid(pid):
    def callback(hwnd, hwnds):
        if win32gui.IsWindowVisible(hwnd) and win32gui.IsWindowEnabled(hwnd):
            _, found_pid = win32process.GetWindowThreadProcessId(hwnd)
            if found_pid == pid:
                hwnds.append(hwnd)
        return True

    hwnds = list()
    win32gui.EnumWindows(callback, hwnds)
    return hwnds

# from stackoverflow.com/questions/12118939/how-to-make-a-pyqt4-window-jump-to-the-front
def makeTopMost(hwnd):
    isMinimized = win32gui.IsIconic(hwnd)
    if isMinimized:
        win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
        win32gui.RedrawWindow(hwnd, None, None, win32con.RDW_INVALIDATE | win32con.RDW_INTERNALPAINT)

    makeAlwaysOnTop(hwnd, True)
    makeAlwaysOnTop(hwnd, False)

def makeAlwaysOnTop(hwnd, bAlwaysOnTop=True):
    if bAlwaysOnTop:
        topmost_constant = win32con.HWND_TOPMOST # = always on top
    else:
        topmost_constant = win32con.HWND_NOTOPMOST # = disable always on top

    win32gui.SetWindowPos(hwnd,
        topmost_constant, 
        0, 0, 0, 0,
        win32con.SWP_NOMOVE | win32con.SWP_NOSIZE | win32con.SWP_SHOWWINDOW)

# inspired by https://www.stefaanlippens.net/python-asynchronous-subprocess-pipe-reading/,
# but re-written for Qt using QThread and signals
class AsyncFileReader(QtCore.QThread):
    lineReceived = QtCore.pyqtSignal(str)

    def __init__(self, fd):
        super(AsyncFileReader, self).__init__()
        self._fd = fd
        self.lineReceived.emit("thread started")

    def run(self):
        '''The body of the thread: read lines and send them out as a signal '''
        for line in iter(self._fd.readline, ''):
            line_stripped = line.rstrip()
            self.lineReceived.emit(line_stripped)

class CustomTextEdit(QtWidgets.QPlainTextEdit):
    def __init__(self, *args, **kwargs):
        super(CustomTextEdit, self).__init__(*args, **kwargs)
        self.mouse_down = False
        self.has_selection = False
        self.copyAvailable.connect(self.copyAvailableEvent)

        # create a mono-spaced font:
        font = QtGui.QFont("Monospace")
        font.setStyleHint(QtGui.QFont.TypeWriter)
        self.setFont(font)

    def copyAvailableEvent(self, has_selection):
        self.has_selection = has_selection

    def mousePressEvent(self, event):
        super(CustomTextEdit, self).mousePressEvent(event)
        self.mouse_down = True

    def mouseReleaseEvent(self, event):
        super(CustomTextEdit, self).mouseReleaseEvent(event)
        self.mouse_down = False

    def setLineLimit(self, lineLimit):
        self.setMaximumBlockCount(lineLimit)

    def appendText(self, newLine, lineLimit=None):
        # time_start = time.perf_counter()

        self.appendPlainText(newLine)
        # time_append = time.perf_counter()-time_start

        if self.shouldScroll():
            self.moveCursor(QtGui.QTextCursor.End, QtGui.QTextCursor.MoveAnchor)
            self.ensureCursorVisible()
            # time_scroll = time.perf_counter()-time_start
        # else:
        #     time_scroll = time.perf_counter()-time_start

        # if time_scroll > 10e-3:
        #     print("appendText(): limit=%.0f, append=%.0f, scroll=%.0f" % (1e3*(time_limit), 1e3*(time_append-time_limit), 1e3*(time_scroll-time_append)))

    def shouldScroll(self):
        return not (self.mouse_down or self.has_selection)

class LauncherGui(QtWidgets.QWidget):
    def __init__(self, subprocesses):
        super(LauncherGui, self).__init__()
        self._subprocesses = subprocesses

        self.style_sheets = {
            'Normal':           '',
            'NormalEven':       'background-color: rgb(255, 255, 255)',
            'NormalOdd':        'background-color: rgb(200, 200, 200)',
            'red':              'background-color: rgb(213, 0, 43); color: rgb(255, 255, 255); ',
            'yellow':           'background-color: rgb(255, 255, 0)',
            'green':            'background-color: rgb(0, 165, 114); color: rgb(255, 255, 255); ',
            'oxford_blue':      'background-color: #01172F; color: rgb(255, 255, 255); ',
            'ultramarine_blue': 'background-color: #446df6; color: rgb(255, 255, 255); ',
            'electric_indigo':  'background-color: #6610F2; color: rgb(255, 255, 255); ',
            }
        self.last_err_cmd = ''
        self.lineLimit = int(10e3)
        self.initUI()

        self.pollingTimer = QtCore.QTimer(self)
        self.pollingTimer.timeout.connect(self.timerEvent)
        self.pollingTimer_timeout_in_secs = 1
        self.pollingTimer.start(self.pollingTimer_timeout_in_secs*1000.) # start() takes the timeout in ms instead of seconds

    def closeEvent(self, event):
        reply = QtWidgets.QMessageBox.question(self, 'Warning',
                    "Are you sure you want to quit?",
                    QtWidgets.QMessageBox.Yes | QtWidgets.QMessageBox.No, QtWidgets.QMessageBox.No)
        
        if reply == QtWidgets.QMessageBox.Yes:
            event.accept()
        else:
            event.ignore()

    def initUI(self):
        # Create buttons to "launch/bring to front/display the state" of each subprocess:
        hbox = QtWidgets.QHBoxLayout()
        # font = QtGui.QFont(Q, pointSize=16)
        font = QtGui.QFont()
        font.setPointSize(16)
        self.txt = dict()
        self.threads_stdout = dict()
        self.threads_stderr = dict()
        self.processes = dict()
        for cmd_text in self._subprocesses:
            b = QtWidgets.QPushButton(cmd_text)
            b.setFont(font)
            b.setAutoFillBackground(True)
            b.setStyleSheet(self.style_sheets['red'])
            # b.setFlat(True) # make the button look like a label
            b.clicked.connect(functools.partial(self.txtClicked, cmd_text))
            
            self.txt[cmd_text] = b
            hbox.addWidget(b)


        # Create text boxes to show stderr:
        # grid to hold both controls for stderr:
        grid = QtWidgets.QGridLayout()
        self.btnClearStdErr = QtWidgets.QPushButton('Clear errors')
        self.btnClearStdErr.clicked.connect(self.clearStdErr)
        self.editStdError = CustomTextEdit(self)
        self.editStdError.setLineLimit(self.lineLimit)
        grid.addWidget(self.btnClearStdErr, 0, 0)
        grid.addWidget(self.editStdError, 1, 0, 1, 2)
        self.stdOutTabs = QtWidgets.QTabWidget(self)

        splitter = QtWidgets.QSplitter(QtCore.Qt.Horizontal)
        # have to wrap layout in a widget so we can add it to the splitter
        widget = QtWidgets.QWidget()
        widget.setLayout(grid)
        splitter.addWidget(widget)
        splitter.addWidget(self.stdOutTabs)

        # hbox2 = QtWidgets.QHBoxLayout()
        # hbox2.addLayout(grid)
        # hbox2.addWidget(self.stdOutTabs)

        # Create text boxes to show stderr:
        self.editStdOut = dict()
        self.btnClearStdOut = dict()
        self.btnKillProcess = dict()
        for cmd_text in self._subprocesses:
            (cmd, cwd) = self._subprocesses[cmd_text]
            self.editStdOut[cmd_text] = CustomTextEdit('')
            self.editStdOut[cmd_text].setLineLimit(self.lineLimit)
            self.btnClearStdOut[cmd_text] = QtWidgets.QPushButton('Clear console')
            self.btnKillProcess[cmd_text] = QtWidgets.QPushButton('Kill Process')
            self.btnClearStdOut[cmd_text].clicked.connect(functools.partial(self.clearStdOut, cmd_text))
            self.btnKillProcess[cmd_text].clicked.connect(functools.partial(self.killProcess, cmd_text))
            grid = QtWidgets.QGridLayout()
            grid.addWidget(self.btnClearStdOut[cmd_text], 0, 0)
            grid.addWidget(self.btnKillProcess[cmd_text], 0, 1)
            grid.addWidget(self.editStdOut[cmd_text], 1, 0, 1, 3)
            w = QtWidgets.QWidget()
            w.setLayout( grid )
            self.stdOutTabs.addTab(w, cmd_text)

        vbox = QtWidgets.QVBoxLayout()
        vbox.addLayout(hbox)
        # vbox.addLayout(hbox2)
        vbox.addWidget(splitter)
        self.setLayout(vbox)

        icon = QtGui.QIcon('icons/Launcher.ico')
        self.setWindowIcon(icon)
        self.setWindowTitle('PULSE Launcher')


    def clearStdErr(self):
        self.editStdError.setPlainText('')

    def clearStdOut(self, cmd_text):
        self.editStdOut[cmd_text].setPlainText('')

    def killProcess(self, cmd_text):
        self.processes[cmd_text].kill()

    def timerEvent(self):
        # check which subprocesses are running and set the label colors accordingly:
        for cmd_text in self._subprocesses:
            if self.isSubprocessRunning(cmd_text):
                style_sheet = self.style_sheets['green']
            else:
                style_sheet = self.style_sheets['red']

            self.txt[cmd_text].setStyleSheet(style_sheet)

    @QtCore.pyqtSlot(str, str)
    def lineReceivedStdOut(self, cmd_text, line):
        time_start = time.perf_counter()
        self.editStdOut[cmd_text].appendText(str(line))
        # if time.perf_counter()-time_start>1e-3:
        #     print("Elapsed = %f sec\n" % (time.perf_counter()-time_start))

    @QtCore.pyqtSlot(str, str)
    def lineReceivedStdErr(self, cmd_text, line):
        # TODO: Add to a command multiline textbox
        if self.last_err_cmd != cmd_text:
            self.editStdError.appendText('From cmd_text=%s, time %s:' % (cmd_text, datetime.datetime.now()))
        self.last_err_cmd = cmd_text
        self.editStdError.appendText(str(line))

    def isSubprocessRunning(self, cmd_text):
        try:
            return self.threads_stdout[cmd_text].isRunning() or self.threads_stdout[cmd_text].isRunning()
        except KeyError:
            return False

    def launch_subprocess(self, cmd_text, command, cwd):
        self.processes[cmd_text] = subprocess.Popen(command, stdout=subprocess.PIPE,
                                                             stderr=subprocess.PIPE,
                                                             cwd=cwd,
                                                             bufsize=1, # line-buffered
                                                             universal_newlines=True # text mode
                                                             )
        # self.processes[cmd_text] = subprocess.Popen(command, cwd=cwd)
        # Launch the asynchronous readers of the process' stdout and stderr.
        self.threads_stdout[cmd_text] = AsyncFileReader(self.processes[cmd_text].stdout)
        self.threads_stdout[cmd_text].lineReceived.connect(functools.partial(self.lineReceivedStdOut, cmd_text))
        self.threads_stdout[cmd_text].start()
        self.threads_stderr[cmd_text] = AsyncFileReader(self.processes[cmd_text].stderr)
        self.threads_stderr[cmd_text].lineReceived.connect(functools.partial(self.lineReceivedStdErr, cmd_text))
        self.threads_stderr[cmd_text].start()

        self.processes[cmd_text].stdout = sys.stdout

    def makeForeground(self, cmd_text):
        processID = self.processes[cmd_text].pid
        hwnd = get_hwnds_for_pid(processID)
        if len(hwnd) >= 1:
            makeTopMost(hwnd[0]) # not too sure how we should handle the case of more than 1 window for this process...

    def txtClicked(self, cmd_text):
        if self.isSubprocessRunning(cmd_text):
            # print("txtClicked(), cmd_text=%s, cmd is already running. Bringing to foreground" % (cmd_text))
            self.makeForeground(cmd_text)
        else:
            (cmd, cwd) = self._subprocesses[cmd_text]
            print("txtClicked(), launching cmd_text=%s." % (cmd_text))
            print(cmd)
            self.launch_subprocess(cmd_text, cmd, cwd)
            self.editStdOut[cmd_text].appendText('>>>>' + ' '.join(cmd))
            self.timerEvent() # run this once for faster response

            # # REMOVEME: for debugging sliggishness after lots of lines:
            # if cmd_text == "Agilent Counters":
            #     for k in range(int(10e3)):
            #         self.editStdOut[cmd_text].appendText("-"*100)

        tab_index = tuple(self._subprocesses).index(cmd_text)
        self.stdOutTabs.setCurrentIndex(tab_index)

def run_gui():
    app = QtWidgets.QApplication([])
    GUI = LauncherGui(subprocesses)
    GUI.show()

    # Execute application unless we are running in interactive mode (got this trick from PyQtGraph examples)
    if (sys.flags.interactive != 1) or not hasattr(QtCore, 'PYQT_VERSION'):
        QtWidgets.QApplication.instance().exec_()
    else:
        app.exec_()

def produce_infinite():
    while 1:
        print("time = %s" % (str(datetime.datetime.now())))
        time.sleep(1)

def produce_infinite_lock():
    while 1:
        print("time = %s" % (str(datetime.datetime.now())))
        start_time = time.perf_counter()
        while time.perf_counter()-start_time<1:
            # try to lock the GUI thread
            pass
        time.sleep(0.1)

def produce_limited():
    for k in range(3):
        print("time = %s" % (str(datetime.datetime.now())))
        time.sleep(1)

def produce_stderr():
    raise Exception()


if __name__ == '__main__':
    # The main flow:
    # if there is an command line argument 'produce', act as a producer
    # otherwise be a consumer (which launches a producer as subprocess).
    if len(sys.argv) == 2 and sys.argv[1] == 'produce_infinite':
        produce_infinite()
    elif len(sys.argv) == 2 and sys.argv[1] == 'produce_infinite_lock':
        produce_infinite_lock()
    elif len(sys.argv) == 2 and sys.argv[1] == 'produce_limited':
        produce_limited()
    elif len(sys.argv) == 2 and sys.argv[1] == 'produce_stderr':
        produce_stderr()
    else:
        run_gui()
