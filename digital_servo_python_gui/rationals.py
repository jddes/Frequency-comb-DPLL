import math
import functools

class RationalNumber():
    """ represents a rational number as a ratio of integers """
    def __init__(self, numerator, denominator):
        self.num   = FactoredInteger(numerator)
        self.denom = FactoredInteger(denominator)
        self.simplify()

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

        lcm = lowest_common_multiple(self.factors, other.factors)
        self_factors,  _ = eliminate_common_factors(self.factors, lcm)
        other_factors, _ = eliminate_common_factors(other.factors, lcm)
        num1 = product_of_factors(self_factors) * self.num
        num2 = product_of_factors(other_factors) * other.num
        num = FactoredInteger(num1+num2)
        result = RationalNumber(num, lcm)
        return result

    def __eq__(self, other):
        if self.num.x*other.denom.x == other.num.x*self.denom.x:
            return True
        else:
            return False

    def __str__(self):
        return "num=%s, denom=%s" % (self.num, self.denom)

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
        if isinstance(x, FactoredInteger):
            self.x = x.x
            self.factors = x.factors
        elif isinstance(x, int):
            self.x = x
            if factors is None:
                self.factors = factor(x)
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

    # (reduced_list1, reduced_list2) = eliminate_common_factors(list1, list2)
    # print(locals())
    # factors = reduced_list1 + reduced_list2
    factors.sort()
    value = product_of_factors(factors)
    return_value = FactoredInteger(value, factors)
    return return_value

def factor(x):
    """ Factorize the integer x into its prime factors (and 1, to avoid the pathological case).
    Negative integers are handled by adding an extra factor equal to -1 to the list """
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

    # max_factor = math.ceil(math.sqrt(x))
    # print("factorizing %d up to %d" % (x, max_factor))
    y = x
    # brute-force algorithm, since that's fast enough for our purposes
    candidate = 2
    while True:
        ratio = y//candidate
        if ratio*candidate == y:
            factors.append(candidate)
            y = ratio
        else:
            candidate += 1
        if y == 1:
            break

    return factors
