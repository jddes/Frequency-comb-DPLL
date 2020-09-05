import math
import functools
import numpy as np
from time import perf_counter as c

class RationalNumber():
    """ represents a rational number as a ratio of integers """
    def __init__(self, numerator=None, denominator=None, from_string=None, scale_factor=None):
        if from_string is not None:
            self.fromString(from_string, scale_factor)
        else:
            t1 = c()
            self.num   = FactoredInteger(numerator)
            self.denom = FactoredInteger(denominator)
            t2 = c()
            if t2-t1 >= 5e-3:
                print("%s: %f sec" % (str(self), t2-t1))
        t1 = c()
        self.simplify()
        t2 = c()
        if t2-t1 >= 5e-3:
            print("simplify %s: %f sec" % (str(self), t2-t1))

    def fromString(self, s, scale_factor):
        """ Interprets string s as a rational fraction float(s)*scale_factor,
        but without actually using the float() built-in, which produces a floating-point number.
        Also handles inputs in format: 'num*denom' or 'num/denom' (untested!) """
        product_symbol = s.find('*')
        division_symbol = s.find('/')
        if product_symbol != -1:
            num1_str, num2_str = s.split('*')
            # print("fromString(): num1_str=", num1_str, ", num2_str=", num2_str)
            num1 = RationalNumber(from_string=num1_str, scale_factor=scale_factor)
            num2 = RationalNumber(from_string=num2_str)
            product = num1 * num2
            self.num   = product.num
            self.denom = product.denom
            # print(self)
            return
        elif division_symbol != -1:
            num_str, denom_str = s.split('/')
            # print("fromString(): num_str=", num_str, ", denom_str=", denom_str)
            num   = RationalNumber(from_string=num_str, scale_factor=scale_factor)
            denom = RationalNumber(from_string=denom_str)
            self.num   = num.num * denom.denom
            self.denom = denom.num * num.denom
            # print(self)
            return

        decimal_index = s.find('.')
        if decimal_index == -1:
            # Easy case: value is an integer * scale_factor
            self.num = FactoredInteger(int(s))
            self.denom = FactoredInteger(1)
        else:
            # Slightly harder case: convert integer and fractional parts separately as integers
            int_part = int(s[:decimal_index])
            if decimal_index == len(s)-1:
                # pathological case: number ends with a decimal point with no digits afterwards
                fract_part = 0
                fract_digits = 0
            else:
                fract_part_str = s[decimal_index+1:]
                fract_digits = len(fract_part_str)
                fract_part = int(fract_part_str)
            # combine integer and fractional parts into a single rational number:
            self.num = FactoredInteger(int_part * 10**(fract_digits) + fract_part)
            self.denom = FactoredInteger(10**fract_digits)
        # add scale factor:
        if scale_factor is not None:
            self.num = self.num * scale_factor

    def __mul__(self, other):
        if isinstance(other, int):
            # Rational * int
            result = RationalNumber(self.num * other, self.denom)
        elif isinstance(other, RationalNumber):
            # Rational * Rational
            result = RationalNumber(self.num * other.num, self.denom * other.denom)
        else:
            raise Exception("Operator not implemented. %s * %s" % (type(self), type(other)))
        return result

    def __add__(self, other):
        # this is harder, need to find lowest common multiple
        if isinstance(other, int):
            other = RationalNumber(other, 1)
        if not isinstance(other, RationalNumber):
            raise Exception("Operator not implemented. %s * %s" % (type(self), type(other)))

        lcm = lowest_common_multiple(self.denom.factors, other.denom.factors)
        _, lcm_factors1 = eliminate_common_factors(self.denom.factors, lcm.factors)
        _, lcm_factors2 = eliminate_common_factors(other.denom.factors, lcm.factors)
        num1 =  self.num * product_of_factors(lcm_factors1)
        num2 = other.num * product_of_factors(lcm_factors2)
        num = FactoredInteger(num1+num2)
        result = RationalNumber(num, lcm)
        return result

    def __sub__(self, other):
        minus_other = RationalNumber(other.num * -1, other.denom)
        return self + minus_other

    def isNegative(self):
        """ Returns True if the number is negative, False otherwise """
        bSignIsNegative =  self._isNegative(self.num.factors)
        bSignIsNegative |= self._isNegative(self.denom.factors)
        return bSignIsNegative

    def _isNegative(self, factors):
        """ Returns true if the list of factors describes a negative number """
        bSignIsNegative = False
        for factor in factors:
            if factor < 0:
                bSignIsNegative = not bSignIsNegative
        return bSignIsNegative

    def makePositive(self, factors):
        """ Modifies a list of factors in-place to make them all positive """
        for index, factor in enumerate(factors):
            if factor < 0:
                factors[index] = -factor

    def __abs__(self):
        num = FactoredInteger(self.num)
        denom = FactoredInteger(self.denom)
        self.makePositive(num.factors)
        self.makePositive(denom.factors)
        # need to make the internal state of num and denom consistent
        num.x = product_of_factors(num.factors)
        denom.x = product_of_factors(denom.factors)
        return RationalNumber(num, denom)

    def __eq__(self, other):
        if self.num.x*other.denom.x == other.num.x*self.denom.x:
            return True
        else:
            return False

    def __str__(self):
        return "RationalNumber(%s/%s)" % (self.num, self.denom)

    def __repr__(self):
        return self.__str__()

    def simplify(self):
        """ Simplifies the fraction by eliminating common factors from the numerator and denominators """
        division_before = self.num.x // self.denom.x
        remainder_before = self.num.x  - division_before * self.denom.x
        denom_before = self.denom.x

        (reduced_list1, reduced_list2) = eliminate_common_factors(self.num.factors, self.denom.factors)
        self.num.factors   = reduced_list1
        self.denom.factors = reduced_list2
        # at this exact point, the internal state of num and denom is inconsistent, so we fix that:
        self.num.x   = product_of_factors(self.num.factors)
        self.denom.x = product_of_factors(self.denom.factors)

        # this should have conserved the division result:
        division_after = self.num.x // self.denom.x
        remainder_after = self.num.x  - division_after * self.denom.x
        assert division_after == division_before
        assert remainder_after * denom_before//self.denom.x == remainder_before

