FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_MODULE_LOADING=LAZY
ENV TORCH_COMPILE_DISABLE=1
ENV TORCHINDUCTOR_DISABLE=1
ENV VLLM_DISABLE_COMPILE_CACHE=1

# Install Python 3.11 + system deps
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3.11 \
        python3.11-dev \
        python3-pip \
        git \
        curl \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1 \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip install --upgrade pip

# Install vLLM with audio support
RUN pip install --no-cache-dir "vllm[audio]"

# Install Mistral specific packages
RUN pip install --no-cache-dir \
    "mistral_common>=1.9.0" \
    huggingface_hub \
    hf_transfer

# Copy run script
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

EXPOSE 8080

CMD ["/app/run.sh"]