import pwn
from pwn import remote, xor
from hashlib import sha256
import random
from base64 import b64encode, b64decode
from Crypto.Util.number import getStrongPrime, bytes_to_long
from separate_prefixes import gen_lists, choose

e = 3
Ze = GF(e)
RSA_BYTES = 2048 // 8
PARTS = 23
md5_separatorsA, md5_separatorsB = gen_lists(PARTS)


def hash_msg(m):
    return int(sha256(m).hexdigest()[:16], 16)


def compute_pub_key(sig: dict[int, int]):
    s = list(sig.keys())
    N = gcd(sig[s[0]] ^ e - hash_msg(s[0]), sig[s[1]] ^ e - hash_msg(s[1]))
    N = gcd(sig[s[2]] ^ e - hash_msg(s[2]), N)
    for i in range(2,100_000):
        while (N % i) == 0:
            N //= i
    print(N)
    assert 2048 >= int(N).bit_length() > 2040
    return N


def request_signatures(msgs, vector_of_powers, remote_conn=None, mod=None, priv_key=None) -> dict:
    local_sigs = {}
    if remote_conn is None:
        for msg, power1 in zip(msgs, vector_of_powers):
            if power1 != 0:
                h1 = hash_msg(msg)
                local_sigs[h1] = pow(h1, priv_key, mod)

    else:
        i = 0
        r = remote_conn
        r.recvuntil(b"3: verify message signature")
        r.sendline(b"2")
        print(r.recvline())
        m = choose(0, md5_separatorsA, md5_separatorsB)
        print(b64encode(m))
        r.sendline(b64encode(m))
        result = b64decode(r.recvline()[2:-2])
        key = xor(result, m)[:RSA_BYTES]
        for h1, power1 in zip(msgs, vector_of_powers):
            if power1 != 0:
                i += 1
                r.recvuntil(b"3: verify message signature")
                r.sendline(b"1")
                r.recvline()
                r.sendline(b64encode(h1))
                received = b64decode(r.recvline()[2:-2])
                sig = bytes_to_long(xor(received, key))
                local_sigs[h1] = sig
                print(f"Got the #{i}th signature")
    return local_sigs


m1 = b"Forgery is futile. I'm unforgeable."
print(factor(hash_msg(m1)))
#exit()
primes_from_msg = set(prime_factors(hash_msg(m1)))
hashes = []
all_primes = set()
primes_still_needed = primes_from_msg.copy()
i = 0
messages = []
rand_choices = []
factors_dict = []
generating = False
if generating:
    # get an instance for every prime
    while primes_still_needed != set():
        i += 1
        rand_index = random.getrandbits(PARTS)
        m_test = choose(rand_index, md5_separatorsA, md5_separatorsB)
        h = hash_msg(m_test)
        tmp_st_needed = primes_still_needed.copy()
        for p in primes_still_needed:
            if h % p == 0:
                print(f"added {p} after {i} iterations")
                f = prime_factors(h)
                hashes.append(h)
                messages.append(m_test)
                rand_choices.append(rand_index)
                all_primes |= set(f)
                tmp_st_needed -= set(f).intersection(primes_still_needed)
                factors_dict.append(dict(factor(h)))
        primes_still_needed = tmp_st_needed

    print(len(hashes))
    print(len(all_primes))
    # getting more values until you have a square matrix
    i = 0
    while len(hashes) - 200 < len(all_primes):
        i += 1
        rand_index = random.getrandbits(PARTS)
        m_test = choose(rand_index, md5_separatorsA, md5_separatorsB)
        h = hash_msg(m_test)
        if h in hashes:
            continue
        factored = factor(h)
        factors = set(dict(factored).keys())
        num_new_primes = len(factors - factors.intersection(all_primes))
        max_factor_bit_size = int(max(factors)).bit_length()
        if ((num_new_primes < 5 and max_factor_bit_size < 18 and len(hashes) < 7000) or
                (num_new_primes == 0)):
            hashes.append(h)
            all_primes |= factors
            factors_dict.append(dict(factored))
            messages.append(m_test)
            rand_choices.append(rand_index)
            print(f"added a new line\nnew dimensions {len(hashes)} x {len(all_primes)}")
    print(f"You needed {i} attempts")

    sorted_primes = list(sorted(all_primes))
    A = {}
    for i, fact in enumerate(factors_dict):
        for p in fact.keys():
            A[(sorted_primes.index(p), i)] = fact[p]
    print("finished dict")
    M = Matrix(Ze, len(sorted_primes), len(hashes), A)

    new_vec = [0] * len(sorted_primes)
    prime_dict_from_msg = dict(factor(hash_msg(m1)))
    for p in primes_from_msg:
        new_vec[sorted_primes.index(p)] = prime_dict_from_msg[p]
    v = vector(Ze, new_vec)
    solved_vector = M.solve_right(v)
    assert len(solved_vector) == len(hashes)
    assert len(messages) == len(hashes)
    import json
    mmm = list(map(lambda x:x.hex(),messages))
    with open("solved_messages.py", "w+") as f:
        f.write(str(rand_choices))
    with open("solved_vector.py", "w+") as f:
        f.write(str(solved_vector))
    print(messages)
else:
    from solved_messages import msgs_solved
    messages = list(map(lambda x: choose(x,md5_separatorsA,md5_separatorsB),msgs_solved))
    from solved_vector import v_solved as solved_vector
    hashes = list(map(lambda x: hash_msg(x),messages))
print("solved !!!")
res = 1
sig_res = 1

connection = pwn.remote("localhost",5000)
sigs = request_signatures(messages, solved_vector, remote_conn=connection)
print("sigs generated")
N = compute_pub_key(sigs)
print("N recovered")
print(N)
for i, power in enumerate(solved_vector):
    res *= hashes[i] ^ int(power)
    if power != 0:
        sig_res *= sigs[messages[i]] ^ int(power)

# assert sig_res % N == pow(res, d, N)
# assert pow(sig_res, e, N) == res % N
print("now factoring again")
a = factor(res)
ff = dict(a)
print(a)
for k, v in ff.items():
    to_divide = int(v) // int(e)
    sig_res = (sig_res * pow(pow(k, to_divide), -1, N)) % N
    # res //= int(int(k) ^ int(to_divide * 3))
    # assert pow(sig_res, 3, N) == res % N
print(hash_msg(m1))
print(pow(sig_res, e, N))
connection.recvuntil(b"3: verify message signature")
connection.sendline(b"3")
connection.recvline()
connection.sendline(b64encode(int(sig_res).to_bytes(RSA_BYTES,"big")))
print(f"flag = {connection.recvline()}")
connection.interactive()
