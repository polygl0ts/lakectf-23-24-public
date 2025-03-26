from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP
from Crypto.Hash import MD5

d, ct = open("output.txt").read().strip().split()
d = int(d)
ct = bytes.fromhex(ct)
φ_multiple = d * 0x10001 - 1
NB = ceil(ZZ(d).nbits() / 8) * 8

# Sage can be fast...
prs = []
for div in divisors(φ_multiple):
    if div.nbits() == NB // 2 and is_prime(div + 1):
        prs.append(div + 1)

def test(p, q):
    try:
        k = RSA.construct((int(p * q), 0x10001r, d, int(p), int(q)))
        c = PKCS1_OAEP.new(k, MD5)
        print(c.decrypt(ct).decode())
    except ValueError as e:
        if not any(known in e.args[0] for known in ["length", "too large", "Incorrect"]): raise

for p in prs:
    for q in prs:
        if p == q: continue
        test(p, q)
