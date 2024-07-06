local opt = vim.opt
local g = vim.g

g.mapleader = " "
g.maplocalleader = " "

-- opt.backup = false
-- opt.writebackup = true
opt.swapfile = false
-- opt.ruler = true

opt.conceallevel = 0 --> default
-- opt.hidden = true --> required to keep multiple buffers and open multiple buffers

opt.cursorline = true
opt.laststatus = 3 --> goobal statusline
opt.signcolumn = "yes" --> always show sign column (left of line numbers)
opt.showtabline = 2 --> always show tabline
opt.showmode = false --> disable insert and visual mode msg in cmdline
opt.shortmess:append("cI") --> don't show redundant msgs from ins-completion-menu & disable default startup screen
opt.completeopt = { "menuone", "noselect" } --> for cmp, show menu for even a single entry and don't select by default
-- opt.pumheight = 10 --> no. of entries in pop-up menu
opt.termguicolors = true
opt.list = true -- show listchars (default: tab, trail, nbsp)

-- opt.iskeyword:append("-") --> consider words with '-' as single word
opt.iskeyword:remove("_") --> don't consider words joined with '_' as single word
opt.grepprg = "rg --vimgrep --smart-case --follow --hidden" --> get persistent recursive grep results in quickfix list

opt.scrolloff = 10 -- minimal number of screen lines to keep above and below the cursor.
opt.sidescrolloff = 10 -- minimal number of screen lines to keep left and right of the cursor.

opt.number = true
opt.relativenumber = true
opt.wrap = false

opt.fileencoding = "utf-8" --> the encoding written to a file
opt.mouse = "a" --> enable mouse
opt.mousemodel = "extend" --> disable right click menu
-- opt.clipboard = "unnamedplus" --> system clipboard
opt.undofile = true --> undo persistence

opt.foldmethod = "indent" -- folding, set to "expr" for treesitter based folding
-- opt.foldenable = false
opt.foldlevel = 99

-- pretty folds
function FoldText()
  local n_lines = vim.v.foldend - vim.v.foldstart
  local text_lines = n_lines == 1 and " line" or " lines"
  local first_line = vim.fn.getbufoneline(vim.api.nvim_get_current_buf(), vim.v.foldstart)
  first_line = first_line:gsub("^%s+", "")
  local step = vim.o.expandtab and (" "):rep(vim.o.shiftwidth - 1) or (" "):rep(vim.o.tabstop - 1)
  step = "│" .. step
  local indent = step:rep(#vim.v.folddashes - 1)
  local text = indent .. first_line .. " ······ " .. n_lines .. text_lines .. " "
  return text
end
vim.opt.foldtext = "v:lua.FoldText()"

opt.fillchars = {
  eob = " ", --> remove ~ under line numbers
  fold = "·", --> foldtext fill char
}

opt.timeoutlen = 600 --> time to wait for a mapped sequence to complete
opt.updatetime = 300 --> faster completion (default: 400ms)

-- better splits
opt.splitbelow = true
opt.splitright = true

-- indentation
opt.expandtab = true --> convert tabs to spaces
-- opt.autoindent = true
opt.smartindent = true
opt.shiftwidth = 4 --> no of spaces to use for each step of indent
opt.tabstop = 4 --> width of a tab
opt.softtabstop = 4 --> no of spaces which <tab> counts for performing <tab> ops
-- opt.smarttab = true

-- searching
-- opt.hlsearch = true --> highlight search
opt.ignorecase = true --> case insensitive search
opt.smartcase = true --> override ignorecase when using uppercase chars

vim.opt.inccommand = "split" --> Preview substitutions live

vim.opt.breakindent = true --> visually indented wrapped lines
vim.opt.linebreak = true --> wrap at `breakat` instead of last char

vim.opt.virtualedit = "block" --> Allow going past eol in visual block mode

-- disable perl and ruby providers
--g.loaded_perl_provider = 0
--g.loaded_ruby_provider = 0

-- disable some builtin vim plugins
local default_plugins = {
  "2html_plugin",
  "getscript",
  "getscriptPlugin",
  "gzip",
  "logipat",
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "matchit",
  "tar",
  "tarPlugin",
  "rrhelper",
  "spellfile_plugin",
  "vimball",
  "vimballPlugin",
  "zip",
  "zipPlugin",
  "tutor",
  "rplugin",
  "syntax",
  "synmenu",
  "optwin",
  "compiler",
  "bugreport",
}

for _, plugin in pairs(default_plugins) do
  g["loaded_" .. plugin] = 1
end

-- diagnostics
vim.diagnostic.config({
  virtual_text = {
    source = false,
    prefix = function(diagnostic, _, _)
      for severity, i in pairs(require("user.utils").diagnostics_icons) do
        if diagnostic.severity == vim.diagnostic.severity[severity:upper()] then return i end
      end
      return ""
    end,
  },
  signs = function()
    local signs = { text = {}, numhl = {}, linehl = {} }
    for _, x in ipairs({ "Error", "Warn", "Hint", "Info" }) do
      local severity = vim.diagnostic.severity[x:upper()]
      signs.text[severity] = ""
      signs.linehl[severity] = ""
      signs.numhl[severity] = "DiagnosticSign" .. x
    end
    return signs
  end,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    scope = "line",
    source = true,
    border = "single",
  },
})
