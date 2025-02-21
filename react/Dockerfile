# Build stage
FROM node:alpine AS build
WORKDIR /app
COPY react-app/package*.json ./
RUN npm install
COPY react-app/ ./
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=build /app/build/ /usr/share/nginx/html
EXPOSE 8001
CMD ["nginx", "-g", "daemon off;"]