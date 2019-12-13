import time
from collections import namedtuple, deque
from enum import Enum, auto
from functools import partial

RegisterInfo = namedtuple('RegisterInfo', ['subsystem', 'display_name', 'addr', 'show', 'formatting_func'])


class EventTypes(Enum):
    read = auto()
    written = auto()
    changed = auto()

RegMarkingInfo = namedtuple('RegMarkingInfo', ['unmark_time', 'field_name', 'event_type'])


class RegisterState():
    def __init__(self, reg_definitions):
        self.mark_timeouts = {  # how long to keep register marked in a different color after each event has happened
            EventTypes.read: 0.1,
            EventTypes.written: 1,
            EventTypes.changed: 1,
        }

        self.unmark_queue = deque()

        self.reg_definitions = reg_definitions
        # build addr -> field_name lookup table for faster lookup at runtime
        self.name_from_addr = {reg_info.addr: fieldname for (fieldname, reg_info) in self.reg_definitions.items()}

    def setMarkCallback(self, callback):
        """ This callback will get called with individual register info
        and event info whenever the GUI needs to mark or unmark the event as recent.
        Prototype should look like:
        def callback(field_name, event_type, bMark)
        (use partial if you need to transfer state) """
        self.mark_reg = callback

    def timerColorCoding(self):
        """ TODO: update the color coding status of the registers that have been
        read/written/changed long enough ago. """
        current_time = time.perf_counter()

        list_del = []
        for index, reg_info in enumerate(self.unmark_queue):
            # check if this register is not yet ready to get unmarked:
            if reg_info.unmark_time > current_time:
                continue
            # time to unmark this register.
            self.mark_reg(reg_info.field_name, reg_info.event_type, bMark=False)

            # remove item from the queue
            list_del.append(index)

        # do the deletion after we are done iterating through the deque itself (otherwise it throws an error)
        for index in list_del:
            del self.unmark_queue[index]

    def reg_event(self, addr=None, field_names=None, event_type=None):
        """ call this when one or more registers has had an event (read, written, changed).
        Specify either the address(es) or the field name of the register.
        Specify a list of addresses or names if there are multiple regs
        being reported at the same time.

        event_type must be one of the valid values
        in the EventTypes enum """

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
        map_if_list(partial(self._reg_event_single, event_type), field_names_internal)

    def _reg_event_single(self, event_type, field_name):
        """ Actual function that does the work, called from reg_event.
        Only handles one register at a time. """
        # TODO: mark this register as reg at current time (change color), scheduled to be unmarked at time+Treg
        reg_info = RegMarkingInfo(unmark_time=time.perf_counter()+self.mark_timeouts[event_type],
                                  field_name=field_name,
                                  event_type=event_type)
        self.mark_reg(field_name, event_type, bMark=True)
        self.unmark_queue.append(reg_info)

# End class RegisterState

def map_if_list(func, obj_list_or_not):
    if isinstance(obj_list_or_not, list):
        return map(func, obj_list_or_not)
    else:
        # scalar case:
        return func(obj_list_or_not)

