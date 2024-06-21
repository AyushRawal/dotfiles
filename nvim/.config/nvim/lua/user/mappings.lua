local M = {}

local function map(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", opts or {}, { noremap = true, silent = true })
  vim.keymap.set(mode, lhs, rhs, opts)
end

M.wk = {
  d = { name = "diagnostics" },
  l = { name = "lsp", w = { "workspace" } },
  t = { name = "terminal" },
  f = { name = "find" },
  b = { name = "buffers" },
  g = { name = "git", t = { "toggle" } },
  n = { name = "notes" },
}

M.main = function()
  -- search in visual selection
  map("x", "/", "<Esc>/\\%V")

  -- moving among splits
  map("n", "<C-h>", "<C-w>h")
  map("n", "<C-j>", "<C-w>j")
  map("n", "<C-k>", "<C-w>k")
  map("n", "<C-l>", "<C-w>l")

  -- clear highlights
  map("n", "<ESC>", "<CMD>noh<CR>")

  -- visual movement but not in operator pending mode
  map("n", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
  map("n", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })

  -- move block of text
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
  map({ "n", "x" }, "<leader>y", '"+y', { desc = "copy to system clipboard" })
  map({ "n", "x" }, "<leader>p", '"+p', { desc = "paste (after) from system clipboard" })
  map({ "n", "x" }, "<leader>P", '"+P', { desc = "paste (before) from system clipboard" })
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

  -- stylua: ignore start
  -- save me
  map("n", "<CR>", function()
    if vim.o.modifiable then return "ciw" end          --> change word under cursor normally
    if vim.o.buftype == "help" then return "<C-]>" end --> follow tags in help windows
    return "<CR>"                                      --> keep enter in other non-modifiable windows such as quickfix etc.
  end, { desc = "ciw / follow help tags / default", expr = true })
  -- stylua: ignore end

  map("n", "<leader>w", "<CMD>w<CR>", { desc = "save file" })

  -- terminal config
  map("n", "<leader>tt", require("user.terminal").float, { desc = "terminal in float" })
  map("n", "<leader>tv", require("user.terminal").split_vert, { desc = "terminal in vertical split" })
  map("n", "<leader>ts", require("user.terminal").split_horz, { desc = "terminal in horizontal split" })
  map("n", "<leader>tf", require("user.terminal").find_term, { desc = "find terminal" })

  -- escape terminal mode
  map("t", "<Esc><Esc>", [[<C-\><C-n>]])

  -- resizing
  map("n", "<C-Up>", "<CMD>resize +2<CR>", { desc = "increase split height" })
  map("n", "<C-Down>", "<CMD>resize -2<CR>", { desc = "decrease split height" })
  map("n", "<C-Left>", "<CMD>vertical resize -2<CR>", { desc = "decrease split width" })
  map("n", "<C-Right>", "<CMD>vertical resize +2<CR>", { desc = "increase split width" })

  map("n", "<F10>", "<CMD>setlocal wrap!<CR>", { desc = "toggle wrap" })
  map("n", "<F9>", function()
    if vim.o.shiftwidth == 2 then
      vim.opt.shiftwidth = 4
      vim.opt.tabstop = 4
    elseif vim.o.shiftwidth == 4 then
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
    end
  end, { desc = "toggle indent size" })

  map("i", "<F3>", "<C-R>=strftime('%Y-%m-%d')<CR>") --> print date at cursor
  map("i", "<F4>", "<C-R>=strftime('%H:%M')<CR>") --> print time at cursor

  map("n", "<leader>li", "<CMD>LspInfo<CR>", { desc = "lsp info" })

  -- diagnostics
  map("n", "gl", vim.diagnostic.open_float, { desc = "current line diagnostics" })
  map("n", "<leader>db", vim.diagnostic.setloclist, { desc = "set location list (buffer diagnostics)" })
  map("n", "<leader>da", vim.diagnostic.setqflist, { desc = "set quickfix list (all diagnostics)" })

  map("n", "<leader>gg", function()
    require("user.terminal").float("lazygit")
  end, { desc = "launch lazygit" })

  map("n", "<leader>bb", "<CMD>b#<CR>", { desc = "pick buffer" })
  map("n", "]b", "<CMD>bnext<CR>", { desc = "next buffer" })
  map("n", "[b", "<CMD>bprevious<CR>", { desc = "previous buffer" })
end

-- competitive programming setup
M.cp = function()
  map("n", "<A-y>", "<CMD>!wl-paste > input.txt<CR>")
  map("n", "<F5>", "<CMD>!runcpp %<CR>")
  map("n", "<A-n>", function()
    vim.ui.input({prompt = "Name: "}, function(input)
      vim.cmd("!ch " .. input)
      vim.cmd("e " .. input .. ".cpp")
    end)
  end)
end

M.mini_bufremove = {
  {
    "<leader>q",
    function()
      require("mini.bufremove").delete()
    end,
    desc = "delete buffer (preserve window)",
  },
}

M.conform = {
  {
    "gq",
    function()
      require("conform").format({ lsp_fallback = true })
    end,
    mode = { "n", "x" },
    desc = "format buffer / range",
  },
}

M.oil = {
  { "<leader>e", "<CMD>Oil<CR>", desc = "toggle oil" },
  {
    "<leader>E",
    function()
      require("oil").open(require("user.root").get())
    end,
    desc = "toggle oil (root dir)",
  },
}

M.cmp = function()
  local cmp = require("cmp")
  return {
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
    ["<C-d>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),

    -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
    ["<C-y>"] = cmp.mapping.confirm({ select = false }),

    -- ["<Tab>"] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_next_item()
    -- elseif luasnip.expand_or_jumpable() then
    --   luasnip.expand_or_jump()
    -- elseif has_words_before() then
    --   cmp.complete()
    --   else
    --     fallback()
    --   end
    -- end, { "i", "s" }),
    --
    -- ["<S-Tab>"] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_prev_item()
    -- elseif luasnip.jumpable(-1) then
    --   luasnip.jump(-1)
    --   else
    --     fallback()
    --   end
    -- end, { "i", "s" }),
  }
