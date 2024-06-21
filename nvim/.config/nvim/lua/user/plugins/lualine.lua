local diff_source = function()
  ---@diagnostic disable-next-line:undefined-field
  local gs = vim.b.gitsigns_status_dict
  if gs then
    return {
      added = gs.added,
      modified = gs.changed,
      removed = gs.removed,
    }
  end
end

local diagnostics_icons = require("user.utils").diagnostics_icons

return {
  "nvim-lualine/lualine.nvim",
  -- dev = true,
  opts = {
    options = {
      icons_enabled = true,
      theme = "gruvbox-material",
      -- component_separators = { left = '', right = '' },
      -- section_separators = { left = '', right = '' },
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = {
        statusline = {},
        winbar = { "neo-tree", "packer", "qf", "help", "term" },
      },
      ignore_focus = { "neo-tree" },
      always_divide_middle = true,
      globalstatus = true,
      refresh = {
        statusline = 1000,
        tabline = 1000,
        winbar = 1000,
      },
    },
    sections = {
      lualine_a = {
        {
          function()
            return " "
          end,
          padding = { left = 0, right = 0 },
        },
      },
      lualine_b = {},
      lualine_c = {
        {
          function()
            return vim.bo.filetype
          end,
          color = function()
            local buf = vim.api.nvim_get_current_buf()
            local ts = vim.treesitter.highlighter.active[buf]
            return { fg = ts and not vim.tbl_isempty(ts) and "#a89984" or "#ea6962" }
          end,
          cond = function()
            return vim.bo.filetype ~= ""
          end,
        },
        {
          "b:gitsigns_head",
          icon = "",
        },
        {
          "diff",
          source = diff_source,
        },
        -- {
        --   function()
        --     return vim.lsp.status()
        --   end
        -- },
        {
          function()
            return "%="
          end,
        },
        {
          "filetype",
          icon_only = true,
        },
        {
          function()
            return require("user.root").pretty_path()
          end,
          padding = { left = 0, right = 1 },
        },
      },
      lualine_x = {
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          symbols = {
            error = diagnostics_icons.Error .. " ",
            warn = diagnostics_icons.Warn .. " ",
            info = diagnostics_icons.Info .. " ",
            hint = diagnostics_icons.Hint .. " ",
          },
        },
        {
          "location",
          color = { fg = "#a89984" },
        },
        {
          "progress",
          -- fmt = function()
          --   return "%P|%L"
          -- end,
          color = { fg = "#a89984" },
        },
        {
          function()
            if vim.api.nvim_buf_get_option(0, "expandtab") then
              return "Space:" .. vim.o.shiftwidth
            end
            return "Tab:" .. vim.o.tabstop
          end,
          color = { fg = "#a89984" },
        },
        {
          "fileformat",
          symbols = {
            unix = "LF",
            dos = "CRLF",
            mac = "CR",
          },
          color = { fg = "#a89984" },
        },
      },
      lualine_y = {},
      lualine_z = {
        {
          function()
            return " "
          end,
          padding = { left = 0, right = 0 },
        },
      },
    },
    inactive_sections = {},
    tabline = {
      lualine_b = {
        {
          "buffers",
          mode = 4,
          show_filename_only = false,
          max_length = function()
            return vim.o.columns
          end,
        },
      },
      lualine_y = {
        "tabs",
      },
    },
    winbar = {
      lualine_c = {
        -- {
        --   function()
        --     return "󰐅"
        --   end,
        --   color = function()
        --     local colors = {
        --       green = vim.g.terminal_color_2,
        --       red = vim.g.terminal_color_1,
        --     }
        --     local buf = vim.api.nvim_get_current_buf()
        --     local ts = vim.treesitter.highlighter.active[buf]
        --     return { fg = ts and not vim.tbl_isempty(ts) and colors.green or colors.red }
        --   end,
        --   -- separator = "│",
        -- },
        {
          function()
            if not package.loaded["nvim-navic"] then
              return ""
            end
            if require("nvim-navic").is_available() then
              return require("nvim-navic").get_location()
            else
              return ""
            end
          end,
        },
      },
      lualine_x = {
        {
          function()
            if not package.loaded["lint"] then
              return ""
            end
            local linters = require("lint").linters_by_ft[vim.bo.filetype]
            ---@diagnostic disable-next-line:param-type-mismatch
            if next(linters) == nil then
              return ""
            end
            local s = " "
            ---@diagnostic disable-next-line:param-type-mismatch
            for i, linter in ipairs(linters) do
              s = s .. linter
              if i ~= #linters then
                s = s .. ", "
              end
            end
            return s
          end,
          color = { fg = "#e78a4e" },
        },
        {
          function()
            if not package.loaded["conform"] then
              return ""
            end
            local formatters = require("conform").formatters_by_ft[vim.bo.filetype]
            ---@diagnostic disable-next-line:param-type-mismatch
            if next(formatters) == nil then
              return ""
            end
            local s = "  "
            ---@diagnostic disable-next-line:param-type-mismatch
            for i, formatter in ipairs(formatters) do
              s = s .. formatter
              if i ~= #formatters then
                s = s .. ", "
              end
            end
            return s
          end,
          color = { fg = "#d3869b" },
        },
        {
          function()
            local conda_env = os.getenv("CONDA_DEFAULT_ENV")
            local venv_path = os.getenv("VIRTUAL_ENV")

            if venv_path == nil then
              if conda_env == nil then
                return ""
              else
                return string.format(" (conda) %s", conda_env)
              end
            else
              local venv_name = vim.fn.fnamemodify(venv_path, ":t")
              return string.format(" (venv) %s", venv_name)
            end
          end,
          cond = function()
            return vim.bo.filetype == "python"
          end,
          color = { fg = "#7daea3" },
        },
        {
          function()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if next(clients) == nil then
              return ""
            end
            local s = "  LSP ~ "
            -- local s = "~ "
            for i, client in ipairs(clients) do
              s = s .. client.name
              if i ~= #clients then
                s = s .. " | "
              end
            end
            return s
          end,
        },
      },
    },
    inactive_winbar = {
      lualine_a = {
        {
          function()
            return require("user.root").pretty_path()
          end,
        },
      },
      lualine_b = { "diff" },
      lualine_x = { "filetype" },
      lualine_y = { "location" },
      lualine_z = { "progress" },
    },
    extensions = { "quickfix", "lazy", "man", "nvim-dap-ui", "oil" },
  },
}
