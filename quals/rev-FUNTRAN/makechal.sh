#!/bin/bash
set -euo pipefail
set -x
# cleanup
rm -r FUNTRAN.zip FUNTRAN || true
mkdir FUNTRAN
# compile chal
make EVIL=0
cp build/funtran src/arrayops.f90 FUNTRAN
# ship libs
# mkdir FUNTRAN/libs
# cp /lib/x86_64-linux-gnu/libgfortran.so.5 /lib/x86_64-linux-gnu/libm.so.6 /lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/libquadmath.so.0 /lib/x86_64-linux-gnu/libgcc_s.so.1 FUNTRAN/libs
# done
zip -r FUNTRAN.zip FUNTRAN