class FactoredInteger():
    """ Represents an integer, but maintains the list of its prime factors """
    def __init__(self, x, factors=None):
        """ factors should be a list of prime factors if it is known, otherwise it will be computed """
        t1 = c()
        if isinstance(x, FactoredInteger):
            self.x = x.x
            self.factors = x.factors
        elif isinstance(x, int):
            self.x = x
            if factors is None:
                self.factors = factor(x)
                t2 = c()
                if t2-t1 >= 5e-3:
                    print("%s: %f sec" % (str(self), t2-t1))
            else:
                self.factors = factors
        else:
            raise Exception('unsupported, type(x)=%s' % type(x))
        self.validate_internal_state()

    def validate_internal_state(self):
        """ Sanity-check on the internal state:
        the number must be equal to the product of its prime factors """
        assert product_of_factors(self.factors) == self.x

    def __str__(self):
        return "FactoredInteger(%s = product(%s))" % (self.x, self.factors)

    def __mul__(self, other):
        if isinstance(other, int):
            product = self.x * other
            factors = self.factors + factor(other)

        elif isinstance(other, FactoredInteger):
            product = self.x * other.x
            factors = self.factors + other.factors
        else:
            raise Exception("Operator not implemented. %s * %s" % (type(self), type(other)))

        factors.sort()
        result = FactoredInteger(product, factors)
        return result

    def __add__(self, other):
        # have no choice but to recompute all the factors anyway
        if isinstance(other, int):
            result = FactoredInteger(self.x + other)
        elif isinstance(other, FactoredInteger):
            result = FactoredInteger(self.x + other.x)
        else:
            raise Exception("Operator not implemented. %s * %s" % (type(self), type(other)))
        return result

    def __sub__(self, other):
        # have no choice but to recompute all the factors anyway
        if isinstance(other, int):
            result = FactoredInteger(self.x - other)
        elif isinstance(other, FactoredInteger):
            result = FactoredInteger(self.x - other.x)
        else:
            raise Exception("Operator not implemented. %s * %s" % (type(self), type(other)))
        return result

    def __eq__(self, other):
        if isinstance(other, int):
            return self.x == other
        if self.x == other.x and self.factors == other.factors:
            return True
        else:
            return False

def product_of_factors(factors):
    """ Returns the product of the factors """
    return functools.reduce(int.__mul__, factors)

