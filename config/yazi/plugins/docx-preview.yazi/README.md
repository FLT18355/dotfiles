# 📄 docx-preview.yazi

> **Instant `.docx` preview inside [Yazi](https://github.com/s-yazi/yazi).**

Put the cursor on a `.docx` file and the preview panel instantly shows its content — no Word / WPS, no loading screens. The plugin runs `pandoc` on the fly to convert the Word document into plain text, then renders it paginated to fit the preview pane. Zero delay, zero temp files ⚡

---

## ✨ Features

- ⚡ **Instant preview** — content shows up as soon as the cursor rests, no `Enter` needed
- 🔄 **On-the-fly conversion** — `pandoc` runs per preview and writes nothing to disk
- 🪶 **Lightweight** — pure Lua, `pandoc` is the only dependency
- 📜 **Auto pagination** — long documents are paginated to the pane height and scrollable
- 🛡️ **Friendly errors** — clear messages for a missing `pandoc`, conversion failures, and empty documents
- 🎯 **Non-intrusive** — only `.docx` files are handled; Yazi's built-in previewers stay untouched
- 🌏 **CJK-friendly** — Chinese text extracts and displays correctly

## 📦 Requirements

| Requirement | Required | Purpose |
| :--- | :---: | :--- |
| [Yazi](https://github.com/s-yazi/yazi) | ✅ | Runtime (tested on **Yazi 26.9.1**) |
| [pandoc](https://pandoc.org/) | ✅ | Converts `.docx` into plain text (tested on **pandoc 3.12.1**) |

Install `pandoc`:

```bash
# Arch Linux
sudo pacman -S pandoc

# Debian / Ubuntu
sudo apt install pandoc

# Fedora
sudo dnf install pandoc

# macOS (Homebrew)
brew install pandoc

# Windows (Scoop)
scoop install pandoc
```

## 🚀 Installation

**Option 1: Yazi's built-in package manager (recommended)** 🎉

```bash
ya pkg add linxuan-sys/docx-preview
```

**Option 2: Manual**

```bash
mkdir -p ~/.config/yazi/plugins/docx-preview.yazi
# then copy main.lua from this repo into that folder
```

## ⚙️ Configuration

Register `docx-preview` at the top of the previewer list in `~/.config/yazi/yazi.toml`:

```toml
[plugin]
prepend_previewers = [
	{ url = "*.docx", run = "docx-preview" },
]
```

> 💡 `prepend_previewers` inserts the rule *before* Yazi's built-in previewers, so `.docx` files are handled by this plugin.
> `url = "*.docx"` matches every Word document; you can match by MIME type instead:
> `{ mime = "application/vnd.openxmlformats-officedocument.wordprocessingml.document", run = "docx-preview" }`.

Restart Yazi and you're good to go 🚀

## 💡 Usage

1. Open Yazi in any directory and move the cursor onto a `.docx` file 👀
2. The preview panel immediately shows the document as plain text
3. Scroll long documents with `J` / `K` in the preview pane (Yazi's default `seek` bindings — remap them in `keymap.toml` if you like)
4. Press `Enter` to open the original file with your system's default application

## 🧩 How It Works

The plugin does exactly one thing, very purely:

```bash
pandoc -t plain --wrap=auto --columns=100 <your-document.docx>
```

1. `pandoc` converts the Word document to plain text (`-t plain`)
2. The output is split into lines and paginated using `job.skip` and the current pane height
3. Lines are handed to Yazi's `ui.Text` for rendering

The conversion goes through memory (stdout) only — **no temporary files are created**, so it's both fast and clean. Scrolling is handled by `seek()`, which re-triggers pagination on every scroll.

## ❓ FAQ

<details>
<summary><b>A red <code>pandoc command failed</code> error shows up in the preview pane.</b></summary>

`pandoc` is either not installed or not on your `PATH`. Install it as described in the Requirements section above.
</details>

<details>
<summary><b>The preview is blank.</b></summary>

The document probably contains no extractable text (for example, it's made of images or is a scan). `pandoc` can only extract text, not pictures.
</details>

<details>
<summary><b>Are tables, formulas, or images displayed?</b></summary>

No. The preview output is *plain text* — complex layouts are flattened into text, and formulas and images are ignored 🙈
</details>

<details>
<summary><b>Does it support the legacy <code>.doc</code> format?</b></summary>

No. `.doc` is a legacy binary format that `pandoc` cannot parse reliably. Save the file as `.docx` (Word / WPS can do this) first.
</details>

<details>
<summary><b>How do I change the wrap width or the preview output?</b></summary>

Open `main.lua` and change the number in `--columns=100` to whatever you prefer.
</details>

<details>
<summary><b>Will Chinese text be garbled?</b></summary>

Normally not. As long as your terminal font and encoding are set up correctly, Chinese content displays fine 🌏
</details>

<details>
<summary><b>Is it slow on very large documents?</b></summary>

Each preview invokes `pandoc` once, so a several-hundred-page document may take a moment to first appear. Thanks to pagination, scrolling itself stays smooth.
</details>

## 📁 Project Structure

```
docx-preview.yazi/
├── main.lua     # 🧠 Plugin core: peek() renders the preview, seek() handles scrolling
├── README.md    # 📖 The document you are reading right now
└── LICENSE      # 📄 MIT license
```

## 📄 License

Released under the [MIT License](LICENSE). Free to use, modify, and distribute.

## 🤝 Credits

- [Yazi](https://github.com/s-yazi/yazi) — the absurdly fast terminal file manager 🦆
- [pandoc](https://pandoc.org/) — the Swiss Army knife of document conversion 🔧

---

<div align="center">

**If this plugin helps you, a ⭐ Star is much appreciated!**

Made with ❤️ by [linxuan-sys](https://github.com/linxuan-sys)

</div>
