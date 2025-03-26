import base64
import os
from pwn import *

if args["LOCAL"]:
    r = process(["python3", "run.py"])
else:
    r = remote("chall.polygl0ts.ch", 12007)

if args["CHEAT"]:
    os.system(f'gcc src/cheat.c -o level2_solve')
elif args["WRONGCMD"]:
    os.system(f'gcc src/wrong_cmd.c -o level2_solve')
elif args["WRONGCRASH"]:
    os.system(f'gcc src/wrong_crashes.c -o level2_solve')
elif args["WRONGEXEC"]:
    os.system(f'gcc src/wrong_iter.c -o level2_solve')
else:
    os.system(f'gcc src/level2.c -o level2_solve')
    
raw = open('./level2_solve', 'rb').read()
b64 = base64.b64encode(raw)
r.recvuntil(b"pls:")
r.sendline(b64)
r.interactive()
