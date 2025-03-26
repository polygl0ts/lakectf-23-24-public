from Crypto.Util.number import getStrongPrime, getPrime

h = 2 * 3 * 7 ^ 2
e = 3
Ze = Zmod(e)

p = 11
q = next_prime(10_000_000)
# q = 17
N = p * q
phi = (p - 1) * (q - 1)
d = int(pow(e, -1, phi))

target_number = int(2 * 3 * 7 ^ 2)
target_sig = int(pow(target_number, d, N))

msgs = [2 * 3 * 5,
        2 ^ 2 * 7,
        2 * 3 * 5 * 7 ^ 5,
        2 * 3 ^ 2 * 5 ^ 2 * 7 ^ 2,
        3 * 7]
sigs = list(map(lambda msg: int(pow(int(msg), d, N)), msgs))
sorted_primes = [2, 3, 5, 7]
factors_dict = map(lambda msg: dict(factor(msg)), msgs)
A = {}
for i, fact in enumerate(factors_dict):
    for p in fact.keys():
        A[(sorted_primes.index(p), i)] = fact[p]
M = Matrix(Ze, len(sorted_primes), len(msgs), A)
target = vector([1, 1, 0, 2])
solve_vec = M.solve_right(target)
print(solve_vec)
res = 1
sig_res = 1
for i, power in enumerate(solve_vec):
    res *= pow(msgs[i], int(power))
    sig_res = sig_res * pow(sigs[i], int(power))
ff = dict(factor(res))
print(factor(res))
assert sig_res % N == pow(res, d, N)
for k, v in ff.items():
    print(k, v)
    to_divide = int(v) // e
    sig_res = (sig_res * pow(pow(int(k), -1, N), to_divide, N)) % N
    res //= int(k) ^ int(to_divide * 3)
    print(factor(res))
    assert sig_res % N == pow(res, d, N)
    print(f"{factor(pow(sig_res,3,N)) = }")

print(pow(sig_res, 3, N))
print(target_number % N)
