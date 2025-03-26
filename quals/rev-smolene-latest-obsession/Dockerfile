FROM docker.io/library/ubuntu:22.04 as builder

RUN useradd -u 1000 jail

FROM pwn.red/jail

COPY --from=builder / /srv

COPY --chmod=0755 --chown=1000:1000 chal /srv/app/chal
COPY --chmod=0755 --chown=1000:1000 runchal.bash /srv/app/run
COPY --chmod=0644 --chown=1000:1000 prompt /srv/app/prompt

ENV JAIL_TIME 60
ENV JAIL_CONNS_PER_IP 5
ENV JAIL_MEM 20M
