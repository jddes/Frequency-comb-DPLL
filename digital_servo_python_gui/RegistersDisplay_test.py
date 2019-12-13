from collections import OrderedDict
import time
import pytest
from functools import partial

from RegistersDisplay import RegisterInfo as r
from RegistersDisplay import RegisterState
import RegistersDisplay

@pytest.fixture(scope="function")
def reg_definitions():
    # RegisterInfo = namedtuple('RegisterInfo', ['subsystem', 'display_name', 'addr', 'show', 'formatting_func'])
    return OrderedDict([
        ('reg_name1', r('', '', 1, True, str)),
        ('reg_name2', r('', '', 2, True, str)),
        ('reg_name3', r('', '', 3, True, str)),
        ])

@pytest.fixture(scope="function")
def state(reg_definitions):
    return RegisterState(reg_definitions)


def testReverseLookup(state):
    # check that the reverse lookup indeed does the inverse of the forward mapping:
    for key in state.reg_definitions:
        assert state.name_from_addr[state.reg_definitions[key].addr] == key

def test_conditional_map(state):
    assert RegistersDisplay.map_if_list(str, 5) == '5'
    assert RegistersDisplay.map_if_list(int, '555') == 555
    assert list(RegistersDisplay.map_if_list(str, [1, 2, 3])) == ['1', '2', '3']

@pytest.mark.parametrize('bUseAddr', (False, True))
def test_marking(state, bUseAddr):

    # monkey-patch time.perf_counter() so that the test is deterministic.
    mock_time = 0
    time.perf_counter = lambda : mock_time

    # "output" is mark_reg and unmark_reg function:
    is_marked = {'reg_name2': False}
    def mark_mock(self, field_name=None):
        print("mark_mock: %s" % field_name)
        is_marked[field_name] = True
        self.mark_reg_bck(field_name)
    def unmark_mock(self, field_name):
        print("unmark_mock: %s" % field_name)
        is_marked[field_name] = False
        self.unmark_reg_bck(field_name)

    
    state.mark_reg_bck   = state.mark_reg
    state.unmark_reg_bck = state.unmark_reg
    state.mark_reg   = partial(mark_mock, state)
    state.unmark_reg = partial(unmark_mock, state)

    for k in range(200): # fake test duration = 2 secs
        mock_time = float(k)/100
        state.timerColorCoding()

        if k < 10:
            assert is_marked['reg_name2'] == False
        elif k == 10:
            # fake a read event:
            if bUseAddr:
                state.read_event(addr=2)
            else:
                state.read_event(field_names='reg_name2')

            mark_time = mock_time
        else:
            if mock_time < mark_time + state.Tread:
                assert is_marked['reg_name2'] == True
            else:
                assert is_marked['reg_name2'] == False



