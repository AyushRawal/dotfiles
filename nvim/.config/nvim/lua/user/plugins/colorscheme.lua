local gruvbox_custom = function()
  local highlights = {
    -- lsp and floats
    NormalFloat = "Normal",
    FloatBorder = "Normal",
    ErrorFloat = "DiagnosticSignError",
    WarningFloat = "DiagnosticSignWarn",
    HintFloat = "DiagnosticSignHint",
    InfoFloat = "DiagnosticSignFloat",
  }
  for from, to in pairs(highlights) do
    vim.api.nvim_set_hl(0, from, { link = to })
  end
end

return {
  "sainnhe/gruvbox-material",
  lazy = false,
  config = function()
    vim.g.gruvbox_material_better_performance = 1
    vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
    vim.g.gruvbox_material_sign_column_background = "grey"
    vim.g.gruvbox_material_enable_italic = 1
    vim.g.gruvbox_material_enable_bold = 1
    vim.g.gruvbox_material_background = "hard"
    local group = vim.api.nvim_create_augroup("user_gruvbox_custom", { clear = true })
    vim.api.nvim_create_autocmd(
      "ColorScheme",
      { pattern = "gruvbox-material", callback = gruvbox_custom, group = group }
    )
    vim.cmd("colorscheme gruvbox-material")
  end,
}
