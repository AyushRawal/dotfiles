local M = {}
local root = require("user.custom.root")

local function map(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

M.wk = {
  { "<leader>w",  group = "window" },
  { "<leader>d",  group = "diagnostics" },
  { "<leader>l",  group = "lsp" },
  { "<leader>lw", group = "workspace" },
  { "<leader>t",  group = "terminal" },
  { "<leader>f",  group = "find" },
  { "<leader>s",  group = "search" },
  { "<leader>b",  group = "buffers" },
  { "<leader>g",  group = "git" },
  { "<leader>gt", group = "toggle" },
  { "<leader>n",  group = "neovim" },
  { "<leader>a",  group = "avante" },
  { "<leader>m",  group = "file_marks" },
  { "<leader>u",  group = "toggle" },
}

M.main = function()
  -- search in visual selection
  map("x", "/", "<Esc>/\\%V")

  -- window operations
  map("n", "<leader>w", "<C-w>")

  -- clear highlights using escape in normal mode
  map("n", "<ESC>", "<CMD>noh<CR>")

  -- visual movement but not in operator pending mode
  map("n", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
  map("n", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })

  -- move lines of text up or down
  map("n", "<A-k>", ":m .-2<CR>==", { desc = "move line / range up" })
  map("x", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "move line / range up" })
  map("i", "<A-k>", "<ESC>:m .-2<CR>==gi", { desc = "move line / range up" })
  map("n", "<A-j>", ":m .+1<CR>==", { desc = "move line / range down" })
  map("x", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "move line / range down" })
  map("i", "<A-j>", "<ESC>:m .+1<CR>==gi", { desc = "move line / range down" })

  -- better indenting
  map("x", "<", "<gv")
  map("x", ">", ">gv")

  -- better yanking
  map("n", "<leader>y", "<CMD>%y+<CR>", { desc = "copy whole buffer" })
  map({ "n", "x" }, "<A-y>", '"+y', { desc = "copy to system clipboard" })
  map("n", "<A-Y>", '"+y$', { desc = "copy till end of line to system clipboard" })
  map({ "n", "x" }, "<A-p>", '"+p', { desc = "paste (after) from system clipboard" })
  map({ "n", "x" }, "<A-P>", '"+P', { desc = "paste (before) from system clipboard" })
  map("n", "x", '"_x') --> do not send deleted char to clipboard
  map("x", "x", '"_x') --> send selecction to blackhole register

  -- quickfix list
  map("n", "]q", "<CMD>cnext<CR>", { desc = "next entry in qflist" })
  map("n", "[q", "<CMD>cprev<CR>", { desc = "previous entry in qflist" })
  map("n", "<A-q>", "<CMD>cclose<CR>", { desc = "close quickfix list" })
  -- location list
  map("n", "]l", "<CMD>lnext<CR>", { desc = "next entry in loclist" })
  map("n", "[l", "<CMD>lprev<CR>", { desc = "previous entry in loclist" })
  map("n", "<A-l>", "<CMD>lclose<CR>", { desc = "close location list" })

  -- resizing
  map("n", "<C-Up>", "<CMD>resize +2<CR>", { desc = "increase split height" })
  map("n", "<C-Down>", "<CMD>resize -2<CR>", { desc = "decrease split height" })
  map("n", "<C-Left>", "<CMD>vertical resize -2<CR>", { desc = "decrease split width" })
  map("n", "<C-Right>", "<CMD>vertical resize +2<CR>", { desc = "increase split width" })

  map("i", "<F3>", "<C-R>=strftime('%Y-%m-%d')<CR>") --> print date at cursor
  map("i", "<F4>", "<C-R>=strftime('%H:%M')<CR>")    --> print time at cursor

  -- diagnostics
  map("n", "gl", vim.diagnostic.open_float, { desc = "current line diagnostics" })
  map("n", "<leader>db", vim.diagnostic.setloclist, { desc = "set location list (buffer diagnostics)" })
  map("n", "<leader>da", vim.diagnostic.setqflist, { desc = "set quickfix list (all diagnostics)" })

  map("n", "]b", "<CMD>bnext<CR>", { desc = "next buffer" })
  map("n", "[b", "<CMD>bprevious<CR>", { desc = "previous buffer" })

  -- arglist
  map("n", "<leader>mm", "<cmd>$arge %<bar>argded<cr>", { desc = "add current file to arglist" })
  map("n", "<leader>md", "<cmd>argd %<cr><C-l>", { desc = "remove current file from arglist" }) -- <c-l> for screen redraw to update tabline
  map("n", "<leader>mc", "<cmd>%argd<cr><C-l>", { desc = "clear the arglist" })
  for i = 1, 9 do -- loop from 0 to 9 creating keymaps as <leader>0 -> :argu 0 ...
    map("n", "<leader>" .. i, "<CMD>argu " .. i .. "<CR>", { desc = "goto arglist entry " .. i })
  end
  map("n", "<leader>" .. 0, "<CMD>argu 10<CR>", { desc = "goto arglist entry 10" })


  map("n", "<leader>e", "<CMD>Ex<CR>")
