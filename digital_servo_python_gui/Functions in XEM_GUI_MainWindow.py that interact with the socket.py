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
timerDitherEvent(self): done
grabAndDisplayADC(): done. now actually done, including exception recovery
displayDAC(self): done
displayDDC(self): done
timerEvent(self, e): done
chkLockClickedEvent(self): done


------------- next up:

-Test and make sure that our RP_PLL (and controller?) object is nicely behaved when the socket throws exceptions.
    -Build a mock:
        -server runs in a separate QThread (in the test file)
        -server receives signals:
        -next reply adds X seconds of delay
        -next reply adds X seconds of delay then closes connection
        -close connection immediately (are there multiple ways of closing the connection?)

        -handling of socket errors:
            -on first socket error, throw a CommsLoggeableException, set valid_socket = False, notify whoever will be in charge of a reconnection timeout
            -Next calls to read or send: when valid_socket = True, throw CommsException and do nothing else

            -somewhere is a reconnection mecanism that isn''t obnoxious

            

-Make sure that every other file that interacts either with the socket or RP_PLL device handles comms exceptions correctly.
    -FreqCounterWindow
    -SettingsWindow
    -look around to make sure there are not others too! ditherSettings?

-Make some kind of higher level test, where we can actually open the GUI?  One way would be to create a mock TCP server that returns reasonable values for each read
    -Could start by reading the monitor-tcp or RP_PLL code.  There are a few packet types that we need to handle (reg_write, reg_read (2 types each), read_buffer.)
    -This is will be very helpful in the future...
    -could also be part of future automated tests

-Do we forge ahead and start dealing with RP_PLL, or work on a higher level test?

-could do a pretty low level test with RP_PLL and either a mock socket object, or a mock socket server.
-decision: lets make it a mock socket server!
    -This way we can either do it super simple and just test RP_PLL+simple_server by itself (in the same thread even) to make sure it handles tcp events nicely
    -or we can make a much more sophisticated mock server, which would actually enable using the GUI without a real device connected.







