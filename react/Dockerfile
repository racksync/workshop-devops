# Stage 1: Build the React app
FROM node:14-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY react-app/package*.json ./
RUN npm install

# Copy the rest of the app code and build
COPY react-app/ ./
RUN npm run build

# Stage 2: Serve the app using Nginx
FROM nginx:alpine

# Remove the default Nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy the React build from the previous stage to Nginx's directory
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
