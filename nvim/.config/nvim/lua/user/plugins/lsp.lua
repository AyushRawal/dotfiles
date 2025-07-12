return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("user.keymaps").lspconfig()
    end
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "fzf-lua", words = { "FzfLua" } },
        { path = "lazy.nvim", words = { "LazyVim" } },
      },
    },
  },
}
