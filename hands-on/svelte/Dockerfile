# Build stage
FROM node:20-alpine as build

WORKDIR /app

# Copy package.json and yarn.lock
COPY ./svelte/package.json ./svelte/yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy the rest of the application code
COPY ./svelte .

# Build the application
RUN yarn build

# Production stage
FROM nginx:alpine

# Copy built assets from the build stage - using the correct output path
COPY --from=build /app/.svelte-kit/output/client /usr/share/nginx/html
# For static adapter, if you're using adapter-static, we need to copy the prerendered content too
COPY --from=build /app/.svelte-kit/output/prerendered /usr/share/nginx/html

# Copy our custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
