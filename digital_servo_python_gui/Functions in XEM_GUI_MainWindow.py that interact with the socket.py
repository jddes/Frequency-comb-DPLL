Functions in XEM_GUI_MainWindow.py that interact with the socket:

Need to:
    1 - Write a test for each of these, covering both cases of a socket exception and a read success
    2 - Handle the exceptions properly in each of these.
        Decide whether we should use a common handler via a decorator for example,
            (could log the error, and suppress the messages that repeat at every attempt)
        or simply have a custom way of handling the errors in each of those.
    -It would be nice if the whole GUI wouldn't become unresponsive when we encounter a network error.
        -I think a good way of doing this is that the device sets valid_socket=False when it encounters an error,
        and doesn't attempt reads when it knows that it has been disconnected.


slowStart100VSwitchingSupply(self):
setVCOGain_event(self):
getVCOGain(self):
setVCOFreq_event(self):
setVCOFreq_event(self):
getVCOFreq(self):
getVCOFreq(self):
grabAndExportData(self):
grabAndExportData(self):
grabAndExportData(self):
grabAndExportData(self):
grabAndExportData(self):
grabAndExportData(self):
grabAndExportData(self):
chkLockClickedEvent(self):
chkLockClickedEvent(self):
chkLockClickedEvent(self):
chkLockClickedEvent(self):
chkLockClickedEvent(self):
chkLockClickedEvent(self):
chkLockClickedEvent(self):
chkLockClickedEvent(self):
chkLockClickedEvent(self):
chkLockClickedEvent(self):
chkLockClickedEvent(self):
chkLockClickedEvent(self):
timerDitherEvent(self):
timerEvent(self, e):
displayDAC(self):
displayDAC(self):
displayDAC(self):
displayDAC(self):
displayDAC(self):
displayDDC(self):
displayDDC(self):
displayDDC(self):
displayDDC(self):
getADCdata(self, input_select, N_samples):
getADCdata(self, input_select, N_samples):
getADCdata(self, input_select, N_samples):
getADCdata(self, input_select, N_samples):
getADCdata(self, input_select, N_samples):
getADCdata(self, input_select, N_samples):
getADCdata(self, input_select, N_samples):

Unique functions:
----------------------------------------------------
slowStart100VSwitchingSupply(self): done
setVCOGain_event(self): done
getVCOGain(self): done
setVCOFreq_event(self): done
getVCOFreq(self): done
grabAndExportData(self): done, but test is not very thorough
chkLockClickedEvent(self): TODO!%!?%!?!%!?!
timerDitherEvent(self): done
timerEvent(self, e): this calls displayADC, displayDDC depending on internal state. do it after the other ones
grabAndDisplayADC(): done. now actually done, including exception recovery
displayDAC(self): done, including exception recovery
displayDDC(self): 
