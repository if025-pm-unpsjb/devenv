FROM ubuntu:latest

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    make \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /home/dev

WORKDIR /home/dev

RUN mkdir -p arm-none-eabi-gcc qemu openocd novnc novnc/utils/websockify

RUN wget https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v13.3.1-1.1/xpack-arm-none-eabi-gcc-13.3.1-1.1-linux-x64.tar.gz \
    && wget https://github.com/xpack-dev-tools/qemu-arm-xpack/releases/download/v8.2.6-1/xpack-qemu-arm-8.2.6-1-linux-x64.tar.gz \
    && wget https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v0.11.0-4/xpack-openocd-0.11.0-4-linux-x64.tar.gz \
    && wget https://github.com/novnc/websockify/archive/refs/tags/v0.13.0.tar.gz \
    && wget https://github.com/novnc/noVNC/archive/refs/tags/v1.6.0.tar.gz \
    && wget https://eclipse.c3sl.ufpr.br/technology/epp/downloads/release/2025-03/R/eclipse-embedcpp-2025-03-R-linux-gtk-x86_64.tar.gz \
    && tar xfz xpack-arm-none-eabi-gcc-13.3.1-1.1-linux-x64.tar.gz -C arm-none-eabi-gcc --strip-components 1 \
    && tar xfz xpack-qemu-arm-8.2.6-1-linux-x64.tar.gz -C qemu --strip-components 1 \
    && tar xfz xpack-openocd-0.11.0-4-linux-x64.tar.gz -C openocd --strip-components 1 \
    && tar xfz v1.6.0.tar.gz -C novnc --strip-components 1 \
    && tar xfz v0.13.0.tar.gz -C novnc/utils/websockify --strip-components 1 \
    && tar xfz eclipse-embedcpp-2025-03-R-linux-gtk-x86_64.tar.gz \
    && rm -rf *.tar.gz

ENV PATH="/home/dev/arm-none-eabi-gcc/bin:/home/dev/qemu/bin:/home/dev/openocd:/home/dev/novnc/utils:/home/dev/eclipse:$PATH"
