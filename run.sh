#!/bin/bash
set -e  

echo "Starting AI Agent Platform on Runpod..."
echo "=================== HEALTH CHECK ==================="

python -c "import vllm, torch, transformers, fastapi; print('✓ vLLM:', vllm.__version__); print('✓ Torch:', torch.__version__); print('✓ Transformers:', transformers.__version__); print('✓ FastAPI ready')"

if command -v nvidia-smi &> /dev/null; then
    echo "GPU Check:"
    nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader,nounits
    GPU_COUNT=$(nvidia-smi --query-gpu=count --format=csv,noheader,nounits)
else
    echo "No NVIDIA GPU detected"
    GPU_COUNT=0
fi

if [ -n "$HF_TOKEN" ]; then
    echo "Hugging Face token detected"
    export HUGGING_FACE_HUB_TOKEN="$HF_TOKEN"
else
    echo "No HF_TOKEN - public models only"
fi

echo "=================== RUNPOD READY ==================="
echo "Model: fixie-ai/ultravox-v0_6-gemma-3-27b"
echo "GPUs: $GPU_COUNT"

vllm serve fixie-ai/ultravox-v0_6-gemma-3-27b \
  --host 0.0.0.0 \
  --port 8000 \
  --limit-mm-per-prompt '{"audio":20}' \
  --trust-remote-code \
  --gpu-memory-utilization 0.90 \
  --enforce-eager
