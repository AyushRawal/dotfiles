local function augroup(name) return vim.api.nvim_create_augroup("user_" .. name, { clear = true }) end
local autocmd = vim.api.nvim_create_autocmd

-- turn off relative numbers in insert mode
local group = augroup("no_rno_ins")
autocmd("InsertEnter", {
  callback = function() vim.opt.relativenumber = false end,
  group = group,
})
autocmd("InsertLeave", {
  callback = function()
    if vim.o.number == true then vim.opt.relativenumber = true end
  end,
  group = group,
})

-- add formatoptiona
autocmd("BufWinEnter", {
  callback = function() vim.opt.formatoptions:remove({ "c", "r", "o" }) end,
  group = augroup("formatopts"),
})

-- highlight text on yank
autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank({
      higroup = "IncSearch",
      timeout = 400,
    })
  end,
  group = augroup("highlight_yank"),
})

-- show cursor line only in active window
group = augroup("cursorline_on_focus")
autocmd("WinEnter", {
  callback = function() vim.wo.cursorline = true end,
  group = group,
})
autocmd("WinLeave", {
  callback = function() vim.wo.cursorline = false end,
  group = group,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- close some filetypes with <q>
autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "help",
    "query",
    "tsplayground",
    "checkhealth",
    "man",
    "lspinfo",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- auto close some type of windows and exit on quit
autocmd("QuitPre", {
  group = augroup("auto_close"),
  callback = function()
    local autoclose_ft = {
      "snacks_",
      "terminal"
    }
    local wins = vim.api.nvim_list_wins()
    local cur_win = vim.api.nvim_get_current_win()
    for _, win in ipairs(wins) do
      if win == cur_win then goto continue end
      local buf = vim.api.nvim_win_get_buf(win)
      if not vim.iter(autoclose_ft):any(function(ft) return vim.bo[buf].ft:match(ft) end) then return end
      ::continue::
    end
    pcall(vim.cmd.quitall())
  end
})


-- TOOD: remove this after fix in lazy.nvim: https://github.com/folke/lazy.nvim/issues/1951
autocmd("FileType", {
  desc = "User: fix backdrop for lazy window",
  pattern = "lazy_backdrop",
  group = augroup("lazynvim-fix"),
  callback = function(ctx)
    local win = vim.fn.win_findbuf(ctx.buf)[1]
    vim.api.nvim_win_set_config(win, { border = "none" })
  end,
})
