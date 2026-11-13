#!/bin/bash
C_BLUE="\e[38;2;137;180;250m"
C_YELLOW="\e[38;2;249;226;175m"
C_RESET="\e[0m"

if command -v python &> /dev/null; then
    PY_VER=$(python --version 2>/dev/null | awk '{print $2}')
    if [ -n "$PY_VER" ]; then
        # 输出：蓝色的软件名 + 黄色的版本号
        printf "${C_BLUE}Python ${C_YELLOW}%s${C_RESET}\n" "$PY_VER"
    fi
fi