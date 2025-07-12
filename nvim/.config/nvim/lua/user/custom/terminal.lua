local M = {}

M.terminals = {}

M.last_terminal = {
  key = 1,
  type = "float"
}

local get_win_config = function(type)
  local win_opts = { style = "minimal" }
  if type == "float" then
    win_opts.relative = "editor"
    win_opts.border = "single"
    win_opts.zindex = 50
    win_opts.width = math.floor(vim.o.columns * 0.8)
    win_opts.height = math.floor(vim.o.lines * 0.8)
    win_opts.row = math.floor((vim.o.lines - win_opts.height) / 2)
    win_opts.col = math.floor((vim.o.columns - win_opts.width) / 2)
  elseif type == "split" then
    win_opts.height = math.floor(vim.o.lines * 0.25)
    win_opts.split = "below"
    win_opts.win = -1
  elseif type == "vsplit" then
    win_opts.width = math.floor(vim.o.columns * 0.3)
    win_opts.split = "right"
    win_opts.win = -1
  end
  return win_opts
end

local get_win_type = function(win)
  local win_opts = vim.api.nvim_win_get_config(win)
  local type = "float"
  if win_opts.split then
    if win_opts.split == "below" or win_opts.split == "above" then type = "split" end
    if win_opts.split == "left" or win_opts.split == "right" then type = "vsplit" end
  end
  return type
end

M.toggle = function(opts)
  opts = opts or {}
  opts.key = opts.key or opts.cmd or vim.v.count
  opts.key = opts.key == 0 and M.last_terminal.key or opts.key
  opts.type = opts.type or M.last_terminal.type
  opts.key = tostring(opts.key)
  M.last_terminal = { key = opts.key, type = opts.type }
  opts.cmd = opts.cmd or vim.o.shell
  local terminal = M.terminals[opts.key]
  if terminal and not vim.api.nvim_buf_is_valid(terminal.buf) then
    assert(not vim.api.nvim_win_is_valid(terminal.win))
    terminal = nil
    M.terminals[opts.key] = nil
  end
  if not terminal then
    terminal = {}
    terminal.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("ft", "terminal", { buf = terminal.buf })
    vim.keymap.set("n", "q", "<CMD>close<CR>", { buffer = terminal.buf })
  end
  local win_opts = get_win_config(opts.type)
  if terminal.win then
    if vim.api.nvim_win_is_valid(terminal.win) then
      local type = get_win_type(terminal.win)
      vim.api.nvim_win_set_config(terminal.win, win_opts)
      if type == opts.type then vim.api.nvim_win_hide(terminal.win) end
    else
      terminal.win = vim.api.nvim_open_win(terminal.buf, true, win_opts)
      vim.wo[terminal.win].winfixbuf = true
    end
  else
    terminal.win = vim.api.nvim_open_win(terminal.buf, true, win_opts)
    vim.wo[terminal.win].winfixbuf = true
    vim.fn.jobstart(opts.cmd, { term = true })
  end
  M.terminals[opts.key] = terminal
end

local function open_or_focus_term(key, type)
  if key then
    local terminal = M.terminals[key]
    if terminal and vim.api.nvim_win_is_valid(terminal.win) then
      vim.api.nvim_set_current_win(terminal.win)
      -- vim.cmd.startinsert()
    elseif terminal and vim.api.nvim_buf_is_valid(terminal.buf) then
      M.toggle({ key = key, type = type })
    else
      vim.notify("Selected terminal is no longer valid.", vim.log.levels.WARN)
    end
  end
end

