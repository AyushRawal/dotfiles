return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "LspInfo", "LspStart" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    -- config = function()
    --   require("lspconfig.ui.windows").default_options.border = "single"
    --   vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
    --   vim.lsp.handlers["textDocument/signatureHelp"] =
    --     vim.lsp.buf.signature_help, { border = "single" }
    -- end,
  },
  -- language specific
  -->  java
  {
    "nvim-java/nvim-java",
  },
  --> rust
  {
    "mrcjkb/rustaceanvim",
    version = "^3",
    ft = "rust",
  },
  --> lua
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      integrations = {
        lspconfig = true,
        cmp = true,
        coq = false,
      },
    },
  },
  { -- optional completion source for require statements and module annotations
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end,
  },
  -- end --
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "single",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPost", "BufNewFile" },
    -- opts = {
    --   automatic_enable = true
    -- }
    config = function()
      vim.lsp.config.clangd = {
        cmd = {
          'clangd',
          '--clang-tidy',
          '--background-index',
          '--offset-encoding=utf-8',
        },
        root_markers = { '.clangd', 'compile_commands.json' },
        filetypes = { 'c', 'cpp' },
      }
      vim.lsp.enable("clangd")
      require('mason-lspconfig').setup({
        automatic_enable = true
      })
    end
    -- config = function()
    --   local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    --   local capabilities = vim.tbl_deep_extend(
    --     "force",
    --     {},
    --     vim.lsp.protocol.make_client_capabilities(),
    --     has_cmp and cmp_nvim_lsp.default_capabilities() or {}
    --   )
    --   require("mason-lspconfig").setup()
    --   local lspconfig = require("lspconfig")
    --   require("mason-lspconfig").setup_handlers({
    --     function(name)
    --       lspconfig[name].setup({
    --         capabilities = capabilities,
    --       })
    --     end,
    --     ["rust_analyzer"] = function()
    --       vim.g.rustaceanvim = {
    --         tools = {
    --           float_win_config = {
    --             border = "single",
    --           },
    --         },
    --       }
    --     end,
    --     ["jdtls"] = function()
    --       require("java").setup()
    --       lspconfig.jdtls.setup({ capabilities = capabilities })
    --     end,
    --   })
    -- end,
  },
}
