local function prettier_unless_eslint(bufnr)
  if #vim.lsp.get_clients { bufnr = bufnr, name = 'eslint' } > 0 then
    return {}
  end
  return { 'prettierd', 'prettier', stop_after_first = true }
end

local function find_prettier_blade_root(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local directory = filename ~= '' and vim.fs.dirname(filename) or vim.fn.getcwd(0)

  while directory do
    local prettier = vim.fs.joinpath(directory, 'node_modules', '.bin', 'prettier')
    local blade_plugin = vim.fs.joinpath(directory, 'node_modules', 'prettier-plugin-blade')
    if vim.fn.executable(prettier) == 1 and vim.uv.fs_stat(blade_plugin) then
      return directory
    end

    local parent = vim.fs.dirname(directory)
    if not parent or parent == directory then
      break
    end
    directory = parent
  end
end

local function blade_formatter(bufnr)
  if find_prettier_blade_root(bufnr) then
    return { 'prettier_blade' }
  end
  return { 'blade-formatter' }
end

return { -- Formatting
  'stevearc/conform.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  cmd = { 'ConformInfo', 'Format' },
  keys = {
    {
      '<leader>bf',
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
      mode = '',
      desc = '[B]uffer format',
    },
  },
  config = function(_, opts)
    local conform = require 'conform'
    conform.setup(opts)
    vim.api.nvim_create_user_command('Format', function()
      conform.format { async = true, lsp_fallback = true }
    end, { desc = 'Format the current buffer' })
  end,
  opts = {
    notify_on_error = false,
    formatters_by_ft = {
      lua = { 'stylua' },
      -- Prefer the Laravel project's own Pint rules, falling back to PHPCBF
      -- for PHP projects that do not provide vendor/bin/pint.
      php = { 'pint', 'phpcbf', stop_after_first = true },
      blade = blade_formatter,
      javascript = prettier_unless_eslint,
      typescript = prettier_unless_eslint,
      javascriptreact = prettier_unless_eslint,
      typescriptreact = prettier_unless_eslint,
      vue = prettier_unless_eslint,
      json = { 'prettierd', 'prettier', stop_after_first = true },
      jsonc = { 'prettierd', 'prettier', stop_after_first = true },
      html = { 'prettierd', 'prettier', stop_after_first = true },
      css = { 'prettierd', 'prettier', stop_after_first = true },
      scss = { 'prettierd', 'prettier', stop_after_first = true },
      yaml = { 'prettierd', 'prettier', stop_after_first = true },
      markdown = { 'prettierd', 'prettier', stop_after_first = true },
    },
    formatters = {
      prettier_blade = {
        command = function(_, ctx)
          local root = find_prettier_blade_root(ctx.buf)
          return root and vim.fs.joinpath(root, 'node_modules', '.bin', 'prettier') or 'prettier'
        end,
        args = { '--stdin-filepath', '$FILENAME', '--plugin=prettier-plugin-blade' },
        cwd = function(_, ctx)
          return find_prettier_blade_root(ctx.buf)
        end,
        stdin = true,
      },
    },
  },
}
