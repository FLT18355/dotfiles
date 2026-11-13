#!/bin/bash

# 定义 Catppuccin 颜色
C_MAUVE="\e[38;2;203;166;247m"  # 紫红色 (专门给 Shell 名字)
C_TEXT="\e[1;38;2;205;214;244m" # 加粗亮白 (版本号)
C_RESET="\e[0m"

# 自动获取当前 Shell 路径和名称
SHELL_PATH="${SHELL:-/bin/sh}"
SHELL_NAME=$(basename "$SHELL_PATH")
SHELL_VER=""

# 把名字首字母大写（比如把 fish 变成 Fish，看起来更正式）
SHELL_NAME_DISPLAY="$(tr '[:lower:]' '[:upper:]' <<< ${SHELL_NAME:0:1})${SHELL_NAME:1}"

# 根据不同的 Shell 智能提取版本号
case "$SHELL_NAME" in
    fish)
        SHELL_VER=$($SHELL_PATH --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
        ;;
    bash)
        SHELL_VER=$($SHELL_PATH --version 2>/dev/null | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
        ;;
    zsh)
        SHELL_VER=$($SHELL_PATH --version 2>/dev/null | awk '{print $2}')
        ;;
    nu)
        SHELL_VER=$($SHELL_PATH --version 2>/dev/null | head -n 1)
        ;;
    dash)
        SHELL_VER=$($SHELL_PATH -c 'echo $DASH_VERSION' 2>/dev/null)
        [ -z "$SHELL_VER" ] && SHELL_VER=$($SHELL_PATH --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -n 1)
        ;;
    *)
        SHELL_VER="unknown"
        ;;
esac

# 输出逻辑
if [ "$SHELL_VER" = "unknown" ] || [ -z "$SHELL_VER" ]; then
    printf "${C_MAUVE}%s${C_RESET}\n" "$SHELL_NAME_DISPLAY"
else
    # 格式：紫红色的名字 + 亮白的版本号
    printf "${C_MAUVE}%s ${C_TEXT}%s${C_RESET}\n" "$SHELL_NAME_DISPLAY" "$SHELL_VER"
fi