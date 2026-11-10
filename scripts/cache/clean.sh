#!/usr/bin/env bash
# 󰃢 clean.sh — 清理各包管理器缓存（交互选择喵～）
# 用法: ./clean.sh [-n|--dry-run] [-y|--yes] [-l|--list] [管理器...]
#   -n, --dry-run  只打印命令，不动手喵
#   -y, --yes      不询问，全部清理喵
#   -l, --list     列出支持的管理器喵
# 例: ./clean.sh pip bun   # 只清 pip 和 bun 喵
set -uo pipefail

# ── 外观 ──────────────────────────────────────────────
if [[ -t 1 ]]; then
    C_CYAN=$'\033[36m' C_GREEN=$'\033[32m' C_RED=$'\033[31m' C_DIM=$'\033[2m' C_OFF=$'\033[0m'
else
    C_CYAN='' C_GREEN='' C_RED='' C_DIM='' C_OFF=''
fi

ICON_CAT='󰄛' ICON_BROOM='󰃢' ICON_CHECK='󰄬' ICON_ERR='󰅚' ICON_ARROW='󰁔' ICON_DB='󰆼'

# ── 参数 ──────────────────────────────────────────────
dry=0 yes=0 list=0
while [[ ${1:-} == -* ]]; do
    case $1 in
    -n | --dry-run) dry=1 ;;
    -y | --yes) yes=1 ;;
    -l | --list) list=1 ;;
    -h | --help) sed -n '2,7p' "$0" && exit 0 ;;
    *)
        printf '%s%s 喵？不认识这个参数: %s%s\n' "$C_RED" "$ICON_ERR" "$1" "$C_OFF" >&2
        printf '%s 试试 -h 看看用法喵～%s\n' "$C_DIM" "$C_OFF" >&2
        exit 1
        ;;
    esac
    shift
done

# 支持的管理器（顺序即执行顺序）
MANAGERS=(pip uv npm pnpm yarn bun go gem conda cargo pacman yay paru)

has() { command -v -- "$1" >/dev/null 2>&1; }

# pip 可能是 pip3，对外统一叫 pip
available() {
    case $1 in
    pip) has pip3 || has pip ;;
    *) has "$1" ;;
    esac
}

# 清理动作：成功 0，失败非 0
clean() {
    case $1 in
    pip)
        if has pip3; then run "pip 缓存" pip3 cache purge; else run "pip 缓存" pip cache purge; fi
        ;;
    uv) run "uv 缓存" uv cache clean ;;
    npm) run "npm 缓存" npm cache clean --force ;;
    pnpm) run "pnpm 缓存" pnpm store prune ;;
    yarn) run "yarn 缓存" yarn cache clean ;;
    bun) run "bun 缓存" bun pm cache rm ;;
    go) run "go 缓存" go clean -cache -modcache ;;
    gem) run "gem 缓存" gem cleanup ;;
    conda) run "conda 缓存" conda clean -afy ;;
    cargo) run "cargo 缓存" rm -rf "$HOME/.cargo/registry/cache" "$HOME/.cargo/git/db" ;;
    pacman) run "pacman 缓存" sudo pacman -Sc --noconfirm ;;
    yay) run "yay 缓存" rm -rf "$HOME/.cache/yay" ;;
    paru) run "paru 缓存" rm -rf "$HOME/.cache/paru" ;;
    esac
}

run() {
    local desc=$1
    shift
    if ((dry)); then
        printf '%s%s [dry-run] %s: %s%s\n' "$C_DIM" "$ICON_BROOM" "$desc" "$*" "$C_OFF"
        return 0
    fi
    printf '%s%s %s…%s\n' "$C_CYAN" "$ICON_BROOM" "$desc" "$C_OFF"
    "$@"
}

# ── --list ────────────────────────────────────────────
if ((list)); then
    printf '%s%s 支持的管理器喵：%s\n' "$C_CYAN" "$ICON_DB" "$C_OFF"
    for m in "${MANAGERS[@]}"; do
        if available "$m"; then
            printf '  %s%s%s %-7s 已安装喵\n' "$C_GREEN" "$ICON_CHECK" "$C_OFF" "$m"
        else
            printf '  %s%s%s %-7s 还没装喵\n' "$C_DIM" "$ICON_ERR" "$C_OFF" "$m"
        fi
    done
    exit 0
fi

# ── 选择目标 ──────────────────────────────────────────
declare -A selected=()
for m in "$@"; do
    [[ $m == pip3 ]] && m=pip
    if [[ " ${MANAGERS[*]} " != *" $m "* ]]; then
        printf '%s%s 喵？不认识 %s（可用: %s）%s\n' "$C_RED" "$ICON_ERR" "$m" "${MANAGERS[*]}" "$C_OFF" >&2
        exit 1
    fi
    selected[$m]=1
done

if ((${#selected[@]} == 0)); then
    if ((yes || dry)); then
        for m in "${MANAGERS[@]}"; do selected[$m]=1; done
    else
        for m in "${MANAGERS[@]}"; do
            available "$m" || continue
            printf '%s%s%s 清理 %s 缓存喵？[y/N] ' "$C_CYAN" "$ICON_CAT" "$C_OFF" "$m"
            read -r ans || ans=""
            [[ ${ans:-} == [yY]* ]] && selected[$m]=1
        done
        if ((${#selected[@]} == 0)); then
            printf '%s%s 什么都没选，喵…收工～%s\n' "$C_DIM" "$ICON_CAT" "$C_OFF"
            exit 0
        fi
    fi
fi

# ── 执行 ──────────────────────────────────────────────
printf '%s%s 开始清理喵～%s\n' "$C_CYAN" "$ICON_CAT" "$C_OFF"
ok=0 bad=0 skip=0
for m in "${MANAGERS[@]}"; do
    [[ -n ${selected[$m]:-} ]] || continue
    if ! available "$m"; then
        ((++skip))
        printf '%s%s 跳过 %s（没装喵）%s\n' "$C_DIM" "$ICON_ARROW" "$m" "$C_OFF"
        continue
    fi
    if clean "$m"; then
        ((++ok))
        if ((dry)); then
            printf '%s%s %s 演练完成喵～%s\n' "$C_GREEN" "$ICON_CHECK" "$m" "$C_OFF"
        else
            printf '%s%s %s 清干净了喵～%s\n' "$C_GREEN" "$ICON_CHECK" "$m" "$C_OFF"
        fi
    else
        ((++bad))
        printf '%s%s 呜呜… %s 没清掉喵%s\n' "$C_RED" "$ICON_ERR" "$m" "$C_OFF"
    fi
done

# ── 收尾 ──────────────────────────────────────────────
if ((bad == 0)); then
    printf '%s%s 全部搞定喵！成功 %d 项' "$C_GREEN" "$ICON_CAT" "$ok"
    ((skip > 0)) && printf '，跳过 %d 项' "$skip"
    printf '～%s\n' "$C_OFF"
else
    printf '%s%s 有 %d 项失败喵…（成功 %d，跳过 %d）%s\n' "$C_RED" "$ICON_ERR" "$bad" "$ok" "$skip" "$C_OFF"
fi

exit $((bad > 0))
