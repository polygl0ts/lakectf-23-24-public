
# ORDER:
# + netcat -N localhost 4400
# + netcat -N localhost 4445
# + netcat -N localhost 4444
# + netcat -N localhost 4475
# + netcat -N localhost 4451
# 4480
# + netcat -N localhost 4459
# + netcat -N localhost 4471
# + netcat -N localhost 4457
# + netcat -N localhost 4476
# + netcat -N localhost 4481
# + netcat -N localhost 4459
# + netcat -N localhost 4470
# + netcat -N localhost 4457
# + netcat -N localhost 4476
# 4480
# + netcat -N localhost 4457
# + netcat -N localhost 4473
# + netcat -N localhost 4477
# + netcat -N localhost 4466
# + netcat -N localhost 4458
# + netcat -N localhost 4461
# + netcat -N localhost 4471
# + netcat -N localhost 4457
# + netcat -N localhost 4450
#  4480
# + netcat -N localhost 4468 # M must be at least 26 chars
# + netcat -N localhost 4452
# + netcat -N localhost 4473
# + netcat -N localhost 4455
# + netcat -N localhost 4447
#  4480
# + netcat -N localhost 4456
# + netcat -N localhost 4473
#  4480
# + netcat -N localhost 4446
# + netcat -N localhost 4464
# + netcat -N localhost 4477
# + netcat -N localhost 4448
#  4480
# + netcat -N localhost 4449
# + netcat -N localhost 4455
# + netcat -N localhost 4474
# + netcat -N localhost 4476
# + netcat -N localhost 4401



# players/4478.sh # never hit
# 20:        M=${M//'e'/'8'}

# players/4477.sh # for the 7
# 29:        M=${M//"tr"/'3'}

# players/4474.sh # for the 3?
# 15:        M=${M//'x'/'3'}
# 21:        M=${M//'x'/'4'}

# players/4468.sh # impossible condition?
# 18:        M=${M//'t'/'0'}

# players/4466.sh # impossible condition? 
# 15:        M=${M//'j'/'_'}

# players/4464.sh # for the "1"
# 23:        M=${M//"ym"/"0m"}

# players/4458.sh # for the "a"
# 31:        M="${M//'f'/'W'}"

# players/4453.sh # never hit
# 17:    M=${M//'a'/'9'}

# players/4451.sh # removal of z? 
# 20:        M=${M/'z'/''}

# players/4446.sh # for the 6
# 24:    M=${M//'r'/'5'}

# players/4449.sh
# 15:        M=${M/"-p1"/"-p0"}
# 21:        M=${M/"1n"/"0n"}

# players/4400.sh
# 22:M="${M//$nl/$nnl}"





f = open("message.txt", "w")

msg = "bracket"

total = 4445 - 1 # for the initial "{"
total -= 5 # for the last "Voila"
lines = total // 145
chars = total - (lines * 146) + 2
lines -= 1 # for the initial \n
lines += 1

caches = [""]*lines

for e,i in enumerate(range(lines)):
    if e < 30:
        caches[i] = chr(ord('z'))
    else:
        caches[i] = ""

msg += "Vdb"+"qsailY" + "jthm" + "jthm" + "hrrpqilet"+ "b"
#       bah   SUClob     p1n6     p0n6     n37 work1   <succEss letter>
# msg += "ugllcpp" + "ha" + "scrfX" + "gr" + "WorpY" + "Zfnm" + "b"  + "VldWeYn"
msg += "ugllcpp" + "ha" + "scrfX" + "gr" + "WorpY" + "Zftrpm" + "\nldWeYn"
#       winnerS     ng     yi3ld     m3     cu7 e     fl4g       bracket


# xlewgvjbkvas5cdjrqfZpYaicr

# M deve finire per bracket guarda in 4455

# lines -= 1
# chars += 146

for e,l in enumerate(range((lines - 3) - msg.count("\n") + 2)):
    msg += "\n"

chars -= len(msg.replace("\n", "")) 
chars -= 2


chars += 8
print(chars) 
assert(chars >= 0)
for c in range(chars):
    msg += "Z"

msg += "\noila"

f.write(msg)
f.close()

