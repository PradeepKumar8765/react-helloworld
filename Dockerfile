# Stage 1: Build
FROM node:18 AS builder

WORKDIR /app

COPY package.json package-lock.json ./

# Install only production dependencies
RUN npm install --only=production

COPY . .

RUN npm run build

# Stage 2: Production
FROM node:18

WORKDIR /app

COPY --from=builder /app/build ./build

RUN npm install -g serve

CMD ["serve", "-s", "build"]

EXPOSE 3000
