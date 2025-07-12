vim.lsp.enable({
  "lua_ls",
  "clangd",
  "ts_ls",
  "rust_analyzer",
  "basedpyright"
})

local function lsp_highlight_document(client)
  if client.supports_method("textDocument/documentHighlight") then
    local group = vim.api.nvim_create_augroup("user_lsp_document_highlight", { clear = true })
    vim.api.nvim_create_autocmd("CursorHold", {
      group = group,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
      group = group,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

local function codelens_autorefresh(client)
  if client.supports_method("textDocument/codeLens") then
    local group = vim.api.nvim_create_augroup("user_lsp_codelens", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
      callback = function() vim.lsp.codelens.refresh() end,
      group = group,
    })
  end
end

require("user.utils").on_lsp_attach(function(client, bufnr)
  require("user.keymaps").lsp(bufnr)
  if not Snacks then
    lsp_highlight_document(client)
  end
  codelens_autorefresh(client)
end)
