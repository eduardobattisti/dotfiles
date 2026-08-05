local root_dir = function(pattern)
  local cwd = vim.loop.cwd()
  local util = require 'lspconfig.util'
  local root = util.root_pattern('composer.json', '.git', 'wp-config.php')(pattern)

  if root and util.path.is_descendant(cwd, root) then
    return cwd
  end
  return root or ''
end

local M = {}

local filetypes = { 'php', 'blade', 'php_only' }

local settings = {
  files = {
    maxSize = 10000000, -- 10MB
  },
  stubs = { "bcmath", "bz2", "Core", "curl", "date", "dom", "fileinfo", "filter", "gd", "gettext", "hash", "iconv", "imap", "intl", "json", "libxml", "mbstring", "mcrypt", "mysql", "mysqli", "password", "pcntl", "pcre", "PDO", "pdo_mysql", "Phar", "readline", "regex", "session", "SimpleXML", "sockets", "sodium", "standard", "superglobals", "tokenizer", "xml", "xdebug", "xmlreader", "xmlwriter", "yaml", "zip", "zlib", "wordpress", "wordpress-stubs", "woocommerce-stubs", "acf-pro-stubs", "wordpress-globals", "wp-cli-stubs", "genesis-stubs", "polylang-stubs" },
  environment = {
    includePaths = {
      root_dir() .. '/vendor/php-stubs/',
    },
  },
}

M.settings = settings
M.filetypes = filetypes
M.get_language_id = function(_, filetype)
  -- Intelephense only understands PHP language IDs. Keep the Blade filetype
  -- for Tree-sitter while presenting mixed Blade templates as PHP to the LSP.
  return filetype == 'blade' and 'php' or filetype
end

return M
