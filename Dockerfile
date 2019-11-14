FROM debian:buster-slim

LABEL Description="SweRVolf image" Vendor="CHIPS Alliance" Version="2019.1"
LABEL maintainer="Olof Kindgren <olof@fossi-foundation.org>"

#wheel??
RUN apt-get update && apt-get --no-install-recommends install -y \
    bzip2 \
    cmake \
    file \
    g++ \
    git \
    gperf \
    iverilog \
    make \
    ninja-build \
    python3-dev \
    python3-pip \
    python3-pyelftools \
    python3-setuptools \
    verilator \
    wget \
    xz-utils

#Set python3 as default python
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.7 1

#Get and install verilator
#wget http://http.us.debian.org/debian/pool/main/v/verilator/verilator_4.020-1_amd64.deb

#Install FuseSoC
RUN pip3 install fusesoc cocotb

WORKDIR /workspace

#Register required FuseSoC libraries
RUN fusesoc library add fusesoc-cores https://github.com/fusesoc/fusesoc-cores
RUN fusesoc library add swervolf https://github.com/chipsalliance/Cores-SweRVolf

RUN wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.10.0/zephyr-sdk-0.10.0-setup.run && \
    sh zephyr-sdk-0.10.0-setup.run --quiet -- -d /opt/zephyr-sdk && \
    rm zephyr-sdk-0.10.0-setup.run

RUN rm -rf \
    /opt/zephyr-sdk/arc-zephyr-elf \
    /opt/zephyr-sdk/i586-zephyr-elfiamcu \
    /opt/zephyr-sdk/xtensa-zephyr-elf \
    /opt/zephyr-sdk/arm-zephyr-eabi \
    /opt/zephyr-sdk/i586-zephyr-elf \
    /opt/zephyr-sdk/nios2-zephyr-elf

ENV ZEPHYR_TOOLCHAIN_VARIANT zephyr
ENV ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk

#Get SweRVolf-specific version of Zephyr
RUN wget https://github.com/olofk/zephyr/archive/ibs2.tar.gz && mkdir zephyr && tar xzf ibs2.tar.gz -C zephyr --strip-components 1 && rm ibs2.tar.gz
