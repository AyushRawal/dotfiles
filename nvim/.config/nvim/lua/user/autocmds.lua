local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end
local autocmd = vim.api.nvim_create_autocmd

-- turn off relative numbers in insert mode
local group = augroup("no_rno_ins")
autocmd("InsertEnter", {
  callback = function()
    vim.opt.relativenumber = false
  end,
  group = group,
})
autocmd("InsertLeave", {
  callback = function()
    if vim.o.number == true then
      vim.opt.relativenumber = true
    end
  end,
  group = group,
})

-- start in insert mode in terminal
group = augroup("term_start_ins")
autocmd("TermOpen", {
  pattern = "*",
  command = "startinsert",
  group = group
})
autocmd({ "BufWinEnter", "WinEnter" }, {
  group = group,
  callback = function(info)
    if vim.bo[info.buf].ft == "term" then
      vim.cmd.startinsert()
    end
  end
})

-- add formatoptiona
autocmd("BufWinEnter", {
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
  group = augroup("formatopts"),
})

-- highlight text on yank
autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 400,
    })
  end,
  group = augroup("highlight_yank"),
})

-- clear highlights
-- vim.on_key(function(char)
--   if vim.fn.mode() == "n" then
--     vim.opt.hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
--   end
-- end, vim.api.nvim_create_namespace("auto_hlsearch"))

-- remove trailing whitespaces before writing
autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
  group = augroup("remove_trail_spc"),
})

-- show cursor line only in active window
group = augroup("cursorline_on_focus")
autocmd("WinEnter", {
  callback = function()
    vim.wo.cursorline = true
  end,
  group = group,
})
autocmd("WinLeave", {
  callback = function()
    vim.wo.cursorline = false
  end,
  group = group,
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

-- Auto create dir when saving a file, in case some intermediate directory does not exist
autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- do not display process exited msg on terminal close
-- autocmd("TermClose", {
--   group = augroup("term_close"),
--   callback = function(event)
--     vim.api.nvim_buf_delete(event.buf, { force = true })
--   end,
-- })
