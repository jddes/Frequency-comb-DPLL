from PyQt5 import QtGui, Qt, QtCore, QtWidgets
import time, sys
from collections import namedtuple, deque, OrderedDict
from enum import Enum, auto
from functools import partial


class EventTypes(Enum):
    read = auto()
    written = auto()
    changed = auto()

RegEventInfo = namedtuple('RegEventInfo', ('field_name', 'event_type'))

class RegisterState(Qt.QObject):
    def __init__(self, reg_definitions):
        super().__init__()
        self.mark_timeouts = {  # how long to keep register marked in a different color after each event has happened
            EventTypes.read: 0.2,
            EventTypes.written: 1,
            EventTypes.changed: 1,
        }

        self.unmark_queue = dict() # keys are (field_name, event_type) tuples, and values is the expiration time

        self.reg_definitions = reg_definitions
        # build addr -> field_name lookup table for faster lookup at runtime
        self.name_from_addr = {reg_info.addr: fieldname for (fieldname, reg_info) in self.reg_definitions.items()}

        # start with unknown register values
        self.reg_values = {key:None for key in self.reg_definitions.keys()}

        # empty callbacks for now:
        def this_func_does_nothing(*args, **kwargs):
            pass
        self.mark_reg_callback = this_func_does_nothing
        self.reg_changed_callback = this_func_does_nothing

        # start timer which handles color-coding:
        self.timer_obj = Qt.QTimer(self)
        self.timer_obj.timeout.connect(self.timerColorCoding)
        self.timer_obj.start(100)

    def setMarkCallback(self, callback):
        """ This callback will get called with individual register info
        and event info whenever the GUI needs to mark or unmark the event as recent.
        Prototype should look like:
        def callback(field_name, event_type, bMark)
        (use partial if you need to transfer state) """
        self.mark_reg_callback = callback

    def setRegUpdateCallback(self, callback):
        """ This callback will get called with individual register
        name and value whenever the value changes.
        Prototype should look like:
        def callback(field_name, value)
        (use partial if you need to transfer state) """
        self.reg_changed_callback = callback

    def timerColorCoding(self):
        """ update the color coding status of the registers that have been
        read/written/changed long enough ago. """
        current_time = time.perf_counter()

        list_del = []
        for reg_info, unmark_time in self.unmark_queue.items():
            # check if this register is not yet ready to get unmarked:
            if unmark_time > current_time:
                continue
            # time to unmark this register.
            self.mark_reg_callback(reg_info.field_name, reg_info.event_type, bMark=False)

            # remove item from the queue once we are done looping through
            list_del.append(reg_info)

        # do the deletion after we are done iterating through the deque itself (otherwise it throws an error)
        for key in list_del:
            self.unmark_queue.pop(key)

    def reg_event(self, addr=None, field_names=None, event_type=None, values=None):
        """ call this when one or more registers has had an event (read, written, changed).
        Specify either the address(es) or the field name of the register.
        Specify a list of addresses or names if there are multiple regs
        being reported at the same time.

        event_type must be one of the valid values
        in the EventTypes enum 

        values must be the register(s) new value(s)"""

        # first need to figure out if arguments use addr or field_names:
        if addr is not None:
            # must perform lookups from addresses to names:
            if not isinstance(addr, list):
                field_names_internal = self.name_from_addr[addr]
            else:
                field_names_internal = [self.name_from_addr[x] for x in addr]
        else:
            field_names_internal = field_names

        # now do the actual work:
        map_if_list(partial(self._reg_event_single, event_type), field_names_internal, values)

    def _reg_event_single(self, event_type, field_name, value):
        """ Called from reg_event, only handles one register at a time. """

        self._reg_event_add_to_queue(event_type, field_name)

        # update the GUI only if this value is actually different than it was last time:
        last_value = self.reg_values[field_name]
        if value != last_value:
            self.reg_changed_callback(field_name, value)
            self.reg_values[field_name] = value # save new state

            # add an "updated" event to the queue:
            self._reg_event_add_to_queue(event_type=EventTypes.changed, field_name=field_name)

    def _reg_event_add_to_queue(self, event_type, field_name):
        # mark this register as read/written/updated at current time (change color)
        reg_info = RegEventInfo(field_name, event_type)
        self.mark_reg_callback(field_name, event_type, bMark=True)
        # schedule the expiration of this marking at a later time:
        unmark_time = time.perf_counter()+self.mark_timeouts[event_type]
        self.unmark_queue[reg_info] = unmark_time

