local usercmd = vim.api.nvim_create_user_command

-- save me
usercmd("W", "w", {})
usercmd("Wq", "wq", {})
usercmd("Q", "q<bang>", { bang = true })

-- set cwd to root dir
usercmd("CD", function()
  local root_dir = require("user.root").get()
  vim.cmd("cd " .. root_dir)
  vim.notify("Changined cwd to " .. root_dir)
end, {
  desc = "set cwd to root dir",
})

usercmd("ProjectRoot", function() vim.print(require("user.root").get()) end, {
  desc = "print root dir",
})

usercmd("Terminals", function()
  local res = ""
  for k, v in pairs(require("user.terminal").terminals) do
    if vim.api.nvim_buf_is_valid(v.buf) then res = res .. k .. ": " .. vim.api.nvim_buf_get_name(v.buf) .. "\n" end
  end
  vim.print(res)
end, { desc = "list terminals" })

usercmd("CPmode", function() require("user.keymaps").cp() end, { desc = "setup for cp" })
