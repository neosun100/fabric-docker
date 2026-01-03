# Fabric MCP 使用指南

## 概述

Fabric MCP Server 提供 HTTP API 接口，可与支持 MCP 的 AI 助手集成，或直接通过 HTTP 调用。

## 服务地址

- **MCP API**: `http://localhost:8181`
- **REST API**: `http://localhost:8180`
- **Swagger UI**: `http://localhost:8180/swagger/index.html`

## 可用工具/端点

### 1. 列出 Patterns
```bash
curl http://localhost:8181/patterns
```

### 2. 列出 Models
```bash
curl http://localhost:8181/models
```

### 3. 列出 Contexts
```bash
curl http://localhost:8181/contexts
```

### 4. 运行 Pattern ⭐
```bash
curl -X POST http://localhost:8181/run_pattern \
  -H "Content-Type: application/json" \
  -d '{
    "pattern": "summarize",
    "input_text": "Your long text here...",
    "model": "gpt-4o"
  }'
```

**参数**:
- `pattern` (必需): Pattern 名称
- `input_text` (必需): 要处理的文本
- `model` (可选): AI 模型
- `vendor` (可选): 模型供应商
- `context` (可选): 上下文名称
- `temperature` (可选): 温度参数 (0.0-1.0)

### 5. YouTube 字幕
```bash
curl -X POST http://localhost:8181/youtube_transcript \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://youtube.com/watch?v=xxx",
    "with_timestamps": false
  }'
```

### 6. 抓取网页
```bash
curl -X POST http://localhost:8181/scrape_url \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com/article"}'
```

### 7. 获取 Pattern 内容
```bash
curl http://localhost:8181/pattern/summarize
```

### 8. 聊天
```bash
curl -X POST http://localhost:8181/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "What is quantum computing?",
    "model": "gpt-4o",
    "pattern": "explain"
  }'
```

## MCP 客户端配置

### Claude Desktop 配置

在 `~/.config/claude/claude_desktop_config.json` 中添加：

```json
{
  "mcpServers": {
    "fabric": {
      "url": "http://localhost:8181",
      "transport": "http"
    }
  }
}
```

## 与 REST API 的区别

| 特性 | MCP API (8181) | REST API (8180) |
|------|----------------|-----------------|
| 用途 | 工具调用 | 完整 API |
| Swagger | 无 | 有 |
| 流式响应 | 无 | 有 (SSE) |
| 认证 | 无 | 可选 API Key |

## 使用示例

### 示例 1: 总结 YouTube 视频

```bash
# 1. 获取字幕
TRANSCRIPT=$(curl -s -X POST http://localhost:8181/youtube_transcript \
  -H "Content-Type: application/json" \
  -d '{"url": "https://youtube.com/watch?v=xxx"}' | jq -r '.transcript')

# 2. 总结内容
curl -X POST http://localhost:8181/run_pattern \
  -H "Content-Type: application/json" \
  -d "{\"pattern\": \"summarize\", \"input_text\": \"$TRANSCRIPT\"}"
```

### 示例 2: 分析网页内容

```bash
# 1. 抓取网页
CONTENT=$(curl -s -X POST http://localhost:8181/scrape_url \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com/article"}' | jq -r '.content')

# 2. 提取智慧
curl -X POST http://localhost:8181/run_pattern \
  -H "Content-Type: application/json" \
  -d "{\"pattern\": \"extract_wisdom\", \"input_text\": \"$CONTENT\"}"
```

## 错误处理

所有端点返回统一格式：

成功：
```json
{
  "success": true,
  "output": "...",
  "error": null
}
```

失败：
```json
{
  "success": false,
  "output": "",
  "error": "Error message"
}
```

## 端口配置

默认端口:
- REST API: `8180`
- MCP API: `8181`

可通过环境变量修改：
```bash
PORT=9080 MCP_PORT=9081 docker-compose up
```
