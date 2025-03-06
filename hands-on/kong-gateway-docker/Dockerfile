# Use the official Kong image as the base
FROM kong:3.6

# Switch to root user to allow package installation
USER root

# Update package lists and install inetutils-ping and curl
RUN apt-get update && \
    apt-get install -y inetutils-ping curl && \
    rm -rf /var/lib/apt/lists/*

# Revert back to the kong user for running Kong
USER kong
