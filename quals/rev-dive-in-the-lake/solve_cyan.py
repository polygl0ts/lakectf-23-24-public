from z3 import *

rsi = BitVec('x', 64)
rdi = BitVec('y', 64)
rdx = BitVec('z', 64)
s = Solver()

s.add(((rdi & rsi) & rdx) == 0x6430025240464044)
s.add((0x8080808080808080 & rdi) == 0)
s.add((0x8080808080808080 & rsi) == 0)
s.add((0x8080808080808080 & rdx) == 0)
s.add((rdi*rdi)+(rsi*rsi) == 0xfb6c2b50ea292629)
s.add((rdx*rdx)+(rsi*rsi) == 0xe68c336dffd092d4)


print(s.check())
model = s.model()
print(int.to_bytes(model[rdi].as_long(), 16)[:7:-1]
+ int.to_bytes(model[rsi].as_long(), 16)[:7:-1]
+ int.to_bytes(model[rdx].as_long(), 16)[:7:-1])
