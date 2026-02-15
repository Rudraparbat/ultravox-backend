#!/bin/bash
set -e

export TORCH_COMPILE_DISABLE=1
export TORCHINDUCTOR_DISABLE=1
export CUDA_MODULE_LOADING=LAZY

echo "Logging into Hugging Face..."
huggingface-cli login --token $HF_TOKEN

echo "Starting vLLM with mistralai/Voxtral-Mini-4B-Realtime-2602..."

exec vllm serve mistralai/Voxtral-Mini-4B-Realtime-2602 \
  --tokenizer-mode mistral \
  --config-format mistral \
  --load-format mistral \
  --max-model-len 45000 \
  --max-num-batched-tokens 8192 \
  --max-num-seqs 16 \
  --gpu-memory-utilization 0.90 \
  --enforce-eager \
  --trust-remote-code \
  --host 0.0.0.0 --port 8080