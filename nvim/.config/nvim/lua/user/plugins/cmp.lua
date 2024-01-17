local mappings = require("user.mappings")
local cmp_set_hl = function()
  vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
end
return {
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdLineEnter" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      cmp_set_hl()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = cmp_set_hl,
        group = vim.api.nvim_create_augroup("user_cmp_hlgroups", { clear = true }),
      })
      local cmp = require("cmp")
      local kind_icons = require("user.utils").kind_icons
      ---@diagnostic disable-next-line:missing-fields
      cmp.setup({
        snippet = {
          -- REQUIRED - you must specify a snippet engine
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
        ---@diagnostic disable-next-line:missing-fields
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
      })
      ---@diagnostic disable-next-line:missing-fields
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

      ---@diagnostic disable-next-line:missing-fields
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
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    config = function()
      mappings.luasnip()
    end,
  },
}
