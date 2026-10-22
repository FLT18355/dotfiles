# Yazi 汉化增强配置

> 一套基于 [Yazi](https://github.com/sxyazi/yazi) 的**中文增强配置**：界面提示全部汉化，内置 16 个实用插件，开箱即用。

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
| `preview-typst` | `.typ` 排版文档预览 | 依赖 `typst` |
| `gvfs` | 挂载 MTP / SMB / SFTP / WebDAV 等设备与远程存储 | `M` 系列、`G m`；依赖 `gvfs`、`glib` |
| `mount` | 本地磁盘分区挂载 / 卸载 / 弹出 | `M p`；依赖 `udisks2`、`util-linux` |
| `ouch` | 压缩 / 解压（自动适配格式） | `c z`；依赖 `ouch` |
| `recycle-bin` | 回收站管理：浏览、恢复、彻底删除、按天数清理 | `R b`；依赖 `trash-cli` |
| `bookmarks` | 书签管理：vim 风格 mark，持久化保存 | `[` 存、`]` 跳、`\ d` 删、`\ D` 清空；无额外依赖 |
| `bypass` | 自动穿透「只有一个子目录」的目录链 | 配合 `→` 使用 |
| `smart-enter` | 目录则进入、文件则打开的「二合一」动作 | 通过 `bypass` 调用 |
| `augment-command` | 增强命令：选中后自动下移（不循环）等 | `<Space>` 选中后下移 |
| `open-with-cmd` | 用自定义命令打开文件 | `o c` |
| `full-border` | 给三栏界面加完整圆角边框 | 启动即生效 |
| `starship` | 顶部渲染 starship 提示符 | 依赖 `starship` |
| `simple-status` | 精简底部状态栏 | 启动即生效 |

> `package.toml` 锁定 16 个插件与 2 个现成主题（`dracula`、`catppuccin-mocha`），
> 全部由 `ya pkg install` 自动安装，无需任何手动步骤。

---

## 二、相对默认配置的改动

1. **符号链接键位避让（重点）**
   Yazi 默认把 `-`（绝对链接）和 `_`（相对链接）留给符号链接，而这两个键的位置很适合放标签页操作。
   本配置把标签页固定在 `-` `=` `_` `+`，链接功能改绑到右侧符号键：
   - `(` 相对符号链接
   - `)` 绝对符号链接
   - `*` 硬链接
   （用法：`y` 选中文件 → 跳到目标目录 → 按对应符号）

2. **`g t` 为回收站**
   进入 Yazi 内置回收站视图（`plugin trash`）；Templates 挪到 `g T`，另配 `R b` 调用
   `recycle-bin` 插件做浏览、恢复与清理。

3. **标签页操作**
   - `-` / `=`：上一个 / 下一个标签页（默认是 `[` / `]`）
   - `_` / `+`：与上一个 / 下一个标签交换位置（默认是 `{` / `}`）
   - `1`~`9`：直接切换到第 N 个标签
   - `t q`：关闭当前标签（默认是 `<C-c>`，改绑以免与终端「中断」习惯冲突；最后一个标签时退出）
   - `t t` 新建标签、`t r` 重命名标签
   - `}` 因此空置，不再占用

4. **书签改用 `bookmarks` 插件**
   - `[`：保存当前位置为书签
   - `]`：跳转到书签（目录直接 `cd`，文件则 `reveal` 定位）
   - `\ d`：删除单个书签；`\ D`：清空全部书签
   - 持久化由 Yazi DDS 负责（`~/.local/state/yazi/.dds`），配置了 `persist = "all"`，重启不丢

5. **键位表改为「覆盖式」**：`[mgr]` 段使用 `keymap` 而非默认的 `prepend_keymap`，
   即**不再加载 Yazi 内置默认键位**，所有按键都在配置里显式列出（更方便汉化，也避免出现
   「帮助里有一条英文默认键、实际又按不出来」的幽灵条目）。代价是 Yazi 升级后新增的默认键
   不会自动出现，需要手动补充。

6. **输入框**
   保留 vim 风格编辑与历史翻页（`Ctrl+P` / `Ctrl+N`、`↑` / `↓`、普通模式下的 `k` / `j`）；
   默认的 `Alt+B` / `Alt+F` / `Ctrl+←` / `Ctrl+→` 的 "lean" 变体改为普通单词移动。

7. **其他小调整**
   - `<Space>` 选中后自动下移且不循环（借助 `augment-command`）
   - `→` 使用 `bypass smart-enter`（目录进、文件开）
   - `PageUp/PageDown` 与 `Shift+PageUp/PageDown` 的半页/整页对调
   - `<C-Up>` / `<C-Down>` 预览上下滚动 5 行（与 `K` / `J` 等价）
   - `<S-Left>` / `<S-Right>` 目录历史后退 / 前进
   - 支持 `o o` / `p p` 双键前缀写法，`p f` 强制粘贴
   - 重命名提供多种光标位置：`r r`（扩展名前）、`r f`（清空）、`r i`（开头）、`r a`（末尾）、`r c`（清空）
   - 复制路径改用新语法（`c c` / `c d` / `c f` / `c n`），另有 `c m` 清空主名重命名、`c r` 创建
   - `U` 一键从 Git 强制更新本配置（`scripts/update_config.sh`）
   - `yazi.toml`：按扩展名排序、行模式显示创建时间、显示隐藏文件、预览自动换行、
     图像缩放用 `lanczos3`、图片任务内存上限 1 GiB，并为 mediainfo / duckdb /
     docx-preview / preview-typst 注册了 preloader 与 previewer 规则
   - `theme.toml` 为手写 Material 风格深色主题；图标依赖 Nerd Font

---

## 三、汉化说明

- `keymap.toml` 中**所有快捷键的说明（`desc`）均已翻译为中文**，包括原本是英文的默认键
  （`G`、`Home`/`End`、`H`/`J`/`K`/`L`、`o`/`p`/`P`、`Ctrl+-`、`r`、`<F1>` 等）。
- 因此按 `~` 打开帮助面板、或按前缀键（如 `\`、`g`、`M`、`c`）弹出的按键提示，显示的都是中文。
- 插件自身的少数运行提示仍为英文（由上游插件决定），例如 `bookmarks` 保存时弹出的键位选择、
  自定义描述输入框标题。

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

# 4. 启动
yazi
```

### 主要依赖

```bash
# Arch Linux
sudo pacman -S pandoc-cli duckdb mediainfo ffmpeg imagemagick typst \
  starship trash-cli ouch 7zip file gvfs glib2 util-linux fzf zoxide
```

其中 `fzf` 与 `zoxide` 对应 Yazi 内置插件，分别供 `z`（fzf 跳转）和 `Z`（zoxide 跳目录）使用。

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