end

M.treesitter = {
  incremental_selection = { -- set to `false` to disable one of the mappings
    init_selection = "<A-o>",
    node_incremental = "<A-o>",
    scope_incremental = false,
    node_decremental = "<A-i>",
  },
  textobjects = {
    select = {
      -- You can use the capture groups defined in textobjects.scm
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      ["ac"] = "@class.outer",
      -- You can optionally set descriptions to the mappings (used in the desc parameter of
      -- nvim_buf_set_keymap) which plugins like which-key display
      ["ic"] = "@class.inner", --{ query = "@class.inner", desc = "Select inner part of a class region" },
      ["ia"] = "@parameter.inner",
      ["aa"] = "@parameter.outer",
      ["iA"] = "@attribute.inner", -- html
      ["aA"] = "@attribute.outer",
      ["il"] = "@loop.inner",
      ["al"] = "@loop.outer",
      ["ii"] = "@conditional.inner",
      ["ai"] = "@conditional.outer",
    },
    move = {
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = { query = "@class.outer", desc = "Next class start" },
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
  },
}

M.terminal = function()
  -- terminal config
  map(
    "n",
    "<leader>tt",
    function() require("user.custom.terminal").toggle() end,
    { desc = "toggle terminal" }
  )
  map(
    "n",
    "<leader>tf",
    function() require("user.custom.terminal").toggle({ type = "float" }) end,
    { desc = "terminal in float" }
  )
  map(
    "n",
    "<leader>tv",
    function() require("user.custom.terminal").toggle({ type = "vsplit" }) end,
    { desc = "terminal in vertical split" }
  )
  map(
    "n",
    "<leader>ts",
    function() require("user.custom.terminal").toggle({ type = "split" }) end,
    { desc = "terminal in horizontal split" }
  )
  map("n", "<leader>tF", require("user.custom.terminal").pick_terminal_snacks, { desc = "find terminal" })

  map(
    "n",
    "<leader>gg",
    function() require("user.custom.terminal").toggle({ cmd = "lazygit" }) end,
    { desc = "lazygit" }
  )
end

M.lsp = function(bufnr)
  local function buf_map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.buffer = bufnr
    map(mode, lhs, rhs, opts)
  end
  buf_map("n", "<leader>lc", vim.lsp.codelens.run, { desc = "codelens run" })
  -- buf_map(
  --   { "n", "x" },
  --   "<leader>lf",
  --   function() vim.lsp.buf.format({ async = true }) end,
  --   { desc = "lsp format buffer / range" }
  -- )
  buf_map("n", "<leader>lwa", vim.lsp.buf.add_workspace_folder, { desc = "add workspcae folder" })
  buf_map("n", "<leader>lwr", vim.lsp.buf.remove_workspace_folder, { desc = "remove workspace folder" })
  buf_map(
    "n",
    "<leader>lwl",
    function() vim.print(vim.lsp.buf.list_workspace_folders()) end,
    { desc = "list workspace folders" }
  )

  if FzfLua then return end

  buf_map("n", "<leader>li", vim.lsp.buf.incoming_calls, { desc = "lsp incoming calls" })
  buf_map("n", "<leader>lo", vim.lsp.buf.outgoing_calls, { desc = "lsp outgoing calls" })

  if Snacks then return end

  buf_map("n", "gd", vim.lsp.buf.definition, { desc = "lsp definitions" })
  buf_map("n", "gD", vim.lsp.buf.declaration, { desc = "lsp declarations" })
  buf_map("n", "gy", vim.lsp.buf.type_definition, { desc = "lsp type definitions" })
  buf_map("n", "<leader>ls", vim.lsp.buf.workspace_symbol, { desc = "lsp workspace symbols" })
end

M.lspconfig = function()
  map("n", "<leader>lI", "<CMD>LspInfo<CR>", { desc = "lsp info" })
  map("n", "<leader>lR", "<CMD>LspRestart<CR>", { desc = "lsp restart" })
  map("n", "<leader>lS", "<CMD>LspStop<CR>", { desc = "lsp stop" })
end

M.conform = {
  {
    "<leader>lf",
    function() require("conform").format() end,
    mode = { "n", "x" },
    desc = "format buffer / range",
  },
}

-- M.fzf = function()
--   -- files
--   map("n", "<leader>ff", FzfLua.files, { desc = "find files" })
--   map("n", "<leader>fr", FzfLua.oldfiles, { desc = "recent files (oldfiles)" })
--   map("n", "<leader>fg", FzfLua.git_files, { desc = "git files" })
--
--   -- search
--   map("n", "<leader>ss", FzfLua.live_grep_native, { desc = "live grep project" })
--   map("x", "<leader>ss", FzfLua.grep_visual, { desc = "search visual" })
--   map("n", "<leader>sb", FzfLua.lgrep_curbuf, { desc = "live grep buffer" })
--   map("n", "<leader>sw", FzfLua.grep_cword, { desc = "search word under cursor" })
--   map("n", "<leader>sW", FzfLua.grep_cWORD, { desc = "search WORD under cursor" })
--
--   -- git
--   map("n", "<leader>gf", FzfLua.git_files, { desc = "git files" })
--   map("n", "<leader>gb", FzfLua.git_branches, { desc = "git branches" })
--   map("n", "<leader>gc", FzfLua.git_commits, { desc = "git commits (project)" })
--   map("n", "<leader>gC", FzfLua.git_bcommits, { desc = "git commits (buffer)" })
--   map("n", "<leader>gd", FzfLua.git_diff, { desc = "git diff" })
--   map("n", "<leader>gh", FzfLua.git_hunks, { desc = "git hunks" })
--
--   -- buffer
--   map("n", "<leader>bf", FzfLua.buffers, { desc = "find buffer" })
--
--   -- diagnostics
--   map("n", "<leader>dd", FzfLua.diagnostics_workspace, { desc = "workspace diagnostics" })
--   map("n", "<leader>db", FzfLua.diagnostics_document, { desc = "document (buffer) diagnostics" })
--
--   -- lsp
--   map("n", "gra", FzfLua.lsp_code_actions, { desc = "lsp code actions" })
--   map("n", "grr", function() FzfLua.lsp_references({
--     ignore_current_line = true,
--     includeDeclaration = false
--   }) end, { desc = "goto lsp references" })
--   map("n", "gri", FzfLua.lsp_implementations, { desc = "goto lsp implementations" })
--   map("n", "gO",  FzfLua.lsp_document_symbols, { desc = "lsp document symbols" })
--
--   map("n", "gd",  FzfLua.lsp_definitions, { desc = "goto lsp definitions" })
--   map("n", "gD",  FzfLua.lsp_declarations, { desc = "goto lsp declarations" })
--   map("n", "gy",  FzfLua.lsp_typedefs, { desc = "goto lsp type definitions" })
--   map("n", "<leader>ls",  FzfLua.lsp_live_workspace_symbols, { desc = "lsp workspace symbols" })
--   map("n", "<leader>li",  FzfLua.lsp_incoming_calls, { desc = "lsp incoming calls" })
--   map("n", "<leader>lo",  FzfLua.lsp_outgoing_calls, { desc = "lsp outgoing calls" })
--
--   -- neovim
--   map("n", "<leader>nh",  FzfLua.helptags, { desc = "help" })
--   map("n", "<leader>nM",  FzfLua.manpages, { desc = "man pages" })
--   map("n", "<leader>nC",  FzfLua.colorschemes, { desc = "colorschemes" })
--   map("n", "<leader>nc",  FzfLua.commands, { desc = "commands" })
--   map("n", "<leader>nm",  FzfLua.marks, { desc = "marks" })
--   map("n", "<leader>nr",  FzfLua.registers, { desc = "registers" })
--   map("n", "<leader>no",  FzfLua.nvim_options, { desc = "options" })
--   map("n", "<leader>nk",  FzfLua.keymaps, { desc = "keymaps" })
-- end

---@module "user.custom.comment"
---@type CommentingConfig
M.comment = {
  above_linewise = "gcO",
  below_linewise = "gco",
  eol_linewise = "gcA",
  blockwise = "gb",
  current_blockwise = "gbc",
  above_blockwise = "gbO",
  below_blockwise = "gbo",
  eol_blockwise = "gbA",
}

M.snacks = function()
  local no_preview_ivy = {
    layout = {
      box = "vertical",
      backdrop = false,
      row = -1,
      width = 0,
      height = 0.4,
      border = "top",
      title = " {title} {live} {flags}",
      title_pos = "left",
      { win = "input", height = 1,     border = "bottom" },
      { win = "list",  border = "none" },
    },
  }

  map("n", "<leader>bd", Snacks.bufdelete.delete, { desc = "delele current buffer" })
  map("n", "<leader>bD", Snacks.bufdelete.other, { desc = "delele other buffers except current" })

  map("n", "<leader>e", function() Snacks.explorer.open({ cwd = root.get()[1] }) end, { desc = "Explorer" })
  map("n", "<leader>nn", Snacks.notifier.show_history, { desc = "Show notification history" })

  -- map("n", "<leader>gg", Snacks.lazygit.open, { desc = "lazygit" })
  map("n", "<leader>gB", Snacks.gitbrowse.open, { desc = "open current repo in browser" })

  ----------- picker ---------------
  -- files
  map("n", "<leader><leader>", Snacks.picker.smart, { desc = "smart find files" })
  map("n", "<leader>ff", function() Snacks.picker.files({ cwd = root.get()[1] }) end, { desc = "find files (root dir)" })
  map("n", "<leader>fF", Snacks.picker.files, { desc = "find files" })
  map("n", "<leader>fr", Snacks.picker.recent, { desc = "recent files" })
  map("n", "<leader>fg", Snacks.picker.git_files, { desc = "git files" })
  map("n", "<leader>fp", Snacks.picker.projects, { desc = "projects" })

  -- search
  map("n", "<leader>ss", function() Snacks.picker.grep({ cwd = root.get()[1] }) end, { desc = "grep (root dir)" })
  map("n", "<leader>sS", Snacks.picker.grep, { desc = "grep" })
  map("n", "<leader>sb", Snacks.picker.lines, { desc = "grep current buffer" })
  map("n", "<leader>sB", Snacks.picker.grep_buffers, { desc = "grep open buffers" })
  map("n", "<leader>sw", function() Snacks.picker.grep_word({ cwd = root.get()[1] }) end, { desc = "grep word (root dir)" })
  map("n", "<leader>sW", Snacks.picker.grep_word, { desc = "grep word" })
  map("n", "<leader>sg", Snacks.picker.git_grep, { desc = "git grep" })

  -- git
  map("n", "<leader>gf", Snacks.picker.git_files, { desc = "git files" })
  map("n", "<leader>gb", Snacks.picker.git_branches, { desc = "git branches" })
  map("n", "<leader>gc", Snacks.picker.git_log, { desc = "git commits (log)" })
  map("n", "<leader>gC", Snacks.picker.git_log_file, { desc = "git buffer commits (log file)" })
  map("n", "<leader>gl", Snacks.picker.git_log_line, { desc = "git log line (blame)" })
  map("n", "<leader>gd", Snacks.picker.git_diff, { desc = "git diff" })
  map("n", "<leader>gs", Snacks.picker.git_status, { desc = "git stash" })
  map("n", "<leader>gS", Snacks.picker.git_stash, { desc = "git stash" })

  -- lsp
  map("n", "grr", Snacks.picker.lsp_references, { desc = "lsp references" })
  map("n", "gri", Snacks.picker.lsp_implementations, { desc = "lsp implementations" })
  map("n", "gO", Snacks.picker.lsp_symbols, { desc = "lsp document symbols" })

  map("n", "gd", Snacks.picker.lsp_definitions, { desc = "lsp definitions" })
  map("n", "gD", Snacks.picker.lsp_declarations, { desc = "lsp declarations" })
  map("n", "gy", Snacks.picker.lsp_type_definitions, { desc = "lsp type definitions" })
  map("n", "<leader>ls", Snacks.picker.lsp_workspace_symbols, { desc = "lsp workspace symbols" })

  -- neovim
  map("n", "<leader>nh", Snacks.picker.help, { desc = "help pages" })
  map("n", "<leader>nM", Snacks.picker.man, { desc = "man pages" })
  map("n", "<leader>nC", Snacks.picker.colorschemes, { desc = "colorschemes" })
  map("n", "<leader>nc", Snacks.picker.commands, { desc = "commands" })
  map("n", "<leader>nm", Snacks.picker.marks, { desc = "marks" })
  map("n", '<leader>nr', Snacks.picker.registers, { desc = "registers" })
  map("n", '<leader>nu', Snacks.picker.undo, { desc = "undo history" })
  map("n", "<leader>nk", function() Snacks.picker.keymaps({ layout = no_preview_ivy }) end, { desc = "keymaps" })

  -- buffer
  map("n", "<leader>bb", Snacks.picker.buffers, { desc = "find buffer" })

  -- diagnostics
  map("n", "<leader>da", Snacks.picker.diagnostics, { desc = "all diagnostics" })
  map("n", "<leader>db", Snacks.picker.diagnostics_buffer, { desc = "buffer diagnostics" })
  ------------------------------------

  map("n", "]r", function() Snacks.words.jump(vim.v.count1) end, { desc = "jump to next reference" })
  map("n", "[r", function() Snacks.words.jump(-vim.v.count1) end, { desc = "jump to prev reference" })

  Snacks.toggle.option("wrap"):map("<leader>uw")
  Snacks.toggle.scroll():map("<leader>us")
  Snacks.toggle.zen():map("<leader>uz")
  Snacks.toggle.zoom():map("<leader>uZ")
  Snacks.toggle.inlay_hints():map("<leader>ul")
  Snacks.toggle.diagnostics():map("<leader>ud")
  Snacks.toggle({
    name = "sized indent",
    get = function() return vim.o.shiftwidth == 2 end,
    set = function(state)
      vim.opt.shiftwidth = state and 2 or 4
      vim.opt.tabstop = state and 2 or 4
    end,
    notify = false,
    wk_desc = {
      enabled = "4 ",
      disabled = "2 "
    }
  }):map("<leader>ui")
end

return M
