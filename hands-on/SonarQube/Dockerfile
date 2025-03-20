FROM node:16-alpine AS builder

WORKDIR /app

# Install dependencies with security measures
COPY package*.json ./
RUN npm install --omit=dev \
    --registry=https://registry.npmjs.org/ \
    && npm audit fix --force \
    && npm cache clean --force

# Copy source code
COPY . .

# Final stage
FROM node:16-alpine

# Run as non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy only necessary files from builder
#COPY --from=builder --chown=appuser:appgroup /app ./
COPY --from=builder --chown=root:root /app ./


# Set non-sensitive environment variables
ENV NODE_ENV=production
ENV SECURITY_HEADERS=true
ENV MAX_REQUEST_SIZE=1mb

# Switch to non-root user
USER appuser

EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
#CMD wget -q --spider http://localhost:3000/health || exit 1


# Use either secrets or environment variable for session secret
CMD ["sh", "-c", "export SESSION_SECRET=$([ -f /run/secrets/session_secret ] && cat /run/secrets/session_secret || echo ${SESSION_SECRET:-default_secret}) && node app.js"]
#ENTRYPOINT ["wget", "-q", "--spider", "http://localhost:3000/health"] || exit 1
