return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      -- 将主题风格设为 mocha（深色）
      flavour = "mocha",
      -- 深色主题下通常建议关闭透明背景，避免与终端背景冲突
      transparent_background = false,
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
      -- 高亮覆盖：将 latte 改为 mocha
      highlight_overrides = {
        mocha = function(mocha)
          return {
            CursorLineNr = { fg = mocha.yellow },
            TelescopeSelection = { bg = mocha.surface0 },
            TelescopeSelectionCaret = { fg = mocha.yellow, bg = mocha.surface0 },
            TelescopePromptPrefix = { fg = mocha.yellow },
            FlashCurrent = { bg = mocha.peach, fg = mocha.base },
            FlashMatch = { bg = mocha.red, fg = mocha.base },
            FlashLabel = { bg = mocha.teal, fg = mocha.base },
            -- 深色主题下的浮窗背景用 mantle 或 surface0 会更柔和
            NormalFloat = { bg = mocha.mantle },
            FloatBorder = { bg = mocha.mantle },
            FloatTitle = { bg = mocha.mantle },
            RenderMarkdownCode = { bg = mocha.mantle },
            Pmenu = { bg = mocha.surface0 },
            Comment = { bg = nil, style = {} },
            Conditional = { style = { "underline" } },
            Keyword = { style = { "bold" } },
            Repeat = { style = { "bold" } },
            statusline = { bg = nil },

            WinBar = { fg = mocha.blue, bg = mocha.surface0 },
            WinBarNC = { fg = mocha.overlay0, bg = mocha.surface0 },

            CursorLine = { bg = mocha.surface0 }, -- 深色下使用 surface0 高亮当前行
            StatusLine = { bg = nil, fg = mocha.text }, -- 状态栏完全透明

            DiagnosticUnderlineError = { style = { "undercurl", "bold" }, sp = mocha.red },
            DiagnosticUnderlineWarn = { style = { "undercurl" }, sp = mocha.yellow },
            DiagnosticUnderlineInfo = { style = { "undercurl" }, sp = mocha.blue },
            DiagnosticUnderlineHint = { style = { "undercurl" }, sp = mocha.teal },
          }
        end,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      -- colorscheme 名称改为 "catppuccin-mocha"
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
}