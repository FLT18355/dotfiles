#!/usr/bin/env bash
# 清理各包管理器缓存（交互选择）
# 用法: ./clean.sh [-n|--dry-run] [-y|--yes] [管理器...]
#   -n  只打印命令，不执行（也不询问）
#   -y  不询问，清理全部
# 例: ./clean.sh pip bun   # 只清 pip 和 bun
set -uo pipefail

dry=0
yes=0
while [[ ${1:-} == -* ]]; do
    case $1 in
    -n | --dry-run) dry=1 ;;
    -y | --yes) yes=1 ;;
    -h | --help) sed -n '2,6p' "$0"; exit 0 ;;
    *)
        echo "未知参数: $1" >&2
        exit 1
        ;;
    esac
    shift
done
selected=("$@")

has() { command -v "$1" >/dev/null 2>&1; }

# 有传参数就只清指定的，否则清全部
want() {
    (( ${#selected[@]} == 0 )) && return 0
    local m
    for m in "${selected[@]}"; do [[ $m == "$1" ]] && return 0; done
    return 1
}

run() {
    local desc=$1
    shift
    if (( dry )); then
        printf '[dry-run] %s: %s\n' "$desc" "$*"
        return
    fi
    printf '\033[36m==> %s\033[0m\n' "$desc"
    "$@" || printf '\033[31m失败: %s\033[0m\n' "$desc"
}

all=(pip uv npm pnpm yarn bun go gem conda cargo pacman yay paru)

# 没有指定管理器且未加 -y 时，逐个询问
if (( !yes && !dry && ${#selected[@]} == 0 )); then
    chosen=()
    for m in "${all[@]}"; do
        has "$m" || continue
        read -rp "清理 $m 缓存? [y/N] " ans
        [[ $ans == [yY]* ]] && chosen+=("$m")
    done
    if (( ${#chosen[@]} == 0 )); then
        echo "未选择任何项，退出。"
        exit 0
    fi
    selected=("${chosen[@]}")
fi

want pip && has pip && run "pip 缓存" pip cache purge
want uv && has uv && run "uv 缓存" uv cache clean
want npm && has npm && run "npm 缓存" npm cache clean --force
want pnpm && has pnpm && run "pnpm 缓存" pnpm store prune
want yarn && has yarn && run "yarn 缓存" yarn cache clean
want bun && has bun && run "bun 缓存" bun pm cache rm
want go && has go && run "go 缓存" go clean -cache -modcache
want gem && has gem && run "gem 缓存" gem cleanup
want conda && has conda && run "conda 缓存" conda clean -afy
want cargo && has cargo && run "cargo 缓存" rm -rf "$HOME/.cargo/registry/cache" "$HOME/.cargo/git/db"
want pacman && has pacman && run "pacman 缓存" sudo pacman -Sc --noconfirm
want yay && has yay && run "yay 缓存" rm -rf "$HOME/.cache/yay"
want paru && has paru && run "paru 缓存" rm -rf "$HOME/.cache/paru"
