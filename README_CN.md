<div align="center">

# 🧠 Fabric Docker

[English](README.md) | [简体中文](README_CN.md) | [繁體中文](README_TW.md) | [日本語](README_JP.md)

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://hub.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/neosun100/fabric-docker?style=social)](https://github.com/neosun100/fabric-docker)

**[Fabric](https://github.com/danielmiessler/fabric) 的一体化 Docker 部署方案 - 集成 Web UI、REST API 和 MCP 服务器的 AI 增强框架**

<img src="docs/images/fabric-logo-gif.gif" alt="Fabric Logo" width="200"/>

</div>

---

## ✨ 功能特性

| 功能 | 描述 |
|------|------|
| 🌐 **Web UI** | 基于 Svelte 的精美 Web 界面，用于模式管理 |
| 🔌 **REST API** | 功能完整的 HTTP API，带 Swagger 文档 |
| 🤖 **MCP 服务器** | 模型上下文协议服务器，支持 AI 助手集成 |
| 📦 **一体化部署** | 单容器包含所有服务 |
| 🎯 **233+ 模式** | 预置的 AI 提示词模式，覆盖各种任务 |
| 🔧 **多模型支持** | 支持 OpenAI、Anthropic、Gemini、Ollama 等 |

## 🚀 快速开始

```bash
# 克隆仓库
git clone https://github.com/neosun100/fabric-docker.git
cd fabric-docker

# 复制环境配置文件
cp .env.example .env

# 使用 Docker Compose 启动
docker compose up -d

# 访问服务
# Web UI:    http://localhost:5173
# REST API:  http://localhost:8180
# Swagger:   http://localhost:8180/swagger/index.html
# MCP:       http://localhost:8181
```

## 📦 安装部署

### 前置条件

- Docker 20.10+
- Docker Compose 2.0+
- 至少一个 AI 服务商的 API 密钥（OpenAI、Anthropic 等）

### 方式一：Docker Compose（推荐）

1. **克隆仓库**
   ```bash
   git clone https://github.com/neosun100/fabric-docker.git
   cd fabric-docker
   ```

2. **配置环境变量**
   ```bash
   cp .env.example .env
   # 编辑 .env 文件，添加你的 API 密钥
   ```

3. **启动服务**
   ```bash
   docker compose up -d
   ```

4. **验证部署**
   ```bash
   # 检查容器健康状态
   docker ps
   
   # 测试 API
   curl http://localhost:8180/patterns/names
   ```

### 方式二：Docker Run

```bash
# 构建镜像
docker build -t fabric:latest .

# 运行容器
docker run -d \
  --name fabric \
  -p 5173:8080 \
  -p 8180:8180 \
  -p 8181:8181 \
  -e OPENAI_API_KEY=你的密钥 \
  -e ANTHROPIC_API_KEY=你的密钥 \
  -v fabric-config:/root/.config/fabric \
  fabric:latest
```

## ⚙️ 配置说明

### 环境变量

| 变量 | 描述 | 默认值 |
|------|------|--------|
| `PORT` | REST API 端口 | `8180` |
| `WEB_PORT` | Web UI 端口（主机映射） | `5173` |
| `MCP_PORT` | MCP 服务器端口 | `8181` |
| `OPENAI_API_KEY` | OpenAI API 密钥 | - |
| `ANTHROPIC_API_KEY` | Anthropic API 密钥 | - |
| `GEMINI_API_KEY` | Google Gemini API 密钥 | - |
| `OLLAMA_HOST` | Ollama 服务器地址 | - |
| `DEFAULT_MODEL` | 默认 AI 模型 | `gpt-4o` |
| `DEFAULT_VENDOR` | 默认 AI 服务商 | `openai` |
| `API_KEY` | 可选的 API 认证密钥 | - |
| `TZ` | 时区 | `Asia/Shanghai` |

### docker-compose.yml 示例

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

## 📖 使用指南

### Web UI

访问 `http://localhost:5173` 使用 Web 界面：

- 浏览和搜索 233+ 个模式
- 使用自定义输入执行模式
- 管理上下文和会话
- 实时聊天界面

### REST API

```bash
# 列出所有模式
curl http://localhost:8180/patterns/names

# 获取特定模式
curl http://localhost:8180/patterns/summarize

# 检查模式是否存在
curl http://localhost:8180/patterns/exists/summarize

# 获取可用模型
curl http://localhost:8180/models/names

# 获取配置
curl http://localhost:8180/config

# 获取策略
curl http://localhost:8180/strategies
```

### API 端点

| 端点 | 方法 | 描述 |
|------|------|------|
| `/patterns/names` | GET | 列出所有模式名称 |
| `/patterns/:name` | GET | 获取模式详情 |
| `/patterns/exists/:name` | GET | 检查模式是否存在 |
| `/contexts/names` | GET | 列出所有上下文 |
| `/sessions/names` | GET | 列出所有会话 |
| `/models/names` | GET | 列出可用模型 |
| `/config` | GET | 获取配置 |
| `/strategies` | GET | 列出策略 |
| `/chat` | POST | 发送聊天请求 |
| `/swagger/index.html` | GET | Swagger UI |

### MCP 集成

MCP 服务器使 AI 助手（如 Claude Desktop）能够直接使用 Fabric 模式。

在 MCP 客户端中配置：
```json
{
  "mcpServers": {
    "fabric": {
      "url": "http://localhost:8181"
    }
  }
}
```

## 🏗️ 架构设计

```
┌─────────────────────────────────────────────────────────┐
│                    Docker 容器                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   Web UI    │  │  REST API   │  │ MCP Server  │     │
│  │   (Node)    │  │   (Go)      │  │  (Python)   │     │
│  │   :8080     │  │   :8180     │  │   :8181     │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│         │                │                │             │
│         └────────────────┼────────────────┘             │
│                          │                              │
│              ┌───────────┴───────────┐                  │
│              │    Fabric 核心        │                  │
│              │  (233+ 模式)          │                  │
│              └───────────────────────┘                  │
└─────────────────────────────────────────────────────────┘
         │              │              │
    端口 5173      端口 8180      端口 8181
```

## 🛠️ 技术栈

| 组件 | 技术 |
|------|------|
| 后端 | Go (Gin 框架) |
| Web UI | Svelte + SvelteKit + Tailwind CSS |
| MCP 服务器 | Python (FastAPI + Uvicorn) |
| 进程管理 | Supervisor |
| 容器 | Alpine Linux |
| 构建 | 多阶段 Docker 构建 |

## 📁 项目结构

```
fabric-docker/
├── Dockerfile              # 多阶段构建
├── docker-compose.yml      # Compose 配置
├── docker/
│   ├── entrypoint.sh      # 容器入口点
│   ├── supervisord.conf   # 进程管理配置
│   ├── mcp_server.py      # MCP 服务器实现
│   └── nginx.conf         # Nginx 配置（可选）
├── data/
│   ├── patterns/          # 233+ AI 模式
│   └── strategies/        # 提示词策略
├── web/                   # Svelte Web UI
├── cmd/                   # Go 命令
├── internal/              # Go 内部包
└── docs/                  # 文档
```

## 🔧 故障排除

### 容器显示 "unhealthy"

```bash
# 查看日志
docker logs fabric

# 重启 fabric-api 服务
docker exec fabric supervisorctl restart fabric-api

# 验证端口
docker exec fabric netstat -tlnp
```

### API 无响应

```bash
# 检查服务是否运行
docker exec fabric supervisorctl status

# 手动重启
docker compose restart
```

### 端口冲突

编辑 `.env` 修改端口映射：
```bash
PORT=8280
WEB_PORT=5273
MCP_PORT=8281
```

## 🤝 贡献指南

欢迎贡献！请随时提交 Pull Request。

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- [Fabric](https://github.com/danielmiessler/fabric) - 原始 AI 增强框架
- [Daniel Miessler](https://github.com/danielmiessler) - Fabric 创建者

---

## ⭐ Star 历史

[![Star History Chart](https://api.star-history.com/svg?repos=neosun100/fabric-docker&type=Date)](https://star-history.com/#neosun100/fabric-docker)

## 📱 关注公众号

<div align="center">

![公众号](https://img.aws.xin/uPic/扫码_搜索联合传播样式-标准色版.png)

</div>
