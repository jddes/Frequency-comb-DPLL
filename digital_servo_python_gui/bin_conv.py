""" A bunch of helper functions for manipulating individual bits in an integer """

def get_bitmask(bits_list):
    try:
        bitmask = 0
        for bit_number in bits_list:
            bitmask |= (1<<bit_number)
    except TypeError:
        # single-bit case:
        bitmask = (1<<bits_list)
    return bitmask

def extract_bit(x, bit):
    """ return 1 if bit position is set in x, 0 otherwise.
    Only works for positive integers at the moment """
    return (int(x)>>bit) & 0x1

def set_bit(x, bit):
    return x | (1<<bit)

def clear_bit(x, bit, width=32):
    return x & ~(1<<bit)

def extract_bits(x, start, stop):
    """ returns bits number start to stop, inclusively.
    Result is aligned so that bit "start" is now in the LSB position """
    return (int(x)>>start) & get_bitmask(range(stop-start+1))

def clear_bits(x, start, stop):
    """ clear bits number start to stop, inclusively """
    y = x
    for bit in range(start, stop+1):
        y = clear_bit(y, bit)
    return y

def set_bits(x, start, stop):
    """ set bits number start to stop, inclusively """
    y = x
    for bit in range(start, stop+1):
        y = set_bit(y, bit)
    return y

def replace_bit(x, bit, y):
    # replace the value of bit number "bit" in x with y
    if y:
        return set_bit(x, bit)
    else:
        return clear_bit(x, bit)

def replace_bits(x, bit_start, bit_end, y):
    """ Replace the values of bits "bit_start..bit_end" (inclusively) with the first bits from y """
    num_bits = bit_end-bit_start+1
    y_masked = y & get_bitmask(range(num_bits))
    x_masked = clear_bits(x, bit_start, bit_end) | (y_masked << bit_start)
    return x_masked

def int_to_bitlist(x, num_bits, lsb_first=True):
    """ Convert an integer to its (reversed) binary representation in a list.
    Default is to output the LSB first, up to the MSB (num_bits-1)
    ex: int_to_bitlist(3, 5) = [1, 0, 1, 0, 0] """
    if lsb_first:
        bits_pos = range(num_bits)
    else:
        bits_pos = reversed(range(num_bits))
    return [extract_bit(x, bit_pos) for bit_pos in bits_pos]

def interpret_as_signed(x, n_bits):
    """ Interprets integer x as it's two-complement's representation,
    ie bit number n_bits-1 should have it's weight negative instead of positive """
    return x - 2*(x & (1<<(n_bits-1)))