M.pick_terminal_fzf = function()
  local terminals_list = {}

  for key, term_data in pairs(M.terminals) do
    if vim.api.nvim_buf_is_valid(term_data.buf) then
      table.insert(terminals_list, string.format("%s: buf %d", tostring(key), term_data.buf))
    end
  end

  if #terminals_list == 0 then
    vim.notify("No active terminals to pick from.", vim.log.levels.INFO)
    return
  end

  local builtin = require("fzf-lua.previewer.builtin")
  local Term_view = builtin.buffer_or_file:extend()

  function Term_view:new(o, opts, fzf_win)
    Term_view.super.new(self, o, opts, fzf_win)
    setmetatable(self, Term_view)
    return self
  end

  function Term_view:parse_entry(entry_str)
    local key, buf = entry_str:match("(.*): buf (%d+)")
    buf = tonumber(buf)
    if not buf then return end
    return {
      bufnr = buf,
      bufname = "Terminal:" .. key,
    }
  end

  function Term_view:gen_winopts()
    local new_winopts = {
      number         = false,
      relativenumers = false
    }
    return vim.tbl_extend("force", self.winopts, new_winopts)
  end

  FzfLua.fzf_exec(terminals_list, {
    prompt = 'Select Terminal> ',
    winopts = {
      width = 0.6,
      height = 0.4,
      row = 0.5,
      col = 0.5,
      relative = 'editor',
      border = 'single',
      zindex = 100,
    },
    previewer = Term_view,
    actions = {
      ['default'] = function(selected_line)
        if not selected_line then return end
        selected_line = selected_line[1]
        local key = string.match(selected_line, "(.*): buf %d+")
        open_or_focus_term(key, "float")
      end,
      ['ctrl-v'] = function(selected_line)
        if not selected_line then return end
        selected_line = selected_line[1]
        local key = string.match(selected_line, "(.*): buf %d+")
        open_or_focus_term(key, "vsplit")
      end,
      ['ctrl-s'] = function(selected_line)
        if not selected_line then return end
        selected_line = selected_line[1]
        local key = string.match(selected_line, "(.*): buf %d+")
        open_or_focus_term(key, "split")
      end,
      ['ctrl-x'] = function(selected_line)
        if not selected_line then return end
        local key = string.match(selected_line, "(.*): buf %d+")
        if key and M.terminals[key] then
          vim.api.nvim_buf_delete(M.terminals[key].buf, { force = true })
          M.terminals[key] = nil
          vim.notify("Terminal '" .. key .. "' closed.", vim.log.levels.INFO)
        end
      end,
    },
  })
end

M.pick_terminal_snacks = function()
  local finder = function(opts, ctx)
    ---@type snacks.picker.finder.Item[]
    local items = {}
    for key, terminal in pairs(M.terminals) do
      local buf = terminal.buf
      local info = vim.fn.getbufinfo(buf)[1]
      table.insert(items, {
        buf = buf,
        file = key,
        key = key,
        info = info,
      })
    end
    return ctx.filter:filter(items)
  end
  Snacks.picker.pick({
    finder = finder,
    layout = "ivy",
    win = {
      preview = { wo = { number = false, relativenumber = false } }
    },
    actions = {
      confirm = function(picker)
        local selected = picker:selected({ fallback = true })
        if #selected == 0 then return end
        selected = selected[1]
        vim.schedule(function()
          open_or_focus_term(selected.key, "float")
        end)
        picker:close()
      end,
      edit_split = function(picker)
        local selected = picker:selected({ fallback = true })
        if #selected == 0 then return end
        selected = selected[1]
        vim.schedule(function()
          open_or_focus_term(selected.key, "split")
        end)
        picker:close()
      end,
      edit_vsplit = function(picker)
        local selected = picker:selected({ fallback = true })
        if #selected == 0 then return end
        selected = selected[1]
        vim.schedule(function()
          open_or_focus_term(selected.key, "vsplit")
        end)
        picker:close()
      end,
    }
  })
end

M.setup = function()
  local function augroup(name) return vim.api.nvim_create_augroup("user_" .. name, { clear = true }) end
  local autocmd = vim.api.nvim_create_autocmd

  -- start in insert mode in terminal
  local group = augroup("term_start_ins")
  -- autocmd("TermOpen", {
  --   pattern = "*",
  --   command = "startinsert",
  --   group = group,
  -- })
  autocmd({ "BufWinEnter", "WinEnter" }, {
    group = group,
    callback = function(info)
      if vim.bo[info.buf].ft == "terminal" and vim.api.nvim_get_mode().mode ~= "i" then
        vim.api.nvim_feedkeys('i', 'n', false)
        -- vim.cmd.startinsert()
      end
    end,
  })
  -- do not display process exited msg on terminal close
  autocmd("TermClose", {
    group = augroup("term_close"),
    callback = function(event) vim.api.nvim_buf_delete(event.buf, { force = true }) end,
  })
  vim.keymap.set("t", "<ESC><ESC>", [[<C-\><C-n>]])
end

return M
