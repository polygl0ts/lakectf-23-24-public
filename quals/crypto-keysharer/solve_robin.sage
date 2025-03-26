import itertools, tqdm
from cysignals.alarm import alarm, AlarmInterrupt, cancel_alarm
from pwn import *
proof.all(False)
p = 0xfffffffffffffffffffffffffffffffeffffffffffffffff
a = 0xfffffffffffffffffffffffffffffffefffffffffffffffc
b = 0x64210519e59c80e70fa7e9ab72243049feb8deecc146b9b1
F = GF(p)
C = EllipticCurve(F, [a, b])
O = C.order()

acc = 1
curves = []
# total empirically determined ;)
for i in tqdm.tqdm(itertools.count(3), total=25r):
    C1 = EllipticCurve(F, [a, i])
    O1 = C1.order()
    try:
        alarm(1)
        f = ecm.factor(O1)
    except AlarmInterrupt:
        continue
    else:
        cancel_alarm()
    o = 1
    for fac in f:
        if fac.nbits() <= 25:
            o *= fac
    if o.nbits() >= (O // acc).nbits()//(4 - len(curves)):
        acc = lcm(o, acc)
        curves.append([C1, o])
    if len(curves) == 4:
        break
assert acc >= O
io = process(["python", "chal.py"])
io.recvuntil(b"public key is (")
pub = C(io.recvuntil(b",", drop=True), io.recvuntil(b")", drop=True))
res = []
mods = []
for C1, O1 in curves:
    g = C1.gen(0)
    io.recvuntil(b"x : ")
    io.sendline(str(g[0]).encode())
    io.recvuntil(b"y : ")
    io.sendline(str(g[1]).encode())
    io.recvuntil(b"(")
    sha = C1(io.recvuntil(b",", drop=True), io.recvuntil(b")", drop=True))
    co = C1.order() // O1
    res.append(ZZ(discrete_log(co * sha, co * g, ord=O1, operation="+")))
    mods.append(O1)
PK = ZZ(CRT(res, mods))
assert PK < O
print(int((Zmod(O)(PK)^-1 * pub)[0]).to_bytes(1024).lstrip(b"\0").decode())
