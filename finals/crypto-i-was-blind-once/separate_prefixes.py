from hashlib import md5, sha1

PARTS = 23


def choose(choice_num: int, a_s: list[bytes], b_s: list[bytes]) -> bytes:
    res = []
    for i in range(len(a_s)):
        if (choice_num & 1) == 1:
            res.append(a_s[i])
        else:
            res.append(b_s[i])
        choice_num >>= 1
    res = b"".join(res)
    return res


def gen_lists(parts: int):
    partAs = []
    partBs = []
    for i in range(1, parts + 1):
        a = open(f"md5-colls/part{i}A.bin", "rb").read()
        partAs.append(a)
        b = open(f"md5-colls/part{i}B.bin", "rb").read()
        partBs.append(b)
    separatorsA = [partAs[0]]
    separatorsB = [partBs[0]]
    for i in range(1, len(partAs)):
        assert partAs[i - 1] in partAs
        assert partBs[i - 1] in partBs
        separatorsA.append(partAs[i][len(partAs[i - 1]):])
        separatorsB.append(partBs[i][len(partBs[i - 1]):])
    return separatorsA, separatorsB
