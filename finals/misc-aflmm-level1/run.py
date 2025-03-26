#!/usr/bin/python3

import subprocess
import os
import base64

base64_binary = input("binary pls:")
binary = base64.b64decode(base64_binary)
open("/tmp/level1", "wb").write(binary)

subprocess.check_output(f'chmod +x /tmp/level1', shell=True)
subprocess.check_output(f'rm -rf /tmp/in', shell=True)
if os.path.exists('/tmp/out'):
    subprocess.check_output(f'rm -rf /tmp/out', shell=True)
subprocess.check_output(f'mkdir /tmp/in', shell=True)
subprocess.check_output(f'echo asdf > /tmp/in/1', shell=True)

my_env = os.environ.copy()
my_env["AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES"] = "1"
my_env["AFL_PRELOAD"] = "./seccomp_pre.so"
my_env["AFL_DEBUG"] = "0"
my_env["AFL_FORCE_UI"] = "1"
proc = subprocess.Popen(f'timeout 30 /usr/local/bin/afl-fuzz -i /tmp/in -o /tmp/out -- /tmp/level1', shell=True, env=my_env) #, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
proc.wait()

crashes = "/tmp/out/default/crashes"
for crash in os.listdir(crashes):
    if crash == "README.txt":
        continue
    crash = os.path.join(crashes, crash)
    subprocess.check_output(f'chmod +x {crash}', shell=True)
    os.system(f'{crash}')
