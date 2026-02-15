#!/bin/bash
set -e

echo "Logging into HuggingFace..."
huggingface-cli login --token $HF_TOKEN

echo "Starting vLLM with fixie-ai/ultravox-v0_7-glm-4_6..."

exec vllm serve fixie-ai/ultravox-v0_7-glm-4_6 \
  --tensor-parallel-size 2 \
  --gpu-memory-utilization 0.90 \
  --max-model-len 8192 \
  --trust-remote-code \
  --enforce-eager \
  --host 0.0.0.0 --port 8080