# End class RegisterState

def map_if_list(func, *args):
    if isinstance(args[0], list):
        return map(func, *args)
    else:
        # scalar case:
        return func(*args)

class RegistersDisplayWidget(Qt.QWidget):
    def __init__(self, parent, reg_definitions):
        super().__init__(parent)
        # uic.loadUi("RegistersDisplayWidget.ui", self) # no need for this at the moment since the UI is super simple
        self.initUI(reg_definitions)

    def mark_register(self, field_name, event_type, bMark):
        """ Flags this event in the correct row by changing some color appropriately """
        # print("mark_register: %s, event_type=%s, bMark=%d" % (field_name, event_type, bMark))

        item_name, item_addr, item_value, item_r, item_w, item_dummy = self.field_name_to_row[field_name]
        if event_type == EventTypes.changed:
            if bMark:
                item_value.setBackground(self.brushes['yellow'])
            else:
                item_value.setBackground(self.default_brushes[field_name])

        elif event_type == EventTypes.read:
            if bMark:
                item_r.setBackground(self.brushes['green'])
            else:
                item_r.setBackground(self.default_brushes[field_name])

        elif event_type == EventTypes.written:
            if bMark:
                item_w.setBackground(self.brushes['red'])
            else:
                item_w.setBackground(self.default_brushes[field_name])
        
    def reg_update_callback(self, field_name, value):
        """ Change the QStandardItem value field.
        This is also where we need to use the proper formatting function from reg_info """
        print("reg_update_callback: %s to %s" % (field_name, value))
        item_name, item_addr, item_value, item_r, item_w, item_dummy = self.field_name_to_row[field_name]
        print("value = %s"% value)
        display_text = self.reg_definitions[field_name].formatting_func(value)
        print("display_text = %s"% display_text)
        item_value.setText(display_text)

    def initUI(self, reg_definitions):
        # create brushes for various background colors:
        self.brushes = {}
        self.brushes['red']    = Qt.QBrush(Qt.QColor(255, 0, 0))
        self.brushes['yellow'] = Qt.QBrush(Qt.QColor(255, 255, 0))
        self.brushes['green']  = Qt.QBrush(Qt.QColor(0, 165, 114))

        self.default_brushes = {}
        self.field_name_to_row = {}

        self.reg_definitions = reg_definitions
        self.max_rows = 40
        self.views = [] # the registers get split into multiple views/models
        self.models = [] # the registers get split into multiple views/models
        self._populate_views(self.reg_definitions)

        hbox = Qt.QHBoxLayout(self)
        hbox.setContentsMargins(0, 0, 0, 0)
        for view in self.views:
            hbox.addWidget(view)
        self.setLayout(hbox)

        self.setWindowTitle('Registers')

    def _get_item_parent_from_subsystem(self, subsystem, view, model):
        """ This either creates an data item if subsystem is not represented yet
        in the model, or just finds the pre-existing element.
        It maintains a dict of the subsystems in order to do this task. """

        try:
            return_value = self.subsystems[subsystem]
        except KeyError:
            # create that node
            accumulated_name = ''
            all_names = subsystem.split('/')
            names_to = '/'.join(all_names[:-1])
            lower_level_name = all_names[-1]

            child = Qt.QStandardItem(lower_level_name)
            self.subsystems[subsystem] = child

            parent = self._get_item_parent_from_subsystem(names_to, view, model)
            parent.appendRow(child)
            self.rowCount += 1

            index = model.indexFromItem(child)
            view.expand(index)
            # self.view.setFirstColumnSpanned(parent.rowCount()-1, self.model.indexFromItem(parent), True)

            return_value = child

        return return_value

    def _populate_views(self, reg_definitions_subset):

        view = Qt.QTreeView(self)
        view.setSelectionBehavior(Qt.QAbstractItemView.SelectRows)
        model = Qt.QStandardItemModel(self)
        model.setHorizontalHeaderLabels(['Register', 'Addr', 'Value', 'R', 'W', ''])
        view.header().setMinimumSectionSize(0)
        view.setModel(model)
        view.setUniformRowHeights(True)
        view.setAlternatingRowColors(True)

        self.views.append(view)
        self.models.append(model)

        self.rowCount = 0
        self.subsystems = dict()
        self.subsystems[''] = model # root item is the model itself

        # nested subsystems can be specified by separating names by "/",
        # example: "pll/demodulator/oscillator"
        # ['subsystem', 'display_name', 'addr', 'show', 'formatting_func']
        for index, field_name in enumerate(reg_definitions_subset):
            reg_info = reg_definitions_subset[field_name]
            child1 = Qt.QStandardItem(field_name)
            child2 = Qt.QStandardItem(field_name)
            child3 = Qt.QStandardItem('0')
            child4 = Qt.QStandardItem('')
            child5 = Qt.QStandardItem('')
            # child4.setBackground(self.brushes['green'])
            # child5.setBackground(self.brushes['red'])
            self.default_brushes[field_name] = child1.background()
            parent = self._get_item_parent_from_subsystem(reg_info.subsystem, view, model) # this creates the subsystem item if it doesn't exist
            row = [child1, child2, child3, child4, child5, Qt.QStandardItem('')]
            self.field_name_to_row[field_name] = row
            parent.appendRow(row)
            self.rowCount += 1

            if self.rowCount >= self.max_rows:
                # split off the rest of the registers into a separate treeview
                print("Splitting at row %d" % self.rowCount)
                keys = list(reg_definitions_subset.keys())
                reg_definitions_subset_new = OrderedDict()
                for key in keys[index+1:]:
                    reg_definitions_subset_new[key] = reg_definitions_subset[key]

                self._populate_views(reg_definitions_subset_new)
                break


        #view.setColumnWidth(3, 10)
        #view.setColumnWidth(4, 5)
        for k in [0, 1, 2, 3, 4]:
            view.resizeColumnToContents(k)


