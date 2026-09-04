# ============================================
# 别名 (与 abbreviations 不重复)
# ============================================

# ---- 目录导航 ----
alias th='cd ~'
alias troot="cd /"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....='cd ../../../..'

# ---- 包管理 ----
alias upd="oma upgrade && oma upgrade -y && oma refresh"
alias clean="oma clean && apt autoremove -y && pkg clean && apt clean"
alias list="pkg list-installed | bat"
alias prw='pip-review --local --interactive'

# ---- 文件列表 ----
alias li="LS_COLORS= eza --icons --color=always -a"
alias ll="LS_COLORS= eza --icons --color=always -la"
alias la="ls -A --color=always"
alias lt="ls -lt --color=always"
alias lsize="ls -lS --color=always"

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
alias py3="python3"
alias py2="python2"
alias ipy="ipython"
alias vi="nvim"
alias code="/home/flt18355/Downloads/VSCode-linux-arm64/code --no-sandbox"
alias vs='python -m visidata'
alias grep="grep --color=auto"

# ---- 下载工具 ----
alias wget="wget --show-progress"
alias curl-head="curl -I"
alias down="aria2c -x 16 -s 16"
alias bili="yt-dlp --cookies /home/flt18355/cookies.txt"

# ---- Git (缩写未覆盖的) ----
alias gs='git status'
alias ga.='git add .'
alias ggap='git gc --aggressive --prune=now'
alias gsh='grun --shell'

# ---- 系统维护 ----
alias sync="sync && echo '同步完成'"
alias reboot="reboot"
alias poweroff="poweroff"
alias df="df -h"
alias du="du -h"
alias du-max="du -sh * | sort -hr"
alias clear='/usr/bin/clear'
alias cl='clear && echo "󰄛 打扫干净啦！" && ci'
alias maint='python3 ~/Daily/tools/sysmaint.py'

# ---- 搜索 ----
alias ftext="grep -r --include='*.txt'"
alias fcode="grep -r --include='*.{py,js,c}'"

# ---- 工具 ----
alias glow='glow -s ~/.config/glow/catppuccin-mocha.json'
alias vfishrc="vim ~/.config/fish/config.fish && ci"
alias lf="yazi"
alias ncat='nyancat'
alias tldr='tldr -L zh'
alias ffc='fastfetch'
alias fs="fish"
alias fsr="fisher"
alias clock='clock-rs | lolcat'
alias timer='time read'
alias stopwatch='time cat'
alias countdown='seq'
alias e='exit'
alias ST='py ~/终端专用文件夹/f-tools/ST.py'
alias 中国日历='py ~/终端专用文件夹/f-tools/中国日历.py'
alias ydd='py ~/终端专用文件夹/f-tools/yd下载器.py'
alias her='herdr'
alias unm="npx -p @unblockneteasemusic/server"
alias dsh="node --expose-internals /usr/lib/node_modules/@deepseek-ai/dsh/lib/bin.js"
alias xiamenw="curl wttr.in/厦门?lang=zh-cn"
alias gits="/home/flt18355/Daily/tools/gits.py"
