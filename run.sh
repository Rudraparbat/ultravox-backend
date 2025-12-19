#!/bin/bash
set -e  # Exit on any error

echo "🚀 Starting AI Agent Platform on Runpod..."
echo "=================== HEALTH CHECK ==================="

# Check Python packages
echo "✅ Checking Python dependencies..."
python -c "import vllm, torch, transformers, fastapi; print('✓ vLLM:', vllm.__version__); print('✓ Torch:', torch.__version__); print('✓ Transformers:', transformers.__version__); print('✓ FastAPI ready')"

# Runpod GPU check (more detailed)
if command -v nvidia-smi &> /dev/null; then
    echo "✅ Runpod GPU Check:"
    nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader,nounits
    GPU_COUNT=$(nvidia-smi --query-gpu=count --format=csv,noheader,nounits)
    echo "🟢 $GPU_COUNT Runpod A100/H100 GPUs detected"
else
    echo "⚠️  No NVIDIA GPU (Runpod GPU worker required)"
    GPU_COUNT=0
fi

# Runpod env vars (overrides .env)
export HF_TOKEN=${HF_TOKEN:-${RUNPOD_HF_TOKEN:-}}


# ✅ WORKING HF LOGIN (no git credentials)
if [ -n "$HF_TOKEN" ]; then
    echo "🔐 Logging into Hugging Face..."
    HF_TOKEN_ENV=$(echo "$HF_TOKEN" | tr -d '\n')  # Clean token
    hf auth login --token $HF_TOKEN
    echo "✅ Hugging Face authenticated"
    hf auth whoami
else
    echo "⚠️  No HF_TOKEN - public models only"
fi

echo "=================== RUNPOD READY ==================="
echo "🟢 Model: fixie-ai/ultravox-v0_5-llama-3_2-1b"
echo "🟢 GPUs: $GPU_COUNT"
echo "🟢 Ultravox Voice AI loading..."

# Runpod vLLM (optimized for A100/H100)
exec python -m vllm.entrypoints.openai.api_server \
    --model fixie-ai/ultravox-v0_5-llama-3_2-1b \
    --host 0.0.0.0 \
    --port 8000 \
    --dtype bfloat16 \
    --max-model-len 4096 \
    --gpu-memory-utilization 0.90 \
    --trust-remote-code
