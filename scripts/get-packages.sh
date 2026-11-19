#!/usr/bin/env bash
# dump-packages.sh — 导出当前环境的包清单
#
# 用法:
#   ./dump-packages.sh pacman   # pacman 已安装包 → doc/pacman-packages.txt（单行、空格分隔）
#   ./dump-packages.sh brew     # Homebrew 环境     → ./Brewfile（标准 Brewfile，根目录）
#   ./dump-packages.sh          # 两者都导出
#
# 结果同时打印到 stdout，并保存到对应位置。
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCDIR="$REPO/doc"
BREWFILE="$REPO/Brewfile"
mkdir -p "$DOCDIR"

# ---- pacman：单行包名，便于 diff / 阅读 ----
pacman_dump() {
  local out
  # -Qqe：只列显式安装的包（不含依赖），去掉版本号
  out="$(pacman -Qqe 2>/dev/null | tr '\n' ' ' | sed 's/ $//')"
  echo "$out"
  printf '%s\n' "$out" > "$DOCDIR/pacman-packages.txt"
  echo "✓ 已写入 $DOCDIR/pacman-packages.txt" >&2
}

# ---- brew：标准 Brewfile，放仓库根目录 ----
brew_dump() {
  local out
  # --file=- ：dump 到 stdout，避免在 cwd 留下临时 Brewfile
  # --force  ：强制覆盖已有文件
  out="$(brew bundle dump --force --file=- 2>/dev/null)"
  echo "$out"
  printf '%s\n' "$out" > "$BREWFILE"
  echo "✓ 已写入 $BREWFILE" >&2
}

case "${1:-}" in
  pacman) pacman_dump ;;
  brew)   brew_dump ;;
  "")     pacman_dump; brew_dump ;;
  *)      echo "用法: $0 [pacman|brew]" >&2; exit 1 ;;
esac