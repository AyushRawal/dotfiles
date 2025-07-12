local usercmd = vim.api.nvim_create_user_command

-- save me
usercmd("W", "w", {})
usercmd("Wq", "wq", {})
usercmd("Q", "q<bang>", { bang = true })

-- set cwd to root dir
usercmd("CD", function()
  local root_dir = require("user.custom.root").get()[1]
  vim.notify("Changing cwd to " .. root_dir)
  vim.cmd("cd " .. root_dir)
end, {
  desc = "set cwd to root dir",
})
