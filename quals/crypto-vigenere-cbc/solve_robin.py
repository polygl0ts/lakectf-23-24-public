import string, collections, itertools
alpha = string.ascii_uppercase
ct = "AFCNUUOCGIFIDTRSBHAXVHZDRIEZMKTRPSSXIBXCFVVNGRSCZJLZFXBEMYSLUTKWGVVGBJJQDUOXPWOFWUDHYJSMUYMCXLXIWEBGYAGSTYMLPCJEOBPBOYKLRDOJMHQACLHPAENFBLPABTHFPXSQVAFADEZRXYOXQTKUFKMSHTIEWYAVGWWKKQHHBKTMRRAGCDNJOUGBYPOYQQNGLQCITTFCDCDOTDKAXFDBVTLOTXRKFDNAJCRLFJMLQZJSVWQBFPGRAEKAQFUYGXFJAWFHICQODDTLGSOASIWSCPUUHNLAXMNHZOVUJTEIEEJHWPNTZZKXYSMNZOYOVIMUUNXJFHHOVGPDURSONLLUDFAGYGWZNKYXAGUEEEGNMNKTVFYZDIQZPJKXGYUQWFPWYEYFWZKUYUTXSECJWQSTDDVVLIYXEYCZHYEXFOBVQWNHUFHHZBAKHOHQJAKXACNODTQJTGC"
def blocks(x, n=20):
    return [''.join(y) for y in zip(*[iter(x)] * n)]
def sub(a, b):
    return ''.join(alpha[(alpha.index(x) - alpha.index(y)) % len(alpha)] for x, y in zip(a, b))
b = blocks(ct)
normal = ''.join(sub(b1, b0) for b0, b1 in zip(b, b[1:])) + sub(ct[-(len(ct) % 20):], b[-1])
def break_vig(ct, klen=20):
    freq = collections.Counter(x for x in open("/usr/share/dict/words").read().upper() if x in alpha)
    def kscore(i):
        def score(k):
            return sum(freq[alpha[(alpha.index(x) + k) % len(alpha)]] for x in ct[i::klen])
        return score
    K = [max(range(len(alpha)), key=kscore(i)) for i in range(20)]
    return ''.join(alpha[(alpha.index(x) + k) % len(alpha)] for x, k in zip(ct, itertools.cycle(K)))
print(break_vig(normal))
