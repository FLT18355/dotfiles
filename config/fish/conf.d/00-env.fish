# ============================================
# 环境变量 · fish config
# ============================================

# --- 编辑器 ---
# 默认编辑器；EDITOR 供 git/less 等调用，VISUAL 供支持可视编辑的程序调用。
set -gx EDITOR fresh
set -gx VISUAL fresh

# --- PATH ---
# fish_add_path 幂等去重，重复 source 不会累加路径。
fish_add_path $HOME/go/bin $HOME/.cargo/bin $HOME/.local/bin \
              $HOME/bin
# pnpm
set -gx PNPM_HOME "/home/flt18355/.local/share/pnpm"
fish_add_path $PNPM_HOME/bin

# --- 语言 / 本地化 ---
# tldr 页面语言。
set -gx TLDR_LANGUAGE zh

# --- 终端工具 ---
set -gx BAT_THEME "Catppuccin Mocha"   # bat 语法高亮主题
set -gx EZA_COLORS ignore              # eza 不读 LS_COLORS，用自身配色

# --- man 手册彩色显示 ---
# MANPAGER 让 man 走 less 并启用颜色；LESS_TERMCAP_* 定义 man 各类文本的样式。
set -gx MANPAGER "less -R --use-color -Dd+r -Du+b"
set -gx LESS_TERMCAP_mb "\e[1;31m"      # 闪烁/强调（粗红）
set -gx LESS_TERMCAP_md "\e[1;36m"      # 加粗（粗青，标题）
set -gx LESS_TERMCAP_me "\e[0m"         # 结束上述样式
set -gx LESS_TERMCAP_se "\e[0m"         # 结束反显
set -gx LESS_TERMCAP_so "\e[01;44;33m"  # 反显（蓝底黄字，状态栏）
set -gx LESS_TERMCAP_ue "\e[0m"         # 结束下划线
set -gx LESS_TERMCAP_us "\e[1;32m"      # 下划线（粗绿，链接/引用）

# --- Qt ---
set -gx SAL_USE_VCLPLUGIN qt6           # LibreOffice 等使用 Qt6 VCL 插件
set -gx QT_QPA_PLATFORMTHEME qt5ct      # Qt 程序的平台主题由 qt5ct 管理

# --- Fish 历史 ---
# HISTFILE 对 fish 自身无效（fish 内部管理 fish_history），此行主要供子进程（bash/zsh）使用。
set -gx HISTFILE ~/.local/share/fish/fish_history

# --- 光标 / ESC 响应 ---
# KEYTIMEOUT 是 zsh 变量；fish 用 fish_escape_delay_ms（ms，默认 30，范围 10–5000）。
# 设小可让 ESC 更快生效，代价是 Alt+按键 组合需按得更快。
set -g fish_escape_delay_ms 10

# --- 其他 ---
set -gx GLYCIN_DISABLE_SANDBOX 1

# --- PulseAudio ---
# 纯 IP 无协议/端口，通常不生效；如需指定应写 unix:/run/user/<uid>/pulse/native。
# 无特殊需求可删除此行，走默认 socket。
set -gx PULSE_SERVER 127.0.0.1

# --- pip / uv 镜像 ---
set -gx UV_DEFAULT_INDEX https://pypi.tuna.tsinghua.edu.cn/simple

# --- Homebrew（清华镜像）---
# 覆盖 brew/core 的 Git 源、API 索引与预编译 bottle 下载地址。
set -gx HOMEBREW_BREW_GIT_REMOTE "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
set -gx HOMEBREW_CORE_GIT_REMOTE "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
set -gx HOMEBREW_API_DOMAIN       "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
set -gx HOMEBREW_BOTTLE_DOMAIN    "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
# 禁止每次安装时自动更新
set -gx HOMEBREW_NO_AUTO_UPDATE 1

# --- GitHub Copilot CLI ---
# 指向第三方兼容端点及默认模型。
set -gx COPILOT_PROVIDER_BASE_URL https://apihub.agnes-ai.cn/v1
set -gx COPILOT_MODEL agnes-2.5-flash
