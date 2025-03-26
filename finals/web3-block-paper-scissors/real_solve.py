from pwn import *

import os, json, time

from eth_account import Account
from web3 import Web3, HTTPProvider
from web3.middleware import construct_sign_and_send_raw_middleware
from web3.exceptions import ContractPanicError

HOST = args.get('HOST', 'challs.polygl0ts.ch')
r = remote(HOST, 12016)

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

r.recvuntil(b'token:')
token = r.recvline().strip().decode()
r.recvuntil(b'rpc endpoint:')
rpc_url = r.recvline().strip().decode()
r.recvuntil(b'private key:')
privk = r.recvline().strip().decode()
r.recvuntil(b'challenge contract:')
challenge_addr = r.recvline().strip().decode()

CHALLENGE_ABI = json.load(open("contracts/out/Challenge.sol/Challenge.json"))['abi']
GAME_ABI = json.load(open("contracts/out/Game.sol/Game.json"))['abi']


acct = Account.from_key(privk)
web3 = Web3(HTTPProvider(rpc_url))
web3.middleware_onion.add(construct_sign_and_send_raw_middleware(acct))
web3.eth.default_account = acct.address

challenge = web3.eth.contract(address=challenge_addr, abi=CHALLENGE_ABI)

game = web3.eth.contract(address=challenge.functions.game().call(), abi=GAME_ABI)

# we are player 0
opponentAddress = game.functions.playerAddress(1).call()

event_filter = game.events.EncryptionKey.create_filter(fromBlock=0)
enc_key = None
while enc_key is None:
    for event in event_filter.get_new_entries():
        enc_key = event.args.encryptionKey
        break

while not (moves := game.functions.committedMoves(1).call())[0]:
    time.sleep(1)

moves[1] = bytes(b ^ 4 for b in moves[1])
tx_hash = game.functions.commitMoves(0, *moves).transact()
tx_receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
assert tx_receipt['status']

ok = False
while not ok:
    try:
        ok = challenge.functions.isSolved().call()
    except ContractPanicError:
        pass
    print("waiting for solve...")
    time.sleep(1)

r = remote(HOST, 12016)

r.recvuntil(b'action? ')
r.sendline(b'2')
r.recvuntil(b'token? ')
r.sendline(token)
r.interactive()
