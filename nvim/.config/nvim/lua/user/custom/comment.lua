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
local blockwise_comment = function(mode)
  local marks = mode == "n" and { "[", "]" } or { "<", ">" }
  local start_pos = vim.api.nvim_buf_get_mark(0, marks[1])
  local start_row = start_pos[1] - 1
  local start_col = start_pos[2]
  local end_pos = vim.api.nvim_buf_get_mark(0, marks[2])
  local end_row = end_pos[1]
  local end_col = end_pos[2]
  if start_row < 0 or end_row <= 0 then return end
  local end_line_length = vim.api.nvim_buf_get_lines(0, end_row - 1, end_row, true)[1]:len()
  if end_col == vim.v.maxcol or end_col == end_line_length then
    end_col = end_line_length - 1
  end
  local text = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row - 1, end_col + 1, {})
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
    local l1 = text[1]:match("^%s*(" .. vim.pesc(left) .. "%s*).-" .. "%s*$")
    local l2 = text[#text]:match("^%s*" .. ".-(%s*" .. vim.pesc(right) .. ")%s*$")
    if l1 and l2 then -- commented, uncomment
      text[1] = text[1]:gsub(vim.pesc(l1), "", 1)
      text[#text] = text[#text]:gsub(vim.pesc(l2) .. "(%s*)$", "%1", 1)
    else -- not commented, comment
      local pad, content = text[1]:match("^(%s*)(.-)$")
      text[1] = pad .. left .. " " .. content
      text[#text] = text[#text] .. " " .. right
    end
    vim.api.nvim_buf_set_text(0, start_row, start_col, end_row - 1, end_col + 1, text)
  end
end

Op_blockwise_comment = function() blockwise_comment("n") end
Visual_blockwise_comment = function() blockwise_comment("v") end

local setup_ft_get_opt = function()
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
        if m and #m < n then                             -- most commented line
          cs = vim.trim(left .. l .. "%s" .. r .. right) -- add correct whitespace to uncomment
          n = #m
        end
        if not cs then                           -- first pattern is the wanted commentstring
          cs = vim.trim(left .. " %s " .. right) -- add correct whitespace to comment
        end
      end
    end
    return cs
    -- if cs then return cs end
    -- vim.notify(
    --   string.format("No commentstring found for filetype '%s'", filetype),
    --   vim.log.levels.WARN
    -- )
  end
end

local function map(mode, lhs, rhs, opts)
  if not lhs then return end
  opts = vim.tbl_extend("force", opts or {}, { noremap = true, silent = true })
  vim.keymap.set(mode, lhs, rhs, opts)
end

---@diagnostic disable: duplicate-doc-field
---@class CommentingConfig
---@field above_linewise? string
---@field below_linewise? string
---@field eol_linewise? string
---@field blockwise string
---@field current_blockwise string
---@field above_blockwise? string
---@field below_blockwise? string
---@field eol_blockwise? string

---@param config CommentingConfig
M.setup = function(config)
  setup_ft_get_opt()

  map("x", config.blockwise, "<ESC><CMD>lua Visual_blockwise_comment()<CR>", { desc = "Toggle blockwise comment" })
  map("n", config.blockwise, function()
    vim.opt_local.operatorfunc = "v:lua.Op_blockwise_comment"
    return "g@"
  end, { expr = true, desc = "Toggle blockwise comment" })
  map("n", config.current_blockwise, function()
    vim.opt_local.operatorfunc = "v:lua.Op_blockwise_comment"
    return "^g@$"
  end, { expr = true, desc = "Toggle blockwise comment" })

  -- stylua: ignore start
  map("n", config.below_linewise, function() return "o" .. M.get_commentstring() .. "==F%cW" end,
    { expr = true, desc = "add comment below" })
  map("n", config.above_linewise, function() return "O" .. M.get_commentstring() .. "==F%cW" end,
    { expr = true, desc = "add comment above" })
  map("n", config.eol_linewise, function() return "A " .. M.get_commentstring() .. "==F%cW" end,
    { expr = true, desc = "add comment at end of line" })
  map("n", config.below_blockwise, function() return "o" .. M.get_commentstring("block") .. "==F%cW" end,
    { expr = true, desc = "add block comment below" })
  map("n", config.above_blockwise, function() return "O" .. M.get_commentstring("block") .. "==F%cW" end,
    { expr = true, desc = "add block comment above" })
  map("n", config.eol_blockwise, function() return "A " .. M.get_commentstring("block") .. "==F%cW" end,
    { expr = true, desc = "add block comment at end of line" })
  -- stylua: ignore end
end

return M
