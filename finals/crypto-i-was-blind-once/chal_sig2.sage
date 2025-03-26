from hashlib import sha256
import os
import random
from Crypto.Util.number import getStrongPrime

e = 3
Ze = Zmod(e)


def hash_msg(m):
    return int(sha256(m).hexdigest()[:16], 16)


def request_signatures(hashes_passed, vector_of_powers, local=False, mod=None, priv_key=None) -> dict:
    local_sigs = {}
    if local:
        for h1, power1 in zip(hashes_passed, vector_of_powers):
            if power1 != 0:
                local_sigs[h1] = pow(h1, priv_key, mod)
    return local_sigs


msgs = [
    b"You cannot succeed to forge me",
    b"nope, you're doomed trying to craft the uncraftable",
    b"Nice try, but forging me is like trying to catch a shadow",
    b"Attempting to replicate me? Good luck with that futile endeavor!",
    b"Sorry, forging me is beyond the realm of possibility",
    b"I'm like a fortress, impervious to forgery attempts",
    b"Trying to mimic me? That's a recipe for failure",
    b"Forgery of this signature? Not on my watch!",
    b"Crafting me? You might as well try to tame a hurricane",
    b"Attempting to duplicate me? You're in for a disappointment",
    b"Forgery attempt detected. Nice try, but no dice!",
    b"Forgery? Not happening. I'm as authentic as they come",
    b"Crafting this signature is like trying to grasp smoke",
    b"Nice try, but you'll never replicate this signature",
    b"Forge me? I'd like to see you try and fail",
    b"Forgery is futile when it comes to this signature",
    b"Attempting to mimic me? That's a fool's errand",
    b"No amount of effort will result in replicating this signature",
    b"Forging me is as likely as finding a needle in a haystack",
    b"I'm like a puzzle with no solution for forgers",
    b"Forgery attempt thwarted. Better luck next time!",
    b"Replicating me? You might as well try to turn back time",
    b"No chance of forging this signature. It's untouchable",
    b"I'm like an enigma, impervious to replication attempts",
    b"Crafting me? It's like trying to tame a wild beast",
    b"No amount of skill can replicate this signature",
    b"Forgery attempt denied. This signature is one of a kind",
    b"Nice try, but forging this signature is mission impossible",
    b"You can attempt to replicate me, but you'll fail miserably",
    b"Forgery attempt detected. Better luck next time!",
    b"Trying to copy this signature? You're out of your depth",
    b"This signature is as unique as a snowflake, unforgeable",
    b"Forgery attempt thwarted. Better luck next time!",
    b"Forge me? I'd like to see you try and fail",
    b"Forgery is futile when it comes to this signature",
    b"Attempting to mimic me? That's a fool's errand",
    b"No amount of effort will result in replicating this signature",
    b"Forging me is as likely as finding a needle in a haystack",
    b"I'm like a puzzle with no solution for forgers",
    b"Forgery attempt thwarted. Better luck next time!",
    b"Replicating me? You might as well try to turn back time",
    b"No chance of forging this signature. It's untouchable",
    b"I'm like an enigma, impervious to replication attempts",
    b"Crafting me? It's like trying to tame a wild beast",
    b"No amount of skill can replicate this signature",
    b"Forgery attempt denied. This signature is one of a kind",
    b"Nice try, but forging this signature is mission impossible",
    b"You can attempt to replicate me, but you'll fail miserably",
    b"Forgery attempt detected. Better luck next time!",
    b"Trying to copy this signature? You're out of your depth",
    b"This signature is as unique as a snowflake, unforgeable",
    b"Forgery attempt thwarted. Better luck next time!"
]
msgs += [
    b"Attempting to replicate this signature? Think again.",
    b"This signature is like a fortress, impenetrable to forgery.",
    b"Forge me? Not happening. I'm one of a kind.",
    b"Nice try, but you're not getting past this signature.",
    b"Forgery attempt denied. Better luck next time!",
    b"You can try to forge me, but you won't succeed.",
    b"Forgery attempt detected. Security alert!",
    b"No amount of skill can recreate this signature.",
    b"I'm like a secret code, impossible to crack.",
    b"Forgery attempt thwarted. Try harder next time!",
    b"This signature is my identity. No one can replicate it.",
    b"Trying to mimic me? You're barking up the wrong tree.",
    b"Crafting this signature is like chasing a mirage.",
    b"Forgery is futile. This signature is untouchable.",
    b"Replicating this signature? It's like chasing shadows.",
    b"I'm the real deal. Good luck forging me!",
    b"Forgery attempt blocked. Better luck next time!",
    b"Crafting this signature? It's like trying to catch lightning in a bottle.",
    b"Nice try, but you can't fake this signature.",
    b"Forgery attempt failed. Access denied.",
    b"Trying to copy me? You're wasting your time.",
    b"This signature is my seal. No one can duplicate it.",
    b"Forgery attempt detected. System alert!",
    b"I'm like a puzzle with no solution for forgers.",
    b"No chance of forging this signature. It's bulletproof.",
    b"Replicating me? You're in over your head.",
    b"Forgery attempt foiled. Try again if you dare.",
    b"Crafting this signature is like trying to tame a tornado.",
    b"Forgery is futile. I'm unforgeable.",
    b"This signature is my fingerprint. Unique and irreplaceable.",
    b"Trying to replicate me? You're fighting a losing battle.",
    b"Forgery attempt blocked. Access denied.",
    b"Nice try, but this signature is beyond replication.",
    b"Forgery attempt detected. Initiating security protocols.",
    b"Attempting to forge me? You're out of your league.",
    b"Crafting this signature is like trying to bottle lightning.",
    b"Forgery is like trying to paint a masterpiece blindfolded.",
    b"No amount of effort will crack this signature's code.",
    b"I'm like a locked vault. Good luck cracking the code.",
    b"Forgery attempt thwarted. Better luck next time!",
    b"Trying to mimic this signature? You're chasing a ghost.",
    b"This signature is a fortress. You can't breach it.",
    b"Forge me? Not a chance. I'm untouchable.",
    b"Nice try, but you'll never replicate this signature.",
    b"Forgery attempt denied. Access restricted.",
    b"Crafting this signature is like trying to capture lightning in a bottle.",
    b"Forgery is like trying to solve a puzzle with missing pieces.",
    b"No amount of skill can duplicate this signature.",
    b"I'm like a lock with no key. Impossible to open.",
    b"Forgery attempt blocked. Intruder detected.",
    b"Trying to forge me? You're playing with fire.",
    b"This signature is my trademark. You can't copy it.",
    b"Forgery attempt detected. Engaging security measures.",
    b"Attempting to mimic this signature? You're out of your depth.",
    b"Crafting this signature is like trying to tame a hurricane.",
    b"Forgery is futile. This signature is impenetrable.",
    b"No chance of forging this signature. It's rock solid.",
    b"Replicating me? You're chasing a dream.",
    b"Forgery attempt thwarted. Security breach averted.",
    b"This signature is like a lock without a key. Unbreakable.",
    b"Trying to replicate this signature? You're out of luck.",
    b"Forgery attempt blocked. Unauthorized access denied.",
    b"Nice try, but you're not cracking this signature's code.",
    b"Forgery is like trying to find a needle in a haystack.",
    b"I'm like a cryptic message. Impossible to decipher.",
    b"Forgery attempt detected. System lockdown initiated.",
    b"Crafting this signature is like trying to harness a storm.",
    b"No amount of effort will unravel this signature's mystery.",
    b"Trying to mimic me? You're fighting a losing battle.",
    b"This signature is like a fortress. You can't breach it.",
    b"Forgery attempt denied. Access forbidden.",
    b"Nice try, but you're not replicating this signature.",
    b"Forgery is futile. This signature is unbreakable.",
    b"Replicating me? You're chasing shadows.",
    b"Forgery attempt thwarted. Unauthorized entry blocked.",
    b"This signature is like a lock without a key. Indomitable.",
    b"Trying to replicate this signature? You're out of your league.",
    b"Forgery attempt blocked. Access violation detected.",
    b"Nice try, but you're not deciphering this signature's code.",
    b"Forgery is like trying to find a grain of sand on the beach.",
    b"I'm like a riddle with no solution. Unsolved and unforgeable.",
    b"Forgery attempt detected. System security compromised.",
    b"Crafting this signature is like trying to tame a thunderstorm.",
    b"No amount of skill will unlock this signature's secrets.",
    b"Trying to mimic me? You're playing with fire.",
    b"This signature is like a fortress. You can't penetrate it.",
    b"Forgery attempt denied. Access prohibited.",
    b"Nice try, but you're not replicating this signature.",
    b"Forgery is futile. This signature is impenetrable.",
    b"No chance of forging this signature. It's invincible.",
    b"Replicating me? You're chasing ghosts.",
    b"Forgery attempt thwarted. Unauthorized access prevented.",
    b"This signature is like a lock without a key. Unassailable.",
    b"Trying to replicate this signature? You're out of your depth.",
    b"Forgery attempt blocked. Intrusion detected.",
    b"Nice try, but you're not breaking this signature's code.",
    b"Forgery is like trying to find a single drop in the ocean.",
    b"I'm like an enigma, unfathomable and unforgeable.",
    b"Forgery attempt detected. Security breach detected.",
    b"Crafting this signature is like trying to tame a tempest.",
    b"No amount of effort will unravel this signature's complexity.",
    b"Trying to mimic me? You're in over your head.",
    b"This signature is like a fortress. You can't breach it.",
    b"Forgery attempt denied. Unauthorized access denied.",
    b"Nice try, but you're not replicating this signature.",
    b"Forgery is futile. This signature is impregnable.",
    b"No chance of forging this signature. It's indestructible.",
    b"Replicating me? You're chasing phantoms.",
    b"Forgery attempt thwarted. Unauthorized entry blocked.",
    b"This signature is like a lock without a key. Indestructible.",
    b"Trying to replicate this signature? You're outmatched.",
    b"Forgery attempt blocked. Unauthorized access blocked.",
    b"Nice try, but you're not decrypting this signature's code.",
    b"Forgery is like trying to find a speck of dust in the cosmos.",
    b"I'm like a mystery, unfathomable and unreplicable.",
    b"Forgery attempt detected. Security breach detected.",
    b"Crafting this signature is like trying to tame a cyclone.",
    b"No amount of effort will untangle this signature's complexity.",
    b"Trying to mimic me? You're biting off more than you can chew.",
    b"This signature is like a fortress. It's impenetrable.",
    b"Forgery attempt denied. Unauthorized access prohibited.",
    b"Nice try, but you're not cloning this signature.",
    b"Forgery is futile. This signature is unbeatable.",
    b"No chance of forging this signature. It's insurmountable.",
    b"Replicating me? You're chasing illusions.",
    b"Forgery attempt thwarted. Unauthorized entry prevented.",
    b"This signature is like a lock without a key. Invulnerable.",
    b"Trying to replicate this signature? You're outgunned.",
    b"Forgery attempt blocked. Unauthorized access denied.",
    b"Nice try, but you're not cracking this signature's encryption.",
    b"Forgery is like trying to find a grain of sand in the desert.",
    b"I'm like a conundrum, inscrutable and impregnable.",
    b"Forgery attempt detected. Security breach detected.",
    b"Crafting this signature is like trying to tame a tsunami.",
    b"No amount of effort will decipher this signature's complexity.",
    b"Trying to mimic me? You're sailing into a storm.",
    b"This signature is like a fortress. You can't conquer it.",
    b"Forgery attempt denied. Unauthorized access denied.",
    b"Nice try, but you're not cloning this signature.",
    b"Forgery is futile. This signature is unassailable.",
    b"No chance of forging this signature. It's unbeatable.",
    b"Replicating me? You're chasing ghosts.",
    b"Forgery attempt thwarted. Unauthorized entry blocked.",
    b"This signature is like a lock without a key. Invincible.",
    b"Trying to replicate this signature? You're outmatched.",
    b"Forgery attempt blocked. Unauthorized access blocked.",
    b"Nice try, but you're not deciphering this signature's code.",
    b"Forgery is like trying to find a single atom in the universe.",
    b"I'm like a puzzle, unsolvable and impervious.",
    b"Forgery attempt detected. Security breach detected.",
    b"Crafting this signature is like trying to tame a monsoon.",
    b"No amount of effort will unravel this signature's complexity.",
    b"Trying to mimic me? You're swimming against the current.",
    b"This signature is like a fortress. It's unconquerable.",
    b"Forgery attempt denied. Unauthorized access prohibited.",
    b"Nice try, but you're not duplicating this signature.",
    b"Forgery is futile. This signature is unbreakable.",
    b"No chance of forging this signature. It's indestructible.",
    b"Replicating me? You're chasing illusions.",
    b"Forgery attempt thwarted. Unauthorized entry prevented.",
    b"This signature is like a lock without a key. Invulnerable.",
    b"Trying to replicate this signature? You're outgunned.",
    b"Forgery attempt blocked. Unauthorized access denied.",
    b"Nice try, but you're not cracking this signature's encryption.",
    b"Forgery is like trying to find a grain of sand in the desert.",
    b"I'm like a conundrum, inscrutable and impregnable.",
    b"Forgery attempt detected. Security breach detected.",
    b"Crafting this signature is like trying to tame a tsunami.",
    b"No amount of effort will decipher this signature's complexity.",
    b"Trying to mimic me? You're sailing into a storm.",
    b"This signature is like a fortress. You can't conquer it.",
    b"Forgery attempt denied. Unauthorized access denied.",
    b"Nice try, but you're not cloning this signature.",
    b"Forgery is futile. This signature is unassailable.",
    b"No chance of forging this signature. It's unbeatable.",
    b"Replicating me? You're chasing ghosts.",
    b"Forgery attempt thwarted. Unauthorized entry blocked.",
    b"This signature is like a lock without a key. Invincible.",
    b"Trying to replicate this signature? You're outmatched.",
    b"Forgery attempt blocked. Unauthorized access blocked.",
    b"Nice try, but you're not deciphering this signature's code.",
    b"Forgery is like trying to find a single atom in the universe.",
    b"I'm like a puzzle, unsolvable and impervious.",
    b"Forgery attempt detected. Security breach detected.",
    b"Crafting this signature is like trying to tame a monsoon.",
    b"No amount of effort will unravel this signature's complexity.",
    b"Trying to mimic me? You're swimming against the current.",
    b"This signature is like a fortress. It's unconquerable.",
    b"Forgery attempt denied. Unauthorized access prohibited.",
    b"Nice try, but you're not duplicating this signature.",
    b"Forgery is futile. This signature is unbreakable.",
    b"No chance of forging this signature. It's indestructible.",
    b"Replicating me? You're chasing illusions.",
    b"Forgery attempt thwarted. Unauthorized entry prevented."
]
_min = 1 << 1000
m1 = b""
for m in msgs:
    max_fac = max(prime_factors(hash_msg(m)))
    if max_fac < _min:
        _min = max_fac
        m1 = m
