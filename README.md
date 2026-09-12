<div align="center">

# 🚀 My Dotfiles

<img src="./assets/1544x1544_circle.png" width="200" align="center">
[![GitHub last commit](https://img.shields.io/github/last-commit/FLT18355/dotfiles)](https://github.com/FLT18355/dotfiles)
[![GitHub repo size](https://img.shields.io/github/repo-size/FLT18355/dotfiles)](https://github.com/FLT18355/dotfiles)
[![License: Apache-2.0](https://img.shields.io/github/license/FLT18355/dotfiles)](LICENSE)
[![Made with Love](https://img.shields.io/badge/Made%20with-❤️-red)](https://github.com/FLT18355)

**一套精心配置的开发环境** · 一键部署 · Catppuccin 主题

</div>

---

## 📖 目录

- [🛠️ 包含工具](#️-包含工具)
- [⚡ 快速开始](#-快速开始)
- [📦 安装](#-安装)
- [📁 配置结构](#-配置结构)
- [🎨 主题](#-主题)
- [📜 许可证](#-许可证)

---

## 🛠️ 包含工具

| 工具 | 说明 |
|:-----|:-----|
| **Fish Shell** | 智能且友好的交互式 Shell，搭载 Catppuccin Tide 主题 |
| **Neovim** | 基于 LazyVim 的现代化编辑器，集成 LSP 与 AI 补全 |
| **Herdr** | 终端多路复用器，原生支持 AI Agent 集成 |
| **Yazi** | 高性能终端文件管理器，搭配 Catppuccin 配色 |
| **Fastfetch** | 系统信息展示工具，提供美观的终端横幅 |
| **OpenCode** | 终端 AI 编程助手 |
| **Pip** | Python 包管理器镜像配置 |

---

## ⚡ 快速开始

克隆本仓库到本地并进入目录：
`git clone git@github.com:FLT18355/dotfiles.git ~/dotfiles`
`cd ~/dotfiles`

---

## 📦 安装

### 使用 GNU Stow（推荐）
`stow -t ~ fish nvim yazi fastfetch herdr opencode pip`

### 手动安装
将 `config/` 下的各配置目录复制到 `~/.config/` 下，例如：
`cp -r config/fish ~/.config/fish`
`cp -r config/nvim ~/.config/nvim`
`cp -r config/yazi ~/.config/yazi`
`cp -r config/fastfetch ~/.config/fastfetch`
`cp -r config/herdr ~/.config/herdr`
`cp -r config/opencode ~/.config/opencode`
`cp -r config/pip ~/.config/pip`

### 前置依赖

| 工具 | 安装方式 |
|:-----|:---------|
| **Fish Shell** | `pacman -S fish` / `apt install fish` |
| **Neovim** | `pacman -S neovim` / `apt install neovim` |
| **Yazi** | `pacman -S yazi` / `cargo install yazi-fm` |
| **Fastfetch** | `pacman -S fastfetch` / `snap install fastfetch` |
| **Herdr** | 从 herdr.dev 获取官方安装包 |
| **Starship** | `pacman -S starship`（可选，用于 Fish 提示符） |

### 推荐插件

Fish 插件（使用 Fisher）：
`fisher install jorgebucaran/fisher`
`fisher install PatrickF1/fzf.fish`
`fisher install PatrickF1/autopair.fish`
`fisher install Kathlyn/puffer-fish-key-bindings`
`fisher install frikky/sponge`
`fisher install Illystrill/abbr-tips.fish`

Neovim 插件：LazyVim 会自动安装大部分，使用 Mason 手动安装 LSP 与工具。

Yazi 插件：
`ya pack -a yazi-rs/plugins:full`
`ya pack -a stonemetal/starship.yazi`

---

## 📁 配置结构

- `fish/`：Fish Shell 配置
- `nvim/`：Neovim 配置
- `yazi/`：Yazi 文件管理器配置
- `fastfetch/`：Fastfetch 系统信息配置
- `herdr/`：Herdr 终端复用器配置
- `opencode/`：OpenCode AI 编程助手配置
- `pip/`：Pip 镜像源配置

---

## 🎨 主题

本项目默认使用 Catppuccin 配色方案，支持 Mocha、Macchiato、Frappe、Latte 四个变体。

### Fish Shell
在 `config.fish` 中切换主题和风格：
- `catppuccin_tide mocha lean`（默认）
- `catppuccin_tide latte classic`
- `catppuccin_tide frappe rainbow`

### Herdr
在 `config/herdr/config.toml` 中设置主题名称，可选主题包括：`catppuccin`、`terminal`、`tokyo-night`、`dracula`、`nord`、`gruvbox`、`one-dark`、`solarized`、`kanagawa`、`rose-pine`、`vesper`。

### Yazi
在 `config/yazi/theme.toml` 中设置 `bg = "material.theme.mocha.base"`。

### Neovim
在 Neovim 配置中执行 `vim.cmd.colorscheme("catppuccin")`。

---

## 📜 许可证

本项目基于 Apache License 2.0 开源。