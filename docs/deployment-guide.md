# Fabric Docker 一体化部署实战

> 从零开始部署 Fabric AI 增强框架，包含 Web UI、REST API 和 MCP Server

## 📋 项目背景

[Fabric](https://github.com/danielmiessler/fabric) 是一个强大的 AI 增强框架，核心理念是用 AI 来增强人类能力。它提供了 233+ 个精心设计的 AI 提示词模板（Patterns），可以快速完成各种 AI 任务。

本文记录了将 Fabric 打包成 All-in-One Docker 镜像并部署到生产环境的完整过程。

## 🎯 目标架构

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
```

## 🛠️ 实施步骤

### 1. 问题诊断：容器 Unhealthy

部署后发现容器状态显示 `unhealthy`，健康检查连续失败 2475 次：

```bash
$ docker inspect fabric --format='{{json .State.Health}}'
{
  "Status": "unhealthy",
  "FailingStreak": 2475,
  "Log": [
    {
      "ExitCode": 7,
      "Output": "curl: (7) Failed to connect to localhost port 8180"
    }
  ]
}
```

**根因分析**：`fabric-api` 进程虽然显示 RUNNING，但实际上没有绑定到 8180 端口。

**解决方案**：修改 supervisord 配置，添加 stdin 重定向：

```ini
[program:fabric-api]
command=/bin/sh -c "exec /usr/local/bin/fabric --serve --address :8180 < /dev/null"
```

### 2. 多阶段 Docker 构建

创建高效的多阶段 Dockerfile：

```dockerfile
# Stage 1: Build Go binary
FROM golang:1.24-alpine AS go-builder
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /fabric ./cmd/fabric

# Stage 2: Build Web UI
FROM node:20-alpine AS web-builder
WORKDIR /web
RUN apk add --no-cache git
COPY web/package.json ./
RUN npm install --legacy-peer-deps && npm install @sveltejs/adapter-node
COPY web/ ./
RUN sed -i "s|adapter-auto|adapter-node|g" svelte.config.js
RUN npm run build

# Stage 3: Final image
FROM alpine:3.19
RUN apk add --no-cache ca-certificates python3 py3-pip supervisor nodejs npm
COPY --from=go-builder /fabric /usr/local/bin/fabric
COPY --from=web-builder /web/build /app/web/build
```

### 3. Supervisor 进程管理

使用 Supervisor 管理三个服务：

```ini
[program:web-ui]
command=node /app/web/build/index.js
environment=PORT="8080",ORIGIN="https://fabric.aws.xin"

[program:fabric-api]
command=/bin/sh -c "exec /usr/local/bin/fabric --serve --address :8180 < /dev/null"

[program:mcp-server]
command=python3 /app/mcp_server.py
environment=MCP_PORT="8181"
```

### 4. Nginx 反向代理配置

在 Nginx 服务器上配置域名转发：

```nginx
server {
    listen 443 ssl;
    server_name fabric.aws.xin;

    # Web UI - 默认路由
    location / {
        proxy_pass http://44.193.212.118:5173;
    }

    # API 路由 - 转发到 REST API
    location ~ ^/(patterns|contexts|sessions|chat|config|models|strategies|swagger) {
        proxy_pass http://44.193.212.118:8180;
    }
}
```

### 5. DNS 配置

使用 Cloudflare 创建 DNS 记录：

```
fabric.aws.xin -> 107.172.39.47 (Proxied)
```

## ✅ 最终测试结果

| 服务 | 端口 | 状态 | URL |
|------|------|------|-----|
| Web UI | 8080 | ✅ 正常 | https://fabric.aws.xin/ |
| REST API | 8180 | ✅ 正常 | https://fabric.aws.xin/patterns/names |
| Swagger | 8180 | ✅ 正常 | https://fabric.aws.xin/swagger/index.html |
| MCP Server | 8181 | ✅ 正常 | 内部服务 |

### API 测试

```bash
# 获取 Patterns 列表
$ curl -s https://fabric.aws.xin/patterns/names | jq '.[0:5]'
["agility_story", "ai", "analyze_answers", "analyze_bill", "analyze_bill_short"]

# 获取 Models 列表
$ curl -s https://fabric.aws.xin/models/names | jq '.models[0:3]'
["claude-3-5-haiku-20241022", "claude-3-5-haiku-latest", "claude-3-7-sonnet-20250219"]

# 健康检查
$ docker inspect fabric --format='{{.State.Health.Status}}'
healthy
```

## 📊 资源统计

| 资源类型 | 数量 |
|----------|------|
| Patterns | 233 |
| Models | 16 |
| Vendors | 1 (Anthropic) |
| Strategies | 9 |

## 🔑 关键经验

1. **进程管理**：Go 程序在 Supervisor 下可能需要 stdin 重定向
2. **SvelteKit 部署**：需要使用 `adapter-node` 而非 `adapter-auto`
3. **健康检查**：设置合理的 `start_period` 等待服务启动
4. **多阶段构建**：显著减小最终镜像体积

## 🔗 相关链接

- **GitHub**: https://github.com/neosun100/fabric-docker
- **线上服务**: https://fabric.aws.xin
- **原项目**: https://github.com/danielmiessler/fabric

---

*记录时间：2026-01-03*
