FROM vllm/vllm-openai:latest

WORKDIR /app

# Prevent interactive prompts
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV CUDA_MODULE_LOADING=LAZY
ENV TORCH_COMPILE_DISABLE=1
ENV TORCHINDUCTOR_DISABLE=1
ENV VLLM_DISABLE_COMPILE_CACHE=1

# Install vLLM nightly with mistral_common (required for Voxtral)
RUN pip install --no-cache-dir -U vllm \
    --torch-backend=auto \
    --extra-index-url https://wheels.vllm.ai/nightly && \
    pip install --no-cache-dir "mistral_common>=1.9.0"

# Copy run script
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

EXPOSE 8080

CMD ["/app/run.sh"]