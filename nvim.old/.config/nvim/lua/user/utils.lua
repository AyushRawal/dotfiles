local M = {}

M.kind_icons = {
  Array = " ",
  Boolean = "󰨙 ",
  Class = " ",
  -- Codeium = "󰘦 ",
  Color = " ",
  Control = " ",
  Collapsed = " ",
  Constant = "󰏿 ",
  Constructor = " ",
  -- Copilot = " ",
  Enum = " ",
  EnumMember = " ",
  Event = " ",
  Field = " ",
  File = " ",
  Folder = " ",
  Function = "󰊕 ",
  Interface = " ",
  Key = " ",
  Keyword = " ",
  Method = "󰊕 ",
  Module = " ",
  Namespace = "󰦮 ",
  Null = " ",
  Number = "󰎠 ",
  Object = " ",
  Operator = " ",
  Package = " ",
  Property = " ",
  Reference = " ",
  Snippet = " ",
  String = " ",
  Struct = "󰆼 ",
  Text = " ",
  TypeParameter = " ",
  Unit = " ",
  Value = " ",
  Variable = "󰀫 ",
}

M.diagnostics_icons = {
  Error = " ",
  Warn = " ",
  Hint = "",
  Info = " ",
}

---@param on_attach fun(client: vim.lsp.Client, bufnr: buffer)
M.on_lsp_attach = function(on_attach)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then return end
      on_attach(client, buffer)
    end,
  })
end

--- @param name string
--- @param fn function
M.on_plugin_load = function(name, fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyLoad",
    callback = function(event)
      if event.data == name then fn() end
    end,
  })
end

return M
