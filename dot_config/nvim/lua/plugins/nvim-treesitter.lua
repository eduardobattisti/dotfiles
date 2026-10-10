-- nvim-treesitter `main` branch: the plugin only installs parsers and ships
-- queries. Highlighting, indentation and text objects are enabled explicitly
-- below. Requires Neovim 0.12+, a C compiler, curl, tar and the tree-sitter
-- CLI (installed through Mason when it is not already in PATH).
local ensure_installed = {
  'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'vim', 'vimdoc',
  -- Frontend & web
  'javascript', 'typescript', 'tsx', 'json', 'yaml', 'css', 'scss', 'vue', 'graphql', 'dockerfile',
  -- Backend
  'php', 'php_only', 'blade', 'go',
}

-- Filetypes that keep Vim's regex syntax next to Tree-sitter highlighting and
-- use the built-in indentation instead of Tree-sitter's.
local regex_syntax_filetypes = { ruby = true }

local function has_cli()
  return vim.fn.executable 'tree-sitter' == 1
end

-- Install the tree-sitter CLI through Mason, then run `callback`.
local function ensure_cli(callback)
  if has_cli() then
    return callback()
  end
  local ok, registry = pcall(require, 'mason-registry')
  if not ok then
    return vim.notify('nvim-treesitter: the tree-sitter CLI is missing and Mason is unavailable', vim.log.levels.WARN)
  end
  registry.refresh(vim.schedule_wrap(function()
    local found, pkg = pcall(registry.get_package, 'tree-sitter-cli')
    if not found then
      return vim.notify('nvim-treesitter: install the tree-sitter CLI to build parsers', vim.log.levels.WARN)
    end
    registry:on(
      'package:install:success',
      vim.schedule_wrap(function(installed)
        if installed.name == 'tree-sitter-cli' and has_cli() then
          callback()
        end
      end)
    )
    if not pkg:is_installed() and not (pkg.is_installing and pkg:is_installing()) then
      pkg:install()
    end
  end))
end

local function start(buf, filetype, lang)
  if not vim.api.nvim_buf_is_valid(buf) or not pcall(vim.treesitter.start, buf, lang) then
    return
  end
  if regex_syntax_filetypes[filetype] then
    vim.bo[buf].syntax = 'on'
  elseif vim.treesitter.query.get(lang, 'indents') then
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false, -- the main branch does not support lazy-loading
    build = ':TSUpdate',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      vim.filetype.add {
        extension = {
          stylus = 'css',
          postcss = 'sass',
          pcss = 'sass',
        },
        pattern = {
          ['.*%.blade%.php'] = 'blade',
        },
      }

      local treesitter = require 'nvim-treesitter'
      treesitter.setup()

      -- Already installed parsers are skipped, so this is cheap at startup.
      ensure_cli(function()
        treesitter.install(ensure_installed)
      end)

      local installing = {}
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
        desc = 'Start Tree-sitter, installing a missing parser on first use',
        callback = function(args)
          local buf, filetype = args.buf, args.match
          local lang = vim.treesitter.language.get_lang(filetype)
          if not lang then
            return
          end
          if vim.treesitter.language.add(lang) then
            return start(buf, filetype, lang)
          end
          if installing[lang] or not has_cli() or not vim.list_contains(treesitter.get_available(), lang) then
            return
          end
          installing[lang] = true
          treesitter.install(lang):await(vim.schedule_wrap(function()
            installing[lang] = nil
            if vim.treesitter.language.add(lang) then
              start(buf, filetype, lang)
            end
          end))
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = { lookahead = true },
        move = { set_jumps = true },
      }

      local function map(modes, lhs, module, fn, query, desc)
        vim.keymap.set(modes, lhs, function()
          require('nvim-treesitter-textobjects.' .. module)[fn](query, 'textobjects')
        end, { desc = desc })
      end

      for lhs, spec in pairs {
        af = { '@function.outer', 'Select around function' },
        ['if'] = { '@function.inner', 'Select inside function' },
        ac = { '@class.outer', 'Select around class' },
        ic = { '@class.inner', 'Select inside class' },
        aa = { '@parameter.outer', 'Select around argument' },
        ia = { '@parameter.inner', 'Select inside argument' },
        ai = { '@conditional.outer', 'Select around conditional' },
        ii = { '@conditional.inner', 'Select inside conditional' },
        al = { '@loop.outer', 'Select around loop' },
        il = { '@loop.inner', 'Select inside loop' },
      } do
        map({ 'x', 'o' }, lhs, 'select', 'select_textobject', spec[1], spec[2])
      end

      for lhs, spec in pairs {
        [']f'] = { 'goto_next_start', '@function.outer', 'Next function start' },
        [']c'] = { 'goto_next_start', '@class.outer', 'Next class start' },
        [']a'] = { 'goto_next_start', '@parameter.inner', 'Next argument' },
        [']F'] = { 'goto_next_end', '@function.outer', 'Next function end' },
        [']C'] = { 'goto_next_end', '@class.outer', 'Next class end' },
        ['[f'] = { 'goto_previous_start', '@function.outer', 'Previous function start' },
        ['[c'] = { 'goto_previous_start', '@class.outer', 'Previous class start' },
        ['[a'] = { 'goto_previous_start', '@parameter.inner', 'Previous argument' },
        ['[F'] = { 'goto_previous_end', '@function.outer', 'Previous function end' },
        ['[C'] = { 'goto_previous_end', '@class.outer', 'Previous class end' },
      } do
        map({ 'n', 'x', 'o' }, lhs, 'move', spec[1], spec[2], spec[3])
      end

      map('n', '<leader>csa', 'swap', 'swap_next', '@parameter.inner', 'Swap with next argument')
      map('n', '<leader>csA', 'swap', 'swap_previous', '@parameter.inner', 'Swap with previous argument')
    end,
  },
}
