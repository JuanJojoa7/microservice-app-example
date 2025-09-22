# Stage 1: Build the static assets
FROM node:10-alpine AS builder

WORKDIR /app

# Install Python and build dependencies for node-sass
RUN apk add --no-cache python2 python2-dev make g++

COPY package.json ./
COPY package-lock.json ./
RUN npm install

COPY . .
RUN npm run build

# Stage 2: Serve the static assets with Nginx
FROM nginx:1.21-alpine

# Copy the built assets from the builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
