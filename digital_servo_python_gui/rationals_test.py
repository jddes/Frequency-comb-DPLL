import rationals
import random

# list of primes up to 200
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199]

def test_factor():
    print(rationals.factor(1*4*5))
    assert rationals.factor(4*5) == [2, 2, 5]
    assert rationals.factor(-4*5) == [-1, 2, 2, 5]
    assert rationals.factor(1) == [1]
    assert rationals.factor(0) == [0]

    random.seed(0)
    for k in range(1000):
        i1 = primes[random.randint(0, len(primes)-1)]
        i2 = primes[random.randint(0, len(primes)-1)]
        i3 = primes[random.randint(0, len(primes)-1)]
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
