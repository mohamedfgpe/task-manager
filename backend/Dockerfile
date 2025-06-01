# ====================================
# STEP 1: Updated requirements.txt
# ====================================
# Replace your requirements.txt with these exact versions:
#
# Flask==3.0.3
# Flask-SQLAlchemy==3.1.1
# Flask-Migrate==4.0.7
# Flask-Cors==5.0.0
# psycopg2-binary==2.9.10
# python-dotenv==1.0.1
# pytest==8.3.3
# flask-swagger-ui==4.11.1
# requests==2.32.3

# ====================================
# STEP 2: Secure Dockerfile
# ====================================

# Use a more secure and updated base image
FROM python:3.11-slim-bookworm as base

# Set environment variables for security and performance
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    DEBIAN_FRONTEND=noninteractive

# CRITICAL: Update system packages to fix the 881 Debian vulnerabilities
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    gcc \
    libpq-dev \
    ca-certificates \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Upgrade pip, setuptools, and wheel to latest secure versions
RUN python -m pip install --upgrade pip==24.3.1 setuptools==75.1.0 wheel==0.45.1

# Create working directory
WORKDIR /app

# Copy requirements first for better Docker layer caching
COPY requirements.txt .

# Install Python dependencies (this will install the secure versions)
RUN pip install --no-cache-dir -r requirements.txt

# Development stage
FROM base as development
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]

# Production stage  
FROM base as production

# Create non-root user for security
RUN groupadd -r -g 1001 appgroup && \
    useradd -r -u 1001 -g appgroup -m -d /home/appuser appuser

# Copy application code with proper ownership
COPY --chown=appuser:appgroup . .

# Create static directory and copy swagger.json if needed
RUN mkdir -p static && \
    chown -R appuser:appgroup static && \
    if [ -f swagger.json ]; then cp swagger.json static/; fi

# Clean up unnecessary files and set permissions
RUN find /app -name "*.pyc" -delete && \
    find /app -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true && \
    chmod -R 755 /app && \
    chmod 644 /app/*.py 2>/dev/null || true

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 5000

# Add security labels for compliance
LABEL security.non-root="true" \
      security.updated="true" \
      version="secure-1.0"

# Health check with proper error handling
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:5000/health', timeout=5)" || exit 1

# Start the application
CMD ["python", "app.py"]