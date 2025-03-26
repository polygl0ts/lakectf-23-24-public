FROM python:3.10-slim as builder
RUN pip install pycryptodome

FROM pwn.red/jail
COPY --from=builder / /srv

COPY i_was_blind_only_once.py /srv/app/run
ENV JAIL_ENV_flag="EPFL{3v3rything_w4s_1n_th3_h44444shes}"
ENV JAIL_TIME=600
ENV JAIL_MEM 100M
ENV JAIL_ENV_PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
RUN chmod 755 /srv/app/run
