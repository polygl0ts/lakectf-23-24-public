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
    client = docker.from_env()

    # Define container options
    container_options = {
        "image": "pwn-trustmee-chall",
        "stdin_open": True,
        "command": "/bin/bash",
        "mem_limit": "8m",
        "network": "none",
        "auto_remove": True,
        }

    # Create and start the container
    container = client.containers.run(**container_options, detach=True)
    container_id = container.id
    time.sleep(1)
    proc = Popen(["docker", "exec", "-i", "-u", "ctf", container_id, "/bin/bash"])
    # Function to stop the container if it runs for too long
    timer = Timer(timeout_seconds, proc.kill)
    try:
        timer.start()
        stdout, stderr = proc.communicate()
    finally:
        print("[*] time's up...")
        print("[*] exiting....")
        timer.cancel()
        container.stop()
        container.remove()
        # Return the container's exit code and output
    return container


if __name__ == '__main__':
    powser = NcPowser()
    prefix = powser.get_challenge()
    print(f"[*] connected to EPFL grades server")
    print(f"[*] leaked proof of work login for user ctf:")
    print(f"[*] please solve: sha256({prefix} + ???) == {'0'*powser.difficulty}({powser.difficulty})... ")
    print(f"[*] prefix: {prefix}")
    print(f"[*] difficulty: {powser.difficulty}")
    sys.stdout.flush()
    answer = input(" >")    
    if not powser.verify_hash(prefix, answer):
        print(f"[*] incorrect, time to get a lawyer: https://www.epfl.ch/about/overview/wp-content/uploads/2019/09/2.4.0.2Disciplinary_Rules_Regulations_ang.pdf")
        exit(0)

    print(f"[*] correct, logging in")
    print(f"[*] remember the grades are stored in a trusted execution environment!!")
    timeout = 300
    print(f"[*] you have {timeout} seconds")
    sys.stdout.flush()
    # Example usage:
    container = run_docker_container_with_timeout(timeout)
    if container.status == "running":
        container.stop()
        container.remove()

    exit(0)
