-- "heavily" inspired by LazyVim
local M = {}

M.detectors = {} ---@type table<string, function>

M.spec = { { ".nvim" }, "lsp", { ".git", "lua" }, "cwd" } ---@type table<string|string[]>

M.bufpath = function(buf) return vim.uv.fs_realpath(vim.api.nvim_buf_get_name(buf)) end

---@param buf integer
---@return string[]
M.detectors.lsp = function(buf)
  local bufpath = M.bufpath(buf)
  if not bufpath then return {} end
  local roots = {}
  for _, client in pairs(vim.lsp.get_clients({ bufnr = buf })) do
    local workspace = client.config.workspace_folders or {}
    for _, ws in pairs(workspace) do
      roots[#roots + 1] = vim.uri_to_fname(ws.uri)
    end
    if client.root_dir and client.root_dir ~= "" then roots[#roots + 1] = client.root_dir end
  end
  -- return roots
  return vim.tbl_filter(function(path)
    path = vim.fs.normalize(path)
    return path and bufpath:find(path, 1, true) == 1
  end, roots)
end

---@param buf integer
---@param patterns string[]
---@return string[]
M.detectors.pattern = function(buf, patterns)
  local roots = {}
  local bufpath = M.bufpath(buf)
  if not bufpath then bufpath = vim.uv.cwd() end
  assert(bufpath)
  for _, pattern in pairs(patterns) do
    local path = vim.fs.root(bufpath, pattern)
    if path then roots[#roots + 1] = path end
  end
  return roots
end

---@return string[]
M.detectors.cwd = function(_) return { vim.uv.cwd() } end

--- @param buf integer|nil
--- @param all boolean|nil
---@return string[]
M.get = function(all, buf)
  buf = buf or 0
  all = all or false
  local roots = {}
  for _, spec in pairs(M.spec) do
    if type(spec) == "table" then
      vim.list_extend(roots, M.detectors.pattern(buf, spec))
    else
      vim.list_extend(roots, M.detectors[spec](buf))
    end
    if all == false and #roots > 1 then break end
  end
  local paths = roots
  roots = {}
  for _, path in pairs(paths) do
    if not vim.list_contains(roots, path) then roots[#roots + 1] = path end
  end
  return roots
end

---@param buf integer|nil
---@return string
M.pretty_path = function(buf)
  buf = buf or 0
  local bufpath = M.bufpath(buf)
  -- assert(bufpath)
  if not bufpath then return "" end
  local root = M.get(false, buf)[1]
  assert(bufpath:find(root, 1, true) == 1)
  return bufpath:sub(#root + 2)
end

return M
