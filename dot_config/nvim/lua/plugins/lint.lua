return {
  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = { 'PhpStan' },
    config = function()
      local lint = require 'lint'

      local function project_phpstan(bufnr)
        local root = vim.fs.root(bufnr, { 'artisan', 'composer.json' })
        if not root then
          return
        end

        local executable = vim.fs.joinpath(root, 'vendor', 'bin', 'phpstan')
        if vim.fn.executable(executable) == 1 then
          return executable, root
        end
      end

      local function run_phpstan(bufnr)
        local _, root = project_phpstan(bufnr)
        if not root then
          return false
        end
        lint.try_lint('phpstan', { cwd = root })
        return true
      end

      -- nvim-lint defaults to the current working directory. Resolve the
      -- project-local executable instead so Larastan and old projects use the
      -- versions and extensions declared in their own composer.lock.
      lint.linters.phpstan.cmd = function()
        return project_phpstan(0) or 'phpstan'
      end

      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        php = { 'phpcs' },
      }

      vim.api.nvim_create_user_command('PhpStan', function()
        if vim.bo.filetype ~= 'php' then
          vim.notify('PHPStan is only available in PHP buffers', vim.log.levels.WARN)
          return
        end
        if not run_phpstan(0) then
          vim.notify('Project-local vendor/bin/phpstan was not found', vim.log.levels.WARN)
        end
      end, { desc = 'Run the project-local PHPStan/Larastan on this PHP file' })

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function(args)
          lint.try_lint()
          if args.event == 'BufWritePost' and vim.bo[args.buf].filetype == 'php' then
            run_phpstan(args.buf)
          end
        end,
      })
    end,
  },
}
