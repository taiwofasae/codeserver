# Start from the official code-server image
FROM ghcr.io/coder/code-server:latest

# Install make, Python, pip, and venv support
RUN sudo apt-get update && sudo apt-get install -y \
    make \
    python3 \
    python3-pip \
    python3-venv \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

# Create convenient symlinks so 'python' and 'pip' work directly
RUN sudo ln -sf /usr/bin/python3 /usr/local/bin/python && \
    sudo ln -sf /usr/bin/pip3 /usr/local/bin/pip