def eliminate_common_factors(list1, list2):
    """ Eliminates common factors from two prime factors lists.
    Returns a tuple of the two reduced lists """
    # first handle pathological cases:
    if list1 == [1] or list2 == [1]:
        return (list(list1), list(list2))
    reduced_list1 = list(list1)
    reduced_list2 = list(list2)
    for x in list1:
        if x in reduced_list2:
            reduced_list1.remove(x)
            reduced_list2.remove(x)

    if len(reduced_list1) == 0:
        reduced_list1 = [1]
    if len(reduced_list2) == 0:
        reduced_list2 = [1]

    return (reduced_list1, reduced_list2)

def lowest_common_multiple(list1, list2):
    """ Finds the LCM from a list of prime factors for both numbers """
    reduced_list1 = list(list1)
    reduced_list2 = list(list2)
    for factor in list1:
        if factor in reduced_list2:
            reduced_list2.remove(factor)

    factors = reduced_list1 + reduced_list2
    factors.sort()
    value = product_of_factors(factors)
    return_value = FactoredInteger(value, factors)
    return return_value

    # 3**1 and 3**2: take 3**2: combine lists, removed 1 only
    # 3**2 and 3**8: take 3**8: combine lists, removed 2 only
    # 3**8 and 3**8: take 3**8: combine lists, removed 8 only
    # so a rule of "remove each factor by the amount that it lives in the lowest power" seems to work
    # 3**1 and 3**1: take 3**1: combine lists, removed 1 only


def factor(x):
    """ Factorize the integer x into its prime factors (and 1, to avoid the pathological case).
    Negative integers are handled by adding an extra factor equal to -1 to the list.
    Speedup based on https://stackoverflow.com/a/830001 """
    if x == 0:
        factors = [0] # not technically a prime number, but this will avoid having to handle this as a special case later on
        return factors
    if x == 1:
        factors = [1] # not technically a prime number, but this will avoid having to handle this as a special case later on
        return factors
    if x < 0:
        factors = [-1]
        x = -x
    else:
        factors = []

    max_possible_factor = math.ceil(math.sqrt(x))
    # print("factorizing %d up to %d" % (x, max_factor))
    y = x
    # brute-force algorithm, since that's fast enough for our purposes
    candidate = 2
    iterations = 0
    next_iterations_print = 1

    # start with 2 and 3 as special cases, then loop test 6*n-1 and 6*n+1 in the inner loop only:
    while y%2 == 0:
        y = y // 2
        factors.append(2)
    while y%3 == 0:
        y = y // 3
        factors.append(3)

    multOfSix = 6
    candidate1 = 6-1
    candidate2 = 6+1
    while True:

        while y%candidate1==0:
            factors.append(candidate1)
            y = y//candidate1
        while y%candidate2==0:
            factors.append(candidate2)
            y = y//candidate2
        candidate1 += 6
        candidate2 += 6

        if y == 1:
            break
        if candidate1 >= max_possible_factor:
            # this means that the remaining number is prime
            factors.append(y)
            break

        # if iterations >= next_iterations_print:
        #     print("factor(): iteration 10**%f" % math.log10(iterations))
        #     next_iterations_print = 10*next_iterations_print
    # print("factor(): 10**%f iterations taken to factor %d" % (math.log10(iterations), x)) 
    factors.sort()
    return factors

def primes(n, N_prime_count_sparseness=100):
    """ Generate all primes up to n, using the sieve of Eratosthenes.
    Following pseudo-code on https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes.
    requires O(n) of memory, so avoid using too large values of n """
    sqrt_n = math.ceil(math.sqrt(n))
    is_prime = np.ones(n+1, dtype=np.bool) # actually store from 0 to n instead of 2 to n per the pseudo-code
    is_prime[0:2] = False
    for i in range(2, sqrt_n+1):
        if not is_prime[i]:
            continue
        is_prime[i*i:n+1:i] = False
    prime_numbers = np.nonzero(is_prime)[0].astype(np.uint64) # type is int64 by default, which I don't understand
    return prime_numbers

