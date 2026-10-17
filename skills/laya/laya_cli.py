#!/usr/bin/env python3
"""
Laya 决策模型 CLI（HTTP 客户端版）

不再自己加载模型，而是请求常驻服务 laya_server.py。
服务未启动时会提示你先启动服务。

用法示例：
    python laya_cli.py "我被重复扣款了" -q department -c billing,technical,sales
    python laya_cli.py "系统宕机了" -q urgency -t score -c "not urgent,soon,blocking"
    echo "邮件内容..." | python laya_cli.py -q department -c billing,technical
"""

import argparse
import json
import sys
from typing import Any

import requests

# ── 配置 ──────────────────────────────────────────────────────────
DEFAULT_ENDPOINT = "http://127.0.0.1:8008"


# ── 问题构造 ──────────────────────────────────────────────────────
def build_question(args) -> dict[str, Any]:
    q_type, name = args.type, args.question

    if q_type == "choice":
        if not args.criteria:
            sys.exit("choice 类型必须提供 --criteria")
        options = [c.strip() for c in args.criteria.split(",") if c.strip()]
        if len(options) < 2:
            sys.exit("choice 至少需要 2 个选项")
        return {
            "type": "choice",
            "instructions": args.instructions or f"请判断 {name}",
            "criteria": {opt: opt for opt in options},
        }

    if q_type == "score":
        if not args.criteria:
            sys.exit("score 类型必须提供 --criteria（按从低到高）")
        levels = [c.strip() for c in args.criteria.split(",") if c.strip()]
        if len(levels) < 2:
            sys.exit("score 至少需要 2 个档位")
        return {
            "type": "score",
            "instructions": args.instructions or f"请对 {name} 评分",
            "criteria": levels,
        }

    if q_type == "noul":
        return {
            "type": "noul",
            "instructions": args.instructions or f"请判断：{name}",
        }

    sys.exit(f"未知类型: {q_type}")


# ── HTTP 调用 ─────────────────────────────────────────────────────
def call_server(state: str, question: dict, endpoint: str) -> dict:
    try:
        resp = requests.post(
            endpoint,
            json={"state": state, "questions": {question["name"]: question}},
            timeout=120,
        )
        resp.raise_for_status()
        return resp.json()
    except requests.exceptions.ConnectionError:
        sys.exit(
            f"无法连接 {endpoint}\n"
            f"请先启动服务：\n"
            f"  python ~/.agents/skills/laya/laya_server.py"
        )
    except requests.exceptions.Timeout:
        sys.exit("请求超时，模型可能仍在推理中")
    except Exception as e:
        sys.exit(f"调用失败: {e}")


# ── 渲染 ──────────────────────────────────────────────────────────
def render_text(result: dict) -> None:
    if "error" in result:
        sys.exit(f"服务端错误: {result['error']}")

    answers = result.get("answers", {})
    print("\n" + "=" * 50)
    print("  决策结果")
    print("=" * 50)

    for q_name, payload in answers.items():
        print(f"\n▸ {q_name}")
        probs = payload.get("probabilities")

        if "choice" in payload:
            c = payload["choice"]
            conf = probs.get(c) if probs else None
            line = f"  结论: {c}"
            if conf is not None:
                line += f"  (置信度 {conf:.1%})"
            print(line)
            if probs:
                print("  概率分布:")
                for opt, p in sorted(probs.items(), key=lambda x: -x[1]):
                    print(f"    {opt:<14} {p:>6.2%}  {'█' * max(1, int(p * 20))}")

        elif "noul" in payload:
            p = payload["noul"]
            print(f"  结论: {'是' if p >= 0.5 else '否'}  (是={p:.1%})")

        elif "score" in payload:
            print(f"  评分: {payload['score']}")
            if probs:
                for opt, p in sorted(probs.items(), key=lambda x: -x[1]):
                    print(f"    {opt:<14} {p:>6.2%}  {'█' * max(1, int(p * 20))}")

        if "confidence" in payload:
            print(f"  整体置信度: {payload['confidence']:.1%}")

    routing = result.get("routing", {})
    if routing:
        print(f"\n路由模型: {routing.get('model', '?')}")
    print()


def render_json(result: dict) -> None:
    print(json.dumps(result, ensure_ascii=False, indent=2))


# ── CLI ───────────────────────────────────────────────────────────
def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Laya 决策 CLI（HTTP 客户端）")
    p.add_argument("state", nargs="?", help="待分析文本；缺省从 stdin 读取")
    p.add_argument("-q", "--question", default="department", help="问题名")
    p.add_argument("-t", "--type", default="choice",
                   choices=["choice", "score", "noul"], help="问题类型")
    p.add_argument("-c", "--criteria", help="选项/档位，逗号分隔")
    p.add_argument("-i", "--instructions", help="覆盖默认问题说明")
    p.add_argument("-e", "--endpoint", default=DEFAULT_ENDPOINT,
                   help=f"服务地址（默认 {DEFAULT_ENDPOINT}）")
    p.add_argument("--json", action="store_true", help="输出原始 JSON")
    return p.parse_args()


def main() -> None:
    args = parse_args()

    state = (args.state or sys.stdin.read()).strip()
    if not state:
        sys.exit("错误：没有输入文本")

    question = build_question(args)
    question["name"] = args.question

    result = call_server(state, question, args.endpoint)
    render_json(result) if args.json else render_text(result)


if __name__ == "__main__":
    main()