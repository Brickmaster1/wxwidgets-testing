FROM mcr.microsoft.com/devcontainers/base:ubuntu-20.04

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    tar \
    p7zip \
    build-essential \
    pkg-config \
    mingw-w64

# Install Zig
RUN wget https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz && \
    tar -xf zig-linux-x86_64-0.13.0.tar.xz && \
    mv zig-linux-x86_64-0.13.0 /opt/zig && \
    ln -s /opt/zig/zig /usr/local/bin/zig && \
    rm zig-linux-x86_64-0.13.0.tar.xz

USER vscode

# Install xmake
RUN curl -fsSL https://xmake.io/shget.text | bash