FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install -r requirements.txt
RUN python -c "from transformers import T5ForConditionalGeneration, T5Tokenizer; \
    T5ForConditionalGeneration.from_pretrained('t5-small'); \
    T5Tokenizer.from_pretrained('t5-small')"

# Copy application
COPY . .

# Expose port for Cloud Run
EXPOSE 8080

# Run server
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]