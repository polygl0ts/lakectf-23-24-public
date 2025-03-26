print("wow")
from ghidra.app.decompiler import DecompInterface
from ghidra.util.task import ConsoleTaskMonitor

# get the current program
# here currentProgram is predefined

# Distance from address to byte
# |<---------->|
# 00401000      89 c8      MOV EAX, this
DISTANCE_FROM_ADDRESS_TO_BYTE = 15

# Distance from byte to instruction
#               |<------->|
# 00401000      89 c8      MOV EAX, this
DISTANCE_FROM_BYTE_TO_INST = 15

# Output format of instructions
MSG_FORMAT = ' {{addr:<{0}}} {{byte:<{1}}} {{inst}}\n'.format(
    DISTANCE_FROM_ADDRESS_TO_BYTE,
    DISTANCE_FROM_ADDRESS_TO_BYTE+DISTANCE_FROM_BYTE_TO_INST
)

def to_hex(integer):
    return '{:02x}'.format(integer)

def unoverflow(x):
    return (abs(x) ^ 0xff) + 1

program = currentProgram
decompinterface = DecompInterface()
decompinterface.openProgram(program)
functions = program.getFunctionManager().getFunctions(True)
for function in list(functions):
    func_addr = function.getEntryPoint()
    insts = program.getListing().getInstructions(func_addr, True)
    instructions = ''
    for inst in insts:
        instructions += MSG_FORMAT.format(
            addr=inst.getAddressString(True, True),
            byte=' '.join([to_hex(b) if b >= 0 else to_hex(unoverflow(b)) for b in inst.getBytes()]),
            inst=inst
        )
    print(instructions)
    print(function)
    # decompile each function
    tokengrp = decompinterface.decompileFunction(function, 0, ConsoleTaskMonitor())
    print(tokengrp.getDecompiledFunction().getC())