################################################################
## Main code, for testing the widget with no other container
################################################################
def main():
    # Qt4:
    # app = QtGui.QApplication(sys.argv) # Qt4
    app = QtWidgets.QApplication(sys.argv) # Qt5

    import RegistersDisplayDefinitions # this needs to be here to avoid a circular import issue
    reg_definitions = RegistersDisplayDefinitions.reg_definitions
    state = RegisterState(reg_definitions)

    GUI = RegistersDisplayWidget(None, reg_definitions)
    # connect callbacks between our registerstate and
    state.setRegUpdateCallback(GUI.reg_update_callback)
    state.setMarkCallback(GUI.mark_register)

    # todo next: user needs to call the state.reg_event() function whenever there is an interaction with the registers
    timers = list()
    timers.append(Qt.QTimer.singleShot(1000, partial(state.reg_event, field_names='ddc_filter_select', event_type=EventTypes.read, values=3)))
    timers.append(Qt.QTimer.singleShot(3000, partial(state.reg_event, field_names='dac2_setpoint', event_type=EventTypes.written, values=1000)))


    # GUI.show()
    GUI.showMaximized()
    app.exec_()
    del GUI
    
    
if __name__ == '__main__':
    main()



print("TODO: CLICKING ON A REGISTER OPENS A SUMMARY WINDOW: VALUE, and all other parameters (copy-pasteable)")
