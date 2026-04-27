from prometheus_client import Counter, Histogram, generate_latest # python prometheus library and counter and Histogram modules
import time

# Metrics
request_count = Counter('sentiment_requests_total', 'Total requests',['endpoint']) # (name, description, label_names) for counter
prediction_latency = Histogram('sentiment_prediction_latency_ms', 'Prediction latency in ms')
errors = Counter('sentiment_errors_total', 'Total errors')

@app.post("/predict")
def predict(text: str):
    request_count.labels