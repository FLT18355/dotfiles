# ============================================
# 别名 (与 abbreviations 不重复)
# ============================================
# 注意：这里用原生 function 而不是 alias。
# fish 的 alias 每条约 10ms（内置实现要 fork），50 条约 500ms，
# 在 ARM/低配机上占启动时间的一半；function --wraps 几乎 0 成本。
# 写法：command <原命令> $argv，前面的 command 防止递归调用自己。

# ---- 目录导航 ----
function th --wraps=cd --description '回到主目录'
    builtin cd ~ $argv
end
function .. --wraps=cd --description '上级目录'
    builtin cd .. $argv
end
function ... --wraps=cd
    builtin cd ../.. $argv
end
function .... --wraps=cd
    builtin cd ../../.. $argv
end
function ..... --wraps=cd
    builtin cd ../../../.. $argv
end

# ---- 文件列表 (现代化 eza 增强) ----
function ls --wraps=eza --description 'eza 彩色列表'
    command eza --icons --color=always --group-directories-first $argv
end
function ll --wraps=eza --description 'eza 详细列表 + git 状态'
    command eza --icons --color=always -la --git $argv
end
function la --wraps=eza --description 'eza 含隐藏文件'
    command eza --icons --color=always -a $argv
end
function lt --wraps=eza --description 'eza 两层树'
    command eza --icons --color=always --tree --level=2 $argv
end

# ---- 文件操作 ----
function mkdir --wraps=mkdir
    command mkdir -p $argv
end
function mk --wraps=mkdir --description 'mkdir -p'
    command mkdir -p $argv
end
function cp --wraps=cp
    command cp -iv $argv
end
function mv --wraps=mv
    command mv -iv $argv
end
function rm --wraps=rm
    command rm -i $argv
end
function ln --wraps=ln
    command ln -s $argv
end
function tch --wraps=touch --description 'touch'
    command touch $argv
end
function cat --wraps=bat --description '用 bat 替代 cat'
    command bat --paging=never $argv
end

# ---- 压缩解压 ----
function untar --wraps=tar
    command tar -xvf $argv
end
function untgz --wraps=tar
    command tar -xzvf $argv
end
function unbz2 --wraps=tar
    command tar -xjvf $argv
end
function zipf --wraps=zip
    command zip -r $argv
end
function unzipf --wraps=unzip
    command unzip $argv
end
function 7zz --wraps=7z
    command 7z $argv
end
function un7z --wraps=7z
    command 7z x $argv
end

# ---- 开发工具 ----
function py --wraps=python3
    command python3 $argv
end
function v --wraps=nvim
    command nvim $argv
end
function grep --wraps=rg --description '用 rg 替代 grep'
    command rg $argv
end
function find --wraps=fd --description '用 fd 替代 find'
    command fd $argv
end
function j --wraps=just
    command just $argv
end

# ---- 下载工具 ----
function wget --wraps=wget
    command wget --show-progress $argv
end

# ---- 系统维护 ----
function df --wraps=df
    command df -h $argv
end
function du --wraps=dust --description '用 dust 替代 du'
    command dust $argv
end
function top --wraps=btop --description '用 btop 替代 top'
    command btop $argv
end
function cl --wraps=clear
    command clear $argv
end

# ---- 搜索 ----
function ftext --wraps=rg
    command rg --type txt $argv
end
function fcode --wraps=rg
    command rg --type py --type js --type c $argv
end

# ---- 工具 ----
function glow --wraps=glow
    command glow -s $HOME/.config/glow/catppuccin-mocha.json $argv
end
function ncat --wraps=nyancat
    command nyancat $argv
end
function tldr --wraps=tldr
    command tldr -L zh $argv
end
function ffc --wraps=fastfetch
    command fastfetch $argv
end
function fs --wraps=fish
    command fish $argv
end
function fsr --wraps=fisher
    command fisher $argv
end
function timer --description '计时 read'
    time read $argv
end
function e --wraps=exit
    command exit $argv
end
function her --wraps=herdr
    command herdr $argv
end
function dsh --wraps=node
    command node --expose-internals /usr/lib/node_modules/@deepseek-ai/dsh/lib/bin.js $argv
end
function met --wraps=metrocity --description '屏保'
    command metrocity $argv
end
