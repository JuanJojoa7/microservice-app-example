# Stage 1: Install dependencies
FROM node:16-alpine AS deps

WORKDIR /app

COPY package.json ./
COPY package-lock.json ./
RUN npm install

# Stage 2: Build the application
FROM node:16-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# The final image
FROM node:16-alpine

WORKDIR /app

COPY --from=builder /app ./

EXPOSE 8082

CMD ["npm", "start"]
