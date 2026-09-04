# ============================================
# XDG 运行时目录
# ============================================

if not set -q XDG_RUNTIME_DIR
    set -gx XDG_RUNTIME_DIR /tmp/runtime-$USER
    mkdir -p $XDG_RUNTIME_DIR
    chmod 700 $XDG_RUNTIME_DIR
end
