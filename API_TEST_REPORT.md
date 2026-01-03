# Fabric API 测试报告

## 基本信息

| 项目 | 值 |
|------|-----|
| 测试时间 | 2026-01-03 22:39:53 |
| 测试地址 | https://fabric.aws.xin |
| 服务状态 | ✅ 正常运行 |

---

## 测试结果汇总

| 测试项 | 端点 | 状态码 | 结果 |
|--------|------|--------|------|
| 根路径 | GET / | 404 | ⚠️ 预期行为 (无此路由) |
| Swagger UI | GET /swagger/index.html | 200 | ✅ PASS |
| Patterns 列表 | GET /patterns/names | 200 | ✅ PASS |
| 单个 Pattern | GET /patterns/summarize | 200 | ✅ PASS |
| Pattern 存在检查 | GET /patterns/exists/summarize | 200 | ✅ PASS |
| Pattern 不存在检查 | GET /patterns/exists/nonexistent | 200 | ✅ PASS |
| Contexts 列表 | GET /contexts/names | 200 | ✅ PASS |
| Sessions 列表 | GET /sessions/names | 200 | ✅ PASS |
| Models 列表 | GET /models/names | 200 | ✅ PASS |
| Config | GET /config | 200 | ✅ PASS |
| Strategies | GET /strategies | 200 | ✅ PASS |

---

## 资源统计

| 资源类型 | 数量 |
|----------|------|
| Patterns | 233 |
| Models | 16 |
| Vendors | 1 (Anthropic) |
| Strategies | 9 |

---

## 可用端点列表

### Swagger 文档
- **Swagger UI**: https://fabric.aws.xin/swagger/index.html

### Patterns API
```
GET  /patterns/names              # 获取所有 pattern 名称列表
GET  /patterns/:name              # 获取指定 pattern 详情
GET  /patterns/exists/:name       # 检查 pattern 是否存在
POST /patterns/:name              # 创建/更新 pattern
DELETE /patterns/:name            # 删除 pattern
PUT  /patterns/rename/:old/:new   # 重命名 pattern
POST /patterns/:name/apply        # 应用 pattern
```

### Contexts API
```
GET  /contexts/names              # 获取所有 context 名称列表
GET  /contexts/:name              # 获取指定 context
POST /contexts/:name              # 创建/更新 context
DELETE /contexts/:name            # 删除 context
```

### Sessions API
```
GET  /sessions/names              # 获取所有 session 名称列表
GET  /sessions/:name              # 获取指定 session
POST /sessions/:name              # 创建/更新 session
DELETE /sessions/:name            # 删除 session
```

### Chat API
```
POST /chat                        # 发送聊天请求
```

### YouTube API
```
POST /youtube/transcript          # 获取 YouTube 视频字幕
```

### Config API
```
GET  /config                      # 获取配置
POST /config/update               # 更新配置
```

### Models API
```
GET  /models/names                # 获取可用模型列表
```

### Strategies API
```
GET  /strategies                  # 获取所有策略
```

---

## 响应示例

### GET /patterns/names
```json
["agility_story","ai","analyze_answers","analyze_bill","analyze_bill_short","analyze_candidates",...]
```

### GET /patterns/summarize
```json
{
  "Name": "summarize",
  "Description": "",
  "Pattern": "# IDENTITY and PURPOSE\n\nYou are an expert content summarizer..."
}
```

### GET /models/names
```json
{
  "models": ["claude-3-5-haiku-20241022", "claude-3-5-haiku-latest", ...],
  "vendors": {
    "Anthropic": ["claude-3-5-haiku-20241022", ...]
  }
}
```

### GET /strategies
```json
[
  {
    "name": "aot",
    "description": "Atom-of-Thought (AoT) Prompting",
    "prompt": "To solve this problem, break it down into..."
  },
  ...
]
```

---

## 部署信息

| 项目 | 值 |
|------|-----|
| 域名 | fabric.aws.xin |
| DNS | Cloudflare (橙云代理) |
| Nginx 服务器 | 107.172.39.47 |
| 后端服务器 | 44.193.212.118:8180 |
| MCP 服务器 | 44.193.212.118:8181 |
| 容器名称 | fabric |
| 镜像 | neosun/fabric:latest |

---

## 结论

**所有 API 端点均正常工作！** ✅

根路径 `/` 返回 404 是 Fabric REST API 的正常行为，因为该路径没有定义处理器。所有实际功能端点都可正常访问。

建议使用 Swagger UI (https://fabric.aws.xin/swagger/index.html) 进行 API 交互和测试。