end

M.luasnip = function()
  local luasnip = require("luasnip")
  map({ "i", "s" }, "<C-k>", function()
    if luasnip.expand_or_jumpable() then
      luasnip.expand_or_jump()
    end
  end)

  map({ "i", "s" }, "<C-j>", function()
    if luasnip.jumpable(-1) then
      luasnip.jump(-1)
    end
  end)

  map("i", "<C-;>", function()
    if luasnip.choice_active() then
      luasnip.change_choice(1)
    end
  end)
end

M.lsp = function(bufnr)
  local function buf_map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.buffer = bufnr
    map(mode, lhs, rhs, opts)
  end

  buf_map("n", "gD", vim.lsp.buf.declaration, { desc = "go to declaration" })
  buf_map("n", "gs", vim.lsp.buf.signature_help, { desc = "show signature help" })
  buf_map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "rename object" })
  buf_map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "code action" })
  buf_map("n", "<leader>lc", vim.lsp.codelens.run, { desc = "codelens run" })
  buf_map("n", "<leader>li", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
  end, { desc = "toggle inlay hints" })
  buf_map({ "n", "x" }, "<leader>lf", function()
    vim.lsp.buf.format({ async = true })
  end, { desc = "lsp format buffer / range" })
  buf_map("n", "<leader>lwa", vim.lsp.buf.add_workspace_folder, { desc = "add workspcae folder" })
  buf_map("n", "<leader>lwr", vim.lsp.buf.remove_workspace_folder, { desc = "remove workspace folder" })
  buf_map("n", "<leader>lwl", function()
    vim.print(vim.lsp.buf.list_workspace_folders())
  end, { desc = "list workspace folders" })

  local telescope_available, _ = pcall(require, "telescope")
  if not telescope_available then
    buf_map("n", "gd", vim.lsp.buf.definition, { desc = "go to definition" })
    buf_map("n", "gI", vim.lsp.buf.implementation, { desc = "go to implementation" })
    buf_map("n", "gy", vim.lsp.buf.type_definition, { desc = "go to type definition" })
    buf_map("n", "gr", vim.lsp.buf.references, { desc = "go to references" })
    buf_map("n", "<leader>ls", vim.lsp.buf.document_symbol, { desc = "lsp document symbols" })
    buf_map("n", "<leader>lS", vim.lsp.buf.workspace_symbol, { desc = "lsp workspace symbols" })
  end
end

M.telescope = {
  { "<leader>fF", "<CMD>Telescope find_files<CR>", desc = "find files (cwd)" },
  { "<leader>fG", "<CMD>Telescope live_grep<CR>", desc = "grep (cwd)" },
  {
    "<leader>ff",
    function()
      require("telescope.builtin").find_files({ cwd = require("user.root").get() })
    end,
    desc = "find files (root dir)",
  },
  {
    "<leader>fg",
    function()
      require("telescope.builtin").live_grep({ cwd = require("user.root").get() })
    end,
    desc = "grep (root dir)",
  },
  { "<leader>fh", "<CMD>Telescope oldfiles<CR>", desc = "find recent files" },
  { "<leader>bf", "<CMD>Telescope buffers<CR>", desc = "find open buffers" },
  { "<leader>gs", "<CMD>Telescope git_status<CR>", desc = "git status" },
  { "<leader>gS", "<CMD>Telescope git_stash<CR>", desc = "git stash" },
  { "<leader>gb", "<CMD>Telescope git_branches<CR>", desc = "git branches" },
  -- { "<leader>gc", "<CMD>Telescope git_commits<CR>", desc = "git commits" },
  -- { "<leader>gC", "<CMD>Telescope git_bcommits<CR>", desc = "git buffer commits" },
  { "<leader>da", "<CMD>Telescope diagnostics<CR>", desc = "all diagnostics" },
  { "gd", "<CMD>Telescope lsp_definitions<CR>", desc = "go to definition" },
  { "gI", "<CMD>Telescope lsp_implementations<CR>", desc = "go to implementation" },
  { "gy", "<CMD>Telescope lsp_type_definitions<CR>", desc = "go to type definition" },
  { "gr", "<CMD>Telescope lsp_references<CR>", desc = "go to references" },
  { "<leader>ls", "<CMD>Telescope lsp_document_symbols<CR>", desc = "lsp document symbols" },
  { "<leader>lS", "<CMD>Telescope lsp_workspace_symbols<CR>", desc = "lsp workspace symbols" },
}

