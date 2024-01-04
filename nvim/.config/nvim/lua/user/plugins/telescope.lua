return {
  "nvim-telescope/telescope.nvim",
  version = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = require("user.utils").on_plugin_load("telescope.nvim", function()
        require("telescope").load_extension("fzf")
      end),
    },
  },
  keys = require("user.mappings").telescope,
  cmd = "Telescope",
  config = function()
    local vimgrep_arguments = { unpack(require("telescope.config").values.vimgrep_arguments) }
    table.insert(vimgrep_arguments, "--hidden")
    table.insert(vimgrep_arguments, "--glob")
    table.insert(vimgrep_arguments, "!**/.git/*")
    local actions = require("telescope.actions")
    require("telescope").setup({
      defaults = {
        vimgrep_arguments = vimgrep_arguments,
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.60,
            results_width = 0.40,
          },
          vertical = {
            mirror = false,
          },
          width = 0.80,
          height = 0.80,
          preview_cutoff = 120,
        },
        prompt_prefix = "   ",
        selection_caret = " ",
        multi_icon = "+ ",
        -- results_title = false,
        -- border = false,
        borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        -- borderchars = {
        --   prompt = { "─", "│", "─", "│", '┌', '┐', "┤", "├" },
        --   results = { " ", "│", "─", "│", "│", "│", "┘", "└" },
        --   preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
        -- },
      },
      pickers = {
        find_files = {
          find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
        },
        buffers = {
          mappings = {
            i = {
              ["<C-Del>"] = actions.delete_buffer,
            },
            n = {
              ["<C-Del>"] = actions.delete_buffer,
            },
          },
        },
      },
    })
  end,
}
