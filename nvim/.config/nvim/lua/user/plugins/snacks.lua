return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    bufdelete = { enabled = true },
    dashboard = { enabled = true },
    explorer = { enabled = true },
    indent = { enabled = true, animate = { enabled = false } },
    input = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scroll = { enabled = true },
    -- FIX: backdrop doesn't close automatically
    -- lazygit = { enabled =  true, win = { backdrop = false } },
    image = {
      enabled = true,
      -- doc = { inline = false },
      math = {
        latex = { font_size = "normal" }
      }
    },
    statuscolumn = {
      enabled = true,
      left = { "mark" },
      right = { "fold", "git" },
      folds = {
        open = true,
        git_hl = true
      }
    },
    -- scope = { enabled = true },
    dim = { animate = { enabled = false } },
    words = { enabled = false },
    picker = { enabled = true },
    terminal = { enabled = false },
    -- TODO: upstream this and remove
    -- styles = {
    --   ---@diagnostic disable-next-line:missing-fields
    --   terminal = {
    --     keys = {
    --       term_normal = {
    --         "<esc>",
    --         function(self)
    --           ---@diagnostic disable-next-line:inject-field
    --           self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
    --           if self.esc_timer:is_active() then
    --             self.esc_timer:stop()
    --             vim.cmd("stopinsert")
    --             return "<esc>"
    --           else
    --             self.esc_timer:start(200, 0, function() end)
    --             return "<esc>"
    --           end
    --         end,
    --         mode = "t",
    --         expr = true,
    --         desc = "Double escape to normal mode",
    --       },
    --     }
    --   }
    -- }
  },
  config = function(_, opts)
    Snacks.setup(opts)
    Snacks.words.enable()
    require("user.keymaps").snacks()

    vim.api.nvim_create_user_command("Pick", function(cmd_opts)
      Snacks.picker[cmd_opts.fargs[1]]()
    end, {
      desc = "Snacks Pickers",
      nargs = 1, -- `+` for 1 or more args
      complete = function(argLead)
        return vim.tbl_filter(function(val)
          return val:sub(1, #argLead) == argLead
        end, vim.tbl_keys(Snacks.picker.sources))
      end
    })

    -- copied from snacks docs
    ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
    local progress = vim.defaulttable()
    vim.api.nvim_create_autocmd("LspProgress", {
      ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local value = ev.data.params
            .value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
        if not client or type(value) ~= "table" then
          return
        end
        local p = progress[client.id]
        for i = 1, #p + 1 do
          if i == #p + 1 or p[i].token == ev.data.params.token then
            p[i] = {
              token = ev.data.params.token,
              msg = ("[%3d%%] %s%s"):format(
                value.kind == "end" and 100 or value.percentage or 100,
                value.title or "",
                value.message and (" **%s**"):format(value.message) or ""
              ),
              done = value.kind == "end",
            }
            break
          end
        end
        local msg = {} ---@type string[]
        progress[client.id] = vim.tbl_filter(function(v)
          return table.insert(msg, v.msg) or not v.done
        end, p)
        local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        vim.notify(table.concat(msg, "\n"), "info", {
          id = "lsp_progress",
          title = client.name,
          opts = function(notif)
            notif.icon = #progress[client.id] == 0 and " "
                or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
          end,
        })
      end,
    })
  end
}
