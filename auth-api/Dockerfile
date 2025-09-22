# Stage 1: Build the Go binary
FROM golang:1.19-alpine AS builder

WORKDIR /app

# Copy all source files first
COPY . .

# Initialize Go modules, tidy dependencies, and then download them
RUN go mod init auth-api && go mod tidy
RUN go mod download

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -o /auth-api

# Stage 2: Create the final lightweight image
FROM alpine:latest

WORKDIR /

# Copy the binary from the builder stage
COPY --from=builder /auth-api /auth-api

# Expose the port the app runs on
EXPOSE 8000

# Command to run the executable
ENTRYPOINT ["/auth-api"]
