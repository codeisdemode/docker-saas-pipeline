# Base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies (for PostgreSQL, etc.)
RUN apt-get update && apt-get install -y \
    postgresql-client \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install dependencies
COPY projects/example/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY projects/example/ .

# Set environment variables
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1
ENV HOST=0.0.0.0

# Expose ports
EXPOSE 5000 8000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5000/tools || exit 1

# Run the MCP server
CMD ["python", "mcp_server.py"] 