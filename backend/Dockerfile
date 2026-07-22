# Use Python 3.11 slim image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=8000
ENV HF_HOME=/app/.cache/huggingface
ENV EMOTION_MODEL_NAME=mo-thecreator/vit-Facial-Expression-Recognition

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Install torch CPU-only first (smaller than full torch wheel)
RUN pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu

# Copy requirements and install remaining Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ ./app/

# Download the model into the image so Railway does not depend on a runtime
# network download during its first health check.
RUN python -c "import os; from transformers import ViTForImageClassification, ViTImageProcessor; model = os.environ['EMOTION_MODEL_NAME']; ViTImageProcessor.from_pretrained(model); ViTForImageClassification.from_pretrained(model)"

# Create non-root user for security
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=60s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/api/health')" || exit 1

# Start the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
