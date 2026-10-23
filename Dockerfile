# Rockbox build environment.
#
# Builds the cross toolchain(s) via tools/rockboxdev.sh and expects the source
# tree to be bind-mounted at /src (see docker-compose.yml).
#
# TOOLCHAINS takes rockboxdev.sh arch letters, space separated:
#   a = arm (ipods, Sansa, ...), m = m68k, i = mips, x = arm-linux, y = mips-linux
FROM debian:12

ARG TOOLCHAINS="a"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential ca-certificates git perl curl wget \
        texinfo flex bison bzip2 xz-utils gzip zip patch \
        automake autoconf libtool libtool-bin gawk gettext \
        libgmp-dev libmpfr-dev libmpc-dev libisl-dev \
        python3 ccache libsdl2-dev && \
    rm -rf /var/lib/apt/lists/*

# Copy only what the toolchain build needs so source edits don't invalidate
# this (very slow) layer.
COPY tools/rockboxdev.sh /opt/rbdev/tools/rockboxdev.sh
COPY tools/toolchain-patches /opt/rbdev/tools/toolchain-patches

RUN RBDEV_PREFIX=/opt/rockbox-toolchain \
    RBDEV_DOWNLOAD=/tmp/rbdev-dl \
    RBDEV_BUILD=/tmp/rbdev-build \
    /opt/rbdev/tools/rockboxdev.sh --target="$TOOLCHAINS" && \
    rm -rf /tmp/rbdev-dl /tmp/rbdev-build

ENV PATH="/opt/rockbox-toolchain/bin:${PATH}" \
    CCACHE_DIR=/ccache

COPY docker/rbbuild.sh /usr/local/bin/rbbuild

WORKDIR /src
CMD ["bash"]
