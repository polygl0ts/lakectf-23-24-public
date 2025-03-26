#!/bin/bash

# swisstable.tar.gz
mv swisstable/deploy/flag.txt flag.txt.bak
echo "EPFL{fakeflag}" > swisstable/deploy/flag.txt
tar cvzf swisstable.tar.gz swisstable/
mv flag.txt.bak swisstable/deploy/flag.txt

# d8_debug.tar.gz
pushd .
cd d8/
rm -rf debug/gen/ debug/obj/
tar cvzf ../d8_debug.tar.gz debug/
popd
