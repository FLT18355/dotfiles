return {
  {
    "brenoprata10/nvim-highlight-colors",
    event = "VeryLazy",
    opts = {
      ---@type 'foreground'|'background'
      render = 'background',     -- 将颜色渲染为背景色
      enable_tailwind = true,    -- 支持 Tailwind CSS 颜色类
    },
  },
}
