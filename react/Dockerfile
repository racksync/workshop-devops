# Stage 1: Build the React app
FROM node:alpine as build
WORKDIR /app
COPY react-app/package*.json ./
RUN npm install
COPY react-app/. .
RUN npm run build

# Stage 2: Serve the build with nginx
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 8001
CMD ["nginx", "-g", "daemon off;"]
