#!/bin/bash
set -e

export TORCH_COMPILE_DISABLE=1
export TORCHINDUCTOR_DISABLE=1
export CUDA_MODULE_LOADING=LAZY
export VLLM_ATTENTION_BACKEND=FLASH_ATTN 
export VLLM_FLASHINFER_MOE_BACKEND=1   

echo "Logging into Hugging Face..."
huggingface-cli login --token $HF_TOKEN 

echo "Starting vLLM with google/gemma-3-27b-it..."
exec vllm serve google/gemma-3-27b-it \
  --quantization awq \  
  --dtype bfloat16 \
  --tensor-parallel-size 1 \
  --gpu-memory-utilization 0.92 \ 
  --max-model-len 32768 \
  --max-num-seqs 256 \ 
  --max-num-batched-tokens 16384 \
  --enable-chunked-prefill \  
  --enable-prefix-caching \
  --enforce-eager \ 
  --trust-remote-code \
  --host 0.0.0.0 --port 8080