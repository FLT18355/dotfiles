#!/bin/bash

# 提取总内存和可用内存 (单位: kB)
MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_AVAILABLE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
MEM_USED=$((MEM_TOTAL - MEM_AVAILABLE))

# 计算百分比
USAGE=$((MEM_USED * 100 / MEM_TOTAL))

# 计算 GB 并保留两位小数
USED_GB=$(awk "BEGIN {printf \"%.2f\", $MEM_USED / 1024 / 1024}")
TOTAL_GB=$(awk "BEGIN {printf \"%.2f\", $MEM_TOTAL / 1024 / 1024}")

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
    if [ $color_idx -gt 6 ]; then color_idx=6; fi
    BAR+="${COLORS[$color_idx]}━" 
done

# 绘制灰色剩余部分
for ((i=ELAPSED; i<TOTAL_BLOCKS; i++)); do
    BAR+="\e[38;2;88;91;112m─"
done

# 核心修改：去掉了 %3d，直接 %d%%；并去掉了前面的所有空格
printf "%d%% %b \e[38;2;205;214;244m%sG / %sG\e[0m\n" "$USAGE" "${BAR}\e[0m" "$USED_GB" "$TOTAL_GB"