; syscall shit on 32bits:
; args in ebx, ecx, edx, esi, edi, and ebp
; https://stackoverflow.com/questions/2535989/what-are-the-calling-conventions-for-unix-linux-system-calls-and-user-space-f
;
; jump comparison
; http://unixwiz.net/techtips/x86-jumps.html

default rel

global _start

%macro next 0
  lodsd
  jmp [eax]
%endmacro

%macro resetregs 0
  xor eax, eax
  xor ebx, ebx                                                    
  xor ecx, ecx                                                    
  xor edx, edx                                                    
  xor esi, esi                                                    
  xor edi, edi                                                    
  xor esp, esp                                                    
  xor ebp, ebp 
%endmacro

section .text

syscall_exit:
  mov eax, 1
  int 0x80  

_start:
  resetregs
  mov esp, base_end - 256*4
  mov ebp, base_end

letsgo:
  mov esi, main
  next

exit_:
  mov ebx, 0
  jmp syscall_exit

nest_:
  sub ebp, 4
  mov [ebp], esi
  lea esi, [eax+4]
  next

unnest_:
  mov esi, [ebp]
  add ebp, 4
  next

call_:
  pop eax
  jmp [eax]

tail_:
  lodsd
  mov esi, [ebp]
  add ebp, 4
  jmp [eax]

read_:
  pop eax
  push dword [eax]
  next

readb_:
  pop eax
  xor ebx, ebx
  mov bl, byte [eax]
  push ebx
  next

write_:
  pop eax
  pop ebx
  mov [eax], ebx
  next

writeb_:
  pop eax
  pop ebx
  mov byte [eax], bl
  next

putc_:
  mov ebx, 1
  mov ecx, esp
  mov edx, 1
  mov eax, 4
  int 0x80
  pop eax
  next

getc_:
  xor eax, eax
  push eax
  mov ebx, 0
  mov ecx, esp
  mov edx, 1 
  mov eax, 3
  int 0x80

  cmp eax, 0
  jle .error_or_eof
  next
.error_or_eof:
  mov ebx, 69
  jmp syscall_exit

push_:
  lodsd
  push eax
  next

drop_:
  pop eax
  next

dup_:
  mov eax, [esp]
  push eax
  next

swap_:
  mov eax, [esp]
  mov ebx, [esp+4]
  mov [esp], ebx
  mov [esp+4], eax
  next

over_:
  mov eax, [esp+4]
  push eax
  next

nip_:
  pop eax
  mov [esp], eax
  next

add_:
  pop eax
  add [esp], eax
  next
  
sub_:
  pop eax
  sub [esp], eax
  next
  
mul_:
  pop eax
  pop ebx
  imul eax, ebx
  push eax
  next

div_:
  pop ebx
  pop eax
  xor edx, edx
  div ebx
  push eax
  next

mod_:
  pop ebx
  pop eax
  xor edx, edx
  div ebx
  push edx
  next

and_:
  pop eax
  and [esp], eax
  next

or_:
  pop eax
  or [esp], eax
  next

eqz_:
  pop ebx
  xor eax, eax
  test ebx, ebx
  sete al
  push eax
  next

lt_:
  pop ecx
  pop ebx
  xor eax, eax
  cmp ebx, ecx
  setl al
  push eax
  next

gt_:
  pop ecx
  pop ebx
  xor eax, eax
  cmp ebx, ecx
  setg al
  push eax
  next

whenz_:
  lodsd
  pop ebx
  test ebx, ebx
  jz .noop
  lea esi, [esi+eax*4] ; branch jmp distance is in cells
.noop:
  next

%macro defs 1
s%1_:
  mov eax, [esp+4*%1]
  push eax
  next
%endmacro

defs 0
defs 1
defs 2
defs 3
defs 4
defs 5

section .data

; header format:
; dd next ; pointer to next entry in dict.
; db rep 12 name ; 8 bytes with the name, 0 padded.
; dd flags ; 4 bytes of metadata, like immediate
; dd interpreter ; pointer to native code, usually nest
; dd a, b, c, d, ... ; data

%macro mkwsi 3
%1_entry:
  dd last_in_dict
%1_name:
  db %2
  times %1_name+12-$ db 0
  dd %3 ; flags
%1:
%define last_in_dict %1_entry
%endmacro

%macro mkws 2
  mkwsi %1, %2, 0
%endmacro

%macro mkw 1
  mkws %1,%str(%1)
%endmacro

%macro mknw 1
  mkw %1
  dd %1_
%endmacro

%macro mknws 2
  mkws %1, %2
  dd %1_
%endmacro

%define last_in_dict 0

mknw exit
mknw nest
mknw unnest
mknw call
mknw tail
mknws read, '@'
mknws readb, '@b'
mknws write,'!'
mknws writeb,'!b'
mknw putc
mknw getc
mknw push
mknw drop
mknw dup
mknw swap
mknw over
mknw nip
mknws add, '+'
mknws sub, '-'
mknws mul, '*'
mknws div, '/'
mknws mod, '%'
mknw and
mknw or
mknw eqz
mknws lt, '<'
mknws gt, '>'
mknw whenz
mknw s0
mknw s1
mknw s2
mknw s3
mknw s4
mknw s5

mkw main   
  dd outer, exit

