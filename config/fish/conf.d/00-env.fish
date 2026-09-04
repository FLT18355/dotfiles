# ============================================
# 环境变量
# ============================================

# 编辑器
set -gx EDITOR nvim
set -gx VISUAL nvim

# PATH
set -gx PATH $PATH $HOME/go/bin
set -gx PATH $PATH $HOME/.cargo/bin
set -gx PATH $PATH $HOME/.local/bin
fish_add_path ~/bin
fish_add_path /home/flt18355/.opencode/bin

# Bat
set -gx BAT_THEME "Catppuccin Mocha"

# Man 手册彩色显示
set -gx MANPAGER "less -R --use-color -Dd+r -Du+b"
set -gx LESS_TERMCAP_mb (printf '\E[1;31m')
set -gx LESS_TERMCAP_md (printf '\E[1;36m')
set -gx LESS_TERMCAP_me (printf '\E[0m')
set -gx LESS_TERMCAP_se (printf '\E[0m')
set -gx LESS_TERMCAP_so (printf '\E[01;44;33m')
set -gx LESS_TERMCAP_ue (printf '\E[0m')
set -gx LESS_TERMCAP_us (printf '\E[1;32m')

# EZA
set -gx EZA_COLORS ignore

# 语言 / 本地化
set -gx TLDR_LANGUAGE zh

# Qt / 终端
set -gx SAL_USE_VCLPLUGIN qt6
set -x QT_QPA_PLATFORMTHEME qt5ct

# Fish 历史
set -gx HISTFILE ~/.local/share/fish/fish_history

# 光标
set -gx KEYTIMEOUT 10



# 其他
set -gx GLYCIN_DISABLE_SANDBOX 1

# PulseAudio
set -gx PULSE_SERVER 127.0.0.1

# pip 镜像
set -gx UV_DEFAULT_INDEX https://pypi.tuna.tsinghua.edu.cn/simple

# Github Copilot Cli
set -gx COPILOT_PROVIDER_BASE_URL https://apihub.agnes-ai.cn/v1
set -gx COPILOT_PROVIDER_API_KEY sk-zE3PVeemUHeFHgneG7NZi0Y5yTNRKq2qZjh9GMLPtOJ6C3jN
set -gx COPILOT_MODEL agnes-2.5-flash