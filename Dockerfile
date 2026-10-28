FROM python:3.9-slim

LABEL org.opencontainers.image.title="DevOps Capstone Account Service"
LABEL org.opencontainers.image.source="https://github.com/NurasylAitu/devops-capstone-project"


# === Create working folder and install dependencies ===
WORKDIR /app
COPY requirements.txt .
# --no-cache-dir is used to keep image small
RUN pip install --no-cache-dir -r /app/requirements.txt


# === Copy application contents ===
COPY service/ ./service/


# === Switch to non-root user (defined by IBM): ===
RUN useradd --uid 1000 theia && chown -R theia /app
USER theia


# === Run service ===
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1
# According to Docker Terminal: 
# "JSON arguments recommended for CMD to prevent unintended behavior
# related to OS signals" (JSON arguments is the exec form, see Docker doc).
CMD ["gunicorn", "--bind=0.0.0.0:8080", "--log-level=info" , "service:app"]

