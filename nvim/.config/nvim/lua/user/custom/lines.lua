local M = {}

local diagnostics_icons = require("user.utils").diagnostics_icons

local modes = {
  n = "Normal",
  i = "Insert",
  v = "Visual",
  V = "Visual",
  [""] = "Visual",
  [""] = "Visual",
  s = "Visual",
  S = "Visual",
  c = "Command",
  R = "Replace",
}

local function get_mode()
  local mode = vim.api.nvim_get_mode().mode
  local c = mode:sub(1, 1)
  return modes[c] or modes[mode] or "Other"
end

M.hl_str = function(hl, str)
  if hl and str and str ~= "" then
    return "%#" .. hl .. "#" .. str .. "%*"
  end
  return str or ""
end

M.mode_component = function()
  return M.hl_str("MiniStatuslineMode" .. get_mode(), " ")
end

M.filetype_component = function()
  if vim.bo.ft == "" then return "" end
  local buf = vim.api.nvim_get_current_buf()
  local ts = vim.treesitter.highlighter.active[buf]
  local hl = ts and not vim.tbl_isempty(ts) and "Grey" or "Red"
  return M.hl_str(hl, vim.bo.ft)
end

M.git_component = function()
  local dict = vim.b.gitsigns_status_dict
  if not dict then return "" end
  local parts = {}
  if vim.b.gitsigns_head then
    table.insert(parts, " " .. vim.b.gitsigns_head .. "  ")
  end
  if dict.added then
    table.insert(parts, M.hl_str("Green", "+" .. dict.added .. " "))
  end
  if dict.changed then
    table.insert(parts, M.hl_str("Blue", "~" .. dict.changed .. " "))
  end
  if dict.removed then
    table.insert(parts, M.hl_str("Red", "-" .. dict.removed))
  end
  return table.concat(parts)
end

M.mini_icon_component = function()
  ---@diagnostic disable-next-line:undefined-field
  if not _G.MiniIcons then return "" end
  ---@diagnostic disable-next-line:undefined-global
  local icon, hl, _ = MiniIcons.get("filetype", vim.bo.filetype)
  if not icon then return "" end
  return M.hl_str(hl or "Normal", icon)
end

M.filepath_component = function()
  local ok, pretty_path = pcall(require, "user.custom.root")
  if ok and pretty_path and pretty_path.pretty_path then
    return pretty_path.pretty_path()
  end
  return ""
end

M.diagnostics_component = function()
  local diagnostics = vim.diagnostic.count()
  local sev = vim.diagnostic.severity
  local out = {}
  if diagnostics[sev.ERROR] then
    table.insert(out, M.hl_str("DiagnosticError", diagnostics_icons.Error .. diagnostics[sev.ERROR] .. " "))
  end
  if diagnostics[sev.WARN] then
    table.insert(out, M.hl_str("DiagnosticWarn", diagnostics_icons.Warn .. diagnostics[sev.WARN] .. " "))
  end
  if diagnostics[sev.INFO] then
    table.insert(out, M.hl_str("DiagnosticInfo", diagnostics_icons.Info .. diagnostics[sev.INFO] .. " "))
  end
  if diagnostics[sev.HINT] then
    table.insert(out, M.hl_str("DiagnosticHint", diagnostics_icons.Hint .. diagnostics[sev.HINT]))
  end
  return table.concat(out)
end

M.position_component = function()
  return M.hl_str("Grey", "%l:%c")
end

M.file_percent_component = function()
  return M.hl_str("Grey", "%P")
end

M.indent_component = function()
  if vim.bo.expandtab then
    return M.hl_str("Grey", "Spaces:" .. vim.bo.shiftwidth)
  else
    return M.hl_str("Grey", "Tab:" .. vim.bo.tabstop)
  end
end

M.fileformat_component = function()
  local formats = {
    dos = "CRLF",
    unix = "LF",
    mac = "CR"
  }
  if vim.bo.fileformat then
    return M.hl_str("Grey", formats[vim.bo.fileformat])
  end
  return ""
end

local file_state = {
  modified = "",
  close = "",
}

