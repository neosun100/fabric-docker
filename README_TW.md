<div align="center">

# 🧠 Fabric Docker

[English](README.md) | [简体中文](README_CN.md) | [繁體中文](README_TW.md) | [日本語](README_JP.md)

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://hub.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/neosun100/fabric-docker?style=social)](https://github.com/neosun100/fabric-docker)

**[Fabric](https://github.com/danielmiessler/fabric) 的一體化 Docker 部署方案 - 整合 Web UI、REST API 和 MCP 伺服器的 AI 增強框架**

<img src="docs/images/fabric-logo-gif.gif" alt="Fabric Logo" width="200"/>

</div>

---

## ✨ 功能特性

| 功能 | 描述 |
|------|------|
| 🌐 **Web UI** | 基於 Svelte 的精美 Web 介面，用於模式管理 |
| 🔌 **REST API** | 功能完整的 HTTP API，附帶 Swagger 文件 |
| 🤖 **MCP 伺服器** | 模型上下文協議伺服器，支援 AI 助手整合 |
| 📦 **一體化部署** | 單一容器包含所有服務 |
| 🎯 **233+ 模式** | 預置的 AI 提示詞模式，涵蓋各種任務 |
| 🔧 **多模型支援** | 支援 OpenAI、Anthropic、Gemini、Ollama 等 |

## 🚀 快速開始

```bash
# 複製儲存庫
git clone https://github.com/neosun100/fabric-docker.git
cd fabric-docker

# 複製環境設定檔
cp .env.example .env

# 使用 Docker Compose 啟動
docker compose up -d

# 存取服務
# Web UI:    http://localhost:5173
# REST API:  http://localhost:8180
# Swagger:   http://localhost:8180/swagger/index.html
# MCP:       http://localhost:8181
```

## 📦 安裝部署

### 前置條件

- Docker 20.10+
- Docker Compose 2.0+
- 至少一個 AI 服務商的 API 金鑰（OpenAI、Anthropic 等）

### 方式一：Docker Compose（推薦）

1. **複製儲存庫**
   ```bash
   git clone https://github.com/neosun100/fabric-docker.git
   cd fabric-docker
   ```

2. **設定環境變數**
   ```bash
   cp .env.example .env
   # 編輯 .env 檔案，新增您的 API 金鑰
   ```

3. **啟動服務**
   ```bash
   docker compose up -d
   ```

4. **驗證部署**
   ```bash
   # 檢查容器健康狀態
   docker ps
   
   # 測試 API
   curl http://localhost:8180/patterns/names
   ```

### 方式二：Docker Run

```bash
# 建置映像檔
docker build -t fabric:latest .

# 執行容器
docker run -d \
  --name fabric \
  -p 5173:8080 \
  -p 8180:8180 \
  -p 8181:8181 \
  -e OPENAI_API_KEY=您的金鑰 \
  -e ANTHROPIC_API_KEY=您的金鑰 \
  -v fabric-config:/root/.config/fabric \
  fabric:latest
```

## ⚙️ 設定說明

### 環境變數

| 變數 | 描述 | 預設值 |
|------|------|--------|
| `PORT` | REST API 連接埠 | `8180` |
| `WEB_PORT` | Web UI 連接埠（主機對應） | `5173` |
| `MCP_PORT` | MCP 伺服器連接埠 | `8181` |
| `OPENAI_API_KEY` | OpenAI API 金鑰 | - |
| `ANTHROPIC_API_KEY` | Anthropic API 金鑰 | - |
| `GEMINI_API_KEY` | Google Gemini API 金鑰 | - |
| `OLLAMA_HOST` | Ollama 伺服器位址 | - |
| `DEFAULT_MODEL` | 預設 AI 模型 | `gpt-4o` |
| `DEFAULT_VENDOR` | 預設 AI 服務商 | `openai` |
| `API_KEY` | 選用的 API 認證金鑰 | - |
| `TZ` | 時區 | `Asia/Shanghai` |

## 📖 使用指南

### Web UI

存取 `http://localhost:5173` 使用 Web 介面：

- 瀏覽和搜尋 233+ 個模式
- 使用自訂輸入執行模式
- 管理上下文和工作階段
- 即時聊天介面

### REST API

```bash
# 列出所有模式
curl http://localhost:8180/patterns/names

# 取得特定模式
curl http://localhost:8180/patterns/summarize

# 檢查模式是否存在
curl http://localhost:8180/patterns/exists/summarize

# 取得可用模型
curl http://localhost:8180/models/names
```

### API 端點

| 端點 | 方法 | 描述 |
|------|------|------|
| `/patterns/names` | GET | 列出所有模式名稱 |
| `/patterns/:name` | GET | 取得模式詳情 |
| `/patterns/exists/:name` | GET | 檢查模式是否存在 |
| `/contexts/names` | GET | 列出所有上下文 |
| `/sessions/names` | GET | 列出所有工作階段 |
| `/models/names` | GET | 列出可用模型 |
| `/config` | GET | 取得設定 |
| `/strategies` | GET | 列出策略 |
| `/chat` | POST | 傳送聊天請求 |
| `/swagger/index.html` | GET | Swagger UI |

### MCP 整合

MCP 伺服器使 AI 助手（如 Claude Desktop）能夠直接使用 Fabric 模式。

在 MCP 用戶端中設定：
```json
{
  "mcpServers": {
    "fabric": {
      "url": "http://localhost:8181"
    }
  }
}
```

## 🏗️ 架構設計

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
    連接埠 5173    連接埠 8180    連接埠 8181
```

## 🛠️ 技術堆疊

| 元件 | 技術 |
|------|------|
| 後端 | Go (Gin 框架) |
| Web UI | Svelte + SvelteKit + Tailwind CSS |
| MCP 伺服器 | Python (FastAPI + Uvicorn) |
| 程序管理 | Supervisor |
| 容器 | Alpine Linux |
| 建置 | 多階段 Docker 建置 |

## 🔧 故障排除

### 容器顯示 "unhealthy"

```bash
# 檢視日誌
docker logs fabric

# 重新啟動 fabric-api 服務
docker exec fabric supervisorctl restart fabric-api

# 驗證連接埠
docker exec fabric netstat -tlnp
```

### API 無回應

```bash
# 檢查服務是否執行
docker exec fabric supervisorctl status

# 手動重新啟動
docker compose restart
```

## 🤝 貢獻指南

歡迎貢獻！請隨時提交 Pull Request。

1. Fork 本儲存庫
2. 建立功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交變更 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 開啟 Pull Request

## 📄 授權條款

本專案採用 MIT 授權條款 - 詳見 [LICENSE](LICENSE) 檔案。

## 🙏 致謝

- [Fabric](https://github.com/danielmiessler/fabric) - 原始 AI 增強框架
- [Daniel Miessler](https://github.com/danielmiessler) - Fabric 創建者

---

## ⭐ Star 歷史

[![Star History Chart](https://api.star-history.com/svg?repos=neosun100/fabric-docker&type=Date)](https://star-history.com/#neosun100/fabric-docker)

## 📱 關注公眾號

<div align="center">

![公眾號](https://img.aws.xin/uPic/扫码_搜索联合传播样式-标准色版.png)

</div>
