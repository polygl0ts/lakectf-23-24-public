from pwn import *
from Crypto.Util.number import isPrime, long_to_bytes, bytes_to_long
import randcrack
r = remote("localhost", 1337)
cracker = randcrack.RandCrack()
counter = 0
while counter < 624:
	line = r.recvline().strip().decode()
	if "Sadly" in line:
		number = int(line.split(" ")[1])
		for i in range(32):
			a = (number >> (i*32)) & ((1<<32) -1)
			cracker.submit(a)
			counter += 1
			if counter == 624:
				cracker.predict_getrandbits((31-i) * 32)
				break

message = r.recvline().strip().decode()
while "Sadly" in message:
	cracker.predict_getrandbits(1024)
	message = r.recvline().strip().decode()
cipher = int(message.split(" ")[1])
p = cracker.predict_getrandbits(1024)
q = cracker.predict_getrandbits(1024)
while not isPrime(q):
	q = cracker.predict_getrandbits(1024)
n = p * q
e = 65537
print(long_to_bytes(pow(cipher, pow(e,-1,(p-1)*(q-1)), n)))