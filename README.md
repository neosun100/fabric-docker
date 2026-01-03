<div align="center">

# 🧠 Fabric Docker

[English](README.md) | [简体中文](README_CN.md) | [繁體中文](README_TW.md) | [日本語](README_JP.md)

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://hub.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/neosun100/fabric-docker?style=social)](https://github.com/neosun100/fabric-docker)

**All-in-One Docker deployment for [Fabric](https://github.com/danielmiessler/fabric) - AI augmentation framework with Web UI, REST API, and MCP Server**

<img src="docs/images/fabric-logo-gif.gif" alt="Fabric Logo" width="200"/>

</div>

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🌐 **Web UI** | Beautiful Svelte-based web interface for pattern management |
| 🔌 **REST API** | Full-featured HTTP API with Swagger documentation |
| 🤖 **MCP Server** | Model Context Protocol server for AI assistant integration |
| 📦 **All-in-One** | Single container with all services included |
| 🎯 **233+ Patterns** | Pre-loaded AI prompt patterns for various tasks |
| 🔧 **Multi-Model** | Support for OpenAI, Anthropic, Gemini, Ollama, and more |

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/neosun100/fabric-docker.git
cd fabric-docker

# Copy environment file
cp .env.example .env

# Start with Docker Compose
docker compose up -d

# Access the services
# Web UI:    http://localhost:5173
# REST API:  http://localhost:8180
# Swagger:   http://localhost:8180/swagger/index.html
# MCP:       http://localhost:8181
```

## 📦 Installation

### Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- At least one AI provider API key (OpenAI, Anthropic, etc.)

### Method 1: Docker Compose (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/neosun100/fabric-docker.git
   cd fabric-docker
   ```

2. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env and add your API keys
   ```

3. **Start services**
   ```bash
   docker compose up -d
   ```

4. **Verify deployment**
   ```bash
   # Check container health
   docker ps
   
   # Test API
   curl http://localhost:8180/patterns/names
   ```

### Method 2: Docker Run

```bash
# Pull or build the image
docker build -t fabric:latest .

# Run the container
docker run -d \
  --name fabric \
  -p 5173:8080 \
  -p 8180:8180 \
  -p 8181:8181 \
  -e OPENAI_API_KEY=your-key-here \
  -e ANTHROPIC_API_KEY=your-key-here \
  -v fabric-config:/root/.config/fabric \
  fabric:latest
```

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | REST API port | `8180` |
| `WEB_PORT` | Web UI port (host mapping) | `5173` |
| `MCP_PORT` | MCP Server port | `8181` |
| `OPENAI_API_KEY` | OpenAI API key | - |
| `ANTHROPIC_API_KEY` | Anthropic API key | - |
| `GEMINI_API_KEY` | Google Gemini API key | - |
| `OLLAMA_HOST` | Ollama server URL | - |
| `DEFAULT_MODEL` | Default AI model | `gpt-4o` |
| `DEFAULT_VENDOR` | Default AI vendor | `openai` |
| `API_KEY` | Optional API authentication | - |
| `TZ` | Timezone | `Asia/Shanghai` |

### docker-compose.yml

```yaml
services:
  fabric:
    build:
      context: .
      dockerfile: Dockerfile
    image: neosun/fabric:latest
    container_name: fabric
    restart: unless-stopped
    ports:
      - "5173:8080"    # Web UI
      - "8180:8180"    # REST API
      - "8181:8181"    # MCP Server
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY:-}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY:-}
      - DEFAULT_MODEL=gpt-4o
    volumes:
      - fabric-config:/root/.config/fabric
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8180/patterns/names"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  fabric-config:
```

## 📖 Usage

### Web UI

Access the web interface at `http://localhost:5173`:

- Browse and search 233+ patterns
- Execute patterns with custom input
- Manage contexts and sessions
- Real-time chat interface

### REST API

```bash
# List all patterns
curl http://localhost:8180/patterns/names

# Get a specific pattern
curl http://localhost:8180/patterns/summarize

# Check pattern exists
curl http://localhost:8180/patterns/exists/summarize

# Get available models
curl http://localhost:8180/models/names

# Get configuration
curl http://localhost:8180/config

# Get strategies
curl http://localhost:8180/strategies
```

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/patterns/names` | GET | List all pattern names |
| `/patterns/:name` | GET | Get pattern details |
| `/patterns/exists/:name` | GET | Check if pattern exists |
| `/contexts/names` | GET | List all contexts |
| `/sessions/names` | GET | List all sessions |
| `/models/names` | GET | List available models |
| `/config` | GET | Get configuration |
| `/strategies` | GET | List strategies |
| `/chat` | POST | Send chat request |
| `/swagger/index.html` | GET | Swagger UI |

### MCP Integration

The MCP server enables AI assistants (like Claude Desktop) to use Fabric patterns directly.

Configure in your MCP client:
```json
{
  "mcpServers": {
    "fabric": {
      "url": "http://localhost:8181"
    }
  }
}
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Docker Container                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   Web UI    │  │  REST API   │  │ MCP Server  │     │
│  │   (Node)    │  │   (Go)      │  │  (Python)   │     │
│  │   :8080     │  │   :8180     │  │   :8181     │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│         │                │                │             │
│         └────────────────┼────────────────┘             │
│                          │                              │
│              ┌───────────┴───────────┐                  │
│              │    Fabric Core        │                  │
│              │  (233+ Patterns)      │                  │
│              └───────────────────────┘                  │
└─────────────────────────────────────────────────────────┘
         │              │              │
    Port 5173      Port 8180      Port 8181
```

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| Backend | Go (Gin Framework) |
| Web UI | Svelte + SvelteKit + Tailwind CSS |
| MCP Server | Python (FastAPI + Uvicorn) |
| Process Manager | Supervisor |
| Container | Alpine Linux |
| Build | Multi-stage Docker build |

## 📁 Project Structure

```
fabric-docker/
├── Dockerfile              # Multi-stage build
├── docker-compose.yml      # Compose configuration
├── docker/
│   ├── entrypoint.sh      # Container entrypoint
│   ├── supervisord.conf   # Process manager config
│   ├── mcp_server.py      # MCP server implementation
│   └── nginx.conf         # Nginx config (optional)
├── data/
│   ├── patterns/          # 233+ AI patterns
│   └── strategies/        # Prompt strategies
├── web/                   # Svelte Web UI
├── cmd/                   # Go commands
├── internal/              # Go internal packages
└── docs/                  # Documentation
```

## 🔧 Troubleshooting

### Container shows "unhealthy"

```bash
# Check logs
docker logs fabric

# Restart fabric-api service
docker exec fabric supervisorctl restart fabric-api

# Verify ports
docker exec fabric netstat -tlnp
```

### API not responding

```bash
# Check if services are running
docker exec fabric supervisorctl status

# Manual restart
docker compose restart
```

### Port conflicts

Edit `.env` to change port mappings:
```bash
PORT=8280
WEB_PORT=5273
MCP_PORT=8281
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Fabric](https://github.com/danielmiessler/fabric) - The original AI augmentation framework
- [Daniel Miessler](https://github.com/danielmiessler) - Creator of Fabric

---

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=neosun100/fabric-docker&type=Date)](https://star-history.com/#neosun100/fabric-docker)

## 📱 Follow Me

<div align="center">

![WeChat](https://img.aws.xin/uPic/扫码_搜索联合传播样式-标准色版.png)

</div>
