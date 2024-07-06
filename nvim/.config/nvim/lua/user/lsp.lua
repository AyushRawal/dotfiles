-- enable inlay hints
vim.lsp.inlay_hint.enable()

local function lsp_highlight_document(client, bufnr)
  if client.supports_method("textDocument/documentHighlight") then
    local group = vim.api.nvim_create_augroup("user_lsp_document_highlight", { clear = true })
    vim.api.nvim_create_autocmd("CursorHold", {
      group = group,
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      group = group,
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

local function codelens_autorefresh(client, bufnr)
  if client.supports_method("textDocument/codeLens") then
    local group = vim.api.nvim_create_augroup("user_lsp_codelens", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
      callback = function() vim.lsp.codelens.refresh({ bufnr = bufnr }) end,
      group = group,
      buffer = bufnr,
    })
  end
end

require("user.utils").on_lsp_attach(function(client, bufnr)
  require("user.mappings").lsp(bufnr)
  lsp_highlight_document(client, bufnr)
  codelens_autorefresh(client, bufnr)
end)
