
import pytest

from SuperLaserLand_mock import SuperLaserLand_mock



def test_setup_writes_various():
    sl = SuperLaserLand_mock()

    test_list = [
        (sl.setup_ADC0_write, 0), 
        (sl.setup_ADC1_write, 1), 
        (sl.setup_DDC0_write, 2), 
        (sl.setup_DDC1_write, 3), 
        # (sl.setup_VNA_write, 4), 
        (sl.setup_counter_write, 5), 
        (sl.setup_DAC0_write, 6), 
        (sl.setup_DAC1_write, 7), 
        (sl.setup_DAC2_write, 8), 
        # (sl.setup_CRASH_MONITOR_write, 2**4), 
        # (sl.setup_IN10_write, 2**4 + 2**3), 
        ]

    Num_samples = 100

    for (func, expected_selector) in test_list:
        func(Num_samples)
        
        assert(sl.last_selector == expected_selector)
        assert(sl.Num_samples_read == Num_samples)

        Num_samples = Num_samples + 1

