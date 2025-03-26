FROM ubuntu:22.04 as build

ARG IS_DEBUG
ARG OUT_PATH

# install required deps
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -yq --no-install-recommends build-essential git ca-certificates python3-pkgconfig curl python3

# install depot_tools
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /opt/depot_tools
ENV PATH="/opt/depot_tools:${PATH}"

RUN mkdir /build
COPY remove_globals.patch /build/remove_globals.patch
COPY whitelist_swisstables.patch /build/whitelist_swisstables.patch
COPY sbx.patch /build/sbx.patch


RUN cd /build && fetch v8 && cd v8 && git checkout 5f01397651a8742427e068226adafc02c108ad1a && git apply ../remove_globals.patch && git apply ../whitelist_swisstables.patch && git apply ../sbx.patch && gclient sync

RUN cd /build/v8 && gn gen out/$OUT_PATH --args="is_debug="$IS_DEBUG" target_cpu=\"x64\" v8_enable_sandbox=true v8_enable_object_print=true" && \
    autoninja -C out/$OUT_PATH d8
