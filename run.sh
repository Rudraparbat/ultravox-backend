#!/bin/bash
set -e  # Exit on any error

echo "🚀 Starting AI Agent Platform..."
echo "=================== HEALTH CHECK ==================="

# Check Python packages
echo "✅ Checking Python dependencies..."
python -c "import vllm, torch, transformers, fastapi; print('✓ vLLM:', vllm.__version__); print('✓ Torch:', torch.__version__); print('✓ Transformers:', transformers.__version__); print('✓ FastAPI ready')"
