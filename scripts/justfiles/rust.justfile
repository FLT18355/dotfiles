# ==========================================
#  Rust 终极自动化管理 (原生 cargo test 版)
# ==========================================

set shell := ["bash", "-c"]

# 默认执行：列出所有可用命令
default:
    @just --list --unsorted

# ==========================================
#  开发与构建
# ==========================================

# 编译并运行当前项目
run:
    @echo "󰁔 启动项目..."
    cargo run

# 以 Debug 模式运行并开启详细日志（需要 tracing/log 依赖）
run-log:
    RUST_LOG=debug cargo run

# 编译 Release 版本（优化体积）
build:
    @echo "󰒓 正在编译 Release..."
    cargo build --release
    @echo "󰄬 编译完成，体积如下："
    @ls -lh target/release/ | tail -n +2

# 清理编译产物
clean:
    @echo "󰃢 清理 target 目录..."
    cargo clean
    @echo "󰄬 清理完毕"

# ==========================================
#  代码质量与格式化
# ==========================================

# 格式化代码
fmt:
    @echo "󰉢 格式化代码..."
    cargo fmt --all
    @echo "󰄬 格式化完成"

# 检查代码格式（不修改，用于 CI）
fmt-check:
    @echo "󰉢 检查代码格式..."
    cargo fmt --all -- --check

# 运行 Clippy 代码检查（严格模式，警告即错误）
lint:
    @echo "󰒓 运行 Clippy..."
    cargo clippy --all-targets --all-features -- -D warnings
    @echo "󰄬 检查通过"

# ==========================================
#  测试相关 (原生 cargo test)
# ==========================================

# 普通快速测试（只跑单元测试和集成测试，跳过文档测试）
test:
    @echo "󰗡 正在运行普通测试..."
    cargo test --lib --bins --tests

# 全量测试（包含文档测试 Doc tests，以及被忽略的慢测试）
test-all:
    @echo "󰗡 正在运行全量测试..."
    cargo test --all-targets -- --include-ignored

# 运行特定的测试（支持模糊匹配）：just test-one keyword
test-one keyword:
    @echo "󰍉 测试匹配项: {{keyword}}..."
    cargo test {{keyword}}

# 生成测试覆盖率报告（需要安装 cargo-llvm-cov）
test-cov:
    @echo "󰗡 生成代码覆盖率报告..."
    cargo llvm-cov --all-features --workspace --html
    @echo "󰄬 报告已生成: target/llvm-cov/html/index.html"

# 运行基准测试（需要 nightly 及 cargo bench）
bench:
    @echo "󰓅 运行基准测试..."
    cargo bench

# ==========================================
#  依赖管理与安全审计
# ==========================================

# 检查过时的依赖
outdated:
    @echo "󰍉 检查过时依赖..."
    cargo outdated

# 安全漏洞审计（需要 cargo-audit）
audit:
    @echo "󰒃 审计依赖安全漏洞..."
    cargo audit

# 分析依赖树
tree:
    @echo "󰐕 依赖树："
    cargo tree

# 查看依赖体积（需要 cargo-bloat）
bloat:
    @echo "󰓅 分析依赖体积..."
    cargo bloat --release -n 20

# ==========================================
#  交叉编译 (专为 Arch ARM 准备)
# ==========================================

# 编译 aarch64 (ARM64) 版本
build-arm64:
    @echo "󰒓 交叉编译 aarch64-unknown-linux-gnu..."
    cargo build --release --target aarch64-unknown-linux-gnu
    @echo "󰄬 ARM64 编译完成"

# ==========================================
#  Git 自动化
# ==========================================

# 提交并推送：just ship "提交信息"
ship msg:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "$(git status --porcelain)" ]; then
        echo "󰀦 没有需要提交的变更。"
        exit 0
    fi
    git add .
    git commit -m "{{msg}}"
    BRANCH=$(git branch --show-current)
    echo "󰁔 推送分支 $BRANCH..."
    git push origin "$BRANCH"

# 交互式 AI 生成提交信息并推送（需要安装 opencode / aichat 等 CLI）
ship-ai:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "$(git status --porcelain)" ]; then
        echo "󰀦 没有需要提交的变更。"
        exit 0
    fi
    git add .
    echo "󰚩 正在调用 AI 生成 commit message..."
    # 这里以 opencode 为例，你可以换成自己的 AI CLI
    MSG=$(git diff --cached | opencode --prompt "请根据以下代码变更生成一条简短的 git commit message，不要包含任何 Markdown 格式：")
    if [ -z "$MSG" ]; then
        echo "󰅚 生成失败，请手动提交。"
        exit 1
    fi
    echo "󰄬 生成的提交信息：$MSG"
    git commit -m "$MSG"
    BRANCH=$(git branch --show-current)
    echo "󰁔 推送分支 $BRANCH..."
    git push origin "$BRANCH"

# 安全的打标签：just tag v1.0.0 "发布说明"
tag version message:
    #!/usr/bin/env bash
    set -e
    if [ -n "$(git status --porcelain)" ]; then
        echo "󰀦 工作区有未提交的改动，先提交再打标签！"
        exit 1
    fi
    echo "󰓻 正在创建标签 {{version}}..."
    git tag -a {{version}} -m "{{message}}"
    echo "󰁔 推送标签到远端..."
    git push origin {{version}}
    echo "󰄬 标签 {{version}} 已创建并推送！"

# ==========================================
#  环境检查
# ==========================================

# 检查推荐的 Cargo 扩展工具是否安装
check-extensions:
    @echo "󰒓 正在检查 Cargo 扩展工具..."
    @cargo llvm-cov --version >/dev/null 2>&1 || echo "󰅚 缺少 cargo-llvm-cov (建议: cargo install cargo-llvm-cov)"
    @cargo audit --version >/dev/null 2>&1 || echo "󰅚 缺少 cargo-audit (建议: cargo install cargo-audit)"
    @cargo outdated --version >/dev/null 2>&1 || echo "󰅚 缺少 cargo-outdated (建议: cargo install cargo-outdated)"
    @cargo bloat --version >/dev/null 2>&1 || echo "󰅚 缺少 cargo-bloat (建议: cargo install cargo-bloat)"
    @echo "󰄬 检查完成"