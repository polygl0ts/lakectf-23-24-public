import base64
import os
from pwn import *

if args["LOCAL"]:
    r = process(["python3", "run.py"])
else:
    r = remote("challs.polygl0ts.ch", 12006)

if args["CHEAT"]:
    os.system(f'gcc src/cheat.c -o level1_solve')
elif args["INCORRECT"]:
    os.system(f'gcc src/incorrect.c -o level1_solve')
else:
    os.system(f'gcc src/level1.c -o level1_solve')
raw = open('./level1_solve', 'rb').read()
b64 = base64.b64encode(raw)
r.recvuntil(b"pls:")
r.sendline(b64)
r.interactive()
