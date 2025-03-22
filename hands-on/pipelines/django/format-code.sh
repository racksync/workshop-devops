#!/bin/bash

# Build the lint image if it doesn't exist
if ! docker image inspect django-lint-image >/dev/null 2>&1; then
    echo "Building linting Docker image..."
    docker build -t django-lint-image -f Dockerfile.lint .
fi

# Format Python code with Black
echo "Formatting Python code with Black..."
docker run -v "$(pwd)":/app:rw --rm django-lint-image black .

echo "Code formatting complete!"

# Run check to verify
echo "Verifying formatting..."
docker run --rm django-lint-image black --check .

echo "All done!"