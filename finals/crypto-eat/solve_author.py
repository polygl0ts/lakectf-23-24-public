# taken from https://github.com/mimoo/RSA_PKCS1v1_5_attacks/blob/master/manger.py
from pwn import *
from Crypto.PublicKey import RSA
from Crypto.Util.number import long_to_bytes, bytes_to_long, size, ceil_div
from Crypto.Util.strxor import strxor
from Crypto.Util.py3compat import *
from Crypto.Hash import SHA
from Crypto.Signature.pss import MGF1
import time 

#### interaction with chall
def get_key():
    p.recvuntil(b'n: ')
    n = int(p.recvline().decode().strip())
    p.recvuntil(b'e: ')
    e = int(p.recvline().decode().strip())
    return RSA.construct((n, e))

def get_ciphertext():
    p.recvuntil(b'Try to decrypt this: ')
    return int(p.recvline().decode().strip())

def decrypt(c):
    p.recvuntil(b'I will decrypt any ciphertext that you want: ')
    p.sendline(str(c).encode())
    p.recvline().decode().strip() # we don't care about the result, we just want timing

#### attack
def upper(num):
    return 2**(num*8) - 1

def lower(num):
    return 2**((num-1)*8) 

def ceildiv(a, b):
    return -(-a // b)

def oracle_length(c):
    threshold = 0.1     # in seconds
    attempts = 10       # number of attempts per query (to compensate for network lag)
    lag_threshold = 0.2 # when a query is considered laggy, and we should wait a bit ebfore trying again
    
    print("oracle times:", end=" ")
    for i in range(attempts):
        time.sleep(0.05) # avoid spamming the server
        start = time.time()
        decrypt(c)
        end = time.time()
        print(f"{end - start:.2f}", end=" ")
    
        if end - start < threshold:
            print("fast")
            return 128 # doesn't start with b'\x00'
        
        if end - start > lag_threshold:
            print("laggy")
            time.sleep(1)

    print("slow")
    return 127 # starts with b'\x00'

def manger_attack(key: RSA.RsaKey, logging):
    key_size = key.size_in_bits()
    e = key.e
    N = key.n

    # setup 2
    N_size = ceildiv(key_size, 8)
    ciphertext = get_ciphertext()
    
    # setup 3
    B = lower(N_size)
    total_msg = 0

    # attack
    f1 = 2
    leak = 0

    # step 1
    logging.info("step 1.")
    while True:
        c2 = (ciphertext * pow(f1, e, N)) % N
        total_msg += 1
        leak = oracle_length(c2)
        if leak == N_size:
            logging.info("step 1.3b")
            break
        
        logging.info("step 1.3a")
        f1 = 2 * f1

    logging.info(str(total_msg) + " messages")

    # Step 2.
    logging.info("Step 2.")
    f2 = (N+B) // B
    f2 = f2 * (f1 // 2)
    while True:
        c2 = (ciphertext * pow(f2, e, N)) % N
        total_msg += 1
        leak = oracle_length(c2)
        if leak < N_size:
            logging.info("step 2.3b")
            break
        logging.info("step 2.3a")
        f2 = f2 + (f1//2)
    logging.info(str(total_msg) + " messages")
    
    # step 3.
    logging.info("Step 3.")
    m_min = ceildiv(N, f2)
    m_max = (N+B) // f2
    logging.info("\n- m_min: %d\n- m_max: %d\n" % (m_min, m_max))
    while True:
        # find good f3
        f_tmp = 2*B // (m_max - m_min)
        i = f_tmp * m_min // N
        f3 = ceildiv(i * N, m_min)
        # try the oracle
        c2 = (ciphertext * pow(f3, e, N)) % N
        total_msg += 1
        leak = oracle_length(c2)
        # branch
        if leak < N_size:
            logging.info("step 3.5b")
            m_max = (i * N + B) // f3
        else:
            logging.info("3.5a")
            m_min = ceildiv(i * N + B, f3)
        logging.info("\n- m_min: %d\n- m_max: %d\n" % (m_min, m_max))
        if m_min == m_max:
            break
        
    logging.info(str(total_msg) + " messages")
    return m_min  

def unpad(m: bytes, key_size: int) -> bytes:
    """Used to unpad message obtained after manger attack."""
    mgf = lambda x,y: MGF1(x,y,SHA)

    modBits = key_size
    k = ceil_div(modBits,8) # Convert from bits to bytes
    hLen = SHA.digest_size
    
    em = bchr(0x00)*(k-len(m)) + m
    
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
    one = db[hLen:].find(bchr(0x01))
    
    return db[hLen+one+1:]


def main():    
    logging.basicConfig()
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)
    
    key = get_key()
    res = manger_attack(key, logger)
    print(f'Flag: {unpad(long_to_bytes(res), key.size_in_bits())}')
    
if __name__ == '__main__':
    # p = process(['/usr/bin/python3', 'chall.py'])
    p = remote('chall.polygl0ts.ch', 12013)
    main()
