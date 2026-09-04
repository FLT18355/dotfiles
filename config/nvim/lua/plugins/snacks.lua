return {
  "folke/snacks.nvim",
  opts = {
    -- opencode.nvim 依赖 input
    input = { enabled = true },
    winbar = { enabled = true, style = "rounded" },
    zen = {
      enabled = true,
      win = {
        width = vim.o.columns,
        height = vim.o.lines,
        backdrop = {
          transparent = false,
          blend = 0,
        },
      },
      toggles = {
        number = true,
        relativenumber = true,
        signcolumn = true,
        tabline = true,
        statusline = true,
        foldcolumn = true,
        laststatus = true,
      },
    },
    statuscolumn = {
      enabled = true,
      right = { "fold", "git" },
      left = { "mark", "sign" },
    },
    -- explorer 基础配置
    explorer = {
      enabled = true,
      replace_netrw = true,
    },
    -- 关键：隐藏文件的配置在这里！
    picker = {
      sources = {
        explorer = {
          -- 显示隐藏文件
          hidden = true, -- 改为 true 即可[citation:4]
          -- 可选：也显示 git 忽略的文件
          -- ignored = true,
        },
        files = {
          hidden = true, --显示隐藏文件
        },
      },
      actions = {
        opencode_send = function(picker)
          local items = vim.tbl_map(function(item)
            return item.file and require("opencode").format({ path = item.file, from = item.pos, to = item.end_pos })
              or item.text
          end, picker:selected({ fallback = true }))
          require("opencode").prompt(table.concat(items, ", ") .. " ")
        end,
      },
      win = {
        input = {
          keys = {
            ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
          },
        },
      },
    },
  },
  keys = {
    {
      "<leader>fe",
      function()
        Snacks.explorer()
      end,
      desc = "Snacks Explorer (Root Dir)",
    },
    {
      "<leader>fE",
      function()
        Snacks.explorer({ cwd = vim.uv.cwd() })
      end,
      desc = "Snacks Explorer (CWD)",
    },
  },
}
