local mappings = require("user.keymaps")

return {
  "numToStr/Comment.nvim",
  enabled = false,
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    ---Add a space b/w comment and the line
    padding = true,
    ---Whether the cursor should stay at its position
    sticky = true,
    ---Lines to be ignored while (un)comment
    ---@diagnostic disable-next-line: assign-type-mismatch
    ignore = nil,

    -- keybindings
    toggler = mappings.comment.toggler,
    opleader = mappings.comment.opleader,
    extra = mappings.comment.extra,

    ---Enable keybindings
    ---NOTE: If given `false` then the plugin won't create any mappings
    mappings = {
      ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
      basic = true,
      ---Extra mapping; `gco`, `gcO`, `gcA`
      extra = true,
    },
    ---Function to call before (un)comment
    ---@diagnostic disable-next-line: assign-type-mismatch
    pre_hook = nil,
    ---Function to call after (un)comment
    ---@diagnostic disable-next-line: assign-type-mismatch
    post_hook = nil,
  },
}
