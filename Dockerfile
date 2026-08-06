# ==== BUILD STAGE ====
# First container: builds the application
FROM node:22-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Build the application
RUN npm run build


# ==== PRODUCTION STAGE ====
# Second container: runs the application (much smaller)
FROM node:22-alpine

# Set working directory
WORKDIR /app

# Copy only package files from builder
COPY package*.json ./

# Install only production dependencies
RUN npm install --production

# Copy built application from builder stage
COPY --from=builder /app/dist /app/dist

# Tell Express to serve the built React frontend and use production error messages.
# Without this the static-file block in index.ts is skipped, causing GET / → 404.
ENV NODE_ENV=production

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Run the application
CMD ["node", "dist/server.js"]