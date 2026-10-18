# docx.yazi

`docx.yazi` 是一个用于 Yazi 的 `.docx` 文件预览插件。

它通过 `pandoc` 将 Word 文档实时转换为纯文本，并在 Yazi 预览面板中显示内容。

## 功能

- 即时预览 `.docx` 文件
- 基于 `pandoc` 转换，响应快速
- 纯文本输出，便于在终端中阅读
- 依赖简单，仅需安装 `pandoc`

## 依赖

请先安装 `pandoc`：

```bash
# Arch Linux
sudo pacman -S pandoc

# Ubuntu / Debian
sudo apt install pandoc

# macOS (Homebrew)
brew install pandoc
```

## 配置示例

在 `yazi.toml` 的 `prepend_previewers` 中添加：

```toml
{ url = "*.docx", run = "docx-preview" }
```

## 说明

- 插件入口文件：`main.lua`
- 当 `pandoc` 执行失败时，预览面板会显示错误信息
