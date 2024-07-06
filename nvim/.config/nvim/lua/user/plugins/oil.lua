local type_hlgroups = setmetatable({
  ["-"] = "OilTypeFile",
  ["d"] = "OilTypeDir",
  ["p"] = "OilTypeFifo",
  ["l"] = "OilTypeLink",
  ["s"] = "OilTypeSocket",
}, {
  __index = function() return "OilTypeFile" end,
})
local permission_hlgroups = setmetatable({
  ["-"] = "OilPermissionNone",
  ["r"] = "OilPermissionRead",
  ["w"] = "OilPermissionWrite",
  ["x"] = "OilPermissionExecute",
}, {
  __index = function() return "OilDir" end,
})

local function oil_sethl()
  local gethl = function(name) return vim.api.nvim_get_hl(0, { name = name, link = false }) end
  local sethl = function(name, to, opts)
    opts = vim.tbl_deep_extend("force", {
      fg = gethl(to)["fg"],
      default = true,
    }, opts or {})
    vim.api.nvim_set_hl(0, name, opts)
  end
  sethl("OilDir", "Directory")
  sethl("OilDirIcon", "Directory")
  sethl("OilLink", "Constant")
  sethl("OilLinkTarget", "Comment")
  sethl("OilCopy", "DiagnosticSignHint", { bold = true })
  sethl("OilMove", "DiagnosticSignWarn", { bold = true })
  sethl("OilChange", "DiagnosticSignWarn", { bold = true })
  sethl("OilCreate", "DiagnosticSignInfo", { bold = true })
  sethl("OilDelete", "DiagnosticSignError", { bold = true })
  sethl("OilPermissionNone", "NonText")
  sethl("OilPermissionRead", "DiagnosticSignWarn")
  sethl("OilPermissionWrite", "DiagnosticSignError")
  sethl("OilPermissionExecute", "GreenBold")
  sethl("OilTypeDir", "Directory")
  sethl("OilTypeFifo", "Special")
  sethl("OilTypeFile", "NonText")
  sethl("OilTypeLink", "Constant")
  sethl("OilTypeSocket", "OilSocket")
end

return {
  "stevearc/oil.nvim",
  keys = require("user.mappings").oil,
  lazy = false,
  config = function(_, opts)
    require("oil").setup(opts)
    oil_sethl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      desc = "set oil hlgroups",
      group = vim.api.nvim_create_augroup("user_oil_hlgroups", { clear = true }),
      callback = oil_sethl,
    })
  end,
  opts = {
    -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
    -- Set to false if you still want to use netrw.
    default_file_explorer = true,
    -- Id is automatically added at the beginning, and name at the end
    -- See :help oil-columns
    columns = {
      {
        "type",
        icons = {
          directory = "d",
          fifo = "p",
          file = "-",
          link = "l",
          socket = "s",
        },
        highlight = function(type_str) return type_hlgroups[type_str] end,
      },
      {
        "permissions",
        highlight = function(permission_str)
          local hls = {}
          for i = 1, #permission_str do
            local char = permission_str:sub(i, i)
            table.insert(hls, { permission_hlgroups[char], i - 1, i })
          end
          return hls
        end,
      },
      {
        "size",
        highlight = "Special",
      },
      {
        "mtime",
        highlight = "Number",
      },
      "icon",
    },
    -- Buffer-local options to use for oil buffers
    buf_options = {
      buflisted = false,
      bufhidden = "hide",
    },
    -- Window-local options to use for oil buffers
    win_options = {
      wrap = false,
      signcolumn = "no",
      number = true,
      relativenumber = true,
      cursorcolumn = false,
      foldcolumn = "0",
      spell = false,
      list = false,
      conceallevel = 3,
      concealcursor = "nvic",
    },
    -- Send deleted files to the trash instead of permanently deleting them (:help oil-trash)
    delete_to_trash = false,
    -- Skip the confirmation popup for simple operations
    skip_confirm_for_simple_edits = true,
    -- Change this to customize the command used when deleting to trash
    trash_command = "trash-put",
    -- Selecting a new/moved/renamed file or directory will prompt you to save changes first
    prompt_save_on_select_new_entry = true,
    -- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
    -- options with a `callback` (e.g. { callback = function() ... end, desc = "", nowait = true })
    -- Additionally, if it is a string that matches "actions.<name>",
    -- it will use the mapping at require("oil.actions").<name>
    -- Set to `false` to remove a keymap
    -- See :help oil-actions for a list of all available actions
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-x>"] = "actions.select_vsplit",
      ["<C-s>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      -- ["<ESC>"] = "actions.close",
      ["<leader>q"] = "actions.close",
      ["<C-l>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["<BS>"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["."] = "actions.cd", -- set cwd
      ["~"] = "actions.tcd", -- set cwd for current tab only
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
      ["g\\"] = "actions.toggle_trash",
    },
    -- Set to false to disable all of the above keymaps
    use_default_keymaps = true,
    view_options = {
      -- Show files and directories that start with "."
      show_hidden = true,
      -- This function defines what is considered a "hidden" file
      ---@diagnostic disable-next-line:unused-local
      is_hidden_file = function(name, bufnr) return vim.startswith(name, ".") end,
      -- This function defines what will never be shown, even when `show_hidden` is set
      ---@diagnostic disable-next-line:unused-local
      is_always_hidden = function(name, bufnr) return name == ".." end,
      sort = {
        -- sort order can be "asc" or "desc"
        -- see :help oil-columns to see which columns are sortable
        { "type", "asc" },
        { "name", "asc" },
      },
    },
    -- Configuration for the floating window in oil.open_float
    float = {
      -- Padding around the floating window
      padding = 2,
      max_width = math.floor(vim.o.columns * 0.6),
      max_height = math.floor(vim.o.columns * 0.6),
      border = "single",
      win_options = {
        winblend = 0,
      },
      -- This is the config that will be passed to nvim_open_win.
      -- Change values here to customize the layout
      override = function(conf) return conf end,
    },
    -- Configuration for the actions floating preview window
    preview = {
      -- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
      -- min_width and max_width can be a single value or a list of mixed integer/float types.
      -- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
      max_width = 0.9,
      -- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
      min_width = { 40, 0.4 },
      -- optionally define an integer/float for the exact width of the preview window
      width = nil,
      -- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
      -- min_height and max_height can be a single value or a list of mixed integer/float types.
      -- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
      max_height = 0.9,
      -- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
      min_height = { 5, 0.1 },
      -- optionally define an integer/float for the exact height of the preview window
      height = nil,
      border = "single",
      win_options = {
        winblend = 0,
      },
    },
    -- Configuration for the floating progress window
    progress = {
      max_width = 0.9,
      min_width = { 40, 0.4 },
      width = nil,
      max_height = { 10, 0.9 },
      min_height = { 5, 0.1 },
      height = nil,
      border = "single",
      minimized_border = "none",
      win_options = {
        winblend = 0,
      },
    },
  },
}
