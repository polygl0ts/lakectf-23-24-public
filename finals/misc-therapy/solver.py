
init_state = set([(0,0)])

"""
Idea: make 2 => make 4 => neg to get 
"""
# 1 is special? 254 too?
can_mult = [2, 8, 12, 16, 20, 36, 52]
# can mult => can incr
# even nums can get gotten with xor
can_incr = [0, 1, 2, 6, 7, 254]#[0, 1, 2, 3, 4, 5, 6, 7, 254]
can_neg = [1] + [i for i in range(1, 127) if i not in can_mult and i not in can_incr] #[0, 1, 6, 60]
can_xor = [128] + [i for i in range(129, 256, 2) if i not in can_mult and i not in can_incr]
can_incr =  can_incr + can_mult + [i for i in range(128, 256) if i not in can_xor]
# [0, 1, 2, 6, 7, 254]
# can neg => flags 
# can incr => people? 
# can mult => can incr (hands)
# can xor => symbols
# 1 isn 
if [i for i in range(129, 256, 2) if i not in can_mult and i not in can_incr] != [i for i in range(129, 256, 2)]:
   print("Check this out")
n = 256
def add_op(state: tuple[int, int]):
  return None

def push_op(state: tuple[int, int]):
  return (state[0], state[0])

def void_op(state: tuple[int, int]):
  return (0, state[1])

def mult_op(state: tuple[int, int]):
  if state[0] in can_mult and state[1] in can_mult:
    return ((state[0]*state[1])%n, state[1])
  return None

def xor_op(state: tuple[int, int]):
  if state[0] in can_xor and state[1] in can_xor:
    #print("xored to create", state[0] ^ state[1])
    return (state[0] ^ state[1], state[1])
  return None

def incr_op(state: tuple[int, int]):
  if state[0] in can_incr:
    return (state[0]+1, state[1])
  return None

def neg_op(state: tuple[int, int]):
  if state[0] in can_neg:
    return ((~state[0])%n, state[1])
  return None

def explore_states(to_explore:set[tuple[int, int]], have_explored: set[int, int]):
  all_modes=set()
  while len(to_explore)>0:
    current = to_explore.pop()
    have_explored.add(current)
    new_states = set()
    res = add_op(current)
    if res is not None:
        new_states.add(res)
    res = xor_op(current)
    if res is not None:
        new_states.add(res)
    res = push_op(current)
    if res is not None:
        new_states.add(res)
    res = void_op(current)
    if res is not None:
        new_states.add(res)
    res = mult_op(current)
    if res is not None:
        new_states.add(res)
    res = incr_op(current)
    if res is not None:
        new_states.add(res)
    res = neg_op(current)
    if res is not None:
        new_states.add(res)
    new_states.difference_update(have_explored)
    """
    if len(new_states) > 0:
        print("Can reach", new_states,"from", current)
    """
    new_modes = {a[0] for a in new_states if a[0] not in {b[0] for b in have_explored}}.difference(all_modes)
    if len(new_modes) > 0:
       print("Can reach", new_modes, "via", new_states,"from", current)
       all_modes.update(new_modes)
    new_modes = {a[0] for a in new_states if a[0] == 127}
    if len(new_modes) > 0 and current[0] != 127:
       print("FLAG REACHED 127", "via", new_states,"from", current)
    to_explore.update(new_states)
    
  return have_explored

reached = explore_states(init_state, set())
flagged = 127 in {a[0] for a in reached}
print("Of mult are reachable",[i for i in can_mult if i in {a[0] for a in reached}])
print("Reachable:",sorted({a[0] for a in reached}))
print("can mult:", can_mult, len(can_mult))
print("can incr:", sorted(set(can_incr)), len(sorted(set(can_incr))))
print("can neg:", can_neg, len(can_neg))
print("can xor:", can_xor, len(can_xor))
print("does nothing", [i for i in range(256) if i not in can_xor + can_incr + can_neg])
print("Number of states reachable", len({a[0] for a in reached}), "flagged:", flagged)
"""
print("{")
for i in can_mult:
  print(i,':"",')
for i in can_incr:
    if i not in can_mult:
      print(i,':"",')
for i in can_neg:
  print(i,':"",')
for i in can_xor:
  print(i,':"",')
print("}")
"""