M.treesitter = {
  incremental_selection = {
    init_selection = "<A-o>", -- set to `false` to disable one of the mappings
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

M.gitsigns = function(bufnr)
  local gs = package.loaded.gitsigns
  local function buf_map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.buffer = bufnr
    map(mode, lhs, rhs, opts)
  end

  buf_map("n", "]g", function()
    if vim.wo.diff then
      return "]g"
    end
    vim.schedule(function()
      gs.next_hunk()
    end)
    return "<Ignore>"
  end, { expr = true, desc = "next hunk" })

  buf_map("n", "[g", function()
    if vim.wo.diff then
      return "[g"
    end
    vim.schedule(function()
      gs.prev_hunk()
    end)
    return "<Ignore>"
  end, { expr = true, desc = "previous hunk" })

  buf_map({ "n", "x" }, "<leader>ga", "<CMD>Gitsigns stage_hunk<CR>", { desc = "stage hunk" })
  buf_map({ "n", "x" }, "<leader>gr", "<CMD>Gitsigns reset_hunk<CR>", { desc = "reset hunk" })
  buf_map("n", "<leader>gA", gs.stage_buffer, { desc = "stage buffer" })
  buf_map("n", "<leader>gR", gs.reset_buffer, { desc = "reset buffer" })
  buf_map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
  buf_map("n", "<leader>gp", gs.preview_hunk, { desc = "preview hunk" })
  buf_map("n", "<leader>gB", function()
    gs.blame_line({ full = true })
  end, { desc = "blame line" })
  buf_map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "toggle current line blame" })
  buf_map("n", "<leader>gd", gs.diffthis, { desc = "show buffer diff" })
  -- buf_map("n", "<leader>gD", function() gs.diffthis('~') end) --> diff with parent of head
  buf_map("n", "<leader>gtd", gs.toggle_deleted, { desc = "toggle deleted lines" })
  buf_map("n", "<leader>gtl", gs.toggle_linehl, { desc = "toggle line highlight" })
  buf_map("n", "<leader>gl", gs.setloclist, { desc = "set location list with current buffer hunks" })
  buf_map("n", "<leader>gq", function()
    gs.setqflist({ target = "all" })
  end, { desc = "set qf list with hunks from all buffers" })

  -- text object
  buf_map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
end

M.comment = {
  ---LHS of toggle mappings in NORMAL mode
  toggler = {
    ---Line-comment toggle keymap
    line = "gcc",
    ---Block-comment toggle keymap
    block = "gbc",
  },
  ---LHS of operator-pending mappings in NORMAL and VISUAL mode
  opleader = {
    ---Line-comment keymap
    line = "gc",
    ---Block-comment keymap
    block = "gb",
  },
  ---LHS of extra mappings
  extra = {
    ---Add comment on the line above
    above = "gcO",
    ---Add comment on the line below
    below = "gco",
    ---Add comment at the end of line
    eol = "gcA",
  },
}

M.obsidian = {
  { "<leader>nn", ":ObsidianNew ", desc = "new note" },
  { "<leader>nf", "<CMD>ObsidianQuickSwitch<CR>", desc = "find note" },
  { "<leader>ng", "<CMD>ObsidianSearch<CR>", desc = "search or create note" },
  { "<leader>no", "<CMD>ObsidianOpen<CR>", desc = "open current note in Obsidian" },
  { "<leader>nb", "<CMD>ObsidianBacklinks<CR>", desc = "get references to the current note" },
  { "<leader>nd", "<CMD>ObsidianToday<CR>", desc = "today's note" },
  { "<leader>nt", "<CMD>ObsidianTemplate<CR>", desc = "insert template" },
  { "<leader>np", "<CMD>ObsidianPasteImg<CR>", desc = "paste image from clipboard at cursor position" },
}

M.nabla = {
  {
    "<leader>nl",
    function()
      require("nabla").toggle_virt({ autogen = true })
    end,
    desc = "Toggle latex preview",
  },
}

return M
