FROM python:3.9-slim

WORKDIR /app

RUN pip install prometheus_client

COPY app.py .

CMD ["python", "app.py"]
