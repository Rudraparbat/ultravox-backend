#!/bin/bash
set -e

echo "Logging into HuggingFace..."
huggingface-cli login --token $HF_TOKEN

echo "Starting vLLM with fixie-ai/ultravox-v0_6-llama-3_1-8b..."

exec vllm serve fixie-ai/ultravox-v0_6-llama-3_1-8b \
  --gpu-memory-utilization 0.90 \
  --enforce-eager \
  --max-model-len 8192 \
  --max-num-batched-tokens 4096 \
  --max-num-seqs 16 \
  --trust-remote-code \
  --host 0.0.0.0 --port 8080