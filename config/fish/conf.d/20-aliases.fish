# ============================================
# 别名 (与 abbreviations 不重复)
# ============================================

# ---- 目录导航 ----
alias th='cd ~'
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....='cd ../../../..'

# ---- 文件列表 ----
alias ll="LS_COLORS= eza --icons --color=always -la"

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
alias grep="grep --color=auto"

# ---- 下载工具 ----
alias wget="wget --show-progress"

# ---- 系统维护 ----
alias poweroff="poweroff"
alias df="df -h"
alias du="du -h"
alias du-max="du -sh * | sort -hr"
alias cl='clear'

# ---- 搜索 ----
alias ftext="grep -r --include='*.txt'"
alias fcode="grep -r --include='*.{py,js,c}'"

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