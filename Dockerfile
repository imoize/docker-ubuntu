FROM alpine:3.19 as build-stage

ARG TARGETARCH
ARG UBUNTU_RELEASE

ENV REL=${UBUNTU_RELEASE}

# set version for s6 overlay
ARG S6_OVERLAY_VERSION="3.1.6.2"
ARG S6_OVERLAY_ARCH

# build rootfs and add s6 overlay
RUN \
    apk add --no-cache \
    bash \
    curl \
    xz && \
    if [ ${TARGETARCH} == amd64 ]; then ARCH=x86_64; \
    elif [ ${TARGETARCH} == arm64 ]; then ARCH=aarch64; fi && \
    if [ -z ${S6_OVERLAY_ARCH+x} ]; then S6_OVERLAY_ARCH=${ARCH}; fi && \
    \
    mkdir /root-out && \
    curl -o \
    /rootfs.tar.gz -L \
    https://partner-images.canonical.com/core/${REL}/current/ubuntu-${REL}-core-cloudimg-${TARGETARCH}${TARGETVARIANT}-root.tar.gz && \
    tar xf \
    /rootfs.tar.gz -C \
    /root-out && \
    rm -rf \
    /root-out/var/log/* && \
    \
    curl -sLO --output-dir /tmp "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" && \
    tar -C /root-out -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    curl -sLO --output-dir /tmp "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz" && \
    tar -C /root-out -Jxpf /tmp/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz && \
    curl -sLO --output-dir /tmp "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz" && \
    tar -C /root-out -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz && \
    curl -sLO --output-dir /tmp "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz" && \
    tar -C /root-out -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz

# runtime stage
FROM scratch
COPY --from=build-stage /root-out/ /

ARG TARGETARCH
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/root" \
    LANGUAGE="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    TERM="xterm" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME="0" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS="2" \
    S6_VERBOSITY="1"

# copy sources
COPY sources.list.${TARGETARCH} /etc/apt/sources.list

# ripped from ubuntu docker logic
RUN \
    set -xe && \
    echo '#!/bin/sh' \
      > /usr/sbin/policy-rc.d && \
    echo 'exit 101' \
      >> /usr/sbin/policy-rc.d && \
    chmod +x \
      /usr/sbin/policy-rc.d && \
    dpkg-divert --local --rename --add /sbin/initctl && \
    cp -a \
      /usr/sbin/policy-rc.d \
      /sbin/initctl && \
    sed -i \
      's/^exit.*/exit 0/' \
      /sbin/initctl && \
    echo 'force-unsafe-io' \
      > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup && \
    echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' \
      > /etc/apt/apt.conf.d/docker-clean && \
    echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' \
      >> /etc/apt/apt.conf.d/docker-clean && \
    echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' \
      >> /etc/apt/apt.conf.d/docker-clean && \
    echo 'Acquire::Languages "none";' \
      > /etc/apt/apt.conf.d/docker-no-languages && \
    echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' \
      > /etc/apt/apt.conf.d/docker-gzip-indexes && \
    echo 'Apt::AutoRemove::SuggestsImportant "false";' \
      > /etc/apt/apt.conf.d/docker-autoremove-suggests && \
    mkdir -p /run/systemd && \
    echo 'docker' \
      > /run/systemd/container && \
    \
    apt-get update && apt-get upgrade -y && apt-get install -y \
      apt-utils \
      curl \
      cron \
      gnupg \
      jq \
      locales \
      netcat \
      tzdata && \
    \
    locale-gen en_US.UTF-8 && \
    useradd -u 911 -U -d /config -s /bin/false disty && \
    usermod -G users disty && \
    mkdir -p \
      /app \
      /config \
      /defaults && \
    \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf \
      /tmp/* \
      /var/lib/apt/lists/* \
      /var/tmp/* \
      /var/log/*

# add local files
COPY src/ /

ENTRYPOINT ["/init"]