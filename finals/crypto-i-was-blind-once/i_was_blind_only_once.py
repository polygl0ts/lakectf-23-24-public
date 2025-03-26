#!/usr/bin/env python3
from Crypto.Util.number import getStrongPrime, bytes_to_long
from Crypto.Cipher import ChaCha20
from hashlib import sha256, md5
import os
from base64 import b64decode, b64encode

flag = os.getenv("flag", "EPFL{fake_flag}")
RSA_BIT_LENGTH = 2048
RSA_BYTES = RSA_BIT_LENGTH // 8


def hash_msg(m: bytes) -> int:
    # 8 bytes should be enough to avoid a collision without having to use too much compute power
    return int(sha256(m).hexdigest()[:16], 16)


def gen_rsa_key() -> (int, int, int):
    e = 3
    p = getStrongPrime(RSA_BIT_LENGTH // 2, e=e)
    q = getStrongPrime(RSA_BIT_LENGTH // 2, e=e)
    N = p * q
    phi = (p - 1) * (q - 1)
    d = pow(e, -1, phi)
    return N, e, d


def encrypt_signature(cha_cha_key: bytes, provided_sig: int, nonce: bytes):
    cha_cha = ChaCha20.new(key=cha_cha_key, nonce=nonce[:12])
    return cha_cha.encrypt(provided_sig.to_bytes(RSA_BYTES, "big"))

print("Welcome to the signature server, a place that will never be broken !")
print("Generating key ...")
N, e, d = gen_rsa_key()
message = b"Forgery is futile. I'm unforgeable."
message_hash = hash_msg(message)

CHACHA_KEY = os.urandom(ChaCha20.key_size)
used_test_encryption = False
while True:
    print("What do you want to do ?")
    answer = int(input(
        "Options :\n 1: sign a message\n 2: test new encryption feature (only once)\n 3: verify message signature"
    ))

    if answer == 1:
        m = input("type your message in base64\n")
        decoded = b64decode(m)
        if not decoded.startswith(b"VALID MESSAGE :") or decoded == message:
            print("Are you trying to fool me ?")
            exit()
        else:
            signature = pow(hash_msg(decoded), d, N)
            nonce_msg = md5(decoded).digest()
            enc_signature = encrypt_signature(CHACHA_KEY, signature, nonce_msg)
            print(b64encode(enc_signature))
    elif answer == 2:
        if used_test_encryption:
            print("You already tested it !")
            exit()
        else:
            m = input("type your message in base64\n")
            decoded = b64decode(m)
            nonce_msg = bytes.fromhex(md5(decoded).hexdigest())
            cha_cha = ChaCha20.new(key=CHACHA_KEY, nonce=nonce_msg[:12])
            print(b64encode(cha_cha.encrypt(decoded)))
            used_test_encryption = True
    elif answer == 3:
        test_sig_b64 = input("What, you were you able to do it ??\n")
        test_sig = bytes_to_long(b64decode(test_sig_b64))
        assert test_sig < N
        if pow(test_sig, e, N) == message_hash:
            print(f"Well done here is your deserved flag: {flag}")
            exit()
