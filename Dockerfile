FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive

# OS deps minimales
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libsm6 \
    libxext6 \
    git \
    ca-certificates \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m user
USER user
WORKDIR /home/user/app

COPY requirements.txt .

RUN python -m pip install --upgrade pip setuptools wheel \
 && pip install --no-cache-dir -r requirements.txt

CMD ["bash"]
