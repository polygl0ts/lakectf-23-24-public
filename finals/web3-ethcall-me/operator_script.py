import json, os, sys

from eth_abi import abi
from web3 import Web3, HTTPProvider

CHALLENGE_ABI = json.load(open("challenge/contracts/out/Challenge.sol/Challenge.json"))['abi']
FLAG = open('challenge/flag').read().strip()


challenge_addr = sys.argv[1]

web3 = Web3(HTTPProvider(os.environ["RPC_URL"]))

challenge = web3.eth.contract(address=challenge_addr, abi=CHALLENGE_ABI)

if not challenge.functions.testFlag(FLAG).call():
    raise Exception("integrity check failed")

event_filter = challenge.events.CallMe.create_filter(fromBlock=0)

while True:
    for event in event_filter.get_new_entries():
        target = event.args.target
        selector = event.args.selector
        calldata = selector + abi.encode(['string'], [FLAG])
        tx = {'to': target, 'data': calldata}
        try:
            web3.eth.call(tx)
        except Exception:
            pass
