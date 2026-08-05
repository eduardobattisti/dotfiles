return {
  {
    'adalessa/laravel.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-neotest/nvim-nio',
    },
    ft = { 'php', 'blade' },
    event = { 'BufEnter composer.json' },
    keys = {
      { '<leader>Ll', function() Laravel.pickers.laravel() end, desc = 'Laravel: Picker' },
      { '<leader>La', function() Laravel.pickers.artisan() end, desc = 'Laravel: Artisan' },
      { '<leader>Lr', function() Laravel.pickers.routes() end, desc = 'Laravel: Routes' },
      { '<leader>Lm', function() Laravel.pickers.make() end, desc = 'Laravel: Make' },
      { '<leader>Lc', function() Laravel.pickers.commands() end, desc = 'Laravel: Commands' },
      { '<leader>Lo', function() Laravel.pickers.resources() end, desc = 'Laravel: Resources' },
      { '<leader>Lt', function() Laravel.commands.run 'actions' end, desc = 'Laravel: Code actions' },
      { '<leader>Lu', function() Laravel.commands.run 'hub' end, desc = 'Laravel: Artisan Hub' },
      { '<leader>Lp', function() Laravel.commands.run 'command_center' end, desc = 'Laravel: Command center' },
      { '<leader>Lh', function() Laravel.run 'artisan docs' end, desc = 'Laravel: Documentation' },
      { '<leader>Lv', function() Laravel.commands.run 'view:finder' end, desc = 'Laravel: View finder' },
    },
    opts = {
      features = {
        pickers = {
          provider = 'telescope',
        },
      },
      -- Generates typed Eloquent helpers under vendor/ so Intelephense can
      -- understand model/query-builder chains that Laravel creates at runtime.
      eloquent_generate_doc_blocks = true,
    },
  },
  {
    'ricardoramirezr/blade-nav.nvim',
    ft = { 'blade', 'php' },
    dependencies = { 'hrsh7th/nvim-cmp' },
    opts = {
      annotations = {
        -- K is owned by config.blade_hover so directives, projected PHP and
        -- BladeNav's resolved config/env/translation values share one popup.
        create_keymaps = false,
      },
    },
  },
  {
    'jmbuhr/otter.nvim',
    ft = 'blade',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      local otter = require 'otter'

      otter.setup {
        lsp = {
          root_dir = function(_, bufnr)
            return vim.fs.root(bufnr or 0, { 'artisan', 'composer.json', '.git' }) or vim.fn.getcwd(0)
          end,
        },
        buffers = {
          set_filetype = true,
          write_to_disk = false,
          -- Intelephense only parses PHP after an opening tag. This occupies
          -- the first otherwise-empty line of the synchronized projection.
          preambles = { php_only = { '<?php' } },
        },
        -- The Blade parser names injected PHP regions `php_only`; use a .php
        -- virtual filename so PHP language servers recognize the projection.
        extensions = { php_only = 'php' },
        verbose = { no_code_found = false },
      }

      -- Otter targets line-oriented code blocks and currently writes an inline
      -- Tree-sitter capture at column zero. Blade embeds PHP midway through a
      -- line, so preserve that starting column for correct LSP coordinates.
      -- A first-line capture also needs its own PHP opening tag because it
      -- overwrites the projection preamble.
      local keeper = require 'otter.keeper'
      if not keeper.blade_inline_columns then
        local extract_code_chunks = keeper.extract_code_chunks
        keeper.extract_code_chunks = function(...)
          local chunks_by_language = extract_code_chunks(...)
          for _, chunk in ipairs(chunks_by_language.php_only or {}) do
            local row, column = chunk.range.from[1], chunk.range.from[2]
            -- Captured Blade expressions do not include PHP statement
            -- terminators; add one so adjacent projected regions still parse.
            local last_line = #chunk.text
            if chunk.text[last_line] and not chunk.text[last_line]:match '[;{}]%s*$' then
              chunk.text[last_line] = chunk.text[last_line] .. ';'
            end
            if row == 0 then
              local shift = math.max(0, 6 - column)
              chunk.text[1] = '<?php ' .. string.rep(' ', math.max(0, column - 6)) .. chunk.text[1]
              for index = 2, #chunk.text do
                chunk.text[index] = string.rep(' ', shift) .. chunk.text[index]
              end
              chunk.leading_offset = column - 6
            elseif column > 0 then
              chunk.text[1] = string.rep(' ', column) .. chunk.text[1]
              chunk.leading_offset = 0
            end
          end
          return chunks_by_language
        end
        keeper.blade_inline_columns = true
      end

      local function activate_php()
        if vim.bo.filetype == 'blade' then
          -- Completion/hover/navigation are useful; projected diagnostics are
          -- intentionally off because Laravel LSP diagnoses the source buffer.
          otter.activate({ 'php_only' }, true, false)
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('blade-otter', { clear = true }),
        pattern = 'blade',
        callback = activate_php,
      })

      -- lazy.nvim loads this spec in response to FileType, after that event
      -- has already fired for the first Blade buffer.
      vim.schedule(activate_php)
    end,
  },
}
