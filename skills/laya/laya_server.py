#!/usr/bin/env python3
"""
Laya 常驻服务：加载一次模型，监听 8008 端口。
之后所有预测请求通过 HTTP 发送，不再重复加载模型。

启动：
    python ~/.agents/skills/laya/laya_server.py

可选环境变量：
    LAYA_PORT      监听端口（默认 8008）
    LAYA_MODEL     模型路径（默认 ~/laya-multilingual/multilingual）
    LAYA_OFFLINE   设为 1 则禁止 HuggingFace 联网
"""

import json
import os
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

# ── 环境准备 ──────────────────────────────────────────────────────
if os.environ.get("LAYA_OFFLINE", "0") == "1":
    os.environ["HF_HUB_OFFLINE"] = "1"
    os.environ["TRANSFORMERS_OFFLINE"] = "1"

import torch

# CPU 线程优化：官方实测可提速约 12 倍
torch.set_num_threads(4)
torch.set_num_interop_threads(1)

import laya

# ── 配置 ──────────────────────────────────────────────────────────
PORT = int(os.environ.get("LAYA_PORT", "8008"))
MODEL_PATH = Path(
    os.environ.get(
        "LAYA_MODEL",
        str(Path.home() / "laya-multilingual" / "multilingual"),
    )
)


# ── 加载模型 ──────────────────────────────────────────────────────
def load_agent():
    if not MODEL_PATH.exists():
        sys.exit(f"模型路径不存在: {MODEL_PATH}\n"
                 f"请确认已下载多语言版，或用 LAYA_MODEL 指定路径。")

    print(f"[server] 加载模型: {MODEL_PATH}", flush=True)
    agent = laya.load(str(MODEL_PATH))
    print("[server] 模型加载完成", flush=True)
    return agent


AGENT = load_agent()


# ── HTTP Handler ──────────────────────────────────────────────────
class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args):
        # 精简日志，只保留必要信息
        print(f"[server] {self.address_string()} {args[0]}", flush=True)

    def do_POST(self):
        try:
            length = int(self.headers.get("Content-Length", 0))
            body = json.loads(self.rfile.read(length))

            state = body.get("state")
            questions = body.get("questions", {})

            if not state or not questions:
                self._send(400, {"error": "缺少 state 或 questions"})
                return

            result = AGENT.predict(state, questions)
            self._send(200, result)

        except Exception as e:
            self._send(500, {"error": str(e)})

    def _send(self, code: int, payload: dict):
        data = json.dumps(payload, ensure_ascii=False).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)


if __name__ == "__main__":
    print(f"[server] 监听 http://127.0.0.1:{PORT}", flush=True)
    HTTPServer(("127.0.0.1", PORT), Handler).serve_forever()