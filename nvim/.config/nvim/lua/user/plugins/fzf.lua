return {
  "ibhagwan/fzf-lua",
  -- dependencies = { "nvim-tree/nvim-web-devicons" },
  dependencies = { "echasnovski/mini.icons" },
  enabled = false,
  opts = {
    code_actions = { previewer = "codeaction_native" }
  },
  config = function(_, opts)
    require("fzf-lua").setup(opts)
    require("user.keymaps").fzf()
    -- FzfLua.register_ui_select()
  end
}
