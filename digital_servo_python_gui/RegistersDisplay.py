import time
from collections import namedtuple, deque
from enum import Enum, auto

RegisterInfo = namedtuple('RegisterInfo', ['subsystem', 'display_name', 'addr', 'show', 'formatting_func'])


class MarkingType(Enum):
    read = auto()
    written = auto()
    changed = auto()

RegMarkingInfo = namedtuple('RegMarkingInfo', ['unmark_time', 'field_name', 'marking_type'])


class RegisterState():
    def __init__(self, reg_definitions):
        self.Tread = 0.1 # how long to keep register marked as having been read
        self.Twrite = 1 # how long to keep register marked as having been written
        self.Tchanged = 1 # how long to keep register marked as having just changed

        self.unmark_queue = deque()

        self.reg_definitions = reg_definitions
        # build addr -> field_name lookup table for faster lookup at runtime
        self.name_from_addr = {reg_info.addr: fieldname for (fieldname, reg_info) in self.reg_definitions.items()}

    def mark_reg(self, field_name):
        print("mark_reg at time t=%.2f: %s" % (time.perf_counter(), field_name))

    def unmark_reg(self, field_name):
        print("unmark_reg at time t=%.2f: %s" % (time.perf_counter(), field_name))

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
            self.unmark_reg(reg_info.field_name)

            # remove item from the queue
            list_del.append(index)

        # do the deletion after we are done iterating through the deque itself (otherwise it throws an error)
        for index in list_del:
            del self.unmark_queue[index]

    def read_event(self, addr=None, field_names=None):
        """ call this when one or more registers are being read.
        Specify either the address(es) or the field name being read.
        Specify a list of addresses or names if there are multiple reads
        being reported at the same time """

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
        map_if_list(self._read_event_single, field_names_internal)

    def _read_event_single(self, field_name):
        """ Actual function that does the work, called from read_event.
        Only handles one register at a time. """
        # TODO: mark this register as read at current time (change color), scheduled to be unmarked at time+Tread
        reg_info = RegMarkingInfo(unmark_time=time.perf_counter()+self.Tread,
                                  field_name=field_name,
                                  marking_type=MarkingType.read)
        self.mark_reg(field_name)
        self.unmark_queue.append(reg_info)
        pass

# End class RegisterState

def map_if_list(func, obj_list_or_not):
    if isinstance(obj_list_or_not, list):
        return map(func, obj_list_or_not)
    else:
        # scalar case:
        return func(obj_list_or_not)

