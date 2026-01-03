# Fabric All-in-One Docker Image
# UI + API + MCP 三模式支持

# Stage 1: Build Go binary
FROM golang:1.24-alpine AS go-builder

WORKDIR /src
RUN apk add --no-cache git

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go mod tidy && CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /fabric ./cmd/fabric

# Stage 2: Build Web UI
FROM node:20-alpine AS web-builder

WORKDIR /web

# Install git for npm dependencies
RUN apk add --no-cache git

# Copy package files and install adapter-node
COPY web/package.json ./
RUN npm install --legacy-peer-deps && npm install @sveltejs/adapter-node

COPY web/ ./

# Replace adapter-auto with adapter-node in svelte.config.js
RUN sed -i "s|from '@sveltejs/adapter-auto'|from '@sveltejs/adapter-node'|g" svelte.config.js

# Build
ENV PUBLIC_API_BASE_URL=""
RUN npm run build

# Stage 3: Final image
FROM alpine:3.19

LABEL org.opencontainers.image.title="Fabric All-in-One"
LABEL org.opencontainers.image.description="Fabric AI augmentation framework with UI, API and MCP support"
LABEL org.opencontainers.image.source="https://github.com/danielmiessler/fabric"
LABEL maintainer="neosun"

# Install runtime dependencies including Node.js
RUN apk add --no-cache \
    ca-certificates \
    yt-dlp \
    python3 \
    py3-pip \
    supervisor \
    curl \
    tzdata \
    nodejs \
    npm \
    && mkdir -p /root/.config/fabric /app /var/log/supervisor /tmp/fabric /app/web

# Install Python dependencies for MCP
RUN pip3 install --break-system-packages --no-cache-dir \
    fastapi \
    uvicorn \
    httpx \
    pydantic

# Copy built binary
COPY --from=go-builder /fabric /usr/local/bin/fabric

# Copy Web UI build (SvelteKit Node adapter output)
COPY --from=web-builder /web/build /app/web/build
COPY --from=web-builder /web/package.json /app/web/
COPY --from=web-builder /web/node_modules /app/web/node_modules

# Copy patterns and strategies data
COPY data/patterns /app/data/patterns
COPY data/strategies /app/data/strategies

# Copy Docker config files
COPY docker/mcp_server.py /app/mcp_server.py
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/entrypoint.sh /entrypoint.sh

# Copy swagger docs
COPY docs/swagger.yaml /app/docs/swagger.yaml
COPY docs/swagger.json /app/docs/swagger.json

RUN chmod +x /entrypoint.sh

# Environment variables
ENV PORT=8180
ENV MCP_PORT=8181
ENV WEB_PORT=8080
ENV FABRIC_CONFIG_DIR=/root/.config/fabric
ENV TZ=Asia/Shanghai
ENV NODE_ENV=production

EXPOSE 8080 8180 8181

WORKDIR /app

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD curl -f http://localhost:${PORT}/patterns/names || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["all"]
