#!/bin/bash

# Build the Docker image
# docker build -t mathisve/do-sample-app .

docker buildx rm mybuilder || true
docker buildx create --use --name mybuilder --driver docker
docker buildx build --platform linux/amd64 -t mathisve/do-sample-app --push .

# Run the Docker container, exposing port 8080
# docker run -p 8080:8080 my-go-app