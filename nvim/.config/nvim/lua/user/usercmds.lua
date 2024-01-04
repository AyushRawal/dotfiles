local usercmd = vim.api.nvim_create_user_command

-- save me
usercmd("W", "w", {})
usercmd("Wq", "wq", {})
usercmd("Q", "q<bang>", { bang = true })

-- set cwd to root dir
usercmd("CD", function()
  local root_dir = require("user.root").get()
  vim.cmd("cd " .. root_dir)
end, {
  desc = "set cwd to root dir",
})

vim.api.nvim_create_user_command("Term", function()
  local res = ""
  for k, v in pairs(require("user.terminal").terminals) do
    local buf_name = vim.api.nvim_buf_get_name(v.buf)
    res = res .. k .. ": " .. buf_name .. "\n"
  end
  vim.print(res)
end, { desc = "list terminals" })
