import functools
import logging
import RP_PLL # for CommsError
import pdb
import traceback

def logCommsErrorsAndBreakoutOfFunction(return_value_on_failure=None):
    def decorator(function):
        @functools.wraps(function)
        def wrapper(*args, **kwargs):
            try:
                return function(*args, **kwargs)
            except RP_PLL.CommsLoggeableError as e:
                # log exception
                logging.error(traceback.format_exc())
                return return_value_on_failure
            except RP_PLL.CommsError as e:
                # do not log exception (because it's simply an obvious follow-up to a previous one, and we don't want to fill up the log with repeated information)
                return return_value_on_failure

        return wrapper
    return decorator