# base image
FROM python:3.11-slim 


# Set working directory
WORKDIR /app

# Copy requirements  and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# copy application code
COPY app.py .

#Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 CMD python -c "import requests; requests requests.get('http://localhost:8000/health')"

# Run the app
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]



