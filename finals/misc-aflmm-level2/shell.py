#!/usr/bin/python3

import secrets
import hashlib
from subprocess import Popen, PIPE
from threading import Timer
import docker
import sys
import time

# 22
# copied from: https://github.com/balsn/proof-of-work
class NcPowser:
    def __init__(self, difficulty=22, prefix_length=16):
        self.difficulty = difficulty
        self.prefix_length = prefix_length

    def get_challenge(self):
        return secrets.token_urlsafe(self.prefix_length)[:self.prefix_length].replace('-', 'b').replace('_', 'a')

    def verify_hash(self, prefix, answer):
        h = hashlib.sha256()
        h.update((prefix + answer).encode())
        bits = ''.join(bin(i)[2:].zfill(8) for i in h.digest())
        return bits.startswith('0' * self.difficulty)
    

# Credits: ChatGPT
def run_docker_container_with_timeout(timeout_seconds):
    # Create and start the container
    proc = Popen(["docker", "run", "--rm", "-i", "-u", "ctf", "misc-aflmm-level2-chall", "/app/run"])
    # Function to stop the container if it runs for too long
    timer = Timer(timeout_seconds, proc.kill)
    try:
        timer.start()
        stdout, stderr = proc.communicate()
    finally:
        print("[*] time's up...")
        print("[*] exiting....")
        timer.cancel()
        proc.terminate()
        # Return the container's exit code and output

if __name__ == '__main__':
    timeout = 300
    sys.stdout.flush()
    run_docker_container_with_timeout(timeout)
    exit(0)