def factor2(x, list_of_primes, threshold_skip_numpy=100000000069):
    # this time, we use a list of primes and only test those
    # ends up more than twice as fast as the first version
    if x == 0:
        factors = [0] # not technically a prime number, but this will avoid having to handle this as a special case later on
        return factors
    if x == 1:
        factors = [1] # not technically a prime number, but this will avoid having to handle this as a special case later on
        return factors
    if x < 0:
        factors = [-1]
        x = -x
    else:
        factors = []

    # first stage: use numpy to perform division with the whole list of primes at once,
    # computing all factors up to a multiplicity of 1.
    if x < threshold_skip_numpy:
        y = x
    else:
        factors_np = list_of_primes[np.mod(x, list_of_primes)==0]
        # special case if the number was prime: factors_np is empty
        if len(factors_np) == 0:
            factors += [x]
            return factors
        factors += [val.item() for val in factors_np] # convert each element from np.uint64 to built-in int(), and collect into a list
        y = x // int(np.prod(factors_np))

    # final steps: iterated division, although the number has been reduced in the first stage
    k = 0
    max_possible_factor = int(math.ceil(math.sqrt(y)))
    try:
        while True:
            candidate = int(list_of_primes[k])
            if y%candidate == 0:
                factors.append(candidate)
                y = y//candidate
            else:
                k+=1

            # exit conditions:
            if y == 1:
                break
            if candidate >= max_possible_factor:
                # this means that the remaining number is prime
                factors.append(y)
                break
        factors.sort()
        return factors
    except IndexError:
        print("Error: could not factor integer %d, with primes list up to %d" % (x, list_of_primes[-1]))
        print("Work done up to this point: %d = %d*product(%s)" % (x, y, factors))
        raise

def test_numpy_speed(x, list_of_primes):
    # test a possibly much quicker implementation of the factorization algorithm above (repeated trial division with a pre-calculated list of primes):
    # use numpy to perform the integer operations on the whole list at once to avoid looping in pure Python
    
    x_np = np.uint64(x)
    t1 = c()
    y = x * list_of_primes
    print("x*list of primes(%d numbers): %f sec" % (len(list_of_primes), c()-t1))
    t1 = c()
    y = x / list_of_primes
    print("x/list of primes(%d numbers): %f sec" % (len(list_of_primes), c()-t1))
    t1 = c()
    y = np.mod(x, list_of_primes)==0
    print("x modulo list of primes(%d numbers): %f sec" % (len(list_of_primes), c()-t1))
    t1 = c()
    factors_np = list_of_primes[np.mod(x, list_of_primes)==0]
    print("factors_np = list_of_primes[np.mod(x, list_of_primes)==0] (%d factors): %f sec" % (len(factors_np), c()-t1))
    t1 = c()
    y = np.prod(factors_np)
    print("prod(factors_np): %f sec" % (c()-t1))

    prime_count = np.arange(len(list_of_primes))
    t1 = c()
    prime_count_eval = np.interp(list_of_primes[-1]-1, list_of_primes, prime_count)
    print("finding number of primes to n-1: %f sec" % (c()-t1))


def test_threshold(list_of_primes):
    """ a few quick tests to find a sensible threshold for activating the numpy exhaustive search """
    for k in range(20):
        t1 = c()
        factor2(2**k, list_of_primes)
        print("%d, %f" % (k, c()-t1))

    # test the worst case of the pure-Python loop algorithm: primes
    for value in [997, 1000003, 100002613, 10000002589, 10000000019, 100000000069, 9999995297, 91479367430963, 2**48]:
        t1 = c()
        print(factor2(value, list_of_primes))
        print("test_threshold, %d = %f" % (value, c()-t1))

    t1 = c()
    print(factor2(list_of_primes[-1], list_of_primes))
    print("test_threshold, %d = %f" % (list_of_primes[-1], c()-t1))


list_of_primes = primes(2**24)
# print(len(list_of_primes))
# list_of_primes = primes(100)
factor = lambda x : factor2(x, list_of_primes) # monkey-patching

if __name__ == '__main__':
    t1 = c()
    factor(44948035343483)
    print("factor(44948035343483): %.3f sec" % (c()-t1))
    t1 = c()
    res = factor(2**47+5) # 2**47+5 is prime, so should be worst-case for the trial-division algorithm above
    print("factor(2**47+5=%d): %.3f sec" % (2**47+5, c()-t1))
    print(res)
    assert res == [2**47+5]

    t1 = c()
    print(primes(int(2**24)))
    print("primes(2**24): %f sec" % (c()-t1))

    test_numpy_speed(2**47+5, list_of_primes)
    test_threshold(list_of_primes)