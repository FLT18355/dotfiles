#!/bin/bash

# 定义 Catppuccin 颜色
C_ARCH="\e[38;2;137;180;250m"   # Arch 蓝
C_BREW="\e[38;2;250;179;135m"   # Brew 橙
C_NUM="\e[1;38;2;205;214;244m"  # 加粗亮白 (数字)
C_LABEL="\e[38;2;166;173;200m"  # Subtext0：清晰的浅灰蓝
C_SEP="\e[38;2;108;112;134m"    # Overlay0：中灰色
C_RESET="\e[0m"

OUTPUT=""

# 统计 pacman
if command -v pacman &> /dev/null; then
    PACMAN_COUNT=$(pacman -Q 2>/dev/null | wc -l)
    OUTPUT+="${C_ARCH}󰣇 ${C_NUM}${PACMAN_COUNT} ${C_LABEL}pacman${C_RESET}"
fi

# 统计 brew
if command -v brew &> /dev/null; then
    BREW_COUNT=$(timeout 2s brew list -1 2>/dev/null | wc -l)
    if [ -n "$OUTPUT" ]; then
        OUTPUT+=" ${C_SEP}│${C_RESET} "
    fi
    OUTPUT+="${C_BREW}󰀵 ${C_NUM}${BREW_COUNT} ${C_LABEL}brew${C_RESET}"
fi

if [ -n "$OUTPUT" ]; then
    printf "%b\n" "$OUTPUT"
else
    printf "无\n"
fi