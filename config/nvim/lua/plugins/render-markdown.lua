return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },  -- 只在 markdown 文件中加载，提升启动速度
    opts = {
      -- 基础配置
      enabled = true,
      render_modes = { "n", "c", "t" },  -- 普通模式、命令行模式、终端模式
      max_file_size = 10.0,              -- 超过 10MB 的文件不渲染
      debounce = 100,                    -- 防抖延迟（毫秒）

      -- 标题渲染
      heading = {
        enabled = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },  -- 更美观的标题图标
        signs = { "󰫎 " },  -- 符号列图标
        width = "block",   -- 标题背景宽度：block（跟随文字）或 full（全宽）
        left_margin = 0,
        left_pad = 1,
        right_pad = 1,
        border = false,
      },

      -- 代码块渲染
      code = {
        enabled = true,
        sign = true,           -- 显示代码块图标
        width = "block",       -- 代码块宽度
        left_pad = 0,
        right_pad = 0,
      },

      -- 列表渲染
      bullet = {
        enabled = true,
        icons = { "•", "◦", "▪" },  -- 不同层级的列表符号
        sign = true,
      },

      -- 复选框渲染
      checkbox = {
        enabled = true,
        unchecked = { icon = "󰄱 ", highlight = "RenderMarkdownUnchecked" },
        checked = { icon = "󰱒 ", highlight = "RenderMarkdownChecked" },
        todo = { icon = "󰥔 ", highlight = "RenderMarkdownTodo" },
      },

      -- 引用块渲染
      quote = {
        enabled = true,
        icon = "▌",
        highlight = "RenderMarkdownQuote",
      },

      -- 表格渲染
      table = {
        enabled = true,
        style = "round",  -- 表格边框样式：round, heavy, double, markdown, none
      },

      -- 链接渲染
      link = {
        enabled = true,
        icon = "󰌵 ",
        highlight = "RenderMarkdownLink",
      },

      -- 图片占位符
      image = {
        enabled = true,
        icon = "󰋩 ",
        highlight = "RenderMarkdownImage",
      },

      -- 脚注渲染
      footnote = {
        enabled = true,
        before = "󰅂 ",
        after = "󰅀 ",
        highlight = "RenderMarkdownFootnote",
      },

      -- 光标行特殊处理（光标所在行显示原始 Markdown）
      anti_conceal = {
        enabled = true,
        mode = "n",  -- 普通模式下光标行不隐藏语法符号
      },

      -- 使用 LazyVim 预设，自动适配 LazyVim 的主题和风格
      preset = "lazy",
    },
    keys = {
      {
        "<leader>mr",
        "<cmd>RenderMarkdown toggle<cr>",
        desc = "Toggle markdown rendering",
      },
    },
  },
}
