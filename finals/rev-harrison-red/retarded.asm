.section .data
hello_world:
    .asciz "Hello, World!\n"

.section .text
.globl _start

unswitch_thumb:
	mov r10, lr
	sub r10, #1
	blx r10

switch_thumb:
	mov r10, lr
	add r10, #1
	blx r10

_start:
	ldr r10, =myprint2
		// break ida decompilation
		push {r10}
		pop {r10}
		// opaque predicate for ghidra
		mul r11, r12, r12
		add r11, r12
		ands r11, r11, #1
		beq .+8  // always false
			mov r10, r11 // fake ins
		add r10, #5
		bx r10

myprint2:
		// fake intro
		.thumb
		nop // fake ins
		nop // fake ins

	.thumb_func
	ldr r0, =print2
	blx r0

_exit:
	.thumb_func
	b confused
    mov r0, #0              // use 0 as the exit status
    mov r7, #1              // system call number for sys_exit
    svc 0                   // make system call: exit(0)


print2:
	mov r0, #1              // file descriptor 1 (stdout)
	ldr r1, =hello_world    // pointer to the "Hello, World!\n" string
	mov r2, #12             // length of the "Hello, World!\n" string
	mov r7, #4              // system call number for sys_write
	svc 0                   // make system call: write(1, hello_world, 13)
	mov pc, lr

// this thumb code will look like valid 32bit arm code!
// b.+4 gets compiled to "00e0" which in arm is opcode for "and"
// the other two bytes do not really matter
confused:
	.thumb_func
	.force_thumb
	mov r0, r1
	b .+4
	cmp r0, #1
	b .+4
