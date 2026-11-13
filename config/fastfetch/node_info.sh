#!/bin/bash
C_GREEN="\e[38;2;166;227;161m"
C_RED="\e[38;2;243;139;168m"
C_RESET="\e[0m"

if command -v node &> /dev/null; then
    NODE_VER=$(node --version 2>/dev/null)
    if [ -n "$NODE_VER" ]; then
        # 输出：绿色的软件名 + 红色的版本号
        printf "${C_GREEN}Node ${C_RED}%s${C_RESET}\n" "$NODE_VER"
    fi
fi