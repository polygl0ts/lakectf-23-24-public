FROM docker.io/library/ubuntu:22.04 as builder

RUN useradd -u 1000 jail

FROM pwn.red/jail

COPY --from=builder / /srv
COPY run /srv/app/run
COPY libscudo-linux.so /srv/app/
COPY libc.so.6 /srv/app/
COPY ld-linux-x86-64.so.2 /srv/app/
COPY link /srv/app/
COPY flag /srv/app/flag

RUN chmod 755 /srv/app/run 
RUN chmod 755 /srv/app/libscudo-linux.so 
RUN chmod 755 /srv/app/libc.so.6 
RUN chmod 755 /srv/app/ld-linux-x86-64.so.2 
RUN chmod 744 /srv/app/flag

ENV JAIL_TIME 120
ENV JAIL_CONNS_PER_IP 5
ENV JAIL_MEM 20M

