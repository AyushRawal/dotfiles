local opt = vim.opt
local g = vim.g

g.mapleader = " "
g.maplocalleader = " "


opt.timeoutlen = vim.g.vscode and 1000 or
    600              --> time to wait for a mapped sequence to complete, low value to trigger which-key
opt.updatetime = 300 --> faster completion, save swap file and trigger CursorHold (default: 400ms)

-- opt.backup = false
-- opt.writebackup = true
opt.undofile = true --> undo persistence
opt.autowrite = true
opt.swapfile = false
opt.confirm = true
opt.fileencoding = "utf-8" --> the encoding written to a file
-- opt.hidden = true                                        --> required to keep multiple buffers and open multiple buffers (default: true)


if vim.fn.has("nvim-0.10") == 1 then opt.smoothscroll = true end
-- opt.ruler = true                                         --> (default: true)
opt.winborder = "single"
opt.cursorline = true      --> highlight current line
opt.laststatus = 3         --> global statusline
opt.signcolumn = "yes"     --> always show sign column (left of line numbers)
opt.showtabline = 2        --> always show tabline
opt.showmode = false       --> disable insert and visual mode msg in cmdline
opt.shortmess:append("cI") --> don't show redundant msgs from ins-completion-menu & disable default startup screen
opt.termguicolors = true
-- opt.pumheight = 10                                       --> no. of entries in pop-up menu
vim.opt.inccommand = "split" --> Preview substitutions live
vim.opt.breakindent = true   --> visually indented wrapped lines
vim.opt.linebreak = true     --> wrap at `breakat` instead of last char
--> better splits <--
opt.splitbelow = true
opt.splitright = true
opt.splitkeep =
"screen"        --> scroll behavior within splits, keep text on same screen line if possible
opt.list = true --> show listchars (default: tab, trail, nbsp)
opt.fillchars = {
  eob = " ",    --> remove ~ under line numbers
  fold = " "    -- "·",   --> foldtext fill char
}
--> completion <--
opt.completeopt = {
  "menuone",  --> show for even a single entry
  "noselect", --> don't select by default
  "noinsert", --> don't insert until selected
  "popup",    --> show info about current entry
  "fuzzy",    --> enable fuzzy matching
}
opt.wildignorecase = true
opt.wildmode = "longest:full,full"


-- opt.clipboard = "unnamedplus"                            --> system clipboard
opt.conceallevel = 0   --> default
opt.scrolloff = 10     --> minimal number of screen lines to keep above and below the cursor.
opt.sidescrolloff = 10 --> minimal number of screen lines to keep left and right of the cursor.
opt.number = true
opt.relativenumber = true
opt.wrap = false
-- opt.iskeyword:append("-")                                --> consider words with '-' as single word
opt.iskeyword:remove("_")     --> don't consider words joined with '_' as single word
vim.opt.virtualedit = "block" --> Allow going past eol in visual block mode
--> indentation <--
opt.expandtab = true          --> convert tabs to spaces
-- opt.autoindent = true                                    --> (default: true)
opt.smartindent = true
opt.shiftwidth = 4    --> no of spaces to use for each step of indent
opt.tabstop = 4       --> width of a tab
opt.softtabstop = 4   --> no of spaces which <tab                                 > counts for performing <tab> ops
opt.shiftround = true --> Round indent to multiple of 'shiftwidth' with `<` and  `>`
-- opt.smarttab = true                                      --> (default: true)
--> searching <--
-- opt.hlsearch = true                                      --> highlight search (default: true)
opt.ignorecase = true                                       --> case insensitive search
opt.smartcase = true                                        --> override ignorecase when using uppercase chars
opt.grepprg = "rg --vimgrep --smart-case --follow --hidden" --> get persistent recursive grep results in quickfix list


opt.mouse = "a"           --> enable mouse
opt.mousemodel = "extend" --> disable right click menu


function FoldExpr()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].ts_folds == nil then
    -- as long as we don't have a filetype, don't bother
    -- checking if treesitter is available (it won't)
    if vim.bo[buf].filetype == "" then return "0" end
    if vim.bo[buf].filetype:find("dashboard") then
      vim.b[buf].ts_folds = false
    else
      vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
    end
  end
  return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or "0"
end

function FoldText()
  local function fold_virt_text(result, s, lnum, coloff)
    if not coloff then coloff = 0 end
    local text = ""
    local hl
    for i = 1, #s do
      local char = s:sub(i, i)
      local hls = vim.treesitter.get_captures_at_pos(0, lnum, coloff + i - 1)
      local _hl = hls[#hls]
      if _hl then
        local new_hl = "@" .. _hl.capture
        if new_hl ~= hl then
          table.insert(result, { text, hl })
          text = ""
          hl = nil
        end
        hl = new_hl
      end
      text = text .. char
    end
    table.insert(result, { text, hl })
  end
  local start = vim.fn.getline(vim.v.foldstart):gsub("\t", string.rep(" ", vim.o.tabstop))
  local end_str = vim.fn.getline(vim.v.foldend)
  local end_ = vim.trim(end_str)
  local result = {}
  fold_virt_text(result, start, vim.v.foldstart - 1)
  table.insert(result, { " ... ", "Delimiter" })
  fold_virt_text(result, end_, vim.v.foldend - 1, #(end_str:match("^(%s+)") or ""))
  local n_lines = vim.v.foldend - vim.v.foldstart
  local n_lines_text = n_lines .. (n_lines == 1 and " line" or " lines")
  table.insert(result, { "  " .. n_lines_text, "Comment" })
  return result
end


-- opt.foldenable = false
opt.foldlevel = 99
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.FoldExpr()"
vim.opt.foldtext = "v:lua.FoldText()" --> currently not highlighted by treesitter
-- vim.opt.foldtext = "v:lua.vim.lsp.foldtext()"
-- opt.foldtext = ""


--> disable perl and ruby providers <--
-- g.loaded_perl_provider = 0
-- g.loaded_ruby_provider = 0

--> disable some builtin vim plugins <--
-- local default_plugins = {
--   "2html_plugin",
--   "getscript",
--   "getscriptPlugin",
--   "gzip",
--   "logipat",
--   "netrw",
--   "netrwPlugin",
--   "netrwSettings",
--   "netrwFileHandlers",
--   "matchit",
--   "tar",
--   "tarPlugin",
--   "rrhelper",
--   "spellfile_plugin",
--   "vimball",
--   "vimballPlugin",
--   "zip",
--   "zipPlugin",
--   "tutor",
--   "rplugin",
--   "syntax",
--   "synmenu",
--   "optwin",
--   "compiler",
--   "bugreport",
-- }
--
-- for _, plugin in pairs(default_plugins) do
--   g["loaded_" .. plugin] = 1
-- end

--> diagnostics <--
vim.diagnostic.config({
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    scope = "line",
    source = true,
  },
  virtual_lines = {
    current_line = true,
    severity     = { min = vim.diagnostic.severity.ERROR },
    format       = function(diagnostic)
      for severity, icon in pairs(require("user.utils").diagnostics_icons) do
        if diagnostic.severity == vim.diagnostic.severity[severity:upper()] then
          return string.format("%s %s", icon, diagnostic.message)
        end
      end
      return diagnostic.message
    end
  },
  -- virtual_text = false,
  virtual_text = {
    source = false,
    severity = { max = vim.diagnostic.severity.WARN },
    spacing = 4,
    prefix = function(diagnostic, i, _)
      if i > 1 then return "" end
      for severity, icon in pairs(require("user.utils").diagnostics_icons) do
        if diagnostic.severity == vim.diagnostic.severity[severity:upper()] then return icon end
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
})
