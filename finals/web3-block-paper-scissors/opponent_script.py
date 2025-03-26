#!/usr/bin/env python

import json, os, secrets, sys

import coincurve
from Crypto.Cipher import ChaCha20
from web3 import Web3, HTTPProvider
from web3.middleware import construct_sign_and_send_raw_middleware

from ctf_launchers.types import get_additional_account

CHALLENGE_ABI = json.load(open("challenge/contracts/out/Challenge.sol/Challenge.json"))['abi']
GAME_ABI = json.load(open("challenge/contracts/out/Game.sol/Game.json"))['abi']


mnemonic = os.environ["MNEMONIC"]
challenge_addr = sys.argv[1]
acct = get_additional_account(mnemonic, 1)

web3 = Web3(HTTPProvider(os.environ["RPC_URL"]))
web3.middleware_onion.add(construct_sign_and_send_raw_middleware(acct))
web3.eth.default_account = acct.address

challenge = web3.eth.contract(address=challenge_addr, abi=CHALLENGE_ABI)

game = web3.eth.contract(address=challenge.functions.game().call(), abi=GAME_ABI)
event_filter = game.events.EncryptionKey.create_filter(fromBlock=0)

enc_key = None
while enc_key is None:
    for event in event_filter.get_new_entries():
        enc_key = event.args.encryptionKey
        break

moves = bytes(secrets.randbelow(3) for _ in range(16))
r = coincurve.PrivateKey()
R = r.public_key
k = r.ecdh(enc_key)
nonce = [0]*8
cipher = ChaCha20.new(key=k, nonce=nonce)
ciphertext = cipher.encrypt(moves)

tx_hash = game.functions.commitMoves(1, R.format(), ciphertext).transact()
tx_receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
assert tx_receipt['status']
