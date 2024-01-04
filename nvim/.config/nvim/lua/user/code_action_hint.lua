-- Credits: heavily inspired by https://github.com/rockyzhang24/dotfiles/blob/master/.config/nvim/lua/rockyz/lsp/lightbulb.lua
local icon = "󱐋"
local function code_action_hint_hl()
  vim.api.nvim_set_hl(0, "CodeActionHint", { link = "DiagnosticSignInfo" })
end
code_action_hint_hl()
vim.api.nvim_create_autocmd("ColorScheme", {
  desc = "set code action hint hlgroups",
  group = vim.api.nvim_create_augroup("user_code_action_hint_hlgroups", { clear = true }),
  callback = code_action_hint_hl
})

local M = {}
local cur_bufnr = nil
local prev_bufnr = nil
local code_action_support = false
local ns_id = vim.api.nvim_create_namespace("code_action_hint")
local mark_id = nil
--- Get diagnostics (LSP Diagnostic) at the cursor
---
--- Grab the code from https://github.com/neovim/neovim/issues/21985
---
--- TODO:
--- This PR (https://github.com/neovim/neovim/pull/22883) extends
--- vim.diagnostic.get to return diagnostics at cursor directly and even with
--- LSP Diagnostic structure. If it gets merged, simplify this funciton (the
--- code for filter and build can be removed).
---
---@return table # A table of LSP Diagnostic
local function get_diagnostic_at_cursor()
  cur_bufnr = vim.api.nvim_get_current_buf()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0)) -- line is 1-based indexing
  -- Get a table of diagnostics at the current line. The structure of the
  -- diagnostic item is defined by nvim (see :h diagnostic-structure) to
  -- describe the information of a diagnostic.
  local diagnostics = vim.diagnostic.get(cur_bufnr, { lnum = line - 1 }) -- lnum is 0-based indexing
  -- Filter out the diagnostics at the cursor position. And then use each to
  -- build a LSP Diagnostic (see
  -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#diagnostic)
  local lsp_diagnostics = {}
  for _, diag in pairs(diagnostics) do
    if diag.col <= col and diag.end_col >= col then
      table.insert(lsp_diagnostics, {
        range = {
          ["start"] = {
            line = diag.lnum,
            character = diag.col,
          },
          ["end"] = {
            line = diag.end_lnum,
            character = diag.end_col,
          },
        },
        severity = diag.severity,
        code = diag.code,
        source = diag.source or nil,
        message = diag.message,
      })
    end
  end
  return lsp_diagnostics
end

M.remove_hint = function()
  if not cur_bufnr or not mark_id then
    return
  end
  vim.api.nvim_buf_del_extmark(cur_bufnr, ns_id, mark_id)
end

M.show_hint = function()
  cur_bufnr = vim.api.nvim_get_current_buf()
  if cur_bufnr ~= prev_bufnr then -- when entering to another buffer
    prev_bufnr = cur_bufnr
    code_action_support = false
  end
  if code_action_support == false then
    for _, client in pairs(vim.lsp.get_active_clients({ bufnr = cur_bufnr })) do
      if client then
        if client.supports_method("textDocument/codeAction") then
          code_action_support = true
        end
      end
    end
  end
  if code_action_support == false then
    M.remove_hint()
    return
  end
  local params = vim.lsp.util.make_range_params()
  params.context = {
    diagnostics = get_diagnostic_at_cursor(),
  }
  vim.lsp.buf_request_all(0, "textDocument/codeAction", params, function(results)
    local has_actions = false
    for _, result in pairs(results) do
      for _, action in pairs(result.result or {}) do
        if action then
          has_actions = true
          break
        end
      end
    end
    M.remove_hint()
    if has_actions then
      local cur_lnum = vim.fn.line(".")
      local opts = {
        virt_text = { { "  ", "CodeActionHint" }, { icon, "CodeActionHint" } },
        virt_text_pos = "eol",
      }
      mark_id = vim.api.nvim_buf_set_extmark(cur_bufnr, ns_id, cur_lnum - 1, 0, opts)
    end
  end)
end

return M
