local M = {}

M._get_option = vim.filetype.get_option

---@param key "line"|"block"|nil
---@return string
M.get_commentstring = function(key)
  local commentstring = nil
  if key == "block" then
    local ok, ts_context_commentstring = pcall(require, "ts_context_commentstring")
    if ok then
      local pos = vim.api.nvim_win_get_cursor(0)
      pos[1] = pos[1] - 1
      commentstring = ts_context_commentstring.calculate_commentstring({ key = "__multiline", location = pos })
    end
  end
  if not commentstring then commentstring = vim.filetype.get_option(vim.bo.ft, "commentstring") end
  assert(type(commentstring) == "string")
  return commentstring
end

---@param mode "n"|"v"
M.blockwise_comment = function(mode)
  local marks = mode == "n" and { "[", "]" } or { "<", ">" }
  local start = vim.api.nvim_buf_get_mark(0, marks[1])[1] - 1
  local end_pos = vim.api.nvim_buf_get_mark(0, marks[2])[1]
  if start < 0 or end_pos <= 0 then return end
  local lines = vim.api.nvim_buf_get_lines(0, start, end_pos, true)
  local commentstring = M.get_commentstring("block")
  local left, right = commentstring:match("^%s*(.-)%s*%%s%s*(.-)%s*$")
  if left and right then
    if vim.trim(right) == "" then -- not a block commentstring, fallback to linewise commenting
      if mode == "n" then
        vim.api.nvim_feedkeys("'[gc']", "m", false)
      else
        vim.api.nvim_feedkeys("'<gc'>", "m", false)
      end
      return
    end
    local l1 = lines[1]:match("^%s*(" .. vim.pesc(left) .. "%s*).-" .. "%s*$")
    local l2 = lines[#lines]:match("^%s*" .. ".-(%s*" .. vim.pesc(right) .. ")%s*$")
    if l1 and l2 then -- commented, uncomment
      lines[1] = lines[1]:gsub(vim.pesc(l1), "", 1)
      lines[#lines] = lines[#lines]:gsub(vim.pesc(l2) .. "(%s*)$", "%1", 1)
    else -- not commented, comment
      local pad, content = lines[1]:match("^(%s*)(.-)$")
      lines[1] = pad .. left .. " " .. content
      lines[#lines] = lines[#lines] .. " " .. right
    end
    vim.api.nvim_buf_set_lines(0, start, end_pos, true, lines)
  end
end

---@diagnostic disable: duplicate-doc-field
---@class CommentingConfig
---@field above_linewise string
---@field below_linewise string
---@field eol_linewise string
---@field blockwise string
---@field current_blockwise string
---@field above_blockwise string
---@field below_blockwise string
---@field eol_blockwise string

---@param config CommentingConfig
M.setup = function(config)
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.filetype.get_option = function(filetype, option)
    if option ~= "commentstring" then return M._get_option(filetype, option) end
    local ok, ts_context_commentstring = pcall(require, "ts_context_commentstring")
    local line = vim.fn.getline(".")
    local pos = vim.api.nvim_win_get_cursor(0)
    pos[1] = pos[1] - 1
    local patterns = {}
    vim.list_extend(patterns, {
      ok and ts_context_commentstring.calculate_commentstring({ key = "__default", location = pos }) or nil,
      ok and ts_context_commentstring.calculate_commentstring({ key = "__multiline", location = pos }) or nil,
      M._get_option(filetype, option),
    })
    --> credits to `folke/ts-comments.nvim` for the code below <--
    local cs = nil
    local n = math.huge
    for _, pattern in ipairs(patterns) do
      local left, right = pattern:match("^%s*(.-)%s*%%s%s*(.-)%s*$")
      if left and right then
        local l, m, r = line:match("^%s*" .. vim.pesc(left) .. "(%s*)(.-)(%s*)" .. vim.pesc(right) .. "%s*$")
        if m and #m < n then -- most commented line
          cs = vim.trim(left .. l .. "%s" .. r .. right) -- add correct whitespace to uncomment
          n = #m
        end
        if not cs then -- first pattern is the wanted commentstring
          cs = vim.trim(left .. " %s " .. right) -- add correct whitespace to comment
        end
      end
    end
    assert(cs, "commentstring should not be nil")
    return cs
  end

  Op_blockwise_comment = function() M.blockwise_comment("n") end

  local function map(mode, lhs, rhs, opts)
    opts = vim.tbl_extend("force", opts or {}, { noremap = true, silent = true })
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  map("x", config.blockwise, "<ESC><CMD>lua require('user.comment').blockwise_comment('v')<CR>")
  map("n", config.blockwise, function()
    vim.opt_local.operatorfunc = "v:lua.Op_blockwise_comment"
    return "g@"
  end, { expr = true })
  map("n", config.current_blockwise, function()
    vim.opt_local.operatorfunc = "v:lua.Op_blockwise_comment"
    return "g@$"
  end, { expr = true })
  map("n", config.below_linewise, function() return "o" .. M.get_commentstring() .. "==F%cW" end, { expr = true })
  map("n", config.above_linewise, function() return "O" .. M.get_commentstring() .. "==F%cW" end, { expr = true })
  map("n", config.eol_linewise, function() return "A " .. M.get_commentstring() .. "==F%cW" end, { expr = true })
  -- stylua: ignore start
  map("n", config.below_blockwise, function() return "o" .. M.get_commentstring("block") .. "==F%cW" end, { expr = true })
  map("n", config.above_blockwise, function() return "O" .. M.get_commentstring("block") .. "==F%cW" end, { expr = true })
  map("n", config.eol_blockwise, function() return "A " .. M.get_commentstring("block") .. "==F%cW" end, { expr = true })
  -- stylua: ignore end
end

return M
