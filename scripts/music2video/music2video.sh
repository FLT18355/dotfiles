#!/usr/bin/env bash
# music2video —— 音频 → 可视化视频
#
# 用法:
#   ./music2video.sh                        交互向导（推荐，一步步问）
#   ./music2video.sh 某首歌.mp3              快速单个文件（用默认参数）
#   ./music2video.sh 某首歌.mp3 --style radial
#   ./music2video.sh <任意参数>              透传给 music2video.py
#
# 风格 --style:
#   bars    中心对称柱状，上下镜像（默认）
#   scale   从中轴向两边缩放，宽高同时变
#   radial  环形柱状，沿圆周发散
#
# 歌名 / 作者 / 字幕:
#   --title "歌名" --artist "歌手"    不给就不显示，给 "-" 也是不显示
#   --subs 歌词.srt  或 歌词.lrc
#
# 存在感（默认偏鲜艳，当背景/配字时压低）:
#   --dim 0.45          配字、叠素材
#   --dim 0.75          纯背景氛围
#   --theme ash --dim 0.5   极简中性灰
#   --saturation 0.6 --brightness 0.8   单独调
#
# 其它常用参数:
#   --size 1920x1080   --fps 30   --bars 36
#   --color "#FF7A18"  --glow "#FF6A00"  --glow-strength 0.65
#
# 渐变配色:
#   --theme catppuccin   Catppuccin Mocha 粉彩渐变（薰衣草→天蓝→薄荷→绿→黄→桃→粉）
#   --theme orange|catppuccin|soft|ash|sunset|fire|mono|neon
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY="$HERE/music2video.py"

[ -f "$PY" ] || { echo "找不到 $PY" >&2; exit 1; }

case "${1:-}" in
    -h|--help)
        sed -n '2,32p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
        exit 0
        ;;
esac

mkdir -p "$HERE/video"

if [ $# -eq 0 ]; then
    # 不带参数 → 进入交互向导
    exec python3 "$PY"
elif [ -f "$1" ]; then
    # 第一个参数是文件 → 输出到 video/，其余参数原样透传
    SRC="$1"; shift
    exec python3 "$PY" "$SRC" "$HERE/video" "$@"
else
    exec python3 "$PY" "$@"
fi
