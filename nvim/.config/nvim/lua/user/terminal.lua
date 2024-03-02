local M = {}
M.terminals = {}

local function size(max, value)
  return value > 1 and math.min(value, max) or math.floor(max * value)
end

M.float = function(cmd, key)
  key = key or cmd or vim.v.count or 0
  local opts = { size = { height = 0.8, width = 0.8 } }
  -- opts = vim.tbl_deep_extend("force", { size = { height = 0.8, width = 0.8 }}, opts or {})
  cmd = cmd or vim.o.shell

  local win_opts = {
    relative = "editor",
    style = "minimal",
    border = "single",
    zindex = 50,
  }
  win_opts.width = size(vim.o.columns, opts.size.width)
  win_opts.height = size(vim.o.lines, opts.size.height)
  win_opts.row = math.floor((vim.o.lines - win_opts.height) / 2)
  win_opts.col = math.floor((vim.o.columns - win_opts.width) / 2)

  if M.terminals[key] and vim.api.nvim_buf_is_valid(M.terminals[key].buf) then
    if vim.api.nvim_win_is_valid(M.terminals[key].win) then
      vim.api.nvim_win_hide(M.terminals[key].win)
    else
      local win = vim.api.nvim_open_win(M.terminals[key].buf, true, win_opts)
      M.terminals[key] = { buf = M.terminals[key].buf, win = win }
      -- vim.cmd.startinsert()
    end
  else
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, win_opts)
    vim.api.nvim_buf_set_option(buf, "ft", "term")
    vim.fn.termopen(cmd, vim.empty_dict())
    -- vim.keymap.set("n", "<ESC>", "<CMD>close<CR>", { buffer = buf })
    vim.keymap.set("n", "q", "<CMD>close<CR>", { buffer = buf })
    M.terminals[key] = { buf = buf, win = win }
  end
end

local split = function(split_cmd, key)
  key = key or vim.v.count or 0
  local win, buf
  if M.terminals[key] and vim.api.nvim_buf_is_valid(M.terminals[key].buf) then
    if vim.api.nvim_win_is_valid(M.terminals[key].win) then
      vim.api.nvim_win_hide(M.terminals[key].win)
    else
      vim.cmd(split_cmd)
      win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(win, M.terminals[key].buf)
      -- vim.cmd.startinsert()
      M.terminals[key] = { buf = M.terminals[key].buf, win = win }
    end
  else
    vim.cmd(split_cmd)
    win = vim.api.nvim_get_current_win()
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "ft", "term")
    vim.api.nvim_win_set_option(win, "number", false)
    vim.api.nvim_win_set_option(win, "relativenumber", false)
    vim.api.nvim_win_set_option(win, "signcolumn", "no")
    vim.api.nvim_win_set_buf(win, buf)
    vim.fn.termopen(vim.o.shell, vim.empty_dict())
    -- vim.keymap.set("n", "<ESC>", "<CMD>close<CR>", { buffer = buf })
    vim.keymap.set("n", "q", "<CMD>close<CR>", { buffer = buf })
    M.terminals[key] = { buf = buf, win = win }
  end
end

M.split_horz = function(height, key)
  height = height or 0.25
  height = size(vim.o.lines, height)
  split(height .. "split", key)
end
M.split_vert = function(width, key)
  width = width or 0.3
  width = size(vim.o.columns, width)
  split(width .. "vsplit", key)
end

M.find_term = function(opts)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values

  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  opts = opts or {}

  local results = {}
  for k, v in pairs(M.terminals) do
    local buf_name = vim.api.nvim_buf_get_name(v.buf)
    table.insert(results, { k, k .. " " .. buf_name })
  end
  pickers
    .new(opts, {
      prompt_title = "M.terminals",
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
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.schedule(function()
            M.float(nil, selection.value[1])
          end)
        end)
        actions.select_horizontal:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.schedule(function()
            M.split_horz(nil, selection.value[1])
          end)
        end)
        actions.select_vertical:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.schedule(function()
            M.split_vert(nil, selection.value[1])
          end)
        end)
        actions.select_tab:replace(function() end)
        return true
      end,
    })
    :find()
end

return M
