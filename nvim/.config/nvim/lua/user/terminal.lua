local M = {}

M.terminals = {}

local open_win = function(buf, type)
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
  local win = vim.api.nvim_open_win(buf, true, win_opts)
  vim.wo[win].winfixbuf = true
  return win
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
  assert(opts and opts.type, "invalid arguments; type not specified")
  assert(
    opts.type == "float" or opts.type == "split" or opts.type == "vsplit",
    "unknown window type " .. opts.type .. "; allowed window types: float, split and vsplit"
  )
  opts.key = opts.key or opts.cmd or vim.v.count or 0
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
    vim.api.nvim_buf_set_option(terminal.buf, "ft", "terminal")
    vim.keymap.set("n", "q", "<CMD>close<CR>", { buffer = terminal.buf })
  end
  if terminal.win then
    if vim.api.nvim_win_is_valid(terminal.win) then
      local type = get_win_type(terminal.win)
      vim.api.nvim_win_hide(terminal.win)
      if opts.type ~= type then terminal.win = open_win(terminal.buf, opts.type) end
    else
      terminal.win = open_win(terminal.buf, opts.type)
    end
  else
    terminal.win = open_win(terminal.buf, opts.type)
    vim.fn.termopen(opts.cmd, vim.empty_dict())
  end
  M.terminals[opts.key] = terminal
end

M.find_term = function(opts)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local custom_action = function(buf, type)
    return function()
      actions.close(buf)
      local selection = action_state.get_selected_entry()
      vim.schedule(function() M.toggle({ type = type, key = selection.value[1] }) end)
    end
  end

  opts = opts or {}
  local results = {}
  for k, v in pairs(M.terminals) do
    if vim.api.nvim_buf_is_valid(v.buf) then
      table.insert(results, { k, k .. " " .. vim.api.nvim_buf_get_name(v.buf) })
    end
  end

  pickers
    .new(opts, {
      prompt_title = "Terminals",
      finder = finders.new_table({
        results = results,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry[2],
            ordinal = entry[2],
          }
        end,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, _) -- _ -> map
        actions.select_default:replace(custom_action(prompt_bufnr, "float"))
        actions.select_horizontal:replace(custom_action(prompt_bufnr, "split"))
        actions.select_vertical:replace(custom_action(prompt_bufnr, "vsplit"))
        actions.select_tab:replace(function() end)
        return true
      end,
    })
    :find()
end

return M
