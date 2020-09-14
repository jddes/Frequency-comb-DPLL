from PyQt5 import QtCore, QtGui, QtWidgets, uic
import time
import sys

class EmptyWidgetTemplate(QtWidgets.QWidget):

    def __init__(self, parent=None):
        """  """
        super().__init__(parent)

        # Load UI elements:
        self.setupUi()

    def setupUi(self):
        # Use this to load the GUI from a .ui file:
        uic.loadUi("empty_widget_template.ui", self)


def main():
    app = QtWidgets.QApplication(sys.argv)
    gui = EmptyWidgetTemplate()
    gui.show()
    app.exec_()

if __name__ == '__main__':
    main()

