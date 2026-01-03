#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker not found. Please install Docker first."
        exit 1
    fi
    log_success "Docker found"
}

# Check docker-compose
check_compose() {
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    elif docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    else
        log_error "docker-compose not found"
        exit 1
    fi
    log_success "Docker Compose found: $COMPOSE_CMD"
}

# Check ports
check_ports() {
    local ports=("${PORT:-8180}" "${WEB_PORT:-5173}" "${MCP_PORT:-8181}")
    for port in "${ports[@]}"; do
        if ss -tlnp 2>/dev/null | grep -q ":${port} " || netstat -tlnp 2>/dev/null | grep -q ":${port} "; then
            log_warn "Port $port is already in use"
            log_info "Please modify .env file to use different ports"
        fi
    done
}

# Setup environment
setup_env() {
    if [ ! -f .env ]; then
        if [ -f .env.example ]; then
            cp .env.example .env
            log_info "Created .env from .env.example"
            log_warn "Please edit .env and add your API keys"
        fi
    else
        log_success ".env file exists"
    fi
    
    # Load environment
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    fi
}

# Build and start
start_services() {
    log_info "Building Docker image..."
    $COMPOSE_CMD build
    
    log_info "Starting services..."
    $COMPOSE_CMD up -d
    
    log_success "Services started!"
}

# Show access info
show_info() {
    echo ""
    echo "=========================================="
    echo -e "${GREEN}Fabric is running!${NC}"
    echo "=========================================="
    echo ""
    echo -e "🌐 ${BLUE}Web UI:${NC}     http://0.0.0.0:${WEB_PORT:-5173}"
    echo -e "🔌 ${BLUE}REST API:${NC}   http://0.0.0.0:${PORT:-8180}"
    echo -e "📚 ${BLUE}Swagger:${NC}    http://0.0.0.0:${PORT:-8180}/swagger/index.html"
    echo -e "🤖 ${BLUE}MCP Server:${NC} http://0.0.0.0:${MCP_PORT:-8181}"
    echo ""
    echo "Commands:"
    echo "  View logs:    $COMPOSE_CMD logs -f"
    echo "  Stop:         $COMPOSE_CMD down"
    echo "  Restart:      $COMPOSE_CMD restart"
    echo ""
}

# Main
main() {
    cd "$(dirname "$0")"
    
    log_info "Starting Fabric..."
    
    check_docker
    check_compose
    setup_env
    check_ports
    start_services
    show_info
}

main "$@"
