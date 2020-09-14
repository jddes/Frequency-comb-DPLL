from PyQt5 import QtCore, QtGui, QtWidgets, uic
import time
import sys

class CheckboxesCollectionWidget(QtWidgets.QWidget):
    sig_new_state = QtCore.pyqtSignal(dict)

    def __init__(self, names, default_state=True, parent=None):
        """ Widgets that displays a bunch of checkboxes with names from an iterable, and
        emits a dictionary with the state of each checkboxes whenever the user changes it """
        super().__init__(parent)
        self.names = names
        self.setupUi(default_state)

    def update(self):
        checkboxes_state = {n: self.checkboxes[n].isChecked() for n in self.names}
        self.sig_new_state.emit(checkboxes_state)

    def setupUi(self, default_state):
        vbox = QtWidgets.QVBoxLayout()
        self.checkboxes = dict()
        for n in self.names:
            w = QtWidgets.QCheckBox(n, self)
            w.setChecked(default_state)
            w.clicked.connect(self.update)
            self.checkboxes[n] = w
            vbox.addWidget(w)
        self.setLayout(vbox)

def main():
    app = QtWidgets.QApplication(sys.argv)
    gui = CheckboxesCollectionWidget(["test1", "test2"])
    gui.show()
    app.exec_()

if __name__ == '__main__':
    main()
