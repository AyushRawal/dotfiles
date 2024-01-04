return {
  "willothy/flatten.nvim",
  -- Ensure that it runs first to minimize delay when opening file from terminal
  lazy = false,
  priority = 1001,
  opts = function()
    local term_win
    return {
      window = {
        open = "alternate",
      },
      callbacks = {
        should_block = function(argv)
          -- This allows you to use `nvim -b file1` instead of
          -- `nvim --cmd 'let g:flatten_wait=1' file1` to block
          return vim.tbl_contains(argv, "-b")
        end,
        pre_open = function()
          -- local term_key = require("user.terminal").get_focused_term_key()
          -- term_win = require("user.terminal").terminals[term_key].win
          term_win = vim.api.nvim_get_current_win()
        end,
        post_open = function(_, winnr, _, is_blocking) --> _bufnr, _ft
          -- local win_conf = vim.api.nvim_win_get_config(term_win)
          -- local is_floating = win_conf.relative ~= "" or win_conf.external
          local is_floating = (vim.fn.win_gettype(term_win) == "popup")
          if is_blocking or is_floating then
            if vim.api.nvim_win_is_valid(term_win) then
              vim.api.nvim_win_hide(term_win)
            end
          else
            vim.api.nvim_set_current_win(winnr)
          end
          -- if ft == "gitcommit" or ft == "gitrebase" then
          --   vim.api.nvim_create_autocmd("BufWritePost", {
          --     buffer = bufnr,
          --     once = true,
          --     callback = vim.schedule_wrap(function()
          --       vim.api.nvim_buf_delete(bufnr, {})
          --     end),
          --   })
          -- end
        end,
      },
    }
  end,
}
