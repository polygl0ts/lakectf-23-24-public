#!/usr/bin/python3

import subprocess
import os
import base64

base64_binary = input("binary pls:")
binary = base64.b64decode(base64_binary)
open("/tmp/level2", "wb").write(binary)
subprocess.check_output(f'chmod +x /tmp/level2', shell=True)

subprocess.check_output(f'rm -rf /tmp/in', shell=True)
if os.path.exists('/tmp/out'):
    subprocess.check_output(f'rm -rf /tmp/out', shell=True)
subprocess.check_output(f'mkdir /tmp/in', shell=True)
subprocess.check_output(f'echo asdf > /tmp/in/1', shell=True)

my_env = os.environ.copy()
my_env["AFL_PRELOAD"] = "./seccomp_pre.so"
my_env["AFL_DEBUG"] = "0"
my_env["AFL_FORCE_UI"] = "1"
proc = subprocess.Popen(f'timeout 30 /usr/local/bin/afl-fuzz -i /tmp/in -o /tmp/out -- /tmp/level2', shell=True, env=my_env) #, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
proc.wait()

fuzzer_stats = "/tmp/out/default/fuzzer_stats"
fuzzer_stats = open(fuzzer_stats).read().split("\n")
for l in fuzzer_stats:
    if l.startswith('execs_done'):
        execs_done = int(l.split(':')[-1].strip(" "))
    if l.startswith('saved_crashes'):
        saved_crashes = int(l.split(':')[-1].strip(" "))

print(f'execs done: {execs_done}, saved crashes: {saved_crashes}')
if execs_done == 33333 and saved_crashes == 69:
    crashes = "/tmp/out/default/crashes"
    for crash in os.listdir(crashes):
        if crash == "README.txt":
            continue
        crash = os.path.join(crashes, crash)
        subprocess.check_output(f'chmod +x {crash}', shell=True)
        os.system(f'{crash}')
else:
    print("not the results I was expecting...")
