root_dir = function(pattern)
  local cwd = vim.loop.cwd()
  local util = require 'lspconfig.util'
  local root = util.root_pattern('composer.json', '.git', 'wp-config.php')(pattern)

  return util.path.is_descendant(cwd, root) and cwd or root or '';
end

local M = {}

local filetypes = { 'php', 'blade', 'php_only' }

local settings = {
  files = {
    maxSize = 10000000, -- 10MB
  },
  stubs = {"bcmath", "bz2", "Core", "curl", "date", "dom", "fileinfo", "filter", "gd", "gettext", "hash", "iconv", "imap", "intl", "json", "libxml", "mbstring", "mcrypt", "mysql", "mysqli", "password", "pcntl", "pcre", "PDO", "pdo_mysql", "Phar", "readline", "regex", "session", "SimpleXML", "sockets", "sodium", "standard", "superglobals", "tokenizer", "xml", "xdebug", "xmlreader", "xmlwriter", "yaml", "zip", "zlib", "wordpress", "wordpress-stubs", "woocommerce-stubs", "acf-pro-stubs", "wordpress-globals", "wp-cli-stubs", "genesis-stubs", "polylang-stubs"},
  environment = {
    includePaths = {
      root_dir() .. '/vendor/php-stubs/',
    },
  },
}

M.settings = settings
M.filetypes = filetypes

return M
