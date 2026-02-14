FROM python:3.11-slim

WORKDIR /app

# Prevent interactive prompts
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install nginx (optimized)
RUN apt-get update && \
    apt-get install -y --no-install-recommends nginx && \
    rm -rf /var/lib/apt/lists/*


# Upgrade pip
RUN pip install --upgrade pip

# Install vLLM with audio support (BUILD TIME)
RUN pip install --no-cache-dir "vllm[audio]"


# Copy configs

COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

EXPOSE 8080


CMD ["/app/run.sh"]
