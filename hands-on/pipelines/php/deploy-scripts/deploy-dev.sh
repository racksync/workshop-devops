#!/bin/bash

# This script is used by Bitbucket Pipelines to deploy to dev environment

# Load the docker image
docker load -i /tmp/php-app-image.tar

# Remove existing container if it exists
docker rm -f ${CONTAINER_NAME} || true

# Ensure network exists
docker network create backend || true

# Start new container
docker run -d -p ${PORT}:80 --network backend --name ${CONTAINER_NAME} ${IMAGE_NAME}

# Clean up old images (keep only 3 latest)
docker image prune -a --filter "until=72h" --force
