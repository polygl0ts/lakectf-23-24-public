FROM python:3.10-slim as builder
RUN pip install pycryptodome

FROM pwn.red/jail
COPY --from=builder / /srv

COPY chal.py /srv/app/run
ENV JAIL_ENV_flag="EPFL{w0w_s0_much_r4nd000o0oo0om}"
ENV JAIL_TIME=120
ENV JAIL_ENV_PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
RUN chmod 755 /srv/app/run