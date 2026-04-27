from fastapi import FastAPI # python module for building  APIs
from transformers import pipeline # python function for running AI models
import time 


app = FastAPI() # application object 

classifier = pipeline("sentiment-analysis",model="distilbert-base-uncased-finetuned-sst-2-english") # pipeline function that specifies what type of model we are creating

@app.get("/health") # when a get request hits the health endpoint run thefunction below
def health(text: str): # function to return status response 
    return {"status: ok"}


@app.post("/predict")# when a post request hits the predict endpoint run the function below
def predict(text: str): # function to calculate time, latency and return results of sentiment analysis of string values
    start = time.time()
    result = classifier(text[:512]) 
    latency = time.time() - start

    return {"text": text,
            "sentiment": result [0]["label"], # returns the first item in the list by the 0 index and gives the value for the label key
            "confidence":round(result[0]["score"],3), # returns the score 
            "latency_ms": round(latency * 1000, 2) # calculates the latency
            }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)





from prometheus_client import Counter, Histogram, generate_latest # python prometheus library and counter and Histogram modules
import time

# Metrics
request_count = Counter('sentiment_requests_total', 'Total requests',['endpoint']) # (name, description, label_names) for counter object
prediction_latency = Histogram('sentiment_prediction_latency_ms', 'Prediction latency in ms')# (name, description, label_names) for histogram object
errors = Counter('sentiment_errors_total', 'Total errors')

@app.post("/predict")
def predict(text: str):
    request_count.labels(endpoint="predict").inc() # defines the endpoint/label value and increments by 1
    
    try: # prediction function
        start = time.time()
        result = classifier(text[:512])
        latency = time.time() - start
        prediction_latency.observe(latency * 1000)

        return {"text" : text, "sentiment": result[0]["label"],"confidence": round(result[0]["score"], 3)}


    except Exception as e: 
        errors.inc()# increment the errors counter
        raise

@app.get("/metrics")
def metrics(): 
    return generate_latest() 