# 默认执行：列出所有可用命令
default:
    @just --list --unsorted

# 提交并推送：just ship "提交信息"
ship msg:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "$(git status --porcelain)" ]; then
        echo "󰀦  没有需要提交的变更。"
        exit 0
    fi
    git add .
    git commit -m "{{msg}}"
    BRANCH=$(git branch --show-current)
    echo "󰁔  推送分支 $BRANCH..."
    git push origin "$BRANCH"

# 安全的打标签：just tag v1.0.0 "发布说明"
tag version message:
    #!/usr/bin/env bash
    set -e
    if [ -n "$(git status --porcelain)" ]; then
        echo "󰀦  工作区有未提交的改动，先提交再打标签！"
        exit 1
    fi
    echo "󰓻  正在创建标签 {{version}}..."
    git tag -a {{version}} -m "{{message}}"
    echo "󰁔  推送标签到远端..."
    git push origin {{version}}
    echo "󰄬  标签 {{version}} 已创建并推送！"