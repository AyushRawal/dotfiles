local gruvbox_custom = function()
  local highlights = {
    -- lsp and floats
    NormalFloat = "Normal",
    FloatBorder = "Normal",
    ErrorFloat = "DiagnosticSignError",
    WarningFloat = "DiagnosticSignWarn",
    HintFloat = "DiagnosticSignHint",
    InfoFloat = "DiagnosticSignFloat",
    DiagnosticSignOk = "AquaSign"
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
    -- vim.g.gruvbox_material_sign_column_background = "grey"
    vim.g.gruvbox_material_enable_italic = 1
    vim.g.gruvbox_material_enable_bold = 1
    vim.g.gruvbox_material_background = "hard"
    vim.g.gruvbox_material_foreground = "material"
    vim.g.gruvbox_material_ui_contrast = "high"
    vim.g.gruvbox_material_colors_override = {
      bg0 = { "#1a1a1a", 234 },
      bg1 = { "#252525", 235 },
      bg2 = { "#252525", 235 },
      bg3 = { "#303533", 237 },
      bg4 = { "#303533", 237 },
      bg5 = { "#4d4542", 239 },
      bg_statusline1 = { "#252525", 235 },
      bg_statusline3 = { "#4d4542", 239 }
    }
    local group = vim.api.nvim_create_augroup("user_gruvbox_custom", { clear = true })
    vim.api.nvim_create_autocmd(
      "ColorScheme",
      { pattern = "gruvbox-material", callback = gruvbox_custom, group = group }
    )
    vim.cmd("colorscheme gruvbox-material")
  end,
}
