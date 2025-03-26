#### Copied from my cryptopals solutions :)
import os
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

    def __init__(self, seed=None):
        if seed is None:
            seed = int.from_bytes(os.urandom(self.W // 8), byteorder='little')
        self.state = [seed % (2**self.W)]
        for i in range(1, self.N):
            self.state.append((self.F * (self.state[-1] ^ (self.state[-1] >> (self.W - 2))) + i) % (2**self.W))
        self.idx = self.N

    def rand(self):
        if self.idx >= self.N:
            self._twist()
        y = self.state[self.idx]
        y ^= (y >> self.U) & self.D
        y ^= (y << self.S) & self.B
        y ^= (y << self.T) & self.C
        y ^= y >> self.L
        self.idx += 1
        return y % (2**self.W)

    def _twist(self):
        lower_mask = (1 << self.R) - 1
        upper_mask = (~lower_mask) % (2**self.W)
        for i in range(0, self.N):
            x = (self.state[i] & upper_mask) + (self.state[(i + 1) % self.N] & lower_mask)
            xA = x >> 1
            if x % 2 != 0:
                xA ^= self.A
            self.state[i] = self.state[(i + self.M) % self.N] ^ xA
        self.idx = 0

class Cloner(MT19937):
    def __init__(self):
        super().__init__()
        self.idx = 0
        self.done = 0

    def feed(self, x):
        if self.done >= 624:
            assert x == self.rand()
            return
        self.state[self.idx] = self._untemper(x)
        self.idx += 1
        self.done += 1

    def _untemper(self, x):
        def g(x, i): return x & (1 << i)
        def _undo_rshift(v, l, mask=None):
            if mask is None: mask = (1 << self.W) - 1
            r = 0
            for i in range(self.W):
                if i < l:
                    r |= g(x, self.W - 1 - i)
                else:
                    r |= g(x, self.W - 1 - i) ^ ((g(r, self.W - 1 - i + l) >> l) if g(mask, self.W - 1 - i) else 0)
            return r
        def _undo_lshift(x, l, mask=None):
            if mask is None: mask = (1 << self.W) - 1
            r = 0
            for i in range(self.W):
                if i < l:
                    r |= g(x, i)
                else:
                    r |= g(x, i) ^ ((g(r, i - l) << l) if g(mask, i) else 0)
            return r

        x = _undo_rshift(x, self.L)
        x = _undo_lshift(x, self.T, self.C)
        x = _undo_lshift(x, self.S, self.B)
        x = _undo_rshift(x, self.U, self.D)
        return x
###################3

def blocks(x, n):
    return list(zip(*[iter(x)] * n))

from pwn import *
io = process(["python", "chal.py"])
cloner = Cloner()
while True:
    line = io.recvline()
    tag, data, *_ = line.strip().decode().split()
    data = int(data)
    match tag:
        case "Sadly,":
            for b in blocks(data.to_bytes(128, "big"), 4)[::-1]:
                cloner.feed(int.from_bytes(b, "big"))
        case "Ciphertext:":
            # Gamble it's small enough to fit under p (< 128 chars) :)
            p = 0
            for i in range(128//4):
                p |= cloner.rand() << (32 * i)
            print(pow(data, pow(0x10001, -1, p - 1), p).to_bytes(128, "big").lstrip(b"\0").decode())
            break
        case _:
            raise RuntimeError("Unknown data: " + tag)
