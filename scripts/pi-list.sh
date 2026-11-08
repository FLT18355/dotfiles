#!/usr/bin/env bash
# pi-list.sh — 运行 pi list 并生成美化的 markdown 报告到 doc/
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$REPO/doc/pi-extensions.md"

mkdir -p "$REPO/doc"

# 抓取原始输出
raw="$(pi list 2>/dev/null || true)"

ts="$(date '+%Y-%m-%d %H:%M:%S')"

{
  echo "# Pi 扩展清单"
  echo
  echo "> 由 \`scripts/pi-list.sh\` 自动生成于 ${ts}"
  echo
  echo "## 概览"
  echo
  count="$(printf '%s\n' "$raw" | grep -c '^\s*npm:' || true)"
  gitcount="$(printf '%s\n' "$raw" | grep -c '^\s*git:' || true)"
  echo "| 来源 | 数量 |"
  echo "|------|------|"
  echo "| npm | ${count:-0} |"
  echo "| git | ${gitcount:-0} |"
  echo
  echo "## 扩展列表"
  echo
  echo '```'
  echo "$raw"
  echo '```'
} > "$OUT"

echo "✓ 报告已生成: $OUT"
