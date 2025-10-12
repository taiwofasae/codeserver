# Dockerfile
FROM ghcr.io/coder/code-server:latest

# Install make, python3, pip, and common dev tools
RUN sudo apt-get update && sudo apt-get install -y \
    make \
    python3 \
    python3-pip \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*