print(m1)
print(factor(hash_msg(m1)))
#exit()

# m1 = b"Trying to forge me? You're playing with fire."


primes_from_msg = set(prime_factors(hash_msg(m1)))
hashes = []
all_primes = set()
primes_still_needed = primes_from_msg.copy()
i = 0
messages = []
factors_dict = []

# get an instance for every prime
while primes_still_needed != set():
    i += 1
    m_test = os.urandom(16)
    h = hash_msg(m_test)
    tmp_st_needed = primes_still_needed.copy()
    for p in primes_still_needed:
        if h % p == 0:
            print(f"added {p} after {i} iterations")
            f = prime_factors(h)
            hashes.append(h)
            messages.append(m_test)
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
    m_test = os.urandom(16)
    h = hash_msg(m_test)
    factored = factor(h)
    factors = set(dict(factored).keys())
    num_new_primes = len(factors - factors.intersection(all_primes))
    max_factor_bit_size = int(max(factors)).bit_length()
    if ((num_new_primes < 5 and max_factor_bit_size < 20 and len(hashes) < 20_000) or
            (num_new_primes == 0)):
        hashes.append(h)
        all_primes |= factors
        factors_dict.append(dict(factored))
        messages.append(m_test)
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
print("solved !!!")
p = getStrongPrime(1024, e=e)
q = getStrongPrime(1024, e=e)
N = p * q
phi = (p - 1) * (q - 1)
d = pow(e, -1, phi)
assert pow(pow(2, d, N), e, N) == 2
res = 1
sig_res = 1
print("sigs generated")
assert len(solved_vector) == len(hashes)
sigs = request_signatures(hashes, solved_vector, local=True, mod=N, priv_key=d)
for i, power in enumerate(solved_vector):
    res *= hashes[i] ^ int(power)
    if power != 0:
        sig_res *= sigs[hashes[i]] ^ int(power)

assert sig_res % N == pow(res, d, N)
assert pow(sig_res, e, N) == res % N
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
print(expected := pow(sig_res, e, N))
print(factor(expected))
