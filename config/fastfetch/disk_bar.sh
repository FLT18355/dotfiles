#!/bin/bash

# 提取根目录磁盘总容量和已用容量（单位：Bytes）
read -r DISK_TOTAL DISK_USED < <(
    df -B1 --output=size,used / | awk 'NR==2 {print $1, $2}'
)

# 检查磁盘数据
if [[ -z "$DISK_TOTAL" || -z "$DISK_USED" || "$DISK_TOTAL" -eq 0 ]]; then
    echo "无法获取磁盘信息喵~"
    exit 1
fi

# 计算使用百分比
USAGE=$((DISK_USED * 100 / DISK_TOTAL))

# 计算 GB 并保留两位小数
USED_GB=$(awk "BEGIN {printf \"%.2f\", $DISK_USED / 1024 / 1024 / 1024}")
TOTAL_GB=$(awk "BEGIN {printf \"%.2f\", $DISK_TOTAL / 1024 / 1024 / 1024}")

# 定义 Catppuccin Mocha 彩虹色
COLORS=(
    "\e[38;2;243;139;168m" # 红
    "\e[38;2;250;179;135m" # 橙
    "\e[38;2;249;226;175m" # 黄
    "\e[38;2;166;227;161m" # 绿
    "\e[38;2;148;226;213m" # 青
    "\e[38;2;137;180;250m" # 蓝
    "\e[38;2;203;166;247m" # 紫
)

TOTAL_BLOCKS=25
ELAPSED=$((USAGE * TOTAL_BLOCKS / 100))
BAR=""

# 绘制彩虹进度
for ((i=0; i<ELAPSED; i++)); do
    color_idx=$((i * 7 / TOTAL_BLOCKS))
    if [ "$color_idx" -gt 6 ]; then
        color_idx=6
    fi
    BAR+="${COLORS[$color_idx]}━"
done

# 绘制灰色剩余部分
for ((i=ELAPSED; i<TOTAL_BLOCKS; i++)); do
    BAR+="\e[38;2;88;91;112m─"
done

# 输出磁盘信息
printf "%d%% %b \e[38;2;205;214;244m%sG / %sG\e[0m\n" \
    "$USAGE" "${BAR}\e[0m" "$USED_GB" "$TOTAL_GB"