-- copied from LazyVim
local M = {}

---@return string
function M.norm(path)
  if path:sub(1, 1) == "~" then
    local home = vim.loop.os_homedir()
    if home == nil then
      return ""
    end
    if home:sub(-1) == "\\" or home:sub(-1) == "/" then
      home = home:sub(1, -2)
    end
    path = home .. path:sub(2)
  end
  path = path:gsub("\\", "/"):gsub("/+", "/")
  return path:sub(-1) == "/" and path:sub(1, -2) or path
end

M.spec = { "lsp", { ".git", "lua", ".nvim" }, "cwd" }

M.detectors = {}

function M.detectors.cwd()
  return { vim.loop.cwd() }
end

function M.detectors.lsp(buf)
  local bufpath = M.bufpath(buf)
  if not bufpath then
    return {}
  end
  local roots = {} ---@type string[]
  for _, client in pairs(vim.lsp.get_active_clients({ bufnr = buf })) do
    local workspace = client.config.workspace_folders
    for _, ws in pairs(workspace or {}) do
      roots[#roots + 1] = vim.uri_to_fname(ws.uri)
    end
    if client.config.root_dir then
      roots[#roots + 1] = client.config.root_dir
    end
  end
  return vim.tbl_filter(function(path)
    path = M.norm(path)
    return path and bufpath:find(path, 1, true) == 1
  end, roots)
end

---@param patterns string[]|string
function M.detectors.pattern(buf, patterns)
  patterns = type(patterns) == "string" and { patterns } or patterns
  local path = M.bufpath(buf) or vim.loop.cwd()
  local pattern = vim.fs.find(patterns, { path = path, upward = true })[1]
  return pattern and { vim.fs.dirname(pattern) } or {}
end

function M.bufpath(buf)
  return M.realpath(vim.api.nvim_buf_get_name(assert(buf)))
end

function M.realpath(path)
  if path == "" or path == nil then
    return nil
  end
  path = vim.loop.fs_realpath(path) or path
  return M.norm(path)
end

function M.resolve(spec)
  if M.detectors[spec] then
    return M.detectors[spec]
  elseif type(spec) == "function" then
    return spec
  end
  return function(buf)
    return M.detectors.pattern(buf, spec)
  end
end

function M.detect(opts)
  opts = opts or {}
  opts.spec = opts.spec or M.spec
  opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf

  local ret = {}
  for _, spec in ipairs(opts.spec) do
    local paths = M.resolve(spec)(opts.buf)
    paths = paths or {}
    paths = type(paths) == "table" and paths or { paths }
    local roots = {} ---@type string[]
    for _, p in ipairs(paths) do
      local pp = M.realpath(p)
      if pp and not vim.tbl_contains(roots, pp) then
        roots[#roots + 1] = pp
      end
    end
    table.sort(roots, function(a, b)
      return #a > #b
    end)
    if #roots > 0 then
      ret[#ret + 1] = { spec = spec, paths = roots }
      if opts.all == false then
        break
      end
    end
  end
  return ret
end

-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@return string|nil
function M.get()
  local roots = M.detect({ all = false })
  return roots[1] and roots[1].paths[1] or vim.loop.cwd()
end

M.pretty_cache = {} ---@type table<string, string>
function M.pretty_path()
  local path = vim.fn.expand("%:p") --[[@as string]]
  if path == "" then
    return ""
  end

  path = M.norm(path)
  if M.pretty_cache[path] then
    return M.pretty_cache[path]
  end
  local cache_key = path
  local cwd = M.realpath(vim.loop.cwd()) or ""

  if path:find(cwd, 1, true) == 1 then
    path = path:sub(#cwd + 2)
  else
    local roots = M.detect({ spec = { ".git" } })
    local root = roots[1] and roots[1].paths[1] or nil
    if root then
      path = path:sub(#vim.fs.dirname(root) + 2)
    end
  end

  local sep = package.config:sub(1, 1)
  local parts = vim.split(path, "[\\/]")
  if #parts > 3 then
    parts = { parts[1], "…", parts[#parts - 1], parts[#parts] }
  end
  local ret = table.concat(parts, sep)
  M.pretty_cache[cache_key] = ret
  return ret
end

return M
