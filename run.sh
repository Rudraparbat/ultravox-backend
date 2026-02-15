#!/bin/bash
set -e

export TORCH_COMPILE_DISABLE=1
export TORCHINDUCTOR_DISABLE=1
export CUDA_MODULE_LOADING=LAZY
export VLLM_ATTENTION_BACKEND=FLASHINFER

echo "Logging into Hugging Face..."
huggingface-cli login --token $HF_TOKEN 

echo "Starting vLLM with google/gemma-3-27b-it..."

exec vllm serve google/gemma-3-27b-it \
  --dtype bfloat16 \
  --tensor-parallel-size 1 \
  --gpu-memory-utilization 0.90 \
  --max-model-len 32768 \
  --max-num-seqs 512 \
  --max-num-batched-tokens 32768 \
  --enable-chunked-prefill \
  --enable-prefix-caching \
  --enforce-eager \
  --host 0.0.0.0 --port 8080