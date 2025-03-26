_int = (int, Integer)

class BoPoRint:
    # Σ vars[i] * 2^i
    def __init__(self, R, vars):
        self.R = R
        self.vars = tuple(vars)

    def __xor__(self, other):
        if isinstance(other, BoPoRint):
            assert len(self.vars) == len(other.vars)
            return BoPoRint(self.R, [v + w for v, w in zip(self.vars, other.vars)])
        else:
            return BoPoRint(self.R, [v + ((other >> i) & 1) for i, v in enumerate(self.vars)])

    __rxor__ = __xor__

    def __mul__(self, other):
        assert isinstance(other, _int) and other >= 0
        if other in [0, 1]:
            return self if other else BoPoRint(self.R, [self.R(0) for _ in self.vars])
        elif all(v == self.R(0) for v in self.vars[1:]):
            return BoPoRint(self.R, [self.vars[0] if o == "1" else self.R(0) for o in bin(other)[2:].zfill(len(self.vars))[::-1]])
        else:
            assert False, "Unsupported kind of mult"

    # def __rmul__(self, other):
        # return self * other

    def __rshift__(self, other):
        assert isinstance(other, _int)
        zeroes = tuple(self.R(0) for _ in range(other))
        return BoPoRint(self.R, (self.vars + zeroes)[-len(self.vars):])

    def __lshift__(self, other):
        assert isinstance(other, _int)
        zeroes = tuple(self.R(0) for _ in range(other))
        return BoPoRint(self.R, (zeroes + self.vars)[:len(self.vars)])

    def __and__(self, other):
        assert isinstance(other, _int)
        return BoPoRint(self.R, [v if (other >> i) & 1 else self.R(0) for i, v in enumerate(self.vars)])
    __rand__ = __and__

    def __mod__(self, other):
        assert isinstance(other, _int)
        assert int(other).bit_count() == 1
        return self & (other - 1)

    def eval(self, asn):
        def eval_v(x):
            return ZZ(sum(asn[m] for m in x.monomials()) % 2)
        return sum(eval_v(v) * 2**i for i, v in enumerate(self.vars))
        
        
def boporints(n, k, name="x"):
    R = BooleanPolynomialRing(n * k, name)
    gens = tuple(R.gens())
    return [BoPoRint(R, gens[k*i:k*(i + 1)]) for i in range(n)]


class MT19937:
    W = 32
    N = 624
    M = 397
    R = 31
    A = 0x9908B0DF
    U = 11
    D = 0xFFFFFFFF
    S = 7
    B = 0x9D2C5680
    T = 15
    C = 0xEFC60000
    L = 18

    F = 1812433253

    def __init__(self):
        self.state = boporints(self.N, self.W)
        self.idx = self.N

    def rand(self):
        if self.idx >= self.N:
            self._twist()
        y = self.state[self.idx]
        y ^^= (y >> self.U) & self.D
        y ^^= (y << self.S) & self.B
        y ^^= (y << self.T) & self.C
        y ^^= y >> self.L
        self.idx += 1
        return y % (2**self.W)

    def getrandbits(self, n):
        assert n <= 32
        return self.rand() >> (32 - n)

    def _twist(self):
        lower_mask = (1 << self.R) - 1
        upper_mask = 2^self.W - 1 - lower_mask
        for i in range(0, self.N):
            x = (self.state[i] & upper_mask) ^^ (self.state[(i + 1) % self.N] & lower_mask)
            xA = x >> 1
            xA ^^= (x % 2) * self.A
            self.state[i] = self.state[(i + self.M) % self.N] ^^ xA
        self.idx = 0

def eval_sol(gens, sol, seen):
    asn = dict(zip(gens, sol))
    res = ["?" for _ in range(32)]
    for k, v in seen.items():
        res[v.eval(asn)] = k
    return f"EPFL{{{''.join(res)}}}"

def validate():
    import random
    real = random.Random(42r)
    initstate = real.getstate()[1][:-1]
    initstate = sum(([(x >> i) & 1 for i in range(32)] for x in initstate), start=[])
    clone = MT19937()
    assert len(clone.state[0].R.gens()) == len(initstate)
    asn= {v: b for v, b in zip(clone.state[0].R.gens(), initstate)}
    for x, y in zip(real.getstate()[1][:-1], clone.state):
        assert x == y.eval(asn)
    for i in range(20000):
        assert real.getrandbits(32) == clone.getrandbits(32).eval(asn), i
    print("Validation okay")

if __name__ == "__main__":
    # validate()
    # exit()
    import tqdm, sys
    with open("output.txt") as f:
        data = f.read().strip()
    if len(sys.argv) > 1:
        data = data[:int(sys.argv[1])]
    else:
        data = data[:5000]  # Found to be enough :)
    d = list(set(data))
    rows = []
    seen = {}
    r = MT19937()
    gens = r.state[0].R.gens()
    for x in tqdm.tqdm(data):
        R = r.getrandbits(5)
        if x in seen:
            for i in range(5):
                rows.append(seen[x].vars[i] + R.vars[i])
        else:
            seen[x] = R
        r.getrandbits(32)  # Skip
    # https://github.com/python/cpython/blob/main/Modules/_randommodule.c#L241
    rows += gens[:32]
    print("Building coefs")
    M = Matrix(GF(2), nrows=len(rows), ncols=len(gens))
    D = {x: i for i, x in enumerate(gens)}
    for i, row in enumerate(tqdm.tqdm(rows)):
        for m in row.monomials():
            M[i,D[m]] = 1
    print("Computing kernel")
    ker = M.right_kernel()
    print(f"Kernel dimension: {ker.dimension()}")
    b = vector(GF(2), len(rows))
    b[-1] = 1
    print("Solving system")
    print(eval_sol(gens, M \ b, seen))
