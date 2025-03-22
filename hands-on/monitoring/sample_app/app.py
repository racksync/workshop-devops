from prometheus_client import start_http_server, Counter, Gauge, Histogram
import random
import time
import threading

# Create metrics
REQUEST_COUNT = Counter('app_requests_total', 'Total app HTTP requests')
REQUEST_INPROGRESS = Gauge('app_requests_inprogress', 'Number of in-progress HTTP requests')
REQUEST_DURATION = Histogram('app_request_duration_seconds', 'HTTP request duration in seconds',
                            buckets=[0.1, 0.2, 0.3, 0.5, 0.7, 1, 2, 5, 10])

# Simulate a function that processes requests
def process_request():
    REQUEST_COUNT.inc()
    REQUEST_INPROGRESS.inc()
    
    # Simulate random processing time
    duration = random.uniform(0.1, 1.5)
    time.sleep(duration)
    
    REQUEST_INPROGRESS.dec()
    REQUEST_DURATION.observe(duration)
    
    print(f"Processed request in {duration:.2f} seconds")

# Generate load in a separate thread
def generate_load():
    while True:
        process_request()
        time.sleep(random.uniform(0.1, 0.3))

if __name__ == '__main__':
    # Start metrics server
    start_http_server(8000)
    print("Metrics server started on port 8000")
    
    # Start load generation in a separate thread
    load_thread = threading.Thread(target=generate_load, daemon=True)
    load_thread.start()
    
    # Keep the main thread running
    while True:
        time.sleep(1)
