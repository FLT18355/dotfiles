return {
  {
    "mg979/vim-visual-multi",
    branch = "master",
    lazy = false, -- 多光标是核心功能，建议立即加载
    init = function()
      -- 手动修复快捷键冲突 (将 <C-n> 的功能映射到 <C-d>)
      vim.g.VM_maps = {
        ["Find Under"] = "<C-d>",   -- 原来是 <C-n>
        ["Find Subword Under"] = "<C-d>", -- 原来是 <C-n>
      }
    end,
  },
}
