#!/usr/bin/env bash
# 把仓库配置软链到 $HOME（config/* → ~/.config/*，.local/*/* → ~/.local/*/*）
# 用法: ./install.sh [-n|--dry-run] [-f|--force]
#   -n  只打印，不创建链接
#   -f  目标已存在时先备份为 *.bak.<时间戳> 再覆盖（默认跳过）
set -euo pipefail
cd "$(dirname "$0")"

dry=0
force=0
for arg in "$@"; do
    case $arg in
    -n | --dry-run) dry=1 ;;
    -f | --force) force=1 ;;
    -h | --help) sed -n '2,5p' "$0"; exit 0 ;;
    *)
        echo "未知参数: $arg" >&2
        exit 1
        ;;
    esac
done

link() {
    local src=$1 dst=$2
    if [[ -L $dst && $(readlink -f "$dst") == $(readlink -f "$src") ]]; then
        echo "已链接 $dst"
        return
    fi
    if [[ -e $dst || -L $dst ]]; then
        if (( !force )); then
            echo "跳过 $dst（已存在，用 -f 备份后覆盖）"
            return
        fi
        if (( dry )); then
            echo "[dry-run] 备份 $dst -> $dst.bak.<时间戳>"
        else
            mv "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
        fi
    fi
    if (( dry )); then
        echo "[dry-run] 链接 $dst -> $src"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$(readlink -f "$src")" "$dst"
    echo "链接 $dst -> $src"
}

link_dir() {
    local src_root=$1 dst_root=$2
    for src in "$src_root"/*; do
        [[ -e $src ]] || continue
        link "$src" "$dst_root/${src##*/}"
    done
}

link_dir config "$HOME/.config"
for src in .local/*/*; do
    [[ -d $src ]] || continue
    link "$src" "$HOME/$src"
done
