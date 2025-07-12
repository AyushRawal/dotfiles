local mappings = require("user.keymaps")
local cmp_set_hl = function() vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true }) end
return {
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdLineEnter" },
    dependencies = {
      "L3MON4D3/LuaSnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "saadparwaiz1/cmp_luasnip",
    },
    opts = function()
      cmp_set_hl()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = cmp_set_hl,
        group = vim.api.nvim_create_augroup("user_cmp_hlgroups", { clear = true }),
      })
      local cmp = require("cmp")
      local kind_icons = require("user.utils").kind_icons
      return {
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        window = {
          completion = cmp.config.window.bordered({ border = "single" }),
          documentation = cmp.config.window.bordered({ border = "single" }),
        },
        mapping = cmp.mapping.preset.insert(mappings.cmp()),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "nvim_lsp_signature_help" },
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = function(_, vim_item)
            vim_item.kind = string.format("   %s%s", kind_icons[vim_item.kind], vim_item.kind)
            -- vim_item.menu = ({
            --   buffer = "[Buffer]",
            --   nvim_lsp = "[LSP]",
            --   luasnip = "[LuaSnip]",
            -- })[entry.source.name]
            return vim_item
          end,
        },
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
      }
    end,
    config = function(_, opts)
      local cmp = require("cmp")
      cmp.setup(opts)
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
        ---@diagnostic disable-next-line:missing-fields
        formatting = {
          format = function(_, vim_item)
            vim_item.kind = ""
            vim_item.menu = ""
            return vim_item
          end,
        },
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
        ---@diagnostic disable-next-line:missing-fields
        formatting = {
          format = function(_, vim_item)
            vim_item.kind = ""
            vim_item.menu = ""
            return vim_item
          end,
        },
      })
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    build = "make install_jsregexp",
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function() require("luasnip.loaders.from_vscode").lazy_load() end,
    },
    config = function()
      -- latex snippets in markdown math blocks
      require("luasnip").filetype_extend("latex", { "tex" })
      require("luasnip").setup({
        ft_func = require("luasnip.extras.filetype_functions").from_cursor_pos,
        load_ft_func = require("luasnip.extras.filetype_functions").extend_load_ft({
          markdown = { "latex" },
          markdown_inline = { "latex" },
        }),
      })
      mappings.luasnip()
    end,
  },
  -- {
  --   "iurimateus/luasnip-latex-snippets.nvim",
  --   dependencies = {
  --     "L3MON4D3/LuaSnip",
  --   },
  --   ft = { "markdown, markdown_inline", "tex", "latex" },
  --   config = function()
  --     require("luasnip-latex-snippets").setup({
  --       use_treesitter = true,
  --       allow_on_markdown = true,
  --     })
  --     require("luasnip").config.setup({
  --       enable_autosnippets = true,
  --     })
  --   end,
  -- },
}
