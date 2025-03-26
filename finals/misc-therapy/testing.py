
import random
n = 256
"""

restricted = [1, 2, 3, 5, 7, 11, 13]
results = set()
for i in range(n):
    for j in range(n):
        if i == 1 or j == 1 or i in restricted:
            continue
        res = (i*j)%n
        if res not in results:
            print(res, "was made with", i, "*", j)
            results.add((i*j)%n)
for i in range(n):
    if i not in results:
        print(i, "would be free")
"""
target = 255

def gcd(p, q):
    # Use Euclid's algorithm to find the GCD.
    while q != 0:
        p, q = q, p % q
    return p

# Define a function 'is_coprime' to check if two numbers are coprime (GCD is 1).
def is_coprime(x, y):
    # Check if the GCD of 'x' and 'y' is equal to 1.
    return gcd(x, y) == 1

coprimes = [i for i in range(n) if is_coprime(i,n)]
# https://fmipa.um.ac.id/wp-content/uploads/2019/10/MATEMATIKA_PURWANTO-Rev-14-23.pdf 
# McLean criterion
coprimes = [4* i for i in range(16)]
print(coprimes)

for i in coprimes:
    for j in coprimes:
        res = (i*j)%n
        #if res not in coprimes:
        #print(res, "was made with", i, "*", j)
# [16, 20, 8, 36, 52, 0, 12]
# [52, 16, 36, 0, 8, 12, 20]
coprimes = random.sample(coprimes, k=7)
coprimes = [2, 8, 12, 16, 20, 36, 52]
# 128 was made with 16 * 8

print(coprimes)
target = 128
for i in coprimes:
    for j in coprimes:
        res = (i*j)%n
        if res == target:
            print(res, "was made with", i, "*", j, target)
#exit(0)
#exit(0)
allowed = coprimes
results = set()
for i in allowed:
    for j in allowed:
        res = (i*j)%n
        if res not in results:
            print(res, "was made with", i, "*", j)
            results.add((i*j)%n)
for i in range(n):
    if i in results:
        print(i, "would not be free and would make",(~i)%n,"with neg")