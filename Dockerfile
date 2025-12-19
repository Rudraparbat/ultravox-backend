FROM vllm/vllm-openai:latest

# HF token (use ARG for build-time secret)
ARG HF_TOKEN
ENV HF_TOKEN=$HF_TOKEN

# Pre-accept model license + trust remote code
RUN hf auth login --token $HF_TOKEN && \
    huggingface-cli accept-revoked-access && \
    huggingface-cli accept-terms

# Expose port
EXPOSE 8000

# Healthcheck

# Run Ultravox server
CMD ["vllm", "serve", "fixie-ai/ultravox-v0_5-llama-3_2-1b", \
     "--host", "0.0.0.0", \
     "--port", "8000", \
     "--trust-remote-code", \
     "--max-model-len", "8192"]
