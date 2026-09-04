return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      -- 将主题风格设为 latte（亮色）
      flavour = "latte",
      -- 亮色主题下一般不需要透明背景，但如果你需要可以保持 true
      transparent_background = true,
      term_colors = true,
      integrations = {
        aerial = true,
        diffview = true,
        mini = {
          enabled = true,
          indentscope_color = "sky",
        },
        noice = true,
        -- overseer = true,
        telescope = {
          enabled = true,
          -- style = "nvchad",
        },
        treesitter = true,
        notify = true,
        gitsigns = true,
        flash = true,
        blink_cmp = true,
        mason = true,
        snacks = true,
      },
      -- 高亮覆盖：将 mocha 改为 latte
      highlight_overrides = {
        latte = function(latte)
          return {
            CursorLineNr = { fg = latte.yellow },
            TelescopeSelection = { bg = latte.surface0 },
            TelescopeSelectionCaret = { fg = latte.yellow, bg = latte.surface0 },
            TelescopePromptPrefix = { fg = latte.yellow },
            FlashCurrent = { bg = latte.peach, fg = latte.base },
            FlashMatch = { bg = latte.red, fg = latte.base },
            FlashLabel = { bg = latte.teal, fg = latte.base },
            -- 亮色主题下的浮窗背景用 crust 或 surface0 会更柔和
            NormalFloat = { bg = latte.crust },
            FloatBorder = { bg = latte.crust },
            FloatTitle = { bg = latte.crust },
            RenderMarkdownCode = { bg = latte.crust },
            Pmenu = { bg = latte.surface0 },
            Comment = { bg = nil, style = {} },
            Conditional = { style = { "underline" } },
            Keyword = { style = { "bold" } },
            Repeat = { style = { "bold" } },
            statusline = { bg = nil },

            WinBar = { fg = latte.blue, bg = latte.surface0 },
            WinBarNC = { fg = latte.overlay0, bg = latte.surface0 },

            CursorLine = { bg = latte.surface0 }, -- 亮色下使用 surface0 高亮当前行
            StatusLine = { bg = nil, fg = latte.text }, -- 状态栏完全透明

            DiagnosticUnderlineError = { style = { "undercurl", "bold" }, sp = latte.red },
            DiagnosticUnderlineWarn = { style = { "undercurl" }, sp = latte.yellow },
            DiagnosticUnderlineInfo = { style = { "undercurl" }, sp = latte.blue },
            DiagnosticUnderlineHint = { style = { "undercurl" }, sp = latte.teal },
          }
        end,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      -- colorscheme 会自动根据 flavour 加载，但这里需要改成 "catppuccin-latte"
      vim.cmd.colorscheme("catppuccin-latte")
    end,
  },
}
