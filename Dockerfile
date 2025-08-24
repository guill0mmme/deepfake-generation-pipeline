# Use CUDA 12.4.1 + cuDNN dev image (Ubuntu 22.04)
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

ENV PYTHON_VERSION=3.10.14

# Install OS dependencies including build tools, Python build dependencies,
# meson/ninja (for scikit-image build), git, ffmpeg, and OpenCV dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    ffmpeg \
    libsm6 \
    libxext6 \
    sudo \
    curl \
    wget \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    ca-certificates \
    meson \
    ninja-build \
    pkg-config \
    python3-pkgconfig \
    libopenjp2-7-dev \
    libtiff5-dev \
    libpng-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.10 from source (optimized)
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar -xf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf Python-${PYTHON_VERSION}*

# Symlink python3 and pip3 to the newly installed Python 3.10
RUN ln -sf /usr/local/bin/python3.10 /usr/bin/python3 && \
    ln -sf /usr/local/bin/pip3.10 /usr/bin/pip3

# Verify python and pip
RUN python3 --version && pip3 --version

# Create non-root user for better security & compatibility with VSCode
RUN useradd -m user && echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER user

WORKDIR /home/user/app

# Copy requirements.txt into the container
COPY requirements.txt .

# Upgrade pip first
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install all Python dependencies from requirements.txt
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# Default command (you can override this when running container)
CMD ["bash"]
