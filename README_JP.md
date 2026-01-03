<div align="center">

# 🧠 Fabric Docker

[English](README.md) | [简体中文](README_CN.md) | [繁體中文](README_TW.md) | [日本語](README_JP.md)

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://hub.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/neosun100/fabric-docker?style=social)](https://github.com/neosun100/fabric-docker)

**[Fabric](https://github.com/danielmiessler/fabric) のオールインワン Docker デプロイメント - Web UI、REST API、MCP サーバーを統合した AI 拡張フレームワーク**

<img src="docs/images/fabric-logo-gif.gif" alt="Fabric Logo" width="200"/>

</div>

---

## ✨ 機能

| 機能 | 説明 |
|------|------|
| 🌐 **Web UI** | パターン管理のための美しい Svelte ベースの Web インターフェース |
| 🔌 **REST API** | Swagger ドキュメント付きのフル機能 HTTP API |
| 🤖 **MCP サーバー** | AI アシスタント統合のためのモデルコンテキストプロトコルサーバー |
| 📦 **オールインワン** | すべてのサービスを含む単一コンテナ |
| 🎯 **233+ パターン** | 様々なタスク用のプリロード AI プロンプトパターン |
| 🔧 **マルチモデル** | OpenAI、Anthropic、Gemini、Ollama などをサポート |

## 🚀 クイックスタート

```bash
# リポジトリをクローン
git clone https://github.com/neosun100/fabric-docker.git
cd fabric-docker

# 環境ファイルをコピー
cp .env.example .env

# Docker Compose で起動
docker compose up -d

# サービスにアクセス
# Web UI:    http://localhost:5173
# REST API:  http://localhost:8180
# Swagger:   http://localhost:8180/swagger/index.html
# MCP:       http://localhost:8181
```

## 📦 インストール

### 前提条件

- Docker 20.10+
- Docker Compose 2.0+
- 少なくとも1つの AI プロバイダー API キー（OpenAI、Anthropic など）

### 方法1：Docker Compose（推奨）

1. **リポジトリをクローン**
   ```bash
   git clone https://github.com/neosun100/fabric-docker.git
   cd fabric-docker
   ```

2. **環境を設定**
   ```bash
   cp .env.example .env
   # .env を編集して API キーを追加
   ```

3. **サービスを起動**
   ```bash
   docker compose up -d
   ```

4. **デプロイを確認**
   ```bash
   # コンテナの健全性を確認
   docker ps
   
   # API をテスト
   curl http://localhost:8180/patterns/names
   ```

### 方法2：Docker Run

```bash
# イメージをビルド
docker build -t fabric:latest .

# コンテナを実行
docker run -d \
  --name fabric \
  -p 5173:8080 \
  -p 8180:8180 \
  -p 8181:8181 \
  -e OPENAI_API_KEY=あなたのキー \
  -e ANTHROPIC_API_KEY=あなたのキー \
  -v fabric-config:/root/.config/fabric \
  fabric:latest
```

## ⚙️ 設定

### 環境変数

| 変数 | 説明 | デフォルト |
|------|------|----------|
| `PORT` | REST API ポート | `8180` |
| `WEB_PORT` | Web UI ポート（ホストマッピング） | `5173` |
| `MCP_PORT` | MCP サーバーポート | `8181` |
| `OPENAI_API_KEY` | OpenAI API キー | - |
| `ANTHROPIC_API_KEY` | Anthropic API キー | - |
| `GEMINI_API_KEY` | Google Gemini API キー | - |
| `OLLAMA_HOST` | Ollama サーバー URL | - |
| `DEFAULT_MODEL` | デフォルト AI モデル | `gpt-4o` |
| `DEFAULT_VENDOR` | デフォルト AI ベンダー | `openai` |
| `API_KEY` | オプションの API 認証 | - |
| `TZ` | タイムゾーン | `Asia/Shanghai` |

## 📖 使用方法

### Web UI

`http://localhost:5173` で Web インターフェースにアクセス：

- 233+ パターンを閲覧・検索
- カスタム入力でパターンを実行
- コンテキストとセッションを管理
- リアルタイムチャットインターフェース

### REST API

```bash
# すべてのパターンを一覧表示
curl http://localhost:8180/patterns/names

# 特定のパターンを取得
curl http://localhost:8180/patterns/summarize

# パターンの存在を確認
curl http://localhost:8180/patterns/exists/summarize

# 利用可能なモデルを取得
curl http://localhost:8180/models/names
```

### API エンドポイント

| エンドポイント | メソッド | 説明 |
|---------------|---------|------|
| `/patterns/names` | GET | すべてのパターン名を一覧表示 |
| `/patterns/:name` | GET | パターンの詳細を取得 |
| `/patterns/exists/:name` | GET | パターンの存在を確認 |
| `/contexts/names` | GET | すべてのコンテキストを一覧表示 |
| `/sessions/names` | GET | すべてのセッションを一覧表示 |
| `/models/names` | GET | 利用可能なモデルを一覧表示 |
| `/config` | GET | 設定を取得 |
| `/strategies` | GET | 戦略を一覧表示 |
| `/chat` | POST | チャットリクエストを送信 |
| `/swagger/index.html` | GET | Swagger UI |

### MCP 統合

MCP サーバーにより、AI アシスタント（Claude Desktop など）が Fabric パターンを直接使用できます。

MCP クライアントで設定：
```json
{
  "mcpServers": {
    "fabric": {
      "url": "http://localhost:8181"
    }
  }
}
```

## 🏗️ アーキテクチャ

```
┌─────────────────────────────────────────────────────────┐
│                    Docker コンテナ                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   Web UI    │  │  REST API   │  │ MCP Server  │     │
│  │   (Node)    │  │   (Go)      │  │  (Python)   │     │
│  │   :8080     │  │   :8180     │  │   :8181     │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│         │                │                │             │
│         └────────────────┼────────────────┘             │
│                          │                              │
│              ┌───────────┴───────────┐                  │
│              │    Fabric コア        │                  │
│              │  (233+ パターン)      │                  │
│              └───────────────────────┘                  │
└─────────────────────────────────────────────────────────┘
         │              │              │
    ポート 5173    ポート 8180    ポート 8181
```

## 🛠️ 技術スタック

| コンポーネント | 技術 |
|--------------|------|
| バックエンド | Go (Gin フレームワーク) |
| Web UI | Svelte + SvelteKit + Tailwind CSS |
| MCP サーバー | Python (FastAPI + Uvicorn) |
| プロセスマネージャー | Supervisor |
| コンテナ | Alpine Linux |
| ビルド | マルチステージ Docker ビルド |

## 🔧 トラブルシューティング

### コンテナが "unhealthy" と表示される

```bash
# ログを確認
docker logs fabric

# fabric-api サービスを再起動
docker exec fabric supervisorctl restart fabric-api

# ポートを確認
docker exec fabric netstat -tlnp
```

### API が応答しない

```bash
# サービスが実行中か確認
docker exec fabric supervisorctl status

# 手動で再起動
docker compose restart
```

## 🤝 コントリビューション

コントリビューションを歓迎します！お気軽に Pull Request を提出してください。

1. リポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/AmazingFeature`)
3. 変更をコミット (`git commit -m 'Add some AmazingFeature'`)
4. ブランチにプッシュ (`git push origin feature/AmazingFeature`)
5. Pull Request を開く

## 📄 ライセンス

このプロジェクトは MIT ライセンスの下でライセンスされています - 詳細は [LICENSE](LICENSE) ファイルを参照してください。

## 🙏 謝辞

- [Fabric](https://github.com/danielmiessler/fabric) - オリジナルの AI 拡張フレームワーク
- [Daniel Miessler](https://github.com/danielmiessler) - Fabric の作成者

---

## ⭐ Star 履歴

[![Star History Chart](https://api.star-history.com/svg?repos=neosun100/fabric-docker&type=Date)](https://star-history.com/#neosun100/fabric-docker)

## 📱 フォローする

<div align="center">

![WeChat](https://img.aws.xin/uPic/扫码_搜索联合传播样式-标准色版.png)

</div>
