#!/bin/bash

docker build -t trustmee .
pip3 install docker
apt-get install -y socat