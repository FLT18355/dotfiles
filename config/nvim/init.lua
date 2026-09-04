-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
-- 切换粘贴模式
vim.keymap.set("n", "<F9>", function()
  if vim.o.paste then
    vim.o.paste = false
    print("粘贴模式关闭")
  else
    vim.o.paste = true
    print("粘贴模式开启")
  end
end, { desc = "Toggle paste mode" })

require("mason-lspconfig").setup({
  ensure_installed = {}, -- 清空自动安装列表
})
-- catppuccin
vim.cmd.colorscheme("catppuccin")

-- F2 格式化 Python 文件（使用 ruff）
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.keymap.set("n", "<F2>", function()
      -- 方法一：使用 LSP 格式化（推荐，如果 ruff LSP 已配置）
      -- vim.lsp.buf.format({ async = false })

      -- 方法二：如果不想用 LSP，可以用系统命令直接调用 ruff
      local filename = vim.fn.expand("%:p")
      vim.cmd(string.format('!ruff format "%s"', filename))
      vim.notify("已使用 ruff 格式化", vim.log.levels.INFO)
    end, { buffer = true, desc = "Format Python with ruff" })
  end,
})

-- 指定python目录
vim.g.python3_host_prog = "/usr/bin/python3"
