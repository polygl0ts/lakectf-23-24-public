	.arch armv7-a
	.fpu softvfp
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 6
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"challenge2.c"
	.text
	.global	enc_flag
	.data
	.align	2
	.type	enc_flag, %object
	.size	enc_flag, 38
enc_flag:
	.ascii	"d\347\371\314B\22265J\\p2\244\270\253\352,\302\344t"
	.ascii	"\332\373.\336\207V\310\030AQ\303jH\336m\263\006\000"
	.global	enc_flag2
	.align	2
	.type	enc_flag2, %object
	.size	enc_flag2, 38
enc_flag2:
	.ascii	"1\011C\"\012\362\000\240yhw__ARM'5\\&\014\352\000\244"
	.ascii	"_s3gsUck'9[t\373\000"
	.text
	.align	1
	.global	switch_thumb
	.syntax unified
	.type	switch_thumb, %function
switch_thumb:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	.syntax unified
@ 34 "challenge2.c" 1
	mov r10, lr
	 add r10, #1
	 blx r10
@ 0 "" 2
	.syntax unified
	nop
	bx	lr
	.size	switch_thumb, .-switch_thumb
	.align	1
	.global	unswitch_thumb
	.syntax unified
	.type	unswitch_thumb, %function
unswitch_thumb:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	.syntax unified
@ 38 "challenge2.c" 1
	mov r10, lr
	 sub r10, #1
	 blx r10
@ 0 "" 2
	.syntax unified
	nop
	bx	lr
	.size	unswitch_thumb, .-unswitch_thumb
	.align	1
	.global	write
	.syntax unified
	.type	write, %function
write:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r4, r5, r6, r7}
	sub	sp, sp, #24
	str	r0, [sp, #12]
	str	r1, [sp, #8]
	str	r2, [sp, #4]
	ldr	r3, [sp, #12]
	ldr	r4, [sp, #8]
	ldr	r5, [sp, #4]
	movs	r6, #4
	.syntax unified
@ 43 "challenge2.c" 1
	mov r0, r3
mov r1, r4
mov r2, r5
mov r7, r6
svc 0x00000000
mov r3, r0

@ 0 "" 2
	.syntax unified
	str	r3, [sp, #20]
	ldr	r3, [sp, #20]
	mov	r0, r3
	add	sp, sp, #24
	@ sp needed
	pop	{r4, r5, r6, r7}
	bx	lr
	.size	write, .-write
	.align	1
	.global	read
	.syntax unified
	.type	read, %function
read:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r4, r5, r6}
	sub	sp, sp, #28
	str	r0, [sp, #12]
	str	r1, [sp, #8]
	str	r2, [sp, #4]
	ldr	r3, [sp, #12]
	ldr	r4, [sp, #8]
	ldr	r5, [sp, #4]
	movs	r6, #3
	.syntax unified
@ 59 "challenge2.c" 1
	mov r0, r3
mov r1, r4
mov r2, r5
mov r7, r6
svc 0x00000000
mov r3, r0

@ 0 "" 2
	.syntax unified
	str	r3, [sp, #20]
	ldr	r3, [sp, #20]
	mov	r0, r3
	add	sp, sp, #28
	@ sp needed
	pop	{r4, r5, r6}
	bx	lr
	.size	read, .-read
	.align	1
	.global	exit
	.syntax unified
	.type	exit, %function
exit:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	sub	sp, sp, #8
	str	r0, [sp, #4]
	ldr	r3, [sp, #4]
	movs	r2, #1
	.syntax unified
@ 75 "challenge2.c" 1
	mov r0, r3
mov r7, r2
svc 0x00000000

@ 0 "" 2
	.syntax unified
	nop
	add	sp, sp, #8
	@ sp needed
	bx	lr
	.size	exit, .-exit
	.align	1
	.global	strlen
	.syntax unified
	.type	strlen, %function
strlen:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	sub	sp, sp, #16
	str	r0, [sp, #4]
	mov	r3, #-1
	str	r3, [sp, #12]
.L11:
	ldr	r3, [sp, #12]
	adds	r3, r3, #1
	str	r3, [sp, #12]
	ldr	r3, [sp, #12]
	ldr	r2, [sp, #4]
	add	r3, r3, r2
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	bne	.L11
	ldr	r3, [sp, #12]
	mov	r0, r3
	add	sp, sp, #16
	@ sp needed
	bx	lr
	.size	strlen, .-strlen
	.align	1
	.global	memset
	.syntax unified
	.type	memset, %function
memset:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	sub	sp, sp, #24
	str	r0, [sp, #12]
	str	r1, [sp, #8]
	str	r2, [sp, #4]
	ldr	r3, [sp, #12]
	str	r3, [sp, #20]
	b	.L14
.L15:
	ldr	r3, [sp, #20]
	adds	r2, r3, #1
	str	r2, [sp, #20]
	ldr	r2, [sp, #8]
	uxtb	r2, r2
	strb	r2, [r3]
.L14:
	ldr	r3, [sp, #4]
	subs	r2, r3, #1
	str	r2, [sp, #4]
	cmp	r3, #0
	bne	.L15
	ldr	r3, [sp, #12]
	mov	r0, r3
	add	sp, sp, #24
	@ sp needed
	bx	lr
	.size	memset, .-memset
	.align	1
	.global	memcmp
	.syntax unified
	.type	memcmp, %function
memcmp:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	sub	sp, sp, #24
	str	r0, [sp, #12]
	str	r1, [sp, #8]
	str	r2, [sp, #4]
	movs	r3, #0
	str	r3, [sp, #20]
	movs	r3, #0
	str	r3, [sp, #16]
	b	.L18
.L20:
	ldr	r3, [sp, #16]
	ldr	r2, [sp, #12]
	add	r3, r3, r2
	ldrb	r2, [r3]	@ zero_extendqisi2
	ldr	r3, [sp, #16]
	ldr	r1, [sp, #8]
	add	r3, r3, r1
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r2, r3
	beq	.L19
	movs	r3, #1
	str	r3, [sp, #20]
.L19:
	ldr	r3, [sp, #16]
	adds	r3, r3, #1
	str	r3, [sp, #16]
.L18:
	ldr	r2, [sp, #16]
	ldr	r3, [sp, #4]
	cmp	r2, r3
	blt	.L20
	ldr	r3, [sp, #20]
	mov	r0, r3
	add	sp, sp, #24
	@ sp needed
	bx	lr
	.size	memcmp, .-memcmp
	.align	1
	.global	obfuscate
	.syntax unified
	.type	obfuscate, %function
obfuscate:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{lr}
	sub	sp, sp, #20
	str	r0, [sp, #4]
	movs	r3, #0
	str	r3, [sp, #12]
	b	.L23
.L24:
	bl	switch_thumb
	.syntax unified
@ 111 "challenge2.c" 1
	.thumb
@ 0 "" 2
	.syntax unified
	ldr	r3, [sp, #12]
	ldr	r2, [sp, #4]
	add	r3, r3, r2
	ldrb	r2, [r3]	@ zero_extendqisi2
	ldr	r3, [sp, #12]
	uxtb	r3, r3
	mov	r1, r3
	lsls	r1, r1, #1
	add	r3, r3, r1
	mov	r1, r3
	lsls	r1, r1, #3
	subs	r3, r1, r3
	lsls	r3, r3, #1
	uxtb	r3, r3
	add	r3, r3, r2
	uxtb	r3, r3
	sxtb	r2, r3
	ldr	r3, [sp, #12]
	uxtb	r3, r3
	adds	r3, r3, #3
	uxtb	r3, r3
	sxtb	r3, r3
	eors	r3, r3, r2
	sxtb	r1, r3
	ldr	r3, [sp, #12]
	ldr	r2, [sp, #4]
	add	r3, r3, r2
	uxtb	r2, r1
	strb	r2, [r3]
	ldr	r3, [sp, #12]
	ldr	r2, [sp, #4]
	add	r3, r3, r2
	ldrb	r3, [r3]	@ zero_extendqisi2
	sxtb	r3, r3
	lsls	r3, r3, #4
	sxtb	r2, r3
	ldr	r3, [sp, #12]
	ldr	r1, [sp, #4]
	add	r3, r3, r1
	ldrb	r3, [r3]	@ zero_extendqisi2
	lsrs	r3, r3, #4
	uxtb	r3, r3
	sxtb	r3, r3
	orrs	r3, r3, r2
	sxtb	r1, r3
	ldr	r3, [sp, #12]
	ldr	r2, [sp, #4]
	add	r3, r3, r2
	uxtb	r2, r1
	strb	r2, [r3]
	.syntax unified
@ 114 "challenge2.c" 1
	.align 2
@ 0 "" 2
	.syntax unified
	bl	unswitch_thumb
	.syntax unified
@ 114 "challenge2.c" 1
	.arm
@ 0 "" 2
	.syntax unified
	ldr	r3, [sp, #12]
	adds	r3, r3, #1
	str	r3, [sp, #12]
.L23:
	ldr	r3, [sp, #12]
	cmp	r3, #36
	ble	.L24
	nop
	nop
	add	sp, sp, #20
	@ sp needed
	ldr	pc, [sp], #4
	.size	obfuscate, .-obfuscate
	.align	1
	.global	puts
	.syntax unified
	.type	puts, %function
puts:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{lr}
	sub	sp, sp, #12
	str	r0, [sp, #4]
	ldr	r0, [sp, #4]
	bl	strlen
	mov	r3, r0
	mov	r2, r3
	ldr	r1, [sp, #4]
	movs	r0, #1
	bl	write
	nop
	add	sp, sp, #12
	@ sp needed
	ldr	pc, [sp], #4
	.size	puts, .-puts
	.syntax unified
	.ascii "PORCODIO"
mymul:
  .thumb
	sub	sp, sp, #16
b .+4
	str	r0, [sp, #4]
b .+4
	str	r1, [sp]
b .+4
	movs	r3, #0
b .+4
	str	r3, [sp, #12]
b .+4
	b	.AL27
b .+4
  .thumb
.AL29:
  .thumb
	ldr	r3, [sp]
b .+4
	and	r3, r3, #1
b .+4
	cmp	r3, #0
b .+4
	beq	.AL28
b .+4
	ldr	r2, [sp, #12]
b .+4
	ldr	r3, [sp, #4]
b .+4
	add	r3, r3, r2
b .+4
	str	r3, [sp, #12]
b .+4
  .thumb
.AL28:
  .thumb
	ldr	r3, [sp, #4]
b .+4
	lsls	r3, r3, #1
b .+4
	str	r3, [sp, #4]
b .+4
	ldr	r3, [sp]
b .+4
	lsrs	r3, r3, #1
b .+4
	str	r3, [sp]
b .+4
.AL27:
	ldr	r3, [sp]
b .+4
	cmp	r3, #0
b .+4
	bne	.AL29
b .+4
	ldr	r3, [sp, #12]
b .+4
	mov	r0, r3
b .+4
	add	sp, sp, #16
b .+4
	@ sp needed
	bx	lr
.ascii "PORCODIO"
.arm

	.syntax unified
	.global	fixed_input_one
	.data
	.align	2
	.type	fixed_input_one, %object
	.size	fixed_input_one, 1636
fixed_input_one:
	.word	-235278762
	.word	1419798687
	.word	-11486017
	.word	-1841168372
	.word	-500357890
	.word	-1676149162
	.word	793880080
	.word	512480602
	.word	-1657507289
	.word	-1656652315
	.word	-544981229
	.word	-1962658800
	.word	1418151414
	.word	1671787213
	.word	906541375
	.word	-1037571472
	.word	-604315650
	.word	-1646701571
	.word	-276131033
	.word	171123787
	.word	-467769534
	.word	395260903
	.word	1722998074
	.word	1910002510
	.word	1391317861
	.word	1724933717
	.word	-26018871
	.word	1966549226
	.word	-1495179367
	.word	713779922
	.word	828008944
	.word	-511162539
	.word	1512977522
	.word	283329441
	.word	342913424
	.word	1341292380
	.word	-399690670
	.word	959696281
	.word	1281773242
	.word	508719612
	.word	530342030
	.word	698190811
	.word	558554447
	.word	-745312762
	.word	-1654836470
	.word	-619156483
	.word	-631891589
	.word	-1446480304
	.word	-708014666
	.word	-646242962
	.word	1348238921
	.word	-833863043
	.word	1383372183
	.word	-535910682
	.word	468328841
	.word	1102873428
	.word	967835552
	.word	-79973326
	.word	-86753206
	.word	641549996
	.word	25511238
	.word	252002590
	.word	-575212800
	.word	2011703281
	.word	-174197248
	.word	1242921441
	.word	-673007551
	.word	-409319026
	.word	247236671
	.word	-236710241
	.word	1182954723
	.word	-1829469301
	.word	815523875
	.word	-596392076
	.word	512975922
	.word	1277831540
	.word	1653434471
	.word	109961675
	.word	2036870373
	.word	-910144359
	.word	-54820440
	.word	-33038015
	.word	1441560607
	.word	-1055133316
	.word	1211653712
	.word	-611928037
	.word	-952862928
	.word	1456686747
	.word	-1249745944
	.word	1779273153
	.word	624343117
	.word	-40749902
	.word	-144806989
	.word	-1182632879
	.word	1641998077
	.word	416957496
	.word	1093855065
	.word	-1185067357
	.word	-1056426813
	.word	-1471048484
	.word	801947726
	.word	1039622914
	.word	1102021502
	.word	-1922562227
	.word	168276535
	.word	39161252
	.word	-1001204981
	.word	1836437669
	.word	926308618
	.word	-1687575157
	.word	-29199617
	.word	205634481
	.word	1872032372
	.word	862187438
	.word	1757204024
	.word	77880761
	.word	-711000622
	.word	1731480045
	.word	-1189370242
	.word	529128162
	.word	1229832956
	.word	-257767217
	.word	1114674863
	.word	1737376979
	.word	-766401253
	.word	805854329
	.word	1105127498
	.word	607533220
	.word	-1422660181
	.word	1179784225
	.word	-1708615888
	.word	741097972
	.word	1155988646
	.word	619591590
	.word	-612227644
	.word	1587972678
	.word	131976020
	.word	1223734224
	.word	-44661328
	.word	883061706
	.word	1312567513
	.word	-1033630496
	.word	-644054695
	.word	1077320742
	.word	607018389
	.word	-2084525603
	.word	-966764297
	.word	-1134462493
	.word	1053825364
	.word	-1447594196
	.word	-954715655
	.word	-201668664
	.word	1937766225
	.word	1417385276
	.word	-200228012
	.word	-377852091
	.word	1534982678
	.word	175054570
	.word	1811089332
	.word	1238969803
	.word	1069357579
	.word	-1212097842
	.word	-1644127681
	.word	606538312
	.word	750633203
	.word	850092021
	.word	1846124039
	.word	-1733362716
	.word	-510084026
	.word	-95821927
	.word	1491655647
	.word	-825841705
	.word	-1722456550
	.word	1092643419
	.word	2116406704
	.word	2018650160
	.word	-1186414333
	.word	-66273134
	.word	-1134201665
	.word	828809584
	.word	798486168
	.word	1783995809
	.word	-299442489
	.word	-1245082978
	.word	899901031
	.word	355016769
	.word	183057645
	.word	-477862065
	.word	-1066392120
	.word	-676784584
	.word	-1838080561
	.word	-1354209095
	.word	-1006823714
	.word	-148024028
	.word	-1334690354
	.word	-81702256
	.word	-505622095
	.word	1035482603
	.word	-1538256332
	.word	-894137972
	.word	-1190660142
	.word	-1400841224
	.word	-2110223156
	.word	1165112540
	.word	195814007
	.word	-294157997
	.word	-613495525
	.word	1466436696
	.word	1549016368
	.word	-480836768
	.word	869743924
	.word	-1431988947
	.word	-71709041
	.word	758350793
	.word	73272414
	.word	84633243
	.word	-1923490890
	.word	-691624820
	.word	-1442059950
	.word	1992569375
	.word	-1944037573
	.word	-1942211033
	.word	499476798
	.word	-61628540
	.word	-880025620
	.word	805218863
	.word	-1667292497
	.word	-779518787
	.word	1005813917
	.word	-354569500
	.word	-780533633
	.word	1201215130
	.word	-1999691673
	.word	-1182771717
	.word	55533390
	.word	-2097807073
	.word	1126521385
	.word	-179617403
	.word	-562137376
	.word	1347220249
	.word	1328530413
	.word	-1985689973
	.word	2088965411
	.word	1941938802
	.word	-321865368
	.word	-1437608300
	.word	1931708401
	.word	1310478070
	.word	-1182409739
	.word	1750946929
	.word	-414671993
	.word	-1820165739
	.word	815717855
	.word	549996563
	.word	-1612261115
	.word	2081108710
	.word	487448878
	.word	-473953182
	.word	-423084367
	.word	1830969541
	.word	550272498
	.word	-845663254
	.word	2043576181
	.word	1275012189
	.word	-566303875
	.word	1472762857
	.word	102457817
	.word	-1941467169
	.word	-297504165
	.word	2040204335
	.word	1154097357
	.word	841398853
	.word	2127625049
	.word	-349350611
	.word	1708814409
	.word	-1259160113
	.word	-235278762
	.word	1419798687
	.word	-11486017
	.word	-1841168372
	.word	-500357890
	.word	-1676149162
	.word	793880080
	.word	512480602
	.word	-1657507289
	.word	-1656652315
	.word	-544981229
	.word	-1962658800
	.word	1418151414
	.word	1671787213
	.word	906541375
	.word	-1037571472
	.word	-604315650
	.word	-1646701571
	.word	-276131033
	.word	171123787
	.word	-467769534
	.word	395260903
	.word	1722998074
	.word	1910002510
	.word	1391317861
	.word	1724933717
	.word	-26018871
	.word	1966549226
	.word	-1495179367
	.word	713779922
	.word	828008944
	.word	-511162539
	.word	1512977522
	.word	283329441
	.word	342913424
	.word	1341292380
	.word	-399690670
	.word	959696281
	.word	1281773242
	.word	508719612
	.word	530342030
	.word	698190811
	.word	558554447
	.word	-745312762
	.word	-1654836470
	.word	-619156483
	.word	-631891589
	.word	-1446480304
	.word	-708014666
	.word	-646242962
	.word	1348238921
	.word	-833863043
	.word	1383372183
	.word	-535910682
	.word	468328841
	.word	1102873428
	.word	967835552
	.word	-79973326
	.word	-86753206
	.word	641549996
	.word	25511238
	.word	252002590
	.word	-575212800
	.word	2011703281
	.word	-174197248
	.word	1242921441
	.word	-673007551
	.word	-409319026
	.word	247236671
	.word	-236710241
	.word	1182954723
	.word	-1829469301
	.word	815523875
	.word	-596392076
	.word	512975922
	.word	1277831540
	.word	1653434471
	.word	109961675
	.word	2036870373
	.word	-910144359
	.word	-54820440
	.word	-33038015
	.word	1441560607
	.word	-1055133316
	.word	1211653712
	.word	-611928037
	.word	-952862928
	.word	1456686747
	.word	-1249745944
	.word	1779273153
	.word	624343117
	.word	-40749902
	.word	-144806989
	.word	-1182632879
	.word	1641998077
	.word	416957496
	.word	1093855065
	.word	-1185067357
	.word	-1056426813
	.word	-1471048484
	.word	801947726
	.word	1039622914
	.word	1102021502
	.word	-1922562227
	.word	168276535
	.word	39161252
	.word	-1001204981
	.word	1836437669
	.word	926308618
	.word	-1687575157
	.word	-29199617
	.word	205634481
	.word	1872032372
	.word	862187438
	.word	1757204024
	.word	77880761
	.word	-711000622
	.word	1731480045
	.word	-1189370242
	.word	529128162
	.word	1229832956
	.word	-257767217
	.word	1114674863
	.word	1737376979
	.word	-766401253
	.word	-766401253
	.word	-766401253
	.word	-766401253
	.word	-766401253
	.word	-766401253
	.word	-766401253
	.word	-766401253
	.word	-766401253
	.global	three_final_result
	.bss
	.align	2
	.type	three_final_result, %object
	.size	three_final_result, 2960
three_final_result:
	.space	2960
	.global	new_switch
	.align	2
	.type	new_switch, %object
	.size	new_switch, 4
new_switch:
	.space	4
	.section	.rodata
	.align	2
.LC0:
	.ascii	"\361\371\356VT\240h\237\377P\274\277\222B\000\014\342"
	.ascii	"-$\376\234\027\376V/Q\246\020\036\213\325Z\2354r'\235"
	.text
	.align	1
	.global	stage_three
	.syntax unified
	.type	stage_three, %function
stage_three:
	@ args = 0, pretend = 0, frame = 96
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, lr}
	sub	sp, sp, #100
	add	r3, sp, #40
	movs	r2, #41
	movs	r1, #0
	mov	r0, r3
	bl	memset
	movw	r3, #:lower16:.LC0
	movt	r3, #:upper16:.LC0
	mov	r4, sp
	mov	r5, r3
	ldmia	r5!, {r0, r1, r2, r3}
	stmia	r4!, {r0, r1, r2, r3}
	ldmia	r5!, {r0, r1, r2, r3}
	stmia	r4!, {r0, r1, r2, r3}
	ldm	r5, {r0, r1}
	str	r0, [r4]
	adds	r4, r4, #4
	strb	r1, [r4]
	add	r3, sp, #40
	movs	r2, #37
	mov	r1, r3
	movs	r0, #0
	bl	read
	movs	r3, #0
	str	r3, [sp, #88]
	movs	r3, #0
	str	r3, [sp, #92]
	b	.L27
.L30:
	ldr	r3, [sp, #92]
	adds	r2, r3, #7
	cmp	r3, #0
	ite	lt
	movlt	r3, r2
	movge	r3, r3
	asrs	r3, r3, #3
	adds	r3, r3, #96
	add	r3, sp, r3
	ldrb	r3, [r3, #-56]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r3, [sp, #92]
	and	r3, r3, #7
	movs	r2, #1
	lsl	r3, r2, r3
	ands	r3, r3, r1
	str	r3, [sp, #84]
	ldr	r3, [sp, #84]
	cmp	r3, #0
	beq	.L28
	movw	r3, #:lower16:mymul
	movt	r3, #:upper16:mymul
	adds	r2, r3, #1
	movw	r3, #:lower16:new_switch
	movt	r3, #:upper16:new_switch
	str	r2, [r3]
	b	.L29
.L28:
	movw	r3, #:lower16:new_switch
	movt	r3, #:upper16:new_switch
	movw	r2, #:lower16:mymul
	movt	r2, #:upper16:mymul
	str	r2, [r3]
.L29:
	movw	r3, #:lower16:new_switch
	movt	r3, #:upper16:new_switch
	ldr	r2, [r3]
	movw	r3, #:lower16:fixed_input_one
	movt	r3, #:upper16:fixed_input_one
	ldr	r1, [sp, #92]
	ldr	r0, [r3, r1, lsl #2]
	ldr	r3, [sp, #92]
	adds	r1, r3, #1
	movw	r3, #:lower16:fixed_input_one
	movt	r3, #:upper16:fixed_input_one
	ldr	r3, [r3, r1, lsl #2]
	mov	r1, r3
	blx	r2
	str	r0, [sp, #88]
	movw	r3, #:lower16:three_final_result
	movt	r3, #:upper16:three_final_result
	ldr	r2, [sp, #92]
	ldr	r1, [sp, #88]
	str	r1, [r3, r2, lsl #2]
	ldr	r3, [sp, #92]
	adds	r3, r3, #1
	str	r3, [sp, #92]
.L27:
	ldr	r3, [sp, #92]
	cmp	r3, #296
	blt	.L30
	movs	r2, #37
	movw	r1, #:lower16:three_final_result
	movt	r1, #:upper16:three_final_result
	movs	r0, #1
	bl	write
	nop
	add	sp, sp, #100
	@ sp needed
	pop	{r4, r5, pc}
	.size	stage_three, .-stage_three
	.align	1
	.global	check_flag
	.syntax unified
	.type	check_flag, %function
check_flag:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{lr}
	sub	sp, sp, #12
	str	r0, [sp, #4]
	bl	switch_thumb
	.syntax unified
@ 262 "challenge2.c" 1
	.thumb
@ 0 "" 2
	.syntax unified
	ldr	r0, [sp, #4]
	bl	obfuscate
	.syntax unified
@ 266 "challenge2.c" 1
	.align 2
@ 0 "" 2
	.syntax unified
	bl	unswitch_thumb
	.syntax unified
@ 266 "challenge2.c" 1
	.arm
@ 0 "" 2
	.syntax unified
	movs	r2, #37
	ldr	r1, [sp, #4]
	movw	r0, #:lower16:enc_flag
	movt	r0, #:upper16:enc_flag
	bl	memcmp
	mov	r3, r0
	cmp	r3, #0
	ite	eq
	moveq	r3, #1
	movne	r3, #0
	uxtb	r3, r3
	mov	r0, r3
	add	sp, sp, #12
	@ sp needed
	ldr	pc, [sp], #4
	.size	check_flag, .-check_flag
	.syntax unified
	fake_func2:
   str	r0, [sp, #4]
   ldr	r2, [sp, #4]
   movw	r3, #22136
   movt	r3, 4660
   eors	r3, r3, r2
   mov	r0, r3
   add	sp, sp, #8
func1:
   .thumb
   add r0, #1
   sub	sp, sp, #8
   str	r0, [sp, #4]
   ldr	r2, [sp, #4]
   movw	r3, #22136
   movt	r3, 4660
   eors	r3, r3, r2
   mov	r0, r3
   add	sp, sp, #8
   @ sp needed
   bx	lr
   .align 2
   .arm

	.syntax unified
	.align	1
	.global	func2
	.syntax unified
	.type	func2, %function
func2:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	sub	sp, sp, #16
	str	r0, [sp, #4]
	ldr	r2, [sp, #4]
	movw	r3, #22136
	movt	r3, 4660
	subs	r3, r3, r2
	str	r3, [sp, #12]
	ldr	r3, [sp, #12]
	mov	r0, r3
	add	sp, sp, #16
	@ sp needed
	bx	lr
	.size	func2, .-func2
	.align	1
	.global	func3
	.syntax unified
	.type	func3, %function
func3:
	@ args = 0, pretend = 0, frame = 32
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	sub	sp, sp, #32
	str	r0, [sp, #4]
	ldr	r3, [sp, #4]
	uxtb	r3, r3
	str	r3, [sp, #28]
	ldr	r3, [sp, #4]
	lsrs	r3, r3, #8
	uxtb	r3, r3
	str	r3, [sp, #24]
	ldr	r3, [sp, #4]
	lsrs	r3, r3, #16
	uxtb	r3, r3
	str	r3, [sp, #20]
	ldr	r3, [sp, #4]
	lsrs	r3, r3, #24
	str	r3, [sp, #16]
	movs	r3, #0
	str	r3, [sp, #12]
	ldr	r3, [sp, #28]
	lsls	r2, r3, #24
	ldr	r3, [sp, #24]
	lsls	r3, r3, #16
	add	r2, r2, r3
	ldr	r3, [sp, #20]
	lsls	r3, r3, #8
	add	r3, r3, r2
	ldr	r2, [sp, #16]
	add	r3, r3, r2
	str	r3, [sp, #12]
	ldr	r3, [sp, #12]
	mov	r0, r3
	add	sp, sp, #32
	@ sp needed
	bx	lr
	.size	func3, .-func3
	.section	.rodata
	.align	2
.LC1:
	.ascii	"Not so bad, but what about now?\012\000"
	.align	2
.LC2:
	.ascii	"Correct!\012\000"
	.align	2
.LC3:
	.ascii	"Sorry, try again.\012\000"
	.text
	.align	1
	.global	stage_two
	.syntax unified
	.type	stage_two, %function
stage_two:
	@ args = 0, pretend = 0, frame = 224
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, lr}
	sub	sp, sp, #228
	add	r3, sp, #168
	movs	r2, #41
	movs	r1, #0
	mov	r0, r3
	bl	memset
	add	r3, sp, #4
	movs	r2, #164
	movs	r1, #0
	mov	r0, r3
	bl	memset
	movw	r0, #:lower16:.LC1
	movt	r0, #:upper16:.LC1
	bl	puts
	add	r3, sp, #168
	movs	r2, #37
	mov	r1, r3
	movs	r0, #0
	bl	read
	movs	r3, #0
	str	r3, [sp, #220]
	b	.L38
.L43:
	ldr	r3, [sp, #220]
	lsls	r3, r3, #2
	add	r2, sp, #168
	add	r3, r3, r2
	ldr	r3, [r3]
	str	r3, [sp, #212]
	ldr	r3, [sp, #220]
	and	r3, r3, #3
	cmp	r3, #0
	bne	.L39
	ldr	r7, [sp, #212]
	.syntax unified
@ 348 "challenge2.c" 1
	mov r0, r7
ldr r10, =func1
push {r10}
pop {r10}
// opaque predicate for ghidra
mul r11, r12, r12
add r11, r12
ands r11, r11, #1
beq .+12  // always false
    add r10, r10, #27
    ldr r10, =fake_func2
add r10, #5
blx r10
mov r7, r0

@ 0 "" 2
	.syntax unified
	ldr	r3, [sp, #220]
	lsls	r3, r3, #2
	adds	r3, r3, #224
	add	r3, sp, r3
	str	r7, [r3, #-220]
.L39:
	ldr	r3, [sp, #220]
	rsbs	r2, r3, #0
	and	r3, r3, #3
	and	r2, r2, #3
	it	pl
	rsbpl	r3, r2, #0
	cmp	r3, #1
	bne	.L40
	ldr	r3, [sp, #212]
	mov	r0, r3
	bl	func2
	mov	r2, r0
	ldr	r3, [sp, #220]
	lsls	r3, r3, #2
	adds	r3, r3, #224
	add	r3, sp, r3
	str	r2, [r3, #-220]
.L40:
	ldr	r3, [sp, #220]
	rsbs	r2, r3, #0
	and	r3, r3, #3
	and	r2, r2, #3
	it	pl
	rsbpl	r3, r2, #0
	cmp	r3, #2
	bne	.L41
	ldr	r3, [sp, #212]
	mov	r0, r3
	bl	func3
	mov	r2, r0
	ldr	r3, [sp, #220]
	lsls	r3, r3, #2
	adds	r3, r3, #224
	add	r3, sp, r3
	str	r2, [r3, #-220]
.L41:
	ldr	r3, [sp, #220]
	rsbs	r2, r3, #0
	and	r3, r3, #3
	and	r2, r2, #3
	it	pl
	rsbpl	r3, r2, #0
	cmp	r3, #3
	bne	.L42
	ldr	r3, [sp, #220]
	lsls	r3, r3, #2
	adds	r3, r3, #224
	add	r3, sp, r3
	ldr	r2, [sp, #212]
	str	r2, [r3, #-220]
.L42:
	ldr	r3, [sp, #220]
	adds	r3, r3, #1
	str	r3, [sp, #220]
.L38:
	ldr	r3, [sp, #220]
	cmp	r3, #9
	ble	.L43
	add	r3, sp, #4
	movs	r2, #37
	mov	r1, r3
	movw	r0, #:lower16:enc_flag2
	movt	r0, #:upper16:enc_flag2
	bl	memcmp
	str	r0, [sp, #216]
	ldr	r3, [sp, #216]
	cmp	r3, #0
	bne	.L44
	movw	r0, #:lower16:.LC2
	movt	r0, #:upper16:.LC2
	bl	puts
	b	.L46
.L44:
	movw	r0, #:lower16:.LC3
	movt	r0, #:upper16:.LC3
	bl	puts
.L46:
	nop
	add	sp, sp, #228
	@ sp needed
	pop	{r4, r5, r6, r7, pc}
	.size	stage_two, .-stage_two
	.section	.rodata
	.align	2
.LC4:
	.ascii	"Enter what you think the following means:\012\000"
	.text
	.align	1
	.global	stage_one
	.syntax unified
	.type	stage_one, %function
stage_one:
	@ args = 0, pretend = 0, frame = 48
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{lr}
	sub	sp, sp, #52
	add	r3, sp, #4
	movs	r2, #38
	movs	r1, #0
	mov	r0, r3
	bl	memset
	movw	r0, #:lower16:.LC4
	movt	r0, #:upper16:.LC4
	bl	puts
	bl	switch_thumb
	.syntax unified
@ 393 "challenge2.c" 1
	.thumb
@ 0 "" 2
	.syntax unified
	add	r3, sp, #4
	movs	r2, #37
	mov	r1, r3
	movs	r0, #0
	bl	read
	add	r3, sp, #4
	mov	r0, r3
	bl	check_flag
	str	r0, [sp, #44]
	.syntax unified
@ 399 "challenge2.c" 1
	.align 2
@ 0 "" 2
	.syntax unified
	bl	unswitch_thumb
	.syntax unified
@ 399 "challenge2.c" 1
	.arm
@ 0 "" 2
	.syntax unified
	ldr	r3, [sp, #44]
	cmp	r3, #0
	beq	.L48
	movw	r0, #:lower16:.LC2
	movt	r0, #:upper16:.LC2
	bl	puts
	bl	stage_two
	b	.L50
.L48:
	movw	r0, #:lower16:.LC3
	movt	r0, #:upper16:.LC3
	bl	puts
.L50:
	nop
	add	sp, sp, #52
	@ sp needed
	ldr	pc, [sp], #4
	.size	stage_one, .-stage_one
	.section	.rodata
	.align	2
.LC5:
	.ascii	"A long, long time ago...\012\000"
	.align	2
.LC6:
	.ascii	"A very powerful magician was popular over his kingd"
	.ascii	"om.\012\000"
	.align	2
.LC7:
	.ascii	"His abilities to understand ARM scrolls was unrival"
	.ascii	"ed.\012\000"
	.align	2
.LC8:
	.ascii	"His signature spell, \033[31;1m\"Disassemble!\"\033"
	.ascii	"[0m, was simply devastating.\012\000"
	.align	2
.LC9:
	.ascii	"\012\000"
	.align	2
.LC10:
	.ascii	"He used to say all the time: ARM scrolls are always"
	.ascii	" aligned, you see? \033[31;1m\"Disassemble!\"\033[0"
	.ascii	"m will never fail!\012\000"
	.align	2
.LC11:
	.ascii	"Consumed by hubris and pride, he thought himself as"
	.ascii	" invincible.\012\000"
	.align	2
.LC12:
	.ascii	"Until one day, Ral, the ancient ARM divinity, grew "
	.ascii	"tired of him and decided to teach him a lesson.\012"
	.ascii	"\000"
	.align	2
.LC13:
	.ascii	"The skies turned red, the animals hid in their nest"
	.ascii	"s. Ral produced a scroll that would stop the magici"
	.ascii	"an.\012\000"
	.align	2
.LC14:
	.ascii	"\"You poor mortal,\" thundered Ral - \"I will break"
	.ascii	" your little spell disassembly in TWO different way"
	.ascii	"s!\"\012\000"
	.align	2
.LC15:
	.ascii	"The magician received a scroll so incomprehensible "
	.ascii	"and confusing, he went insane.\012\000"
	.align	2
.LC16:
	.ascii	"People always wondered, Ral is a fair divinity. He "
	.ascii	"would never give an impossible scroll to anyone. Th"
	.ascii	"ere must have been a way to read it!\000"
	.align	2
.LC17:
	.ascii	"What about you, though? Can you read the scroll, wi"
	.ascii	"thout using \033[31;1m\"Disassemble!\"\033[0m ?\012"
	.ascii	"\012\000"
	.text
	.align	1
	.global	_start
	.syntax unified
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r3, lr}
	movw	r0, #:lower16:.LC5
	movt	r0, #:upper16:.LC5
	bl	puts
	movw	r0, #:lower16:.LC6
	movt	r0, #:upper16:.LC6
	bl	puts
	movw	r0, #:lower16:.LC7
	movt	r0, #:upper16:.LC7
	bl	puts
	movw	r0, #:lower16:.LC8
	movt	r0, #:upper16:.LC8
	bl	puts
	movw	r0, #:lower16:.LC9
	movt	r0, #:upper16:.LC9
	bl	puts
	movw	r0, #:lower16:.LC10
	movt	r0, #:upper16:.LC10
	bl	puts
	movw	r0, #:lower16:.LC11
	movt	r0, #:upper16:.LC11
	bl	puts
	movw	r0, #:lower16:.LC12
	movt	r0, #:upper16:.LC12
	bl	puts
	movw	r0, #:lower16:.LC13
	movt	r0, #:upper16:.LC13
	bl	puts
	movw	r0, #:lower16:.LC14
	movt	r0, #:upper16:.LC14
	bl	puts
	movw	r0, #:lower16:.LC15
	movt	r0, #:upper16:.LC15
	bl	puts
	movw	r0, #:lower16:.LC9
	movt	r0, #:upper16:.LC9
	bl	puts
	movw	r0, #:lower16:.LC16
	movt	r0, #:upper16:.LC16
	bl	puts
	movw	r0, #:lower16:.LC17
	movt	r0, #:upper16:.LC17
	bl	puts
	bl	stage_one
	movs	r0, #0
	bl	exit
	.size	_start, .-_start
	.ident	"GCC: (GNU) 13.2.0"
	.section	.note.GNU-stack,"",%progbits
