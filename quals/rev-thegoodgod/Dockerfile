FROM docker.io/library/ubuntu:22.04

RUN apt update && DEBIAN_FRONTEND=non-interactive apt install gcc git build-essential -y
RUN DEBIAN_FRONTEND=non-interactive apt install cmake -y

RUN git clone --recurse-submodules https://github.com/UlfKargen/desync-cc
RUN DEBIAN_FRONTEND=non-interactive apt install python3 -y

RUN DEBIAN_FRONTEND=non-interactive apt install python3-pip -y
RUN pip3 install capstone pyelftools

COPY desync_config.cfg /desync-cc/config/config.cfg
COPY diablo.txt /desync-cc/config/predicates/diablo.txt

RUN cd desync-cc && mkdir build && cd build && cmake .. && cmake --build . -j12

CMD /desync-cc/build/desync-cc/bin/desync-cc /mnt/plus.c -o /mnt/plus_obf_symbols && strip -s /mnt/plus_obf_symbols -o /mnt/plus_obf 
