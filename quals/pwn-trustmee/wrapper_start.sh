#!/bin/sh
echo "listenting on port 9002"

socat TCP4-LISTEN:9002,reuseaddr,fork EXEC:"/shell.py",stderr