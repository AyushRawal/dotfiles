local function navic_sethl()
  local highlights = {
    NavicIconsFile = "CmpItemKindFile",
    NavicIconsModule = "CmpItemKindModule",
    NavicIconsNamespace = "CmpItemKindModule",
    NavicIconsPackage = "CmpItemKindFolder",
    NavicIconsClass = "CmpItemKindClass",
    NavicIconsMethod = "CmpItemKindMethod",
    NavicIconsProperty = "CmpItemKindProperty",
    NavicIconsField = "CmpItemKindField",
    NavicIconsConstructor = "CmpItemKindConstructor",
    NavicIconsEnum = "CmpItemKindEnum",
    NavicIconsInterface = "CmpItemKindInterface",
    NavicIconsFunction = "CmpItemKindFunction",
    NavicIconsVariable = "CmpItemKindVariable",
    NavicIconsConstant = "CmpItemKindConstant",
    NavicIconsString = "CmpItemKindValue",
    NavicIconsNumber = "CmpItemKindValue",
    NavicIconsBoolean = "CmpItemKindValue",
    NavicIconsArray = "CmpItemKindValue",
    NavicIconsObject = "CmpItemKindValue",
    NavicIconsKey = "CmpItemKindValue",
    NavicIconsNull = "CmpItemKindValue",
    NavicIconsEnumMember = "CmpItemKindEnumMember",
    NavicIconsStruct = "CmpItemKindStruct",
    NavicIconsEvent = "CmpItemKindEvent",
    NavicIconsOperator = "CmpItemKindOperator",
    NavicIconsTypeParameter = "CmpItemKindTypeParameter",
    NavicText = "WinBar",
    NavicSeparator = "Conceal",
  }
  for from, to in pairs(highlights) do
    vim.api.nvim_set_hl(0, from, { link = to, default = true })
  end
end

return {
  "SmiteshP/nvim-navic",
  event = { "BufReadPost", "BufNewFile" },
  config = function(_, opts)
    require("nvim-navic").setup(opts)
    navic_sethl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      desc = "set navic hlgroups",
      group = vim.api.nvim_create_augroup("user_navic_hlgroups", { clear = true }),
      callback = navic_sethl,
    })
    require("user.utils").on_lsp_attach(function(client, bufnr)
      if client.supports_method("textDocument/documentSymbol") then
        require("nvim-navic").attach(client, bufnr)
      end
    end)
  end,
  opts = {
    icons = require("user.utils").kind_icons,
    highlight = true,
    separator = " ❯ ",
    depth_limit = 0,
    depth_limit_indicator = "..",
    safe_output = true,
  },
}
