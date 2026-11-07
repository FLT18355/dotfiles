return {
  -- 1. 堵住 LSP 层面的通道 (你之前的配置，保留是正确的)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          mason = false,  -- 非常正确，这样 Mason 就不会为 lua_ls 自动装什么了
        },
      },
    },
  },

  -- 2. 关键：堵住格式化工具 (conform.nvim) 的通道
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- 把这里清空，移除默认的 stylua
        lua = {},
      },
      -- 保险起见：在格式化器的通用设置里也把它排除掉
      formatters = {
        stylua = {
          enabled = false,
        },
      },
    },
  },

  -- 3. 阻击“后备军”：如果你启用了 lang.lua 这个扩展，也需要干预一下
  {
    "LazyVim/LazyVim",
    opts = {
      extras = {
        ["lang.lua"] = {
          mason = {
            ensure_installed = {
              -- 明确把 stylua 排除在外
              -- 如果提示不存在，说明你没装这个扩展，忽略即可
            },
          },
        },
      },
    },
  },
}
