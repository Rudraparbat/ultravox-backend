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
echo "Starting vLLM with mistralai/Voxtral-Mini-4B-Realtime-2602.."

exec vllm serve mistralai/Voxtral-Mini-4B-Realtime-2602 --enforce-eager 