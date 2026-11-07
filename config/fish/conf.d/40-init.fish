# ============================================
# 插件初始化与主题配置
# ============================================

# 禁用默认欢迎语
set -g fish_greeting ""

# 仅在交互式 Shell 中加载以下配置，避免影响非交互式脚本执行速度
if status is-interactive
    
    # 1. 设置终端主题
    fish_config theme choose catppuccin-mocha

    # 2. 提示符配置 (Starship)
    # 启用瞬态提示符模式，精简历史命令展示
    enable_transience
    starship init fish | source

    # 3. 模糊搜索与目录跳转
    fzf --fish | source
    zoxide init fish | source
    # tv init fish | source # 可选: Television 模糊搜索

    # 4. 历史记录管理 (Atuin)
    # 禁用默认快捷键绑定，防止与原生 Fish 历史搜索冲突
    set -gx ATUIN_NOBIND "true"
    atuin init fish | source
    
    # 自定义 Atuin 呼出快捷键 (Ctrl+Up)
    bind ctrl-up _atuin_search
    bind -M insert ctrl-up _atuin_search

    # 5. 补全系统 (可选)
    # carapace _carapace | source

    # 6. Vi 模式 (可选)
    # set -g fish_key_bindings fish_vi_key_bindings

end