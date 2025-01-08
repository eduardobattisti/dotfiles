local M = {}

local filetypes = { 'php', 'blade', 'php_only' }

local settings = {
  filetypes = { 'php', 'blade', 'php_only' },
  files = {
    associations = { '*.php', '*.blade.php' },
    maxSize = 5000000,
  },
}

M.settings = settings
M.filetypes = filetypes

return M
