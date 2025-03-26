#!/bin/sh
echo "listenting on port 12007"

socat TCP4-LISTEN:12007,reuseaddr,fork EXEC:"/shell.py",stderr
