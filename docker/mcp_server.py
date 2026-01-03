#!/usr/bin/env python3
"""
Fabric MCP Server - HTTP API for Fabric AI augmentation framework.
Provides tool endpoints compatible with MCP protocol.
"""

import os
import json
import subprocess
from typing import Optional
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import uvicorn

app = FastAPI(
    title="Fabric MCP Server",
    description="MCP-compatible HTTP API for Fabric AI augmentation framework",
    version="1.0.0"
)

FABRIC_BIN = "/usr/local/bin/fabric"
FABRIC_CONFIG = os.environ.get("FABRIC_CONFIG_DIR", "/root/.config/fabric")


def run_fabric(*args, input_text: Optional[str] = None) -> dict:
    """Execute fabric CLI command and return result."""
    cmd = [FABRIC_BIN] + list(args)
    try:
        result = subprocess.run(
            cmd,
            input=input_text,
            capture_output=True,
            text=True,
            timeout=300
        )
        return {
            "success": result.returncode == 0,
            "output": result.stdout,
            "error": result.stderr if result.returncode != 0 else None
        }
    except subprocess.TimeoutExpired:
        return {"success": False, "output": "", "error": "Command timed out"}
    except Exception as e:
        return {"success": False, "output": "", "error": str(e)}


# Request models
class PatternRequest(BaseModel):
    pattern: str
    input_text: str
    model: Optional[str] = None
    vendor: Optional[str] = None
    context: Optional[str] = None
    temperature: Optional[float] = None


class ChatRequest(BaseModel):
    message: str
    model: Optional[str] = None
    vendor: Optional[str] = None
    pattern: Optional[str] = None


class YouTubeRequest(BaseModel):
    url: str
    with_timestamps: bool = False


class ScrapeRequest(BaseModel):
    url: str


# Endpoints
@app.get("/")
def root():
    return {"service": "Fabric MCP Server", "version": "1.0.0", "status": "running"}


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/tools")
def list_tools():
    """List all available MCP tools."""
    return {
        "tools": [
            {"name": "list_patterns", "description": "List all available Fabric patterns"},
            {"name": "list_models", "description": "List all available AI models"},
            {"name": "list_contexts", "description": "List all available contexts"},
            {"name": "run_pattern", "description": "Run a Fabric pattern on input text"},
            {"name": "summarize", "description": "Summarize text"},
            {"name": "extract_wisdom", "description": "Extract wisdom from text"},
            {"name": "analyze_claims", "description": "Analyze claims in text"},
            {"name": "youtube_transcript", "description": "Get YouTube video transcript"},
            {"name": "scrape_url", "description": "Scrape webpage to markdown"},
            {"name": "chat", "description": "Chat with AI model"},
        ]
    }


@app.get("/patterns")
def list_patterns():
    """List all available Fabric patterns."""
    result = run_fabric("--listpatterns", "--shell-complete-list")
    if result["success"]:
        patterns = [p.strip() for p in result["output"].strip().split("\n") if p.strip()]
        return {"patterns": patterns, "count": len(patterns)}
    raise HTTPException(status_code=500, detail=result["error"])


@app.get("/models")
def list_models():
    """List all available AI models."""
    result = run_fabric("--listmodels", "--shell-complete-list")
    if result["success"]:
        models = [m.strip() for m in result["output"].strip().split("\n") if m.strip()]
        return {"models": models, "count": len(models)}
    raise HTTPException(status_code=500, detail=result["error"])


@app.get("/contexts")
def list_contexts():
    """List all available contexts."""
    result = run_fabric("--listcontexts", "--shell-complete-list")
    if result["success"]:
        contexts = [c.strip() for c in result["output"].strip().split("\n") if c.strip()]
        return {"contexts": contexts, "count": len(contexts)}
    raise HTTPException(status_code=500, detail=result["error"])


@app.post("/run_pattern")
def run_pattern(req: PatternRequest):
    """Run a Fabric pattern on input text."""
    args = ["--pattern", req.pattern]
    
    if req.model:
        args.extend(["--model", req.model])
    if req.vendor:
        args.extend(["--vendor", req.vendor])
    if req.context:
        args.extend(["--context", req.context])
    if req.temperature is not None:
        args.extend(["--temperature", str(req.temperature)])
    
    result = run_fabric(*args, input_text=req.input_text)
    return {
        "pattern": req.pattern,
        "success": result["success"],
        "output": result["output"],
        "error": result.get("error")
    }


@app.post("/summarize")
def summarize(text: str):
    """Summarize text using the 'summarize' pattern."""
    req = PatternRequest(pattern="summarize", input_text=text)
    return run_pattern(req)


@app.post("/extract_wisdom")
def extract_wisdom(text: str):
    """Extract wisdom from text."""
    req = PatternRequest(pattern="extract_wisdom", input_text=text)
    return run_pattern(req)


@app.post("/analyze_claims")
def analyze_claims(text: str):
    """Analyze claims in text."""
    req = PatternRequest(pattern="analyze_claims", input_text=text)
    return run_pattern(req)


@app.post("/youtube_transcript")
def youtube_transcript(req: YouTubeRequest):
    """Get transcript from a YouTube video."""
    args = ["--youtube", req.url]
    if req.with_timestamps:
        args.append("--transcript-with-timestamps")
    else:
        args.append("--transcript")
    
    result = run_fabric(*args)
    return {
        "url": req.url,
        "success": result["success"],
        "transcript": result["output"],
        "error": result.get("error")
    }


@app.post("/scrape_url")
def scrape_url(req: ScrapeRequest):
    """Scrape and convert a webpage to markdown."""
    result = run_fabric("--scrape_url", req.url)
    return {
        "url": req.url,
        "success": result["success"],
        "content": result["output"],
        "error": result.get("error")
    }


@app.get("/pattern/{pattern_name}")
def get_pattern_content(pattern_name: str):
    """Get the content of a specific pattern."""
    pattern_path = os.path.join(FABRIC_CONFIG, "patterns", pattern_name, "system.md")
    try:
        with open(pattern_path, "r") as f:
            content = f.read()
        return {"pattern": pattern_name, "content": content}
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail=f"Pattern '{pattern_name}' not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/chat")
def chat(req: ChatRequest):
    """Send a chat message to an AI model."""
    args = []
    if req.model:
        args.extend(["--model", req.model])
    if req.vendor:
        args.extend(["--vendor", req.vendor])
    if req.pattern:
        args.extend(["--pattern", req.pattern])
    
    result = run_fabric(*args, input_text=req.message)
    return {
        "success": result["success"],
        "response": result["output"],
        "error": result.get("error")
    }


if __name__ == "__main__":
    port = int(os.environ.get("MCP_PORT", 8181))
    print(f"Starting Fabric MCP Server on port {port}...")
    uvicorn.run(app, host="0.0.0.0", port=port)
