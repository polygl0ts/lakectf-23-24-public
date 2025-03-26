import random

random.seed(42)

a = [c for c in range(0, 256)]
b = a[:]
random.shuffle(b)
print(a)
print(b)

inv = [b.index(c) for c in a]

flag = "EPFL{cHucK_m00r3_w0U1d_b3_Pr0ud}"

cf = [b[ord(c)] for c in flag]
print(cf)
print(b)
print(inv)

dec = [chr(inv[c]) for c in cf]
print(dec)

print("cf")
for c in cf:
    print(f"{c} , ", end="")

print("\nb")
for c in b:
    print(f"{c} , ", end="")

print("correct!!")
for c in "correct!!":
    print(f"{ord(c)} putc ", end="")



print("nope")
for c in "nope":
    print(f"{ord(c)} putc ", end="")



