# ============================================
# 别名 (与 abbreviations 不重复)
# ============================================

# ---- 目录导航 ----
alias th='cd ~'
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....='cd ../../../..'

# ---- 文件列表 (现代化 eza 增强) ----
# 去掉了无效的 LS_COLORS 赋值，加入 --git 显示 Git 状态
alias ls="eza --icons --color=always --group-directories-first"
alias ll="eza --icons --color=always -la --git"
alias la="eza --icons --color=always -a"
alias lt="eza --icons --color=always --tree --level=2"

# ---- 文件操作 ----
alias mkdir="mkdir -p"
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -i"
alias ln="ln -s"
alias mk="mkdir -p"
alias tch="touch"
alias head="head -n"
alias tail="tail -n"
alias cat="bat --paging=never" # 用 bat 替代 cat，自带语法高亮

# ---- 压缩解压 ----
alias untar="tar -xvf"
alias untgz="tar -xzvf"
alias unbz2="tar -xjvf"
alias zipf="zip -r"
alias unzipf="unzip"
alias 7zz="7z"
alias un7z="7z x"

# ---- 开发工具 ----
alias py="python3"
alias v="nvim"
alias grep="rg" # 直接用 rg 替代 grep，速度起飞且自带颜色
alias find="fd" # 用 fd 替代 find
alias j="just"

# ---- 下载工具 ----
alias wget="wget --show-progress"

# ---- 系统维护 ----
alias poweroff="poweroff"
alias df="df -h"
alias du="dust" # 用 dust 替代 du，树状图更直观
alias top="btop" # 用 btop 替代 top
alias cl='clear'

# ---- 搜索 ----
alias ftext="rg --type txt"
alias fcode="rg --type py --type js --type c"

# ---- 工具 ----
alias glow='glow -s ~/.config/glow/catppuccin-mocha.json'
alias ncat='nyancat'
alias tldr='tldr -L zh'
alias ffc='fastfetch'
alias fs="fish"
alias fsr="fisher"
alias timer='time read'
alias e='exit'
alias her='herdr'
alias dsh="node --expose-internals /usr/lib/node_modules/@deepseek-ai/dsh/lib/bin.js"