local keymaps = require("user.keymaps")
return {
  {
    "stevearc/conform.nvim",
    keys = keymaps.conform,
    event = { "BufReadPost", "BufNewFile" },
    opts = function()
      local prettier = { "prettierd", "prettier", stop_after_first = true }
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      return {
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "isort", "black" },
          javascript = prettier,
          typescript = prettier,
          javascriptreact = prettier,
          typescriptreact = prettier,
          markdown = prettier,
          sh = { "shfmt" },
          sql = { "sqlfmt" },
          html = prettier,
          css = prettier,
        },
        default_format_opts = {
          lsp_format = "fallback",
          async = true,
        }
      }
    end,
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("lint").linters_by_ft = {
        -- sh = { "shellcheck" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave", "BufEnter" }, {
        group = vim.api.nvim_create_augroup("user_lint", { clear = true }),
        callback = function() require("lint").try_lint() end,
      })
    end,
  },
  {
    "echasnovski/mini.icons",
    lazy = "true",
    opts = {}
  },
  {
    "folke/which-key.nvim",
    opts = {
      preset = "helix",
      icons = { mappings = false },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({ keymaps.wk }, { prefix = "<leader>" })
    end,
  },
  {
    'nmac427/guess-indent.nvim',
    opts = {}
  },
  {
    "kylechui/nvim-surround",
    opts = {
      surrounds = {
        ["*"] = {
          add = { "**", "**" },
        },
      },
      move_cursor = "sticky"
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      current_line_blame_opts = {
        virt_text_opts = "right_align",
      },
      on_attach = keymaps.gitsigns,
    },
  },
  {
    "kosayoda/nvim-lightbulb",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      autocmd = {
        enabled = true,
      },
      sign = { enabled = false },
      code_lenses = true,
      virtual_text = {
        enabled = true,
        text = "  󱐋",
        lens_text = "  "
      },
    },
  },
}
