# Qt Widget to replace Qwt's thermometer widget (vertical only for now) so that we can remove dependency on this package
# JDD 2017-06-04




#from PyQt5 import QtGui, Qt, QtCore, QtWidgets
##import PyQt5.Qwt5 as Qwt
#import numpy as np
import sys


from PyQt5 import QtGui, Qt, QtCore, QtWidgets
#from PyQt5 import QtGui, Qt
#import PyQt5.Qwt5 as Qwt
import numpy as np



# stuff for Python 3 port
#import pyqtgraph as pg


class ThermometerWidget(QtWidgets.QWidget):

    def __init__(self):
        super(ThermometerWidget, self).__init__()

        self.value = 0
        self.min_value = 0
        self.max_value = 1
        self.border_width = 2
        self.bar_height = 120
        self.bar_width = 10
        self.bar_offset = 10
        self.widest_tick_label = 0
        self.text_margin = 6
        self.ticks_width = 8
        self.minor_ticks_width = 5
        
        self.lblTicks = list()
        self.qline_ticks = list()
        self.qline_minor_ticks = list()
        self.ticksValuesList = list()
        self.minorTicksValuesList = list()
        self.ticksTextList = list()

        self.initUI()

    def setRange(self, min_value, max_value):
        if self.max_value <= self.min_value:
            self.max_value = self.min_value+1   # avoids divide by 0 error later in setValue()
        self.min_value = min_value
        self.max_value = max_value
        #print("min = %f, max = %f" % (self.min_value, self.max_value))

    def setScale(self, min_value, max_value):
        # just for compatibility with Qwt's thermometer
        self.setRange(min_value, max_value)

    def setValue(self, value):
        
        # assign value with bounds checking
        if value > self.max_value:
            self.value = self.max_value
        elif value < self.min_value:
            self.value = self.min_value
        else:
            self.value = value

        # Update widget display:
        self.resizeEvent(None)

    def setFillColor(self, color):
        PaletteBackground = Qt.QPalette()
        PaletteBackground.setColor(Qt.QPalette.Background, color)
        self.front_label.setPalette(PaletteBackground)
        self.front_label.setAutoFillBackground(True)

    # def sizeHint(self):
    #     return self.bck_label.size()


    def setTicks(self, ticksValuesList, minorTicksValuesList, ticksTextList):

        
        # we need a black background to create the lines
        PaletteBlack = Qt.QPalette()
        PaletteBlack.setColor(Qt.QPalette.Background, Qt.Qt.black)


        # create one line and one label per major tick mark:
        self.ticksValuesList = list()
        self.ticksTextList = list()
        self.lblTicks = list()
        self.qline_ticks = list()
        self.widest_tick_label = 0
        for index, elem in enumerate(ticksValuesList):
            if elem > self.max_value or elem < self.min_value:
                continue
            self.ticksValuesList.append(elem)
            self.ticksTextList.append(ticksTextList[index])

            self.lblTicks.append(Qt.QLabel(ticksTextList[index], self))
            #self.qline_ticks.append(QtCore.Qline(self))
            self.qline_ticks.append(Qt.QLabel(self))
            self.qline_ticks[-1].setPalette(PaletteBlack)
            self.qline_ticks[-1].setAutoFillBackground(True)
            # measure the widest tick label to size overall widget:
            self.lblTicks[-1].adjustSize()
            if self.lblTicks[-1].size().width() > self.widest_tick_label:
                self.widest_tick_label = self.lblTicks[-1].size().width()


        # create minor tick marks:
        self.minorTicksValuesList = list()
        self.qline_minor_ticks = list()
        for index, elem in enumerate(minorTicksValuesList):
            self.minorTicksValuesList.append(elem)
            self.qline_minor_ticks.append(Qt.QLabel(self))
            self.qline_minor_ticks[-1].setPalette(PaletteBlack)
            self.qline_minor_ticks[-1].setAutoFillBackground(True)

        # Update widgets positions:
        self.resizeEvent(None)

        
    def resizeEvent(self, event):
        #print("resizeEvent()")
        # self.blockSignals(True) # block signals to prevent creating an infinite loop
        # Update back widget size:
        total_size = self.size()
        self.bck_label.setFixedHeight(total_size.height())
        
        self.bck_label.move(self.widest_tick_label+2*self.text_margin+self.ticks_width, 0)
        # Update overall Widget's size
        self.setFixedWidth(self.bar_width+2*self.border_width+self.widest_tick_label+2*self.text_margin+self.ticks_width)

        # compute required size for front label in pixels
        bck_size = self.bck_label.size()
        # Catch "cannot convert float NaN to integer" when one open the GUI without Red Pitaya
        try:
            actual_height = round((float(self.value)-self.min_value)/(self.max_value-self.min_value) * (bck_size.height()-2*self.border_width))
        except:
            actual_height = 100

        #print("value = %f, min = %f, max = %f" % (value, self.min_value, self.max_value))

        # set front label widget size
        self.front_label.setFixedHeight(actual_height)
        self.front_label.move(self.bck_label.pos().x()+self.border_width, bck_size.height()-self.border_width-actual_height)

        # Update ticks and tick labels positions (major ticks):
        for index, elem in enumerate(self.lblTicks):

            # compute vertical position of this tick:
            vert_pos = bck_size.height() - round((float(self.ticksValuesList[index])-self.min_value)/(self.max_value-self.min_value) * (bck_size.height()-2*self.border_width))
            # set tick label's position:
            horiz_pos = self.text_margin
            elem.move(horiz_pos, vert_pos-round(elem.size().height()/2.)-self.border_width)

            # set tick mark's position:
            horiz_pos = 2*self.text_margin + self.widest_tick_label
            #self.qline_ticks[index].setLine(horiz_pos, vert_pos-round(self.qline_ticks[index].size().height()/2.), horiz_pos+self.ticks_width, vert_pos-round(self.qline_ticks[index].size().height()/2.))
            self.qline_ticks[index].setFixedSize(self.ticks_width, 1)
            self.qline_ticks[index].move(horiz_pos, vert_pos-round(self.qline_ticks[index].size().height()/2.)-self.border_width)            

        # Update ticks and tick labels positions (minor ticks):
        for index, elem in enumerate(self.minorTicksValuesList):

            # compute vertical position of this tick:
            vert_pos = bck_size.height() - round((float(self.minorTicksValuesList[index])-self.min_value)/(self.max_value-self.min_value) * (bck_size.height()-2*self.border_width))

            # set tick mark's position:
            horiz_pos = 2*self.text_margin + self.widest_tick_label
            #self.qline_minor_ticks[index].setLine(horiz_pos, vert_pos-round(self.qline_minor_ticks[index].size().height()/2.), horiz_pos+self.minor_ticks_width, vert_pos-round(self.qline_minor_ticks[index].size().height()/2.))
            self.qline_minor_ticks[index].setFixedSize(self.minor_ticks_width, 1)
            self.qline_minor_ticks[index].move(horiz_pos, vert_pos-round(self.qline_minor_ticks[index].size().height()/2.)-self.border_width)
            

        # self.blockSignals(False)


    def initUI(self):
        self.bck_label = Qt.QLabel(self)
        self.front_label = Qt.QLabel(self)

        # add border to back label:
        self.bck_label.setStyleSheet('border: %dpx solid black' % self.border_width)

        
        self.front_label.setFixedWidth(self.bar_width)
        self.bck_label.setFixedWidth(self.bar_width+2*self.border_width)
        self.front_label.setMinimumHeight(self.bar_height)
        self.bck_label.setMinimumHeight(self.bar_height+2*self.border_width)

        self.bck_label.move(0, 0)
        self.front_label.move(self.border_width, self.border_width)


        # back label should be minimum, front label should be fixed (and follow )
        self.bck_label.setSizePolicy(Qt.QSizePolicy.Fixed, Qt.QSizePolicy.Minimum)
        self.front_label.setSizePolicy(Qt.QSizePolicy.Fixed, Qt.QSizePolicy.Ignored)
        self.setFixedWidth(self.bar_width+2*self.border_width)
        self.setSizePolicy(Qt.QSizePolicy.Fixed, Qt.QSizePolicy.Minimum)


if __name__ == '__main__':
    
    #app = QApplication(sys.argv)
    app = QtCore.QCoreApplication.instance()
    if app is None:
        app = QtWidgets.QApplication(sys.argv)
    
    ex = ThermometerWidget()
    ex.setFillColor(Qt.Qt.blue)
    ex.setValue(0.2)
    ticksListMajor = [0, 0.2, 0.4, 0.6, 0.8, 1]
    ticksListMinor = [0.1, 0.3, 0.5, 0.7, 0.9]
    ticksLabelMajor = list(map(str, ticksListMajor))
    ex.setTicks(ticksListMajor, ticksListMinor, ticksLabelMajor)
    ex.show()
    app.exec_()
    #sys.exit(app.exec_())  
    
    