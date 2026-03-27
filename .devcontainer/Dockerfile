FROM mcr.microsoft.com/devcontainers/base:debian

RUN apt-get update && apt-get install -y \
    graphviz \
    make \
    ansible \
    curl \
    tmux \
    screen \
    zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
