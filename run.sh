#!/bin/bash
set -e  

echo "Starting AI Agent Platform on Runpod..."
echo "=================== HEALTH CHECK ==================="

# Check Python packages
echo "Checking Python dependencies..."
python -c "import vllm, torch, transformers, fastapi; print('✓ vLLM:', vllm.__version__); print('✓ Torch:', torch.__version__); print('✓ Transformers:', transformers.__version__); print('✓ FastAPI ready')"

# Runpod GPU check (more detailed)
if command -v nvidia-smi &> /dev/null; then
    echo "Runpod GPU Check:"
    nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader,nounits
    GPU_COUNT=$(nvidia-smi --query-gpu=count --format=csv,noheader,nounits)
    echo "$GPU_COUNT Runpod A100/H100 GPUs detected"
else
    echo "No NVIDIA GPU (Runpod GPU worker required)"
    GPU_COUNT=0
fi

# Runpod env vars 
export HF_TOKEN=${HF_TOKEN:-${RUNPOD_HF_TOKEN:-}}
echo "$HF_TOKEN"


if [ -n "$HF_TOKEN" ]; then
    echo "Logging into Hugging Face..."
    HF_TOKEN_ENV=$(echo "$HF_TOKEN" | tr -d '\n')  
    huggingface-cli login --token $HF_TOKEN
    echo "Hugging Face authenticated"
else
    echo "No HF_TOKEN - public models only"
fi

echo "=================== RUNPOD READY ==================="
echo "Model: fixie-ai/ultravox-v0_5-llama-3_2-1b"
echo "GPUs: $GPU_COUNT"
echo "Ultravox Voice AI loading..."

export TRITON_KERNEL_COMPILE_IMP=inductor
export TORCH_COMPILE_DISABLE=1
export VLLM_ATTENTION_BACKEND=FLASH_ATTN
export VLLM_WORKER_MULTIPROC_METHOD=spawn
export CUDA_LAUNCH_BLOCKING=0
export VLLM_USE_V1_ENGINE=1
export VLLM_DISABLE_CUDAGRAPH_DECODER=False

echo "=================== ULTRAVOX  ==================="

exec python -m vllm.entrypoints.openai.api_server \
    --model fixie-ai/ultravox-v0_5-llama-3_2-1b \
    --host 0.0.0.0 \
    --port 8000 \
    --dtype bfloat16 \
    --max-model-len 2048 \
    --limit-mm-per-prompt "audio=1" \
    --gpu-memory-utilization 0.85 \
    --max-num-seqs 256 \
    --block-size 16 \
    --enforce-eager \
    --swap-space 4 \
    --engine-use-ray=0 \
    --disable-log-stats \
    --trust-remote-code
