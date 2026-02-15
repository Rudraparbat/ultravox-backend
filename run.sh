#!/bin/bash
set -e

export TORCH_COMPILE_DISABLE=1
export TORCHINDUCTOR_DISABLE=1
export CUDA_MODULE_LOADING=LAZY

echo "Logging into Hugging Face..."
huggingface-cli login --token $HF_TOKEN 

echo "Starting vLLM..."
exec vllm serve fixie-ai/ultravox-v0_6-llama-3_1-8b \
  --host 0.0.0.0 \
  --port 8080 \
  --limit-mm-per-prompt '{"audio":20}' \
  --trust-remote-code \
  --gpu-memory-utilization 0.90 \
  --enforce-eager
