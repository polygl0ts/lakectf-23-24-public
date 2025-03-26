# check if arch is X86_64
A = arch
A == ARCH_X86_64 ? next : dead
A = sys_number
A >= 0x40000000 ? dead : next
A == mmap ? ok : next
A == open ? ok : next
A == openat ? ok : next
A == read ? ok : next
A == write ? ok : next
A == close ? ok : next
A == exit ? ok : next
A == exit_group ? ok : dead
ok:
return ALLOW
dead:
return KILL
