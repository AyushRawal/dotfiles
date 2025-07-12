if vim.loader then vim.loader.enable() end

vim.uv = vim.uv or vim.loop
local keymaps = require("user.keymaps")

vim.cmd[[colorscheme retrobox]]

require("user.options")
require("user.autocmds")
require("user.usercmds")
require("user.lsp")
keymaps.main()

require("user.lazy")

require("user.custom.terminal").setup()
keymaps.terminal()
require("user.custom.comment").setup(keymaps.comment)

require("user.custom.lines").setup()

-- DONE: autopairs
-- DONE: comments, surround
-- DONE: completion
-- DONE: lsp keymaps
-- DONE: no quickfix or terminal windows in the buffer list
-- DONE: project root detection
-- DONE: statusline, tabline, statuscolumn
-- DONE: treesitter textobjects
-- DONE: which-key
-- DONE (avante): AI / LLM plugins (avante.nvim, codecompanion.nvim) (TODO: improve upon the llm workflow provided be avante; maybe use aider alongside it)
-- MAYBE: auto root (instead of command), maybe togglable using snacks.toggle
-- MAYBE: base46 colorscheme
-- MAYBE: better window resize
-- MAYBE: block comments: newline padding (with correct indentation) instead of spaces for multiline comments
-- MAYBE: cp mode
-- MAYBE: dadbod (db)
-- MAYBE: dap
-- MAYBE: hardtime.nvim
-- MAYBE: improve upon nvim-lint
-- MAYBE: jupyter
-- MAYBE: kuala.nvim or other for rest api testing (strong maybe), maybe use httpie or some command line tool (maybe using nvim terminal)
-- MAYBE: lines.lua: handle resizing, close button, different lines based on buffer or ft (https://nuxsh.is-a.dev/blog/custom-nvim-statusline.html)
-- MAYBE: mini.ai (textobjects)
-- MAYBE: mini.autopairs
-- MAYBE: mini.diff (minimal gitsigns) with mini.git
-- MAYBE: mini.surround
-- MAYBE: oil
-- MAYBE: QoL: flatten.nvim, more keymaps
-- MAYBE: trailblazer.nvim
-- MAYBE: repl support
-- TODO: color highlights, todo highlights (mini.hipatterns?, virtual text boxes for colors?)
-- DONE (using arglist): harpoon style buffer switching (show marked files in tabline along with other modified buffers, use snacks.picker for finding and deleting; lmm: add current file, (MAYBE)lmA: add file by input, lmd: remove current file, (MAYBE)lmf: picker, lmc: clear list); (TODO) improve upon this
-- TODO: markdown
-- TODO: mini.align
-- TODO: python environments selection and activation
-- TODO: quickfix list enhancements (maybe trouble.nvim?)
-- TODO: split-join (maybe using mini.splitjoin)
-- TODO: TREESITTER: move away from deprecated branch to new branch
-- TODO: winbar, treesitter context (window-id for quick window switching)
-- TOOD: project settings plugin, session management (mini.session)
-- TOOO: language specific (nvim-java, rustacean, tc.)
