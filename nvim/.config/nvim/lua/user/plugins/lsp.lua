return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "LspInfo", "LspStart" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("lspconfig.ui.windows").default_options.border = "single"
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
      vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })
    end,
  },
  -- language specific
  {
    "mrcjkb/rustaceanvim",
    version = "^3",
    ft = "rust",
  },
  {
    "folke/neodev.nvim",
    ft = "lua",
  },
  {
    "williamboman/mason.nvim",
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
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local function lsp_highlight_document(client)
        -- Set autocommands conditional on server_capabilities
        -- if client.server_capabilities.documentHighlightProvider then
        if client.supports_method("textDocument/documentHighlight") then
          local group = vim.api.nvim_create_augroup("user_lsp_document_highlight", { clear = true })
          vim.api.nvim_create_autocmd(
            "CursorHold",
            { callback = vim.lsp.buf.document_highlight, group = group, buffer = 0 }
          )
          vim.api.nvim_create_autocmd(
            "CursorMoved",
            { callback = vim.lsp.buf.clear_references, group = group, buffer = 0 }
          )
        end
      end

      local function codelens_autorefresh(client)
        -- Set autocommands conditional on server_capabilities
        -- if client.server_capabilities.codeLensProvider then
        if client.supports_method("textDocument/codeLens") then
          local group = vim.api.nvim_create_augroup("user_lsp_codelens", { clear = true })
          vim.api.nvim_create_autocmd(
            { "BufEnter", "CursorHold", "InsertLeave" },
            { callback = vim.lsp.codelens.refresh, group = group, buffer = 0 }
          )
        end
      end

      local on_attach = function(client, bufnr)
        require("user.mappings").lsp(bufnr)
        lsp_highlight_document(client)
        codelens_autorefresh(client)
        -- enable inlay hints
        if client.supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable()
        end
      end

      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {}
      )
      require("mason-lspconfig").setup()
      local lspconfig = require("lspconfig")
      require("mason-lspconfig").setup_handlers({
        function(name)
          lspconfig[name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
          })
        end,
        ["rust_analyzer"] = function()
          vim.g.rustaceanvim = {
            tools = {
              float_win_config = {
                border = "single",
              },
            },
            server = {
              on_attach = on_attach,
            },
          }
        end,
        ["lua_ls"] = function()
          local neodev_ok, neodev = pcall(require, "neodev")
          if neodev_ok then
            neodev.setup({
              override = function(root_dir, library)
                if root_dir:find("/home/rawal/LazyVim", 1, true) == 1 then
                  library.enabled = true
                  library.plugins = true
                end
              end,
            })
          end
          local capabilties = capabilities
          lspconfig["lua_ls"].setup({
            on_attach = on_attach,
            capabilities = capabilties,
          })
        end,
        --     settings = {
        --       Lua = {
        --         runtime = {
        --           -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        --           version = "LuaJIT",
        --         },
        --         diagnostics = {
        --           -- Get the language server to recognize the `vim` global
        --           globals = { "vim" },
        --         },
        --         workspace = {
        --           -- Make the server aware of Neovim runtime files
        --           library = vim.api.nvim_get_runtime_file("", true),
        --         },
        --         -- Do not send telemetry data containing a randomized but unique identifier
        --         telemetry = {
        --           enable = false,
        --         },
        --       },
        --     },
        --   })
        -- en
      })
    end,
  },
}
