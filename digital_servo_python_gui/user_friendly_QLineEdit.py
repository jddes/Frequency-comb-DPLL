# -*- coding: utf-8 -*-
"""
"""

import sys
from PyQt5 import QtGui, Qt, QtCore

class user_friendly_QLineEdit(Qt.QLineEdit):

    def __init__(self, text):
        super(user_friendly_QLineEdit, self).__init__(text)

        self.textChanged.connect(self.change_my_color)
        self.returnPressed.connect(self.reset_my_color)
        
        self.reset_my_color()
        
    def change_my_color(self):
        palette = Qt.QPalette()
        palette.setColor(self.backgroundRole(), Qt.QColor('black'))
        palette.setColor(self.foregroundRole(), Qt.QColor('white'))
        self.setPalette(palette)
        
    def reset_my_color(self):
        palette = Qt.QPalette()
        palette.setColor(self.backgroundRole(), Qt.QColor('white'))
        palette.setColor(self.foregroundRole(), Qt.QColor('black'))
        self.setPalette(palette)
        