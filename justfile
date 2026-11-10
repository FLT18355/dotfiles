# 默认执行：列出所有可用命令
default:
    @just --list --unsorted

# ==========================================
#  文档生成
# ==========================================

# 生成 pi 扩展清单到 doc/：just pi-list
pi-list:
    @scripts/pi-list.sh

# ==========================================
#  缓存清理
# ==========================================

# 清理包管理器缓存（交互，可指定管理器）：just clean-cache [pip bun ...]
clean-cache *args:
    @scripts/cache/clean.sh {{args}}

# 预览要执行的清理命令：just clean-cache-dry [pip bun ...]
clean-cache-dry *args:
    @scripts/cache/clean.sh -n {{args}}

# 看看哪些管理器装了：just clean-cache-list
clean-cache-list:
    @scripts/cache/clean.sh -l

# ==========================================
#  Git 自动化
# ==========================================

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
    git push origin {{version}}"
    echo "󰄬  标签 {{version}} 已创建并推送！"
    
# ==========================================
#  更新脚本管理
# ==========================================

# 列出所有可用的更新脚本
update-list:
    @echo "󰍉 可用的更新脚本有："
    @ls scripts/updater/*.py | xargs -n 1 basename | sed 's/\.py$//' | awk '{print "  󰁔 just update " $1}'

# 运行更新脚本：just update <脚本名> (不带参数则列出所有可用脚本)
update script="":
    #!/usr/bin/env bash
    set -e
    
    if [ -z "{{script}}" ]; then
        just update-list
        exit 0
    fi
    
    FILE="scripts/updater/{{script}}.py"
    
    if [ ! -f "$FILE" ]; then
        echo "󰅚 错误：找不到脚本 $FILE"
        just update-list
        exit 1
    fi
    
    echo "󰁔 正在执行：$FILE"
    python "$FILE"
    echo "󰄬 脚本执行完毕！"