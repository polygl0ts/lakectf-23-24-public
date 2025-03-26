#values = ['\x40', '\x42', '\xb8', '\x4f', '\x92', '\xa6', '\x36', '\x53', '\xee', '\xa0', '\xc1', '\x97', '\xbc', '\x4f', '\x81', '\x43', '\x81', '\xe2', '\xdc', '\x2b', '\x92', '\xf9', '\x0f', '\x73', '\x96', '\x18', '\x2b', '\x33', '\xd0']

#values = ['\x4e', '\x39', '\xca', '\x11', '\xe8', '\x6c', '\x1c', '\x38', '\x65', '\x68', '\xa0', '\xd9', '\x03', '\xc1', '\x81', '\x13', '\x09', '\xa7', '\x16', '\xc0', '\xf6', '\xe8']
#values = ['\x40', '\x42', '\xb8', '\x4f', '\x92', '\xa3', '\x22', '\x53', '\xee', '\xa0', '\xc1', '\x97', '\xbc', '\x4f', '\x81', '\x43', '\x81', '\xe2', '\xdc', '\x2b', '\x92', '\xf9', '\x0f', '\x73', '\x96', '\x18', '\x2b', '\x33', '\xd0']
values = ['\x40', '\x42', '\xb8', '\x4f', '\x92', '\xe5', '\x26', '\x33', '\xee', '\xa0', '\xc1', '\x97', '\xbc', '\x4f', '\x81', '\x43', '\x81', '\xe2', '\xdc', '\x2b', '\x92', '\xf9', '\x0f', '\x73', '\x96', '\x18', '\x2b', '\x33', '\xd0']
values = [ord(a) for a in values]
alphabet = "33344445568EFLP___________aaadeeefhhiillmnnrsttttvwzzz{}"
alphabet = "33344445568EFLP___________aaadeeefhhiillmnnrsttttvwzzz{}"
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
  
def is_valid(base:list[int], pos: int):
    #print("Check valid", pos, base)
    res = True
    for i in range(pos//8):
        res = res and base[i] == 0
    if pos%8==0:
        return res
    mask = (1 << (8 - pos%8)) - 1
    #print(mask,base[pos//8] & ~mask)
    return res and (base[pos//8] & ~mask) == 0

def find_candidates(base:list[int], alphabet: str, pos: int):
    cand = ""
    for c in alphabet:
        new_base = base.copy()
        write_to(new_base, c, pos)
        #print(c, new_base)
        if is_valid(new_base, pos+step):
            cand += c
    return cand

#print(find_candidates(values, list( dict.fromkeys(alphabet)), 0 ))


def explore(base:list[int], alphabet:str, path:str, pos:int):
    #print("Exploring path", path, alphabet, pos, base)
    if alphabet=="":
        print("FOUND!")
        print("Path is:", path)
        #exit(0)
    if "}" not in alphabet:
        return
    if len(path)>5 and not path.startswith("EPFL{"):
        return
    for c in list(dict.fromkeys(alphabet)):
        new_base = base.copy()
        write_to(new_base, c, pos)
        #print(c, new_base)
        if is_valid(new_base, pos+step):
            al = alphabet
            al = al.replace(c, "", 1)
            explore(new_base, al, path+c, pos+step)
    """
    
    for c in find_candidates(base, list( dict.fromkeys(alphabet)), pos):
        new_base = base.copy()
        write_to(new_base, c, pos)
    """
        
explore(values, alphabet, "", 0)