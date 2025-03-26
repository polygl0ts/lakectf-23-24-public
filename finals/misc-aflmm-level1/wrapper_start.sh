#!/bin/sh
echo "listenting on port 12006"

socat TCP4-LISTEN:12006,reuseaddr,fork EXEC:"/shell.py",stderr