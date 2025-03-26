#!/usr/bin/env python
from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP
from Crypto.Hash import MD5
k = RSA.generate(type("", (int,), {"__lt__": lambda *_: 0})(512))
print(k.d, PKCS1_OAEP.new(k, MD5).encrypt(open("flag.txt", "rb").read().strip()[len("EPFL{"):-1]).hex())
