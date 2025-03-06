# Stage 1: Build the React app
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Debug Node.js version and package info
RUN node --version && npm --version
RUN cat package.json

# Run build with more diagnostics
RUN NODE_OPTIONS="--trace-warnings" npm run build || (echo "Build failed with error code $?" && ls -la)

# Create a directory for nginx, handle missing build directories
RUN mkdir -p /app/output && \
    if [ -d "/app/build" ]; then \
      echo "Found /app/build directory" && \
      cp -r /app/build/* /app/output/; \
    elif [ -d "/app/dist" ]; then \
      echo "Found /app/dist directory" && \
      cp -r /app/dist/* /app/output/; \
    else \
      echo "No build or dist directory found. Contents of /app:" && \
      ls -la /app; \
    fi

# Stage 2: Serve the build using Nginx
FROM nginx:stable-alpine
COPY --from=build /app/output /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
