return {
  {
    "zbirenbaum/copilot.lua",
    -- optional = true,
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },
  {
    "saghen/blink.cmp",
    -- optional = true,
    dependencies = { "fang2hou/blink-copilot" },
    opts = {
      sources = {
        default = { "copilot" },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            -- score_offset = 100,
            async = true,
          },
        },
      },
    },
  },
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "Kaiser-Yang/blink-cmp-avante" },
    opts = {
      sources = {
        default = { "avante" },
        providers = {
          avante = {
            name = "avante",
            module = "blink-cmp-avante",
            score_offset = 100,
          },
        },
      },
    },
  },
  -- {
  --   "CopilotC-Nvim/CopilotChat.nvim",
  --   enabled = false,
  --   cmd = "CopilotChat",
  --   dependencies = {
  --     "zbirenbaum/copilot.lua",
  --     { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
  --   },
  --   -- build = "make tiktoken", -- Only on MacOS or Linux
  --   opts = {},
  -- },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
      provider = "copilot",
      providers = {
        copilot = {
          model = "claude-3.7-sonnet",
        },
      },
      selector = { provider = "snacks" },
      input = { provider = "snacks" },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "folke/snacks.nvim",
      "zbirenbaum/copilot.lua",
      "HakonHarnes/img-clip.nvim",
    },
    config = function(_, opts)
      require("avante").setup(opts)
      vim.cmd([[ hi AvanteSidebarNormal guibg=#141414 ]])
      vim.cmd([[ hi AvanteSidebarWinHorizontalSeparator guibg=#141414 guifg=#141414 ]])
      vim.cmd([[ hi AvanteSidebarWinSeparator guibg=#141414 guifg=#141414 ]])
    end,
  },
  -- {
  --   "olimorris/codecompanion.nvim",
  --   opts = {},
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  -- },
  { "nvim-lua/plenary.nvim", branch = "master" },
  -- {
  --   'MeanderingProgrammer/render-markdown.nvim',
  --   opts = {
  --     file_types = { "markdown", "Avante", "codecompanion" },
  --   },
  --   ft = { "markdown", "Avante", "codecompanion" },
  -- },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    opts = {
      preview = {
        filetypes = { "markdown", "codecompanion" },
        ignore_buftypes = {},
      },
    },
  },
  {
    "HakonHarnes/img-clip.nvim",
    opts = {
      embed_image_as_base64 = false,
      prompt_for_file_name = false,
      drag_and_drop = {
        insert_mode = true,
      },
      filetypes = {
        codecompanion = {
          prompt_for_file_name = false,
          template = "[Image]($FILE_PATH)",
          use_absolute_path = true,
        },
      },
    },
  },
}
