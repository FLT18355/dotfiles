#!/usr/bin/env bash
# get-packages.sh — 导出当前环境的包清单
#
# 用法:
#   ./scripts/get-packages.sh pacman   # pacman 已安装包 → ./Pacmanfile
#   ./scripts/get-packages.sh brew     # Homebrew 环境     → ./Brewfile（剔除 npm）
#   ./scripts/get-packages.sh bun      # bun 全局包         → ./Bunfile（原样输出）
#   ./scripts/get-packages.sh          # 三者都导出
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACMANFILE="$REPO/Pacmanfile"
BREWFILE="$REPO/Brewfile"
BUNFILE="$REPO/Bunfile"

pacman_dump() {
  local out
  out="$(pacman -Qqe 2>/dev/null | tr '\n' ' ' | sed 's/ $//')"
  echo "$out"
  printf '%s\n' "$out" > "$PACMANFILE"
  echo "✓ 已写入 $PACMANFILE" >&2
}

brew_dump() {
  local raw out
  raw="$(brew bundle dump --force --file=- 2>/dev/null)"
  out="$(echo "$raw" | grep -v '^npm ' || true)"
  echo "$out"
  printf '%s\n' "$out" > "$BREWFILE"
  echo "✓ 已写入 $BREWFILE（已剔除 npm 条目）" >&2
}

bun_dump() {
  bun list -g 2>/dev/null | tee "$BUNFILE"
  echo "✓ 已写入 $BUNFILE" >&2
}

case "${1:-}" in
  pacman) pacman_dump ;;
  brew)   brew_dump ;;
  bun)    bun_dump ;;
  "")     pacman_dump; brew_dump; bun_dump ;;
  *)      echo "用法: $0 [pacman|brew|bun]" >&2; exit 1 ;;
esac
