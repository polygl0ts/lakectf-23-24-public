input = "Testing"
input = "EPFL{3z_disa55em8le_4_an_3z_r3v_with_4n_ez_fl46_at_th4t}"
step = 4
def write_to(base: list[int], c: str, position :int):
    offset = position % 8
    first = position // 8 
    c = ord(c)
    assert len(base) > first
    base[first] = (base[first] ^ (c >> offset))%256
    if (offset == 0) :
        return 
    assert len(base) > (first + 1) 
    base[first+1] = (base[first+1] ^ (c << (8 -offset)))%256

print("Actual size", len(input)*step/8)
myArray_size = int((len(input)*step/8 +1) // 1)
#print(myArray_size) 
l = [0]*myArray_size
for i in range(len(input)):
    write_to(l, input[i], step*i)
print("myArray_size = ", myArray_size)
print("value_size = ", len(input)+1)
#print(l)
print('{', end='')
print(*["'\\"+ f"{e:#0{4}x}'"[1:] for e in l], end='}\n', sep=', ' )
#print('{',",".join([f"'{e}'" for e in sorted(input)]),", '\\0'}")
print("".join(sorted(input)))
#print([hex(int(a)) for a in list(set("".join(sorted(input))))])

"""
    for (size_t i = 0; i < value_size; i++)
    {
        printf("%c\n", input[i]);
    }
    """