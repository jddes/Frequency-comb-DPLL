
def fix_pyqt5_compatibility(QtGui, QtWidgets):
    """ returns a QtGui module, with all the names from QtWidgets imported.
    This is to workaround the incompatibility between the Qt versions
    in WPy3.7 and WPy3.9. """

    for n in dir(QtWidgets):
        if n in dir(QtGui):
            print(f"Warning, {n} already exists in QtGui. Skipping")
            continue

        setattr(QtGui, n, getattr(QtWidgets, n))

    return QtGui
