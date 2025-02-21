# Build stage
FROM node:alpine AS build
WORKDIR /app
COPY react-app/package*.json ./
RUN npm install
COPY react-app/ ./
RUN npm run build
# Debug: verify build output
RUN ls -lah /app

# Production stage
COPY  react-app/dist /usr/share/nginx/html
EXPOSE 8001
CMD ["nginx", "-g", "daemon off;"]