#!/bin/sh

gcc level1.c -o level1
gcc -shared -fPIC -o seccomp_pre.so seccomp_pre.c -lseccomp

AFL_DEBUG_CHILD=1 AFL_DEBUG=1 AFL_PRELOAD=./seccomp_pre.so timeout 20 afl-fuzz -i in -o out -- ./level1
