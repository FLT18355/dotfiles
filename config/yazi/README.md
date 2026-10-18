# Yazi 汉化增强配置

> 一套基于 [Yazi](https://github.com/sxyazi/yazi) 的**中文增强配置**：界面提示全部汉化，内置 15 个实用插件，开箱即用。

- 适用版本：**Yazi 26.9.1**
- 面向用户：中文用户
- 特点：快捷键说明全中文、插件齐全、修复了默认配置里的键位冲突

---

## 一、插件与功能

| 插件 | 功能 | 快捷键 / 说明 |
| :--- | :--- | :--- |
| `mediainfo` | 音视频、图片的缩略图与媒体信息预览 | 光标停留即可预览；依赖 `ffmpeg`、`mediainfo` |
| `duckdb` | 预览 CSV / TSV / JSON / Parquet / XLSX / DB 表格数据 | 光标停留即可预览；依赖 `duckdb` |
| `docx-preview` | `.docx` 文档转纯文本预览（支持中文） | 依赖 `pandoc` |
| `gvfs` | 挂载 MTP / SMB / SFTP / WebDAV 等设备与远程存储 | `M` 系列、`G m`；依赖 `gvfs`、`glib` |
| `mount` | 本地磁盘分区挂载 / 卸载 / 弹出 | `M p`；依赖 `udisks2`、`util-linux` |
| `ouch` | 压缩 / 解压（自动适配格式） | `c z`；依赖 `ouch` |
| `recycle-bin` | 回收站管理：浏览、恢复、彻底删除、按天数清理 | `R b`；依赖 `trash-cli` |
| `whoosh` | 书签管理：持久/临时书签、fzf 模糊搜索、目录历史 | `[`、`}`、`]` 前缀组；依赖 `fzf`，**需手动安装** |
| `bypass` | 自动穿透「只有一个子目录」的目录链 | 配合 `→` 使用 |
| `smart-enter` | 目录则进入、文件则打开的「二合一」动作 | 通过 `bypass` 调用 |
| `augment-command` | 增强命令：选中后自动下移（不循环）等 | `<Space>` 选中后下移 |
| `open-with-cmd` | 用自定义命令打开文件 | `o c` |
| `full-border` | 给三栏界面加完整圆角边框 | 启动即生效 |
| `starship` | 顶部渲染 starship 提示符 | 依赖 `starship` |
| `simple-status` | 精简底部状态栏 | 启动即生效 |

> `package.toml` 锁定 14 个插件与 2 个现成主题（`dracula`、`catppuccin-mocha`），
> **`whoosh` 不在依赖清单里**，需要手动 clone 安装（见「安装」）。

---

## 二、相对默认配置的改动

1. **链接键位冲突修复（重点）**
   默认配置里 `-` 同时是「上一个标签页」和「创建符号链接」，`_` 同时是「与上一个标签交换」和「相对符号链接」，同一个键被两个功能抢占。
   现在 4 个标签键 `-` `=` `_` `+` 保持不变，链接功能改绑到普通符号键：
   - `(` 相对符号链接
   - `)` 绝对符号链接
   - `*` 硬链接
   （用法：`y` 选中文件 → 跳到目标目录 → 按对应符号）

2. **`g t` 改为回收站**
   默认 `g t` 是回收站，本配置原本改成了 Templates；现已恢复为 `plugin trash`（进入 Yazi 原生回收站视图），Templates 挪到 `g T`。

3. **标签页操作**统一用 `-` `=` `_` `+`（上一个 / 下一个 / 交换上一个 / 交换下一个）。
   因为 `[`、`}` 被 whoosh 书签插件占用，`]` 本身只作为 whoosh 的多键前缀（`] a`、`] f` 等），
   不再承担「切换到下一个标签页」的功能。

4. **输入框补回历史翻页**：`Ctrl+P` / `Ctrl+N`、`↑` / `↓` 以及普通模式下的 `k` / `j`
   都可以翻出之前的输入内容。

5. **键位表改为「覆盖式」**：`[mgr]` 段使用 `keymap` 而非默认的 `prepend_keymap`，
   即**不再加载 Yazi 内置默认键位**，所有按键都在配置里显式列出（更方便汉化，也避免出现
   「帮助里有一条英文默认键、实际又按不出来」的幽灵条目）。代价是 Yazi 升级后新增的默认键
   不会自动出现，需要手动补充。

6. **其他小调整**
   - `<Space>` 选中后自动下移且不循环
   - `→` 使用 `bypass smart-enter`（目录进、文件开）
   - `PageUp/PageDown` 与 `Shift+PageUp/PageDown` 的半页/整页对调
   - 复制路径改用新语法（`c c` / `c d` / `c f` / `c n`）
   - `theme.toml` 为手写 Material 风格深色主题；图标依赖 Nerd Font

---

## 三、汉化说明

- `keymap.toml` 中**所有快捷键的说明（`desc`）均已翻译为中文**，包括原本是英文的默认键
  （`G`、`Home`/`End`、`H`/`J`/`K`/`L`、`o`/`p`/`P`、`Ctrl+-`、`r`、`<F1>` 等）。
- 因此按 `~` 打开帮助面板、或按前缀键（如 `]`、`g`、`M`）弹出的按键提示，显示的都是中文。
- 插件自身的少数运行提示仍为英文（由上游插件决定）。

---

## 四、安装

```bash
# 1. 备份原配置
mv ~/.config/yazi ~/.config/yazi.bak

# 2. 克隆本仓库
git clone https://github.com/linxuan-sys/yazi.git ~/.config/yazi

# 3. 安装 package.toml 里的插件与主题
cd ~/.config/yazi
ya pkg install

# 4. whoosh 需要单独安装
git clone https://gitlab.com/WhoSowSee/whoosh.yazi.git \
  ~/.config/yazi/plugins/whoosh.yazi

# 5. 启动
yazi
```

### 主要依赖

```bash
# Arch Linux
sudo pacman -S pandoc-cli duckdb mediainfo ffmpeg imagemagick \
  starship trash-cli ouch 7zip file gvfs glib2 util-linux fzf zoxide
```

其他发行版按上表工具名安装即可（个别包名不同）。

> 更新配置：Yazi 中按 `U` 执行 `scripts/update_config.sh`，会强制覆盖本地改动，执行前请先备份。

---

## 五、说明

- 配置部分（`yazi.toml` / `keymap.toml` / `init.lua` / `theme.toml`）以 **MIT License** 发布，见 [`LICENSE`](./LICENSE)。
- `plugins/` 与 `flavors/` 为上游开源项目的副本，版权归各自作者所有。

<div align="center">

如果这套配置帮到了你，欢迎点个 ⭐ Star ～

Made with ❤️ by [linxuan-sys](https://github.com/linxuan-sys)

</div>
