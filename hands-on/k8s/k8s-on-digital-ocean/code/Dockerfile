# Use the official Golang image to build the app
FROM golang:1.20-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the Go module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the application code
COPY . .

# Build the Go application
RUN go build -o main main.go

# Use a smaller image to run the application
FROM alpine:latest

# Set up the working directory in the new image
WORKDIR /app

# Copy the built binary from the builder image
COPY --from=builder /app/main .
COPY --from=builder /app/templates ./templates

# Expose port 8080
EXPOSE 8080

# Run the binary
CMD ["./main"]