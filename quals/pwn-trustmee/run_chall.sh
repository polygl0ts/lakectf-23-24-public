#!/bin/bash

socat TCP4-LISTEN:9002,reuseaddr,fork EXEC:"./shell.py",stderr