mkw printnya
  dd nest_
  dd push, `\n`, push, '!', push, 'a', push, 'y', push, 'n'
  dd putc, putc, putc, putc, putc, unnest

mkw here
  dd nest_, push, .here_addr, unnest
.here_addr:
  dd base

mkw cells
  dd nest_, push, 4, mul, unnest

mkw cell
  dd nest_, push, 4, unnest

mkws comma, ','
  dd nest_, here, read, write
  dd here, read, cell, add, here, write, unnest

mkw eq
  dd nest_, sub, eqz, unnest

mkw zerobuf
  dd nest_, push, 0, swap, over, over, over, over
  dd write, cell, add, write, push, 2, cells, add, write, unnest

mkw notwhite
  dd nest_, dup, push, ' ', eq, eqz
  dd over, push, `\t`, eq, eqz, and
  dd swap, push, `\n`, eq, eqz, and, unnest

mkw readword
  dd nest_, push, _buf, zerobuf, _skipwhite, push, 0, _readword, push, _buf, unnest
_skipwhite:
  dd nest_, _readc, notwhite, whenz, 2, tail, _skipwhite, unnest
_readword:
  dd nest_, dup, _lastc, _appbuf
  dd push, 1, add, dup, push, 11, sub
  dd whenz, 2, drop, unnest
  dd _readc, notwhite, whenz, 2, drop, unnest, tail, _readword
_appbuf: ; idx, char
  dd nest_, swap, push, _buf, add, writeb, unnest
_readc:
  dd nest_, getc, dup, push, _lastcbuf, writeb, unnest
_lastc:
  dd nest_, push, _lastcbuf, readb, unnest
_lastcbuf:
  db 0,0,0,0
_buf:
  db 0,0,0,0,0,0,0,0,0,0,0,0

mkw streq
  dd nest_, over, read, over, read, eq
  dd s2, cell, add, read, s2, cell, add, read, eq, and
  dd s2, push, 2, cells, add, read, s2, push, 2, cells, add, read, eq, and
  dd nip, nip, unnest

mkw lookup ; ptr to 12 bytes word -- pointer to start of header
  dd nest_, dicthead, read, _lookupl, unnest
_lookupl: ; ptr to 12 bytes word, ptr to header -- 
  dd nest_, dup, whenz, 5, drop, drop, push, 0, unnest
  dd over, over, _entryreq, whenz, 3, read, tail, _lookupl
  dd nip, unnest
_entryreq:
  dd nest_, cell, add, streq, unnest

mkws gotocode, '>code'
  dd nest_, push, 5, cells, add, unnest

mkws gotoflags, '>flags'
  dd nest_, push, 4, cells, add, unnest

mkw isimm
  dd nest_, gotoflags, read, push, 1, and, unnest

mkw isdigit
  dd nest_, dup
  dd push, '0', lt
  dd swap, push, '9', gt, or, eqz
  dd unnest

mkw asnum 
  dd nest_, push, 0, _asnum_loop, unnest
_asnum_loop: ; ptr to next, acc -- num
  dd nest_, over, readb, dup, whenz, 3, drop, nip, unnest
  dd push, '0', sub, swap, push, 10, mul, add
  dd swap, push, 1, add, swap, tail, _asnum_loop

mkw tostr ; num -- strptr
  dd nest_, push, _tostr_buf, zerobuf
  dd push, _tostr_buf+10, swap, _tostr_loop, unnest
_tostr_loop:
  dd nest_, dup, push, 10, mod, push, '0', add, s2, writeb
  dd push, 10, div, dup, whenz, 2, drop, unnest
  dd swap, push, 1, sub, swap
  dd tail, _tostr_loop
_tostr_buf:
  times 12 db 0

mkw puts
  dd nest_, dup, readb, whenz, 2, drop, unnest
  dd dup, readb, putc
  dd push, 1, add, tail, puts

mkws quote, "'"
  dd nest_, readword, lookup, gotocode, unnest

mkws colon, ":"
  dd nest_
  dd dicthead, dup, read, swap, here, read, swap, write, comma
  dd readword, dup, dup
  dd read, comma
  dd cell, add, read, comma
  dd push, 2, cells, add, read, comma
  dd push, 0, comma
  dd push, nest_, comma
  dd push, 1, outermode, write
  dd unnest

mkwsi semi, ";", 1
  dd nest_, push, unnest, comma
  dd push, 0, outermode, write, unnest

mkw outermode
  dd nest_, push, _outermode, unnest
_outermode:
  dd 0

mkw callword
  dd nest_, readword, dup, readb, isdigit
  dd whenz, 4, lookup, gotocode, call, unnest
  dd asnum, unnest

mkw compileword
  dd nest_, readword, dup, readb, isdigit, eqz
  dd whenz, 6, push, push, comma, asnum, comma, unnest
  dd lookup, dup, isimm
  dd whenz, 3, gotocode, comma, unnest
  dd gotocode, call, unnest

mkw outer
  dd nest_, outermode, read
  dd whenz, 3, callword, tail, outer
  dd compileword, tail, outer

mkw dicthead
  dd nest_, push, _dicthead, unnest
_dicthead:
  dd last_in_dict

section .bss
base:
resb 0x10000
base_end:

