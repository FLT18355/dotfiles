-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.guicursor = "i:ver25"
-- 开启自动换行
vim.opt.wrap = true

-- 设置换行边界（可选，默认80列）
vim.opt.textwidth = 0

-- 换行时自动缩进
vim.opt.breakindent = true

-- 换行时显示的对齐符号（可选）
vim.opt.showbreak = "↪ "

-- 让 y 复制到系统剪贴板 + 寄存器
vim.keymap.set({ "n", "v" }, "y", '"+y') -- 普通模式和可视模式下 y 映射到 +y

-- 为 Termux 配置系统剪贴板支持
if vim.fn.executable("termux-clipboard-set") == 1 then
  vim.g.clipboard = {
    name = "termux-clipboard",
    copy = {
      ["+"] = { "termux-clipboard-set" },
      ["*"] = { "termux-clipboard-set" },
    },
    paste = {
      ["+"] = { "termux-clipboard-get" },
      ["*"] = { "termux-clipboard-get" },
    },
  }
end

-- 强制使用basedpyright(在启用lazyvim python扩展的情况下)
vim.g.lazyvim_python_lsp = "basedpyright"
