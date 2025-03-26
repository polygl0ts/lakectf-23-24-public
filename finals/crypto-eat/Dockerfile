FROM python:3.10-slim as builder
RUN pip install pycryptodome

FROM pwn.red/jail
COPY --from=builder / /srv

COPY chall.py /srv/app/run
ENV JAIL_ENV_flag="EPFL{c0nst4nt_t1m3_1s_d1ff1cult}"
ENV JAIL_TIME=1800
ENV JAIL_ENV_PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV JAIL_MEM 100M
RUN chmod 755 /srv/app/run
