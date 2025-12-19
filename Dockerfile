FROM vllm/vllm-openai:v0.6.1.post1-cu121

# HF token (use ARG for build-time secret)

ARG HF_TOKEN
ENV HUGGING_FACE_HUB_TOKEN=$HF_TOKEN


# Expose port
EXPOSE 8000

# Healthcheck

ENTRYPOINT ["vllm", "serve", "fixie-ai/ultravox-v0_5-llama-3_2-1b"]
CMD ["--host", "0.0.0.0", "--port", "8000", \
     "--trust-remote-code", "--max-model-len", "8192"]
