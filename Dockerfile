# Dockerfile
FROM golang:1.16-alpine AS builder

WORKDIR /app

# Initialize Go module
RUN go mod init myapp

COPY . .

# Build the Go application
RUN go build -o main .

# Use a smaller base image for the final Docker image
FROM alpine:latest

WORKDIR /root/

# Copy the built executable from the builder stage
COPY --from=builder /app/main .

# Expose port 8080
EXPOSE 8080

# Run the Go application
CMD ["./main"]

