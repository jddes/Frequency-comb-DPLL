import numpy as np
import random

import rationals

# list of primes up to 1000
primes_to_1000 = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541, 547, 557, 563, 569, 571, 577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 643, 647, 653, 659, 661, 673, 677, 683, 691, 701, 709, 719, 727, 733, 739, 743, 751, 757, 761, 769, 773, 787, 797, 809, 811, 821, 823, 827, 829, 839, 853, 857, 859, 863, 877, 881, 883, 887, 907, 911, 919, 929, 937, 941, 947, 953, 967, 971, 977, 983, 991, 997]

def test_factor():
    print(rationals.factor(1*4*5))
    assert rationals.factor(4*5) == [2, 2, 5]
    assert rationals.factor(-4*5) == [-1, 2, 2, 5]
    assert rationals.factor(1) == [1]
    assert rationals.factor(0) == [0]

    random.seed(0)
    for k in range(1000):
        i1 = primes_to_1000[random.randint(0, len(primes_to_1000)-1)]
        i2 = primes_to_1000[random.randint(0, len(primes_to_1000)-1)]
        i3 = primes_to_1000[random.randint(0, len(primes_to_1000)-1)]
        assert rationals.factor(i1*i2*i3) == sorted([i1, i2, i3])

def test_lcm():
    result = rationals.lowest_common_multiple([3, 3], [3, 7])
    print(result)
    assert result == rationals.FactoredInteger(3*3*7)

def test_eliminate_common_factors():
    (l1, l2) = rationals.eliminate_common_factors([1, 4, 7], [7, 2])
    assert l1 == [1, 4]
    assert l2 == [2]

def test_product_of_factors():
    assert rationals.product_of_factors([1, 4, 7]) == 1*4*7

def test_simplify_fraction():
    x = rationals.RationalNumber(10, 110)
    x.simplify()
    assert x.num == 1 and x.denom == 11

def test_rational_product():
    x = rationals.RationalNumber(10, 110)
    y = rationals.RationalNumber(3*3*7, 3*37)
    expected = rationals.RationalNumber(10*3*3*7, 110*3*37)
    print("x=", x)
    print("y=", y)
    print("expected=", expected)
    assert x*y == expected

def test_rational_sum():
    x = rationals.RationalNumber(10, 110)
    y = rationals.RationalNumber(3*3*7, 3*37)
    expected = rationals.RationalNumber(3*3*7*110+10*3*37, 110*3*37)
    print("x=", x)
    print("y=", y)
    print("expected=", expected)
    result = x+y
    assert result == expected

    x = rationals.RationalNumber(4, 5)
    y = rationals.RationalNumber(133, 768)
    expected = rationals.RationalNumber(4*768+5*133, 768*5)
    result = x+y
    assert result == expected

def test_rational_sub():
    x = rationals.RationalNumber(10, 110)
    y = rationals.RationalNumber(3*3*7, 3*37)
    expected = rationals.RationalNumber(10*3*37-3*3*7*110, 110*3*37)
    result = x-y
    assert result == expected

def test_abs():
    x = rationals.RationalNumber(10, 110)
    y = rationals.RationalNumber(-3*3*7, 3*37)
    z = rationals.RationalNumber(-3*3*7, -3*37)
    w = rationals.RationalNumber(3*3*7, -3*37)
    assert abs(x) == rationals.RationalNumber(10, 110)
    assert abs(y) == rationals.RationalNumber(3*3*7, 3*37)
    assert abs(z) == rationals.RationalNumber(-3*3*7, -3*37)
    assert abs(z) == rationals.RationalNumber(3*3*7, 3*37)
    assert abs(w) == rationals.RationalNumber(3*3*7, 3*37)

def test_from_string():
    x = rationals.RationalNumber(from_string="1.2", scale_factor=1)
    assert x == rationals.RationalNumber(12, 10)

    x = rationals.RationalNumber(from_string="123.45678", scale_factor=10)
    assert x == rationals.RationalNumber(10*12345678, 10**5)

    x = rationals.RationalNumber(from_string="12345678", scale_factor=10)
    assert x == rationals.RationalNumber(10*12345678, 1)

    x = rationals.RationalNumber(from_string="12345678.", scale_factor=10)
    assert x == rationals.RationalNumber(10*12345678, 1)

def test_primes():
    assert np.all(rationals.primes(1000) == primes_to_1000)