-- Buffer info for a given bufnr
local function buffer_info(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  local ft = vim.bo[bufnr].ft
  local icon, iconhl = "", ""

  local alternate_buffer = vim.fn.expand("#") == name

  ---@diagnostic disable-next-line:undefined-field
  if _G.MiniIcons then
    if ft and ft ~= "" then
      ---@diagnostic disable-next-line:undefined-global
      icon, iconhl = MiniIcons.get("filetype", ft)
    else
      local ext = name:match("%.([^%.]+)$")
      if ext then
        ---@diagnostic disable-next-line:undefined-global
        icon, iconhl = MiniIcons.get("file", name)
      end
    end
  end

  local full_path = vim.fn.fnamemodify(name, ":p")

  if name == "" then
    name = "[No Name]"
  else
    local ok, pretty_path = pcall(require, "user.custom.root")
    if ok and pretty_path and pretty_path.pretty_path then
      name = pretty_path.pretty_path(bufnr)
    end
    name = vim.fn.pathshorten(name)
  end

  return {
    name = name,
    icon = icon,
    iconhl = iconhl,
    modified = vim.bo[bufnr].modified,
    alternate = alternate_buffer,
    active = bufnr == vim.api.nvim_get_current_buf(),
    bufnr = bufnr,
    full_path = full_path,
  }
end

-- Singular buffers component (renders all buffer tabs)
function M.buffers_component()
  local result = ""
  local buffers = vim.api.nvim_list_bufs()
  local ignore_ft = {
    qf = true,
  }
  for _, bufnr in ipairs(buffers) do
    if vim.bo[bufnr].buflisted and not ignore_ft[vim.bo[bufnr].filetype] then
      local info = buffer_info(bufnr)
      local tab_hl = "MiniTabLine" .. (info.active and "Current" or "Visible")
      local entry = M.hl_str(tab_hl, " " .. info.bufnr .. (info.alternate and "#" or ""))

      if info.icon and info.icon ~= "" then
        local new_icon_hl_name = info.iconhl .. tab_hl
        local new_icon_hl = vim.api.nvim_get_hl(0, { name = new_icon_hl_name, link = false, create = false })

        if not new_icon_hl or vim.tbl_isempty(new_icon_hl) then
          local tab_hl_d = vim.api.nvim_get_hl(0, { name = tab_hl })
          local icon_hl_d = vim.api.nvim_get_hl(0, { name = info.iconhl })

          vim.api.nvim_set_hl(0, new_icon_hl_name, {
            fg = icon_hl_d and icon_hl_d.fg or nil,
            bg = tab_hl_d and tab_hl_d.bg or nil,
            sp = tab_hl_d and tab_hl_d.sp or nil,
            blend = 100,
          })
        end

        entry = entry .. M.hl_str(new_icon_hl_name, " " .. info.icon)
      end

      entry = entry .. M.hl_str(tab_hl, " " .. info.name)

      if info.modified then
        entry = entry .. M.hl_str(tab_hl, " " .. file_state.modified .. " ")
      else
        entry = entry .. M.hl_str(tab_hl, " " .. file_state.close .. " ")
      end

      result = result .. ("%" .. info.bufnr .. "@v:lua.TabLineSelectBuffer@" .. entry .. "%X")
    end
  end
  return result
end

function M.modified_buffers_component()
  local result = ""
  local buffers = vim.api.nvim_list_bufs()
  local ignore_ft = {
    qf = true,
  }
  for _, bufnr in ipairs(buffers) do
    if vim.bo[bufnr].buflisted and not ignore_ft[vim.bo[bufnr].filetype] then
      local info = buffer_info(bufnr)
      if not info.modified then
        goto continue
      end
      local tab_hl = "MiniTabLine" .. (info.active and "Current" or "Visible")
      local entry = M.hl_str(tab_hl, " " .. info.bufnr .. (info.alternate and "#" or ""))

      if info.icon and info.icon ~= "" then
        local new_icon_hl_name = info.iconhl .. tab_hl
        local new_icon_hl = vim.api.nvim_get_hl(0, { name = new_icon_hl_name, link = false, create = false })

        if not new_icon_hl or vim.tbl_isempty(new_icon_hl) then
          local tab_hl_d = vim.api.nvim_get_hl(0, { name = tab_hl })
          local icon_hl_d = vim.api.nvim_get_hl(0, { name = info.iconhl })

          vim.api.nvim_set_hl(0, new_icon_hl_name, {
            fg = icon_hl_d and icon_hl_d.fg or nil,
            bg = tab_hl_d and tab_hl_d.bg or nil,
            sp = tab_hl_d and tab_hl_d.sp or nil,
            blend = 100,
          })
        end

        entry = entry .. M.hl_str(new_icon_hl_name, " " .. info.icon)
      end

      entry = entry .. M.hl_str(tab_hl, " " .. info.name)

      if info.modified then
        entry = entry .. M.hl_str(tab_hl, " " .. file_state.modified .. " ")
      else
        entry = entry .. M.hl_str(tab_hl, " " .. file_state.close .. " ")
      end

      result = result .. ("%" .. info.bufnr .. "@v:lua.TabLineSelectBuffer@" .. entry .. "%X")
      ::continue::
    end
  end
  return result
end

-- Fill component (for spacing between buffers and tabs)
function M.fill_component()
  return M.hl_str("TabLineFill", "%=")
end

-- Singular tabs component (renders all tabs)
function M.tabs_component()
  local result = ""
  local tabs = vim.api.nvim_list_tabpages()
  for i, _ in ipairs(tabs) do
    local current = i == vim.fn.tabpagenr()
    local hl = current and "TabLineSel" or "TabLine"
    local entry = M.hl_str(hl, " " .. i .. " ")
    result = result .. (" %" .. i .. "@v:lua.TabLineSelectTab@" .. entry .. "%X")
  end
  return result
end

function TabLineSelectBuffer(bufnr)
  vim.api.nvim_set_current_buf(bufnr)
end

function TabLineSelectTab(tabnr)
  vim.cmd("tabnext " .. tabnr)
end

function M.arglist_buffers_component()
  local result = ""
  local arg_list_raw = vim.fn.argv()
  local current_arg_idx = vim.fn.argidx() -- 0-indexed index of the current arglist entry
  assert(type(arg_list_raw) == "table", "Expected arg_list_raw to be a table")

  for i, arg_path in ipairs(arg_list_raw) do
    local arg_path_idx = i - 1                    -- Convert to 0-indexed for comparison
    local root = require("user.custom.root").get()
    arg_path = vim.fn.fnamemodify(arg_path, ":p") -- Get the absolute path
    if (arg_path:find(root[1], 1, true) == 1) then
      arg_path = arg_path:sub(#root[1] + 2)       -- Remove the root path prefix
    end
    arg_path = vim.fn.pathshorten(arg_path)
    local tab_hl = arg_path_idx == current_arg_idx and "Yellow" or "Grey"
    local icon ,iconhl
    ---@diagnostic disable-next-line:undefined-field
    if _G.MiniIcons then
      ---@diagnostic disable-next-line:undefined-global
      icon, iconhl = MiniIcons.get("file", arg_path)
    end
    if icon and icon ~= "" then
        local new_icon_hl_name = iconhl .. tab_hl
        local new_icon_hl = vim.api.nvim_get_hl(0, { name = new_icon_hl_name, link = false, create = false })

        if not new_icon_hl or vim.tbl_isempty(new_icon_hl) then
          local tab_hl_d = vim.api.nvim_get_hl(0, { name = tab_hl })
          local icon_hl_d = vim.api.nvim_get_hl(0, { name = iconhl })

          vim.api.nvim_set_hl(0, new_icon_hl_name, {
            fg = icon_hl_d and icon_hl_d.fg or nil,
            bg = tab_hl_d and tab_hl_d.bg or nil,
            sp = tab_hl_d and tab_hl_d.sp or nil,
            blend = 100,
          })
        end

        result = result .. M.hl_str(new_icon_hl_name, " " .. icon)
      end

    result = result .. M.hl_str(tab_hl, " " .. arg_path .. " ")
  end
  return result
end

M.ai_component = function()
  local ok, avante_config = pcall(require, "avante.config")
  if not ok then return end
  local provider = avante_config.provider
  return provider .. ": " .. avante_config.providers[provider].model
end

local pad = " "

M.opts = {
  statusline = {
    M.mode_component,
    pad,
    M.filetype_component,
    pad,
    M.git_component,
    "%=",
    pad,
    M.mini_icon_component,
    pad,
    M.filepath_component,
    ":",
    M.position_component,
    "%q",
    pad,
    "%=",
    M.diagnostics_component,
    pad,
    M.file_percent_component,
    pad,
    M.indent_component,
    pad,
    M.fileformat_component,
    pad,
    M.mode_component,
  },
  tabline = {
    -- M.modified_arglist_buffers_component,
    -- pad,
    M.modified_buffers_component,
    -- "%=",
    M.arglist_buffers_component,
    M.fill_component,
    M.ai_component,
    M.tabs_component,
  },
}

M.setup = function(opts)
  opts = opts or {}
  M.opts.statusline = opts.statusline or M.opts.statusline
  M.opts.tabline = opts.tabline or M.opts.tabline
  vim.opt.statusline = "%!v:lua.require('user.custom.lines').statusline()"
  vim.opt.tabline = "%!v:lua.require('user.custom.lines').tabline()"
end

M.build_line = function(components)
  local result = ""
  for _, item in ipairs(components) do
    local content = ""
    if type(item) == "function" then
      content = item()
    else
      content = item
    end
    result = result .. (content or "")
  end
  return result
end

M.statusline = function() return M.build_line(M.opts.statusline) end
M.tabline = function() return M.build_line(M.opts.tabline) end

return M
