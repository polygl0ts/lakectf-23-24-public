#!/usr/bin/env python3
from Crypto.PublicKey import RSA
from Crypto.Util.number import long_to_bytes, bytes_to_long, size, ceil_div
from Crypto.Util.strxor import strxor
from Crypto.Util.py3compat import *
from Crypto.Hash import SHA
from Crypto.Signature.pss import MGF1
import os
import time

def encrypt(message, key):
    """Produce the PKCS#1 OAEP encryption of a message.

    This function is named ``RSAES-OAEP-ENCRYPT``, and is specified in
    section 7.1.1 of RFC3447.

    :Parameters:
        message : string
            The message to encrypt, also known as plaintext. It can be of
            variable length, but not longer than the RSA modulus (in bytes)
            minus 2, minus twice the hash output size.
        key : RSA.RSAobj
            The RSA key to use for encryption.

    :Return: A string, the ciphertext in which the message is encrypted.
        It is as long as the RSA modulus (in bytes).
    :Raise ValueError:
        If the RSA key length is not sufficiently long to deal with the given
        message.
    """
    
    mgf = lambda x,y: MGF1(x,y,SHA)
    randFunc = os.urandom

    # See 7.1.1 in RFC3447
    modBits = size(key.n)
    k = ceil_div(modBits,8) # Convert from bits to bytes
    hLen = SHA.digest_size
    mLen = len(message)

    # Step 1b
    ps_len = k-mLen-2*hLen-2
    if ps_len<0:
        raise ValueError("Plaintext is too long.")
    # Step 2a
    lHash = SHA.new().digest()
    # Step 2b
    ps = bchr(0x00)*ps_len
    # Step 2c
    db = lHash + ps + bchr(0x01) + message
    # Step 2d
    ros = randFunc(hLen)
    # Step 2e
    dbMask = mgf(ros, k-hLen-1)
    # Step 2f
    maskedDB = strxor(db, dbMask)
    # Step 2g
    seedMask = mgf(maskedDB, hLen)
    # Step 2h
    maskedSeed = strxor(ros, seedMask)
    # Step 2i
    em = bchr(0x00) + maskedSeed + maskedDB
    # Step 3a (OS2IP), step 3b (RSAEP), part of step 3c (I2OSP)
    m = long_to_bytes(pow(bytes_to_long(em), key.e, key.n))
    # Complete step 3c (I2OSP)
    c = bchr(0x00)*(k-len(m)) + m
    return c

def decrypt(ct, key):
    """Decrypt a PKCS#1 OAEP ciphertext.

    This function is named ``RSAES-OAEP-DECRYPT``, and is specified in
    section 7.1.2 of RFC3447.

    :Parameters:
        ct : string
            The ciphertext that contains the message to recover.
        key : RSA.RSAobj

    :Return: A string, the original message.
    :Raise ValueError:
        If the ciphertext length is incorrect, or if the decryption does not
        succeed.
    :Raise TypeError:
        If the RSA key has no private half.
    """    
    mgf = lambda x,y: MGF1(x,y,SHA)

    # See 7.1.2 in RFC3447
    modBits = size(key.n)
    k = ceil_div(modBits,8) # Convert from bits to bytes
    hLen = SHA.digest_size

    # Step 1b and 1c
    if len(ct) != k or k<hLen+2:
        raise ValueError("Ciphertext with incorrect length.")
    # Step 2a (O2SIP), 2b (RSADP), and part of 2c (I2OSP)
    m = long_to_bytes(pow(bytes_to_long(ct), key.d, key.n))
    # Complete step 2c (I2OSP)
    em = bchr(0x00)*(k-len(m)) + m
    # Step 3a
    lHash = SHA.new().digest()
    # Step 3b
    y = em[0]
    if bord(y)!=0:
        raise ValueError("Incorrect decryption.")
    time.sleep(0.1)
    maskedSeed = em[1:hLen+1]
    maskedDB = em[hLen+1:]
    # Step 3c
    seedMask = mgf(maskedDB, hLen)
    # Step 3d
    seed = strxor(maskedSeed, seedMask)
    # Step 3e
    dbMask = mgf(seed, k-hLen-1)
    # Step 3f
    db = strxor(maskedDB, dbMask)
    # Step 3g
    valid = 1
    one = db[hLen:].find(bchr(0x01))
    lHash1 = db[:hLen]
    if lHash1!=lHash:
        valid = 0
    if one<0:
        valid = 0
    if not valid:
        raise ValueError("Incorrect decryption.")
    # Step 4
    return db[hLen+one+1:]

def main():
    key = RSA.generate(1024)
    
    print(f'n: {key.n}')
    print(f'e: {key.e}')

    flag = os.getenv('flag', 'EPFL{not_the_flag}')
    ciphertext = bytes_to_long(encrypt(flag.encode(), key))

    print(f'Try to decrypt this: {ciphertext}')
    
    while True:
        c = int(input('I will decrypt any ciphertext that you want: '))

        if c == ciphertext:
            print('I lied.')
            continue
        
        try:
            m = decrypt(long_to_bytes(c, key.size_in_bytes()), key)
            print(f'The plaintext is: {bytes_to_long(m)}')
        except Exception as e:
            print(f'Decryption failed: {e}')

if __name__ == '__main__':
    main()
