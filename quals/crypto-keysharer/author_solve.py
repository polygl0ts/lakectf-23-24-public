from sage.all import *
from pwn import *
from Crypto.Util.number import long_to_bytes
from Crypto.Random.random import randrange

p = 0xfffffffffffffffffffffffffffffffeffffffffffffffff
a = 0xfffffffffffffffffffffffffffffffefffffffffffffffc
b = 0x64210519e59c80e70fa7e9ab72243049feb8deecc146b9b1
real_E = EllipticCurve(GF(p), [a, b])
r = remote("localhost", 1337)

bs = [2019,2012,2023,76900185]
dividers = [588894043351284398850618079862891349344177,
			723221628251180866279518067831832261,
			114790003746390518867366679845547928085519,
			78049996161686383351569590008824344213221657219]

r.recvuntil(b"Alice's public key is (")
pub_key = tuple(int(j) for j in r.recvline().strip().decode()[:-1].split(","))
pub_key = real_E(pub_key[0],pub_key[1])
logs = []
mods = []
for b,divider in zip(bs,dividers):
	E = EllipticCurve(GF(p), [a, b])
	P = E.gens()[0]
	q = E.order() // divider
	P_prime = divider * P
	while P_prime.order() != q:
		P = E.gens()[randrange(10,20)]
		P_prime = divider * P
	assert P_prime.order() == q
	r.recvuntil(b"Gimme your pub key's x : \n")
	r.sendline(str(P_prime[0]).encode())
	r.recvuntil(b"Gimme your pub key's y : \n")
	r.sendline(str(P_prime[1]).encode())
	r.recvuntil(b"The shared key is\n ")
	point_received = r.recvline().strip().decode()[1:-1].split(",")
	new_point = E(int(point_received[0]),int(point_received[1]))
	print("new point is : ",new_point)
	log = discrete_log(new_point, P_prime,P_prime.order(), operation='+')
	logs.append(int(log))
	mods.append(int(P_prime.order()))
	if len(logs) > 1:
		print("CRT is : ",crt(logs,mods))
	print("going to new point !")
print(logs)
print(mods)
PK = crt(logs,mods)
inv = int(pow(PK,-1,real_E.order()))
flag = int((pub_key * inv)[0])
print(long_to_bytes(flag))