#!/bin/bash
set -e

echo "Logging into Hugging Face..."
huggingface-cli login --token $HF_TOKEN 

echo "Starting vLLM..."
exec vllm serve fixie-ai/ultravox-v0_6-gemma-3-27b \
  --host 0.0.0.0 \
  --port 8080 \
  --limit-mm-per-prompt '{"audio":20}' \
  --trust-remote-code \
  --gpu-memory-utilization 0.90 \
  --enforce-eager
