# -*- coding: utf-8 -*-
"""
Created on Mon Apr 14 11:46:04 2014

@author: jnd
"""
from __future__ import print_function

import time
from PyQt5 import QtGui, Qt
import numpy as np
import sys

import pyqtgraph as pg

import os

##########################
# Parameters
strFolder = 'O:\\68601\\fiber frequency comb\\Python code\\SuperLaserLand_JD_v9_stable\\data_logging\\'
N_pts_max = 1e6 # -1 means all the file
##########################


##########################
# Start Qt:
app = QtGui.QApplication(sys.argv)

##########################
# Show a dialog to select which log to look at:

print(strFolder)
strFileName = QtGui.QFileDialog.getOpenFileName(None, 'Open file', strFolder)
strFileName = str(strFileName)
print(strFileName)
if strFileName == '':
    print('cancelled.')
    del app
    sys.exit()

##########################
# Parse the selected filename so that we can generate the names of the others logs from this one:
str_split_path = os.path.split(strFileName)
strPath = str_split_path[0]
strFile = str_split_path[1]
strTemplate = strFile.rsplit('_', 1)[0]    # splits the last part of the string, when it encounters the first _

##########################
# Set a few options for PyQtGraph:
pg.setConfigOptions(antialias=False)
pg.setConfigOption('background', 'w')
pg.setConfigOption('foreground', 'k')

##########################
# Create the PyQtGraph window for plotting:
win = pg.GraphicsWindow()
win.resize(1000,600)
win.setWindowTitle('Log viewer: %s' % strTemplate)


##########################
# Generate all the filenames that we want
# This dictionary contains entry with: 'data name': ('data file postfix', plot number, line color, )
infosDictionary = {'DAC0': ('DAC0', 0, (0, 0, 255)),
                     'DAC1': ('DAC1', 0, (0, 127, 0)),
                     'DAC2': ('DAC2', 0, (255, 0, 0)),
                     'CEO freq': ('freq_counter0', 1, (0, 0, 255)),
                     'Optical freq': ('freq_counter1', 1, (0, 127, 0))}
windowsDictionary = {}
plotsTitles = ['Normalized DAC outputs', 'Frequency error']
plot_list = []
for strName, tuple_item in infosDictionary.iteritems():
    # Get information out of our dictionary:
    strCurrentPostfix = tuple_item[0]
    window_number = tuple_item[1]
    line_color = tuple_item[2]
    
    # Generate the filename
    strCurrentFile = os.path.join(strPath, strTemplate) + '_' + strCurrentPostfix + '.bin'
    print(strCurrentFile)
    
    # Read the data from the file
    f = open(strCurrentFile, 'rb')
    with f:        
        data = np.fromfile(file=f, count=int(N_pts_max))
    
    # Create the plot if it doesn't exist yet:
    if not (window_number in windowsDictionary):
        # Have to create the window:
        windowsDictionary[window_number] = win.addPlot(title=plotsTitles[window_number])
        windowsDictionary[window_number].addLegend()
        
    # Add the data to the plot
    if window_number == 1:
#        plot_list.append(windowsDictionary[window_number].plot(np.log10(np.abs(data)), pen=line_color, autoDownsample=True, downsampleMethod='peak'))
        plot_list.append(windowsDictionary[window_number].plot(np.log10(np.abs(data)), pen=line_color, name=strName))
        
#        print(strName)
    else:
        plot_list.append(windowsDictionary[window_number].plot(data, pen=line_color, name=strName))


app.exec_()

del win
del app