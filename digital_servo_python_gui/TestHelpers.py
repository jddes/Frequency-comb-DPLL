import numpy as np

# finds the value of a field in a string, delimited between strStartToken and strStopToken
# Example: strInput = "some field = whatever\nsome other field = nothing"
# strStartToken = "some field", strStopToken = "\n"
# output: "whatever"
def find_field(strInput, strStartToken, strStopToken="\n"):
    field_start_ind = strInput.find(strStartToken)
    field_stop_ind = strInput.find(strStopToken, field_start_ind + 1)
    if field_stop_ind == -1:
        # end token not found: we output the value until the end of string
        field_stop_ind = len(strInput)
    result = strInput[field_start_ind+len(strStartToken):field_stop_ind]

    return result

def str2bool(x):
    return x in ["True", "true"]

# helper comparison function, which automatically handles either Python scalars or numpy arrays, including a little bit of slop:
def close_enough(x, y):
    if isinstance(x, np.ndarray):
        # print("close_enough(): using numpy array comparison with slop")
        if x.shape != y.shape:
            print(x)
            print(y)
            print(type(x))
            print(type(y))
            print(str(x.shape))
            print(str(y.shape))
            print(type(x.shape))
            print(type(y.shape))
            print("close_enough(): incorrect shape: %s vs %s" % (x.shape, y.shape))
            return False
        else:
            return np.max(np.abs(x - y)) < 1e-3
    elif isinstance(x, float):
        # print("close_enough(): using float comparison with slop")
        return bool(np.abs(float(x)-float(y)) < 1e-6)
    elif isinstance(x, bool):
        # print("close_enough(): using bool between %s and %s" % (repr(x), repr(y)))
        # print(type(y))
        if isinstance(y, str):
            y = str2bool(y)
        return (x == y)
    else:
        print("close_enough(): using built-in comparison operator between %s and %s" % (repr(x), repr(y)))
        return (x == y)

# use this to hold various fields for comparison purposes:
class simple_struct:
    pass

def compare_struct_fields(actual, expected, parent_name=""):
    bPass = True
    strFailedFields = ''

    for current_field in expected.__dict__.keys():
        # we support nested objects through recursion:
        if isinstance(expected.__dict__[current_field], simple_struct):
            (bPassNew, strFailedFieldsNew) = compare_struct_fields(actual.__dict__[current_field], expected.__dict__[current_field], parent_name+'.'+current_field)
            bPass = bPass and bPassNew
            strFailedFields += strFailedFieldsNew
            continue

        # Apply the comparison function:
        if not close_enough(actual.__dict__[current_field], expected.__dict__[current_field]):
            bPass = False
            strFailedFields += ('%s, ' % (parent_name+'.'+current_field))

    return (bPass, strFailedFields)


def compare_text_fields(actual, expected_outputs_as_text):
    # print("compare_text_fields:")
    bPass = True
    strFailedFields = ''
    for line in expected_outputs_as_text.split('\n'):
        full_field_name = line.split('=')[0]
        field_value_str = find_field(expected_outputs_as_text, full_field_name + '=')
        field_sub_name = full_field_name[len('g.'):].strip()
        # print("line = '%s'" % line)
        # print("full_field_name = '%s'" % full_field_name)
        # print("field_sub_name = '%s'" % field_sub_name)
        # print("field_value_str = '%s'" % field_value_str)
        # interpret the value as a float for comparison purposes (if possible)
        try:
            field_value = float(field_value_str)
        except ValueError:
            field_value = field_value_str[1:] # keep the comparison as string, removing the excess space character before the field

        # print("field_value = '%s'" % field_value)

        # compare against expected
        result = eval('actual.' + field_sub_name)
        # assert(close_enough(result, field_value))
        if not close_enough(result, field_value):
            bPass = False
            strFailedFields += full_field_name
            print("Failed test: %s: actual : '%s', expected: '%s'" % (full_field_name, repr(result), repr(field_value)))
            print(close_enough(False, 'False'))
    return (bPass, strFailedFields)


class count_calls():
    def __init__(self):
        self.calls_number = 0
        self.raise_exception = False
        self.exception = Exception("Exception from count_calls::calls_counting()")
        
    def calls_counting(self, *args, **kwargs):
        self.calls_number += 1
        if self.raise_exception:
            raise self.exception

# This is a more advanced version of the object above:
# it counts the calls to any method (and doesn't do anything else)
class count_calls_obj():
    def __init__(self, *args, **kwargs):
        self.calls = [] # this will contain a list
        # each entry in this dict will contain a tuple, where each entry is a particular call to a function
        # each entry will then be a tuple of (name, args, kwargs)

        self.mode = 'recording' # switch this to "checking" to facilitate checking the various calls

    def __getattr__(self, name):
        print("getattr(): %s" % name)
        # create a new method that just logs every call to this function along with the arguments
        def newfunc(*args, **kwargs):
            if self.mode == 'recording':
                self.calls.append((name, args, kwargs))
            else:
                return (name, args, kwargs)

        return newfunc