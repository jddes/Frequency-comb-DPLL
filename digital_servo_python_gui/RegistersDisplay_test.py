from collections import OrderedDict
from RegistersDisplay import RegisterInfo as r
from RegistersDisplay import RegisterState

def testReverseLookup():
    # RegisterInfo = namedtuple('RegisterInfo', ['subsystem', 'display_name', 'addr', 'show', 'formatting_func'])
    reg_definitions = OrderedDict([
        ('reg_name1', r('', '', 1, True, str)),
        ('reg_name2', r('', '', 2, True, str)),
        ('reg_name3', r('', '', 3, True, str)),
        ])

    state = RegisterState(reg_definitions)

    # check that the reverse lookup indeed does the inverse of the forward mapping:
    for key in reg_definitions:
        assert state.name_from_addr[state.reg_definitions[key].addr] == key