return {
  "folke/which-key.nvim",
  -- keys = {
  --   "<leader>",
  --   "g",
  -- },
  opts = {
    preset = "helix",
    icons = { mappings = false },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add({ require("user.keymaps").wk }, { prefix = "<leader>" })
  end,
}
