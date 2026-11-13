#!/usr/bin/env bash
# get-packages.sh — 输出已安装的包名（单行、空格分隔、只显示名字）
#
# 用法:
#   ./get-packages.sh pacman   # pacman 已安装的包 → 写入 doc/pacman-packages.txt
#   ./get-packages.sh brew     # brew 已安装的公式/包 → 写入 doc/brew-packages.txt
#   ./get-packages.sh          # 两者都写入各自的文件
#
# 结果同时打印到 stdout，并保存到仓库的 doc/ 目录（.txt）。
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCDIR="$REPO/doc"

pacman_pkgs() {
  # -Qqe 只列出本包（不含依赖）
  pacman -Qqe 2>/dev/null | tr '\n' ' ' | sed 's/ $//'
}

brew_pkgs() {
  # 公式 + cask
  { brew list --formula 2>/dev/null; brew list --cask 2>/dev/null; } \
    | tr '\n' ' ' | sed 's/ $//'
}

save() {
  # $1 = 函数名, $2 = 文件名
  local out
  out="$("$1")"
  echo "$out"
  mkdir -p "$DOCDIR"
  printf '%s\n' "$out" > "$DOCDIR/$2"
  echo "✓ 已写入 $DOCDIR/$2" >&2
}

mkdir -p "$DOCDIR"
case "${1:-}" in
  pacman)
    save pacman_pkgs "pacman-packages.txt"
    ;;
  brew)
    save brew_pkgs "brew-packages.txt"
    ;;
  *)
    save pacman_pkgs "pacman-packages.txt"
    save brew_pkgs "brew-packages.txt"
    ;;
esac
