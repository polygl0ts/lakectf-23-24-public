FROM ubuntu AS builder
RUN apt update && apt install -y python3 && rm -rf /var/lib/apt/lists/*

FROM pwn.red/jail

COPY --from=builder / /srv

WORKDIR /srv/app

COPY flag.txt flag.txt
RUN mv flag.txt flag-$(md5sum flag.txt | awk '{print $1}').txt

COPY --chmod=0755 --chown=1000:1000 run run

COPY --chmod=0755 --chown=1000:1000 server.py server.py
COPY --chmod=0755 --chown=1000:1000 d8 d8
COPY --chmod=0744 --chown=1000:1000 snapshot_blob.bin snapshot_blob.bin

COPY --chmod=0755 hook.sh /jail/hook.sh


ENV JAIL_TIME 60
ENV JAIL_CONNS_PER_IP 5
ENV JAIL_MEM 20M
