vim.g.confirm_load_session = true
vim.g.session_loaded = false

local config_dir = require("user.root").get() .. "/.nvim"

local session_file = config_dir .. "/session.vim"
local settings_file = config_dir .. "/settings.lua"

vim.api.nvim_create_user_command("Mksession", function()
  vim.fn.mkdir(config_dir, "p")
  vim.cmd("mksession! " .. session_file)
  vim.g.session_loaded = true
end, {})

vim.api.nvim_create_user_command("ProjectSettings", "e " .. settings_file, {})

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("user_session", { clear = true }),
  callback = function()
    if vim.g.session_loaded == false or vim.fn.filereadable(session_file) == 0 then
      return
    end
    vim.ui.input({ prompt = "Update session? [Y/n] " }, function(input)
      if input:lower() ~= "n" and input:lower() ~= "no" then
        vim.cmd("Mksession")
      end
    end)
  end,
})

local function load_settings()
  if vim.fn.filereadable(settings_file) == 0 then
    return
  end
  vim.cmd.source(settings_file)
end

local function load_session()
  if vim.g.session_loaded then
    return
  end
  if vim.fn.filereadable(session_file) == 0 then
    return
  end
  local choice = false
  if vim.g.confirm_load_session == true then
    vim.ui.input({ prompt = "Previous session found. Load session? [Y/n] " }, function(input)
      if input:lower() ~= "n" and input:lower() ~= "no" then
        choice = true
      end
    end)
  end
  if choice == true then
    vim.cmd.source(session_file)
    vim.g.session_loaded = true
  end
end

load_settings()
load_session()
