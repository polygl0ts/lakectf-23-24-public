FROM ubuntu:22.04


RUN apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    autoconf \
    bison \
    flex \
    gcc \
    g++ \
    git \
    libprotobuf-dev \
    libnl-route-3-dev \
    libtool \
    make \
    pkg-config \
    protobuf-compiler \
    dropbear-bin \
    vim \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/google/nsjail --branch 3.4 \
    && cd nsjail \
    && make \
    && mv nsjail /bin \
    && cd / \
    && rm -rf nsjail

RUN mkdir /etc/dropbear

RUN adduser user

COPY flag /home/user/flag
COPY chall_vimrc2 /home/user/vimrc
COPY run.sh /home/user
COPY vimjail.cfg /
COPY /run_nsjail.sh /run.sh

RUN chown -R user:user /home/user/
RUN chmod +x /run.sh
RUN /bin/bash -c 'passwd user < <(echo -en "lakectf\nlakectf\n")'
RUN chmod +x /home/user/run.sh

CMD ["dropbear", "-R", "-F", "-E", "-w", "-c", "/run.sh"]
