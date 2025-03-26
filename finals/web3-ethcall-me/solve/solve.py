from pwn import *

import subprocess

HOST = args.get('HOST', 'challs.polygl0ts.ch')
r = remote(HOST, 12014)

r.recvuntil(b'action? ')
r.sendline(b'1')

r.recvuntil("prefix:")
prefix = r.recvline().strip().decode()
r.recvuntil("difficulty:")
difficulty = int(r.recvline().strip().decode())
TARGET = 2**(256-difficulty)
alphabet = string.ascii_letters+string.digits+'+/'
answer = iters.bruteforce(lambda x: int.from_bytes(util.hashes.sha256sum((prefix + x).encode()), 'big') < TARGET, alphabet, length=7)
r.sendlineafter(b">", answer)

r.recvuntil(b'rpc endpoint:')
rpc_url = r.recvline().strip().decode()
r.recvuntil(b'private key:')
privk = r.recvline().strip().decode()
r.recvuntil(b'challenge contract:')
challenge_addr = r.recvline().strip().decode()

os.environ['CHALLENGE_ADDR'] = challenge_addr

subprocess.run(['forge', 'script', '--broadcast', '--rpc-url', rpc_url, '--private-key', privk, 'script/Solve.s.sol'])

info("flag sent to webhook %s", 'https://webhook.site/#!/view/62737f25-4a05-4e7b-a341-9329071159a6/94f377cc-9f1d-48d3-8cd4-ed9172a5d43b/1')
