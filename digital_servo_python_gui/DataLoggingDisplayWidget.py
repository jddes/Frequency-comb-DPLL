from PyQt5 import QtCore, Qt, QtGui, uic
import sys
import time

import numpy as np
import pyqtgraph as pg

import math


class DataLoggingDisplayWidget(QtGui.QWidget):
    def __init__(self, parent=None, numPlots=1, numCurvesPerPlot=1):
        super(DataLoggingDisplayWidget, self).__init__(parent)

        # Set a few global PyQtGraph settings before creating plots:
        pg.setConfigOption('leftButtonPan', False)
        pg.setConfigOption('background', 'w')
        pg.setConfigOption('foreground', 'k')
        pg.setConfigOption('antialias', True)

        # create the arrays that will hold the data:
        self.numPlots = numPlots
        self.N_history = 600   # hold 600 points by default
        self.data_x     = np.zeros(self.N_history)
        self.numCurvesPerPlot = numCurvesPerPlot
        self.data_y = list()
        for k in range(self.numCurvesPerPlot):
            self.data_y.append(np.zeros((self.N_history, self.numPlots)))
        self.data_valid = np.zeros(self.N_history, dtype=bool)
        self.numValid = 0
        self.last_x = 0.
        self.newLocation = 0

        uic.loadUi("DataLoggingDisplayWidget.ui", self)

        self.initUI()

    def resizeDataHistory(self, N_history_new):
        # print('resizeDataHistory(): N_history_new=%d, self.N_history=%d' % (N_history_new, self.N_history))
        # print('State before:')
        # self.printInternalState()
        # are we shrinking or growing?
        if N_history_new < self.N_history:
            # shrinking: just resize the existing vector down to requested size, keeping the last points
            self.data_x = self.data_x[-N_history_new:]
            for k in range(self.numCurvesPerPlot):
                self.data_y[k] = self.data_y[k][-N_history_new:, :]
            self.data_valid = self.data_valid[-N_history_new:]
        else:
            # growing: concatenate into a new array
            self.data_x = np.concatenate((self.data_x, np.zeros(N_history_new-self.N_history)                  ))
            for k in range(self.numCurvesPerPlot):
                self.data_y[k] = np.concatenate((self.data_y[k], np.zeros((N_history_new-self.N_history, self.numPlots)) ))
            self.data_valid = np.concatenate((self.data_valid, np.zeros(N_history_new-self.N_history, dtype=bool)      )) # new points will be filled with False

        # print('State after')
        # self.printInternalState()

        # a little bit of error checking:
        assert self.data_x.shape[0]     == N_history_new
        for k in range(self.numCurvesPerPlot):
            assert self.data_y[k].shape[0]     == N_history_new
        assert self.data_valid.shape[0] == N_history_new
        # update internal state
        self.N_history = self.data_y[0].shape[0]
        self.numValid = np.sum(self.data_valid) # a bit lazy but the cost is insignificant
        

    def initUI(self):

        # list of RGB tuples defining the colors (same colorset as matlab)
        colors_list = [(     0,    0.4470,    0.7410),
                       (0.8500,    0.3250,    0.0980),
                       (0.9290,    0.6940,    0.1250),
                       (0.4940,    0.1840,    0.5560),
                       (0.4660,    0.6740,    0.1880),
                       (0.3010,    0.7450,    0.9330),
                       (0.6350,    0.0780,    0.1840)]
        numColors = len(colors_list)


        # create the PlotItems and curves in the graphicslayoutwidget:
        self.pltItemsList = []
        self.curvesList = []    # this is a list of lists of curves
        for k in range(self.numPlots):
            self.pltItemsList.append(self.graphicsView.addPlot(title='', row=k, col=0))
            # create the curves in the plots:
            for k2 in range(self.numCurvesPerPlot):
                self.curvesList.append(list())
                # create our pen: (TODO)
                (penR, penG, penB) = colors_list[k2 % numColors]
                pen = QtGui.QPen(QtGui.QColor(penR*255, penG*255, penB*255))
                pen.setCosmetic(True)
                self.curvesList[k2].append(self.pltItemsList[-1].plot(pen=pen))

        # self.replot()
        self.lineEdit_DisplayPts.setText('%d' % self.N_history)
        self.lineEdit_DisplayPts.editingFinished.connect(self.updateNumPoints)

    def updateNumPoints(self):
        try:
            new_N = int(round(eval(str(self.lineEdit_DisplayPts.text()))))
        except:
            new_N = self.N_history
            pass

        if new_N != self.N_history:
            self.resizeDataHistory(new_N)

    # x must be a scalar
    # y must be a list of numpy arrays.
    #   the list must have numCurvesPerPlot elements, while the numpy arrays must have numPlots elements
    def addDataPoint(self, x, y):
        # if data history is full, 
        if self.numValid >= self.N_history:
            # we rotate out the oldest point
            self.data_x[:self.N_history-1]    = self.data_x[1:]
            for k in range(self.numCurvesPerPlot):
                self.data_y[k][:self.N_history-1, :] = self.data_y[k][1:, :]
            self.newLocation = self.N_history-1
        else:
            self.newLocation = self.numValid
            self.numValid += 1
        # assign in the new point
        self.data_x[self.newLocation]     = x
        for k in range(self.numCurvesPerPlot):
            self.data_y[k][self.newLocation, :]  = y[k]
        self.data_valid[self.newLocation] = True
        self.last_x = x
        assert np.sum(self.data_valid) == self.numValid
        self.replot()

    def replot(self):

        if not self.checkBox_EnableDisplay.isChecked():
            return

        for k in range(self.numCurvesPerPlot):
            for index, curve in enumerate(self.curvesList[k]):
                curve.setData(self.data_x[self.data_valid]-self.last_x, self.data_y[k][self.data_valid, index])

        # handle Y axis:
        if self.checkBox_manualYlimits.isChecked():
            try:
                y_min = float(str(self.edit_MinY.text()))
                y_max = float(str(self.edit_MaxY.text()))
                self.pltItemsList[0].getViewBox().setYRange(y_min, y_max)
                self.pltItemsList[0].getViewBox().enableAutoRange(y=False)
            except:
                self.pltItemsList[0].getViewBox().enableAutoRange(y=True)

        else:
            self.pltItemsList[0].getViewBox().enableAutoRange(y=True)
            pass
    ################################################################
    ## Functions used for testing and debugging only:

    def startTestMode(self):
        # this generates fake data based on a timer, for testing purposes:
        self.time_start = time.clock()
        self.timer = QtCore.QTimer()
        self.timer.timeout.connect(self.testModeUpdate)
        self.timer.start(500) # 500 ms update period


    def testModeUpdate(self):
        # generate a new data point:
        x = time.clock() - self.time_start
        y_list = list()
        for k in range(self.numCurvesPerPlot):
            y_list.append(np.cos(2*math.pi*0.1*x*np.ones(self.numPlots)) + 0.1*np.random.randn(self.numPlots))
        self.addDataPoint(x, y_list)

    def printInternalState(self):
        print(self.data_valid)
        print(self.data_x)
        print(self.data_y)
        print("self.newLocation = %d" % (self.newLocation))
        print("self.N_history = %d" % (self.N_history))
        print("self.numValid = %d" % (self.numValid))
        print("np.sum(self.data_valid) = %d" % (np.sum(self.data_valid)))


################################################################
## Main code
################################################################



def main():
    app = QtGui.QApplication([])
    GUI = DataLoggingDisplayWidget(numPlots=2, numCurvesPerPlot=3)
    GUI.pltItemsList[0].setToolTip('Blue = First curve, Orange = Second curve')
    GUI.pltItemsList[1].setToolTip('Blue = First curve, Orange = Second curve')
    # Show GUI
    GUI.show()
    # GUI.showMaximized()

    GUI.startTestMode()
        
    # Execute application unless we are running in interactive mode (got this trick from PyQtGraph examples)
    if (sys.flags.interactive != 1) or not hasattr(QtCore, 'PYQT_VERSION'):
        QtGui.QApplication.instance().exec_()

    # del GUI
    # time.sleep(5)
    
    
if __name__ == '__main__':
    main()
    pass