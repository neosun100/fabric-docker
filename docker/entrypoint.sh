#!/bin/sh
set -e

# Initialize fabric config if needed
init_config() {
    if [ ! -f "$FABRIC_CONFIG_DIR/.env" ]; then
        echo "Initializing Fabric configuration..."
        mkdir -p "$FABRIC_CONFIG_DIR/patterns" "$FABRIC_CONFIG_DIR/contexts" "$FABRIC_CONFIG_DIR/sessions" "$FABRIC_CONFIG_DIR/strategies"
        
        # Copy default patterns
        if [ -d "/app/data/patterns" ]; then
            cp -r /app/data/patterns/* "$FABRIC_CONFIG_DIR/patterns/" 2>/dev/null || true
        fi
        
        # Copy default strategies
        if [ -d "/app/data/strategies" ]; then
            cp -r /app/data/strategies/* "$FABRIC_CONFIG_DIR/strategies/" 2>/dev/null || true
        fi
        
        # Create .env file
        cat > "$FABRIC_CONFIG_DIR/.env" << EOF
OPENAI_API_KEY=${OPENAI_API_KEY:-}
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY:-}
GEMINI_API_KEY=${GEMINI_API_KEY:-}
OLLAMA_HOST=${OLLAMA_HOST:-}
DEFAULT_MODEL=${DEFAULT_MODEL:-gpt-4o}
DEFAULT_VENDOR=${DEFAULT_VENDOR:-openai}
EOF
        echo "Configuration initialized at $FABRIC_CONFIG_DIR"
    fi
}

# Start mode
MODE=${1:-all}

case "$MODE" in
    api)
        init_config
        echo "Starting Fabric REST API on port ${PORT:-8180}..."
        exec fabric --serve --address ":${PORT:-8180}" ${API_KEY:+--api-key "$API_KEY"}
        ;;
    mcp)
        init_config
        echo "Starting MCP Server on port ${MCP_PORT:-8181}..."
        exec python3 /app/mcp_server.py
        ;;
    all)
        init_config
        echo "Starting all services (API + MCP)..."
        exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
        ;;
    setup)
        echo "Running Fabric setup..."
        exec fabric --setup
        ;;
    *)
        # Pass through to fabric CLI
        exec fabric "$@"
        ;;
esac
