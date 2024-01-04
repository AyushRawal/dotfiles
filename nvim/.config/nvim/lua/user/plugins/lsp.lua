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
      require('lspconfig.ui.windows').default_options.border = 'single'
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
      vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })
    end,
  },
  -- language specific
  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
  },
  {
    "folke/neodev.nvim",
    ft = "lua",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      -- The directory in which to install packages.
      -- install_root_dir = path.concat { vim.fn.stdpath "data", "mason" },

      -- Where Mason should put its bin location in your PATH. Can be one of:
      -- - "prepend" (default, Mason's bin location is put first in PATH)
      -- - "append" (Mason's bin location is put at the end of PATH)
      -- - "skip" (doesn't modify PATH)
      ---@type '"prepend"' | '"append"' | '"skip"'
      PATH = "prepend",

      pip = {
        -- Whether to upgrade pip to the latest version in the virtual environment before installing packages.
        upgrade_pip = false,

        -- These args will be added to `pip install` calls. Note that setting extra args might impact intended behavior
        -- and is not recommended.
        --
        -- Example: { "--proxy", "https://proxyserver" }
        install_args = {},
      },

      -- Controls to which degree logs are written to the log file. It's useful to set this to vim.log.levels.DEBUG when
      -- debugging issues with package installations.
      log_level = vim.log.levels.INFO,

      -- Limit for the maximum amount of packages to be installed at the same time. Once this limit is reached, any further
      -- packages that are requested to be installed will be put in a queue.
      max_concurrent_installers = 4,

      github = {
        -- The template URL to use when downloading assets from GitHub.
        -- The placeholders are the following (in order):
        -- 1. The repository (e.g. "rust-lang/rust-analyzer")
        -- 2. The release version (e.g. "v0.3.0")
        -- 3. The asset name (e.g. "rust-analyzer-v0.3.0-x86_64-unknown-linux-gnu.tar.gz")
        download_url_template = "https://github.com/%s/releases/download/%s/%s",
      },

      -- The provider implementations to use for resolving package metadata (latest version, available versions, etc.).
      -- Accepts multiple entries, where later entries will be used as fallback should prior providers fail.
      -- Builtin providers are:
      --   - mason.providers.registry-api (default) - uses the https://api.mason-registry.dev API
      --   - mason.providers.client                 - uses only client-side tooling to resolve metadata
      providers = {
        "mason.providers.registry-api",
      },

      ui = {
        -- Whether to automatically check for new versions when opening the :Mason window.
        check_outdated_packages_on_open = true,

        -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
        border = "single",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },

        keymaps = {
          -- Keymap to expand a package
          toggle_package_expand = "<CR>",
          -- Keymap to install the package under the current cursor position
          install_package = "i",
          -- Keymap to reinstall/update the package under the current cursor position
          update_package = "u",
          -- Keymap to check for new version for the package under the current cursor position
          check_package_version = "c",
          -- Keymap to update all installed packages
          update_all_packages = "U",
          -- Keymap to check which installed packages are outdated
          check_outdated_packages = "C",
          -- Keymap to uninstall a package
          uninstall_package = "X",
          -- Keymap to cancel a package installation
          cancel_installation = "<C-c>",
          -- Keymap to apply language filter
          apply_language_filter = "<C-f>",
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
      end

      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {}
        -- opts.capabilities or {}
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
          local rt_ok, rust_tools = pcall(require, "rust-tools")
          if rt_ok then
            rust_tools.setup({
              server = {
                on_attach = on_attach,
                capabilities = capabilities,
              },
              hover_actions = {
                border = "single",
              },
            })
          end
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
