FROM python@sha256:36d57d7f9948fefe7b6092cfe8567da368033e71ba281b11bb9eeffce3d45bc6 AS builder
RUN apt-get update -y && apt-get install -y git && apt-get clean -y
RUN pip install -U git+https://github.com/rocky/python-xdis@5c582e0aac1488e672ea0dae3326ea1c2595e0cf git+https://github.com/rocky/python-decompile3@344bc3bdd6420f3bac5be8de718b30e0d4bd83ed
COPY challenge.py /app/run
COPY flag.txt /app

FROM pwn.red/jail

COPY --from=builder / /srv

ENV JAIL_TIME 60
ENV JAIL_CONNS_PER_IP 5
ENV JAIL_MEM 50M
ENV JAIL_TMP_SIZE 1M
