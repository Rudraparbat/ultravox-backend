#!/bin/bash
set -e

# ─────────────────────────────────────────────
# Environment Variables
# ─────────────────────────────────────────────
export TORCH_COMPILE_DISABLE=1
export TORCHINDUCTOR_DISABLE=1
export CUDA_MODULE_LOADING=LAZY

# ─────────────────────────────────────────────
# HuggingFace Login
# ─────────────────────────────────────────────
echo "Logging into Hugging Face..."
huggingface-cli login --token $HF_TOKEN

# ─────────────────────────────────────────────
# Start vLLM
# ─────────────────────────────────────────────
echo "Starting vLLM with openai/whisper-large-v3-turbo.."

exec vllm serve openai/whisper-large-v3-turbo \
  --dtype bfloat16 \
  --max-model-len 448 \
  --max-num-seqs 128 \
  --gpu-memory-utilization 0.85 \
  --trust-remote-code \
  --host 0.0.0.0 --port 8080