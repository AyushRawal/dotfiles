local mappings = require("user.mappings")
return {
  {
    "kylechui/nvim-surround",
    keys = {
      "ys",
      "ds",
      "cs",
      { "S", mode = "x" },
      { "<C-g>s", mode = "i" },
    },
    opts = {
      surrounds = {
        ["*"] = {
          add = { "**", "**" },
        },
      },
    },
    config = function(opts)
      require("nvim-surround").setup(opts)
      local function surround_set_hl()
        vim.api.nvim_set_hl(0, "NvimSurroundHighlight", { link = "@text.warning" })
      end
      surround_set_hl()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = surround_set_hl,
        group = vim.api.nvim_create_augroup("user_surround_hl", { clear = true }),
      })
    end,
  },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "kosayoda/nvim-lightbulb",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      autocmd = {
        enabled = true,
      },
      sign = { enabled = false },
      virtual_text = {
        enabled = true,
        text = "  󱐋",
      },
    },
  },
  {
    "nvimdev/indentmini.nvim",
    event = { "BufReadPost", "BufNewFile" },
    -- dev = true,
    config = function()
      require("indentmini").setup({
        char = "│",
        exclude = {
          "lisp",
          "scheme",
          "quickfix",
        },
      })
      local function indent_set_hl()
        local indent_hl = vim.api.nvim_get_hl(0, { name = "IndentLine" })
        if vim.tbl_isempty(indent_hl) then
          indent_hl = vim.api.nvim_get_hl(0, { name = "IblIndent" })
        end
        if vim.tbl_isempty(indent_hl) then
          print("hi")
          indent_hl = vim.api.nvim_get_hl(0, { name = "Whitespace" })
        end
        indent_hl.nocombine = true
        vim.api.nvim_set_hl(0, "IndentLine", indent_hl)

        local scope_hl = vim.api.nvim_get_hl(0, { name = "IndentLineCurrent" })
        if vim.tbl_isempty(scope_hl) then
          scope_hl = vim.api.nvim_get_hl(0, { name = "IblScope" })
        end
        if vim.tbl_isempty(scope_hl) then
          scope_hl = vim.api.nvim_get_hl(0, { name = "LineNr" })
        end
        scope_hl.nocombine = true
        vim.api.nvim_set_hl(0, "IndentLineCurrent", scope_hl)
      end
      indent_set_hl()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = indent_set_hl,
        group = vim.api.nvim_create_augroup("user_indentline_hl", { clear = true }),
      })
    end,
  },
  { "j-hui/fidget.nvim", opts = {}, event = { "LspAttach" } },
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufNewFile", "BufReadPost" },
    opts = {
      user_default_options = { css = true },
    },
  },
  {
    "echasnovski/mini.bufremove",
    version = false,
    keys = mappings.mini_bufremove,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      current_line_blame_opts = {
        virt_text_opts = "right_align",
      },
      on_attach = mappings.gitsigns,
    },
  },
  {
    "stevearc/conform.nvim",
    keys = mappings.conform,
    event = { "BufReadPost", "BufNewFile" },
    opts = function()
      local prettier = { { "prettierd", "prettier" } }
      return {
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "isort", "black" },
          javascript = prettier,
          typescript = prettier,
          javascriptreact = prettier,
          typescriptreact = prettier,
          sh = { "shfmt" },
        },
      }
      -- vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("lint").linters_by_ft = {
        sh = { "shellcheck" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave", "BufEnter" }, {
        group = vim.api.nvim_create_augroup("user_lint", { clear = true }),
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
  { "nmac427/guess-indent.nvim", opts = {}, event = "BufReadPost" },
  {
    "echasnovski/mini.align",
    keys = {
      { "ga", mode = { "n", "x" } },
      { "gA", mode = { "n", "x" } },
    },
    version = false,
    opts = {},
  },
  {
    "Wansmer/treesj",
    keys = { "<space>m", "<space>j", "<space>s" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    ft = "markdown",
    keys = require("user.mappings").obsidian,
    cmd = {
      "ObsidianOpen",
      "ObsidianNew",
      "ObsidianQuickSwitch",
      "ObsidianFollowLink",
      "ObsidianBacklinks",
      "ObsidianToday",
      "ObsidianYesterday",
      "ObsidianTomorrow",
      "ObsidianTemplate",
      "ObsidianSearch",
      "ObsidianLink",
      "ObsidianLinkNew",
      "ObsidianWorkspace",
      "ObsidianPasteImg",
      "ObsidianRename",
    },
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    event = {
      "BufReadPre " .. vim.fn.expand("~") .. "/Notes/**.md",
      "BufNewFile " .. vim.fn.expand("~") .. "/Notes/**.md",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "Notes",
          path = "~/Notes",
        },
      },
      disable_frontmatter = true,
      note_id_func = function(title)
        title = title or tostring(os.time())
        return title
      end,
      attachments = {
        img_folder = "assets",
      },
      -- finder_mappings = {
      --   new = "<C-b>" -- not working ??
      -- },
    },
  },
  {
    "3rd/image.nvim",
    build = "luarocks --lua-version 5.1 --local install magick",
    event = {
      "FileType markdown,norg,markdown_inline",
      "BufRead *.png,*.jpg,*.gif,*.webp,*.ipynb",
    },
    enabled = false,
    opts = {
      max_width = 80,
      max_height = 12,
      window_overlap_clear_enabled = true,
      integrations = {
        markdown = {
          -- obsidian vault wiki links
          resolve_image_path = function(document_path, image_path, fallback)
            if vim.startswith(document_path, "/home/rawal/Notes") then
              if not vim.startswith(image_path, "assets/") then
                image_path = "assets/" .. image_path
              end
            end
            return fallback(document_path, image_path)
          end,
        },
      },
    },
    config = function(_, opts)
      package.path = table.concat({
        package.path,
        vim.fs.normalize("~/.luarocks/share/lua/5.1/?/init.lua"),
        vim.fs.normalize("~/.luarocks/share/lua/5.1/?.lua"),
      }, ";")
      require("image").setup(opts)
    end,
  },
  {
    "jbyuki/nabla.nvim",
    ft = { "markdown", "markdown_inline", "latex", "tex" },
    keys = require("user.mappings").nabla,
  },
}
