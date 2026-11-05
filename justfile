# 默认执行：列出所有可用命令
default:
    @just --list

# 提交并推送
ship msg:
    git add .
    git commit -m "{{msg}}"
    git push