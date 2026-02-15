#!/bin/bash
set -e

echo "Logging into HuggingFace..."
huggingface-cli login --token $HF_TOKEN

echo "Starting vLLM with Voxtral-Mini-4B-Realtime-2602..."

exec vllm serve mistralai/Voxtral-Mini-4B-Realtime-2602 \
  --tokenizer-mode mistral \
  --config-format mistral \
  --load-format mistral \
  --gpu-memory-utilization 0.90 \
  --enforce-eager \
  --max-model-len 45000 \
  --max-num-batched-tokens 8192 \
  --max-num-seqs 16 \
  --host 0.0.0.0 --port 8080