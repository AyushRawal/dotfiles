local M = {
  win = nil,
  buf = nil,
  timer = nil,
  ns = vim.api.nvim_create_namespace("user_lsp_progress"),
  mark = nil,
  prev_msg = nil,
  count = 0,
  timeout = 3000,
  winblend = 25,
  highlight = "BlueItalic",
}

--- @param str string
M.win_opts = function(str)
  return {
    relative = "editor",
    anchor = "SE",
    style = "minimal",
    border = "none",
    height = 1,
    width = str:len() + 5,
    row = vim.o.lines - M.count - 1,
    col = vim.o.columns - 1,
    focusable = false,
    zindex = 100,
  }
end

--- @param str string
M.update = function(str)
  local new = false
  local new_msg = str:gsub("[0-9 .%%://]", "")
  if not M.prev_msg == nil or new_msg ~= M.prev_msg then new = true end
  M.prev_msg = new_msg
  if new == true or not vim.api.nvim_win_is_valid(M.win) then
    -- increase count if new msg or previous window no longer valid
    M.count = M.count + 1
  end
  if new == true then
    M.win = nil
    M.buf = nil
    M.timer = nil
  end
  if not M.buf or not vim.api.nvim_buf_is_valid(M.buf) then M.buf = vim.api.nvim_create_buf(false, true) end
  if not M.win or not vim.api.nvim_win_is_valid(M.win) then
    M.win = vim.api.nvim_open_win(M.buf, false, M.win_opts(str))
  end
  vim.wo[M.win].winblend = M.winblend
  M.mark = vim.api.nvim_buf_set_extmark(M.buf, M.ns, 0, 0, {
    id = M.mark,
    virt_text = { { str, M.highlight } },
    virt_text_pos = "right_align",
  })
  if M.timer then
    -- for old msg reset the timer
    M.timer:stop()
  end
  M.timer = M.delayed_close(M.buf, M.win, M.timer)
end

M.delayed_close = function(buf, win, timer)
  if not timer then timer = vim.uv.new_timer() end
  if not timer then
    vim.notify("[lsp_progress] could not create timer", vim.log.levels.ERROR)
    return
  end
  timer:start(M.timeout, 0, function()
    vim.schedule(function()
      if M.win then vim.api.nvim_win_hide(win) end
      if M.buf then vim.api.nvim_buf_delete(buf, { force = true }) end
      M.count = M.count - 1
    end)
  end)
  return timer
end

M.start = function()
  vim.api.nvim_create_autocmd("LspProgress", {
    group = vim.api.nvim_create_augroup("user_lsp_progress", { clear = true }),
    callback = function() M.update(vim.lsp.status()) end,
  })
end

return M
