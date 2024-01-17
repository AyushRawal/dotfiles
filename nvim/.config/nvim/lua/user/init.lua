if vim.loader then
  vim.loader.enable()
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("user.options")
require("lazy").setup({ { import = "user.plugins" } }, {
  ui = {
    border = "single",
  },
  change_detection = {
    notify = false,
  },
})
require("user.usercmds")
require("user.autocmds")
require("user.mappings").main()
require("user.project")
