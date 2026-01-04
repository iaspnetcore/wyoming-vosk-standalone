# https://github.com/home-assistant/docker-base
# syntax=docker/dockerfile:1

# Home Assistant ARM64 Debian 12 base
ARG BUILD_FROM=ghcr.io/home-assistant/arm64-base-debian:bookworm
FROM ${BUILD_FROM}

# Shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Build args
ARG WYOMING_VOSK_VERSION

# Required for Debian 12 pip behavior
ENV PIP_BREAK_SYSTEM_PACKAGES=1
ENV PYTHONUNBUFFERED=1

# Workdir
WORKDIR /usr/src

RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-venv \
        netcat-traditional \
        libatomic1 \
        libsndfile1 \
        ca-certificates \
    \
    # upgrade pip toolchain
    && pip3 install --no-cache-dir -U \
        pip \
        setuptools \
        wheel \
    \
    # install wyoming-vosk (ARM-friendly via piwheels)
    && pip3 install --no-cache-dir \
        --extra-index-url https://www.piwheels.org/simple \
        "wyoming-vosk[limited] @ https://github.com/rhasspy/wyoming-vosk/archive/refs/tags/v${WYOMING_VOSK_VERSION}.tar.gz" \
    \
    # cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Runtime
WORKDIR /
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 10300

ENTRYPOINT ["bash", "/start.sh"]

