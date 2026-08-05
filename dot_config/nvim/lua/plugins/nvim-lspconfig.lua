return {
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for Neovim
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },

    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    { 'folke/lazydev.nvim', ft = 'lua', opts = {} },

    -- JSON/YAML schema catalogue for jsonls/yamlls
    'b0o/schemastore.nvim',
  },

  config = function()
    -- Setup autocmd for LSP attach events (keymappings, highlighting, etc.)
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local lsp_utils = require 'config.lsp.utils'

        lsp_utils.keymap('gd', require('telescope.builtin').lsp_definitions, event.buf, '[G]oto [D]efinition')
        lsp_utils.keymap('gr', require('telescope.builtin').lsp_references, event.buf, '[G]oto [R]eferences')
        lsp_utils.keymap('gI', require('telescope.builtin').lsp_implementations, event.buf, '[G]oto [I]mplementation')
        lsp_utils.keymap('<leader>lD', require('telescope.builtin').lsp_type_definitions, event.buf, 'Type [D]efinition')
        lsp_utils.keymap('<leader>lds', require('telescope.builtin').lsp_document_symbols, event.buf, '[D]ocument [S]ymbols')
        lsp_utils.keymap('<leader>lws', require('telescope.builtin').lsp_dynamic_workspace_symbols, event.buf, '[W]orkspace [S]ymbols')
        lsp_utils.keymap('<leader>lr', vim.lsp.buf.rename, event.buf, '[R]ename')
        lsp_utils.keymap('<leader>la', vim.lsp.buf.code_action, event.buf, '[C]ode [A]ction')
        lsp_utils.keymap('gD', vim.lsp.buf.declaration, event.buf, '[G]oto [D]eclaration')
        lsp_utils.keymap('K', require('config.blade_hover').hover, event.buf, 'Hover Documentation')
        lsp_utils.keymap('<leader>lk', vim.lsp.buf.signature_help, event.buf, 'Signature Help')

        -- LSP status check for debugging
        lsp_utils.keymap('<leader>li', '<cmd>checkhealth vim.lsp<cr>', event.buf, 'LSP [I]nfo')
        lsp_utils.keymap('<leader>ls', function()
          local clients = vim.lsp.get_clients { bufnr = event.buf }
          if #clients == 0 then
            print 'No LSP clients attached to this buffer'
          else
            for _, client in ipairs(clients) do
              print('LSP client: ' .. client.name .. ' (id: ' .. client.id .. ')')
            end
          end
        end, event.buf, 'LSP [S]tatus')

        -- Vue LSP diagnostic command
        lsp_utils.keymap('<leader>lv', function()
          local clients = vim.lsp.get_clients { bufnr = event.buf }
          local vue_clients = {}
          for _, client in ipairs(clients) do
            if client.name == 'vue_ls' or client.name == 'vtsls' then
              table.insert(vue_clients, client.name)
            end
          end
          if #vue_clients == 0 then
            print 'No Vue LSP clients attached'
          else
            print('Vue LSP clients: ' .. table.concat(vue_clients, ', '))
            -- Test hover capability
            if vim.bo.filetype == 'vue' then
              vim.lsp.buf.hover()
            end
          end
        end, event.buf, 'Vue LSP [D]iagnostic')

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })

          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = function()
              vim.lsp.buf.document_highlight()
            end,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- The following autocommand is used to enable inlay hints in your
        -- code, if the language server you are using supports them
        --
        -- This may be unwanted, since they displace some of your code
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) and vim.lsp.inlay_hint then
          lsp_utils.keymap('<leader>lth', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, event.buf, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- Ensure the servers and tools are installed
    require('mason').setup()

    -- You can add other tools here that you want Mason to install
    -- for you, so that they are available from within Neovim.
    local ensure_installed = {
      'phpcbf',
      'phpcs',
      'markdownlint',
      'php-debug-adapter',
      'blade-formatter',
      'prettierd',
      'stylua',
      'cssls',
      'css_variables',
      'html',
      'emmet_ls',
      'intelephense',
      'vue_ls',
      'vtsls',
      'tailwindcss',
      'jsonls',
      'yamlls',
    }

    -- Install tools with mason-tool-installer
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    -- Ensure hover capability is enabled
    capabilities.textDocument.hover = {
      dynamicRegistration = false,
      contentFormat = { 'markdown', 'plaintext' },
    }

    local handlers = {}

    require('mason-lspconfig').setup {
      ensure_installed = {
        'cssls',
        'css_variables',
        'emmet_ls',
        'eslint',
        'html',
        'intelephense',
        'vue_ls',
        'vtsls',
        'tailwindcss',
        'jsonls',
        'yamlls',
      },
      automatic_enable = {
        -- laravel_ls is the old community server. Laravel's official LSP is
        -- installed with Composer and enabled explicitly below.
        exclude = { 'ts_ls', 'laravel_ls' },
      },
    }

    local default_config = {
      capabilities = capabilities,
      handlers = handlers,
    }

    vim.lsp.config(
      'html',
      vim.tbl_deep_extend('force', default_config, {
        filetypes = { 'html', 'blade' },
        get_language_id = function(_, filetype)
          return filetype == 'blade' and 'html' or filetype
        end,
        on_attach = function(client, bufnr)
          local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
          if filetype == 'vue' then
            client.stop()
          end
        end,
      })
    )

    local base_eslint_on_attach = vim.lsp.config.eslint and vim.lsp.config.eslint.on_attach
    local eslint_fix_group = vim.api.nvim_create_augroup('eslint-fix-on-save', { clear = true })

    vim.lsp.config(
      'eslint',
      vim.tbl_deep_extend('force', default_config, {
        on_attach = function(client, bufnr)
          if base_eslint_on_attach then
            base_eslint_on_attach(client, bufnr)
          end
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = eslint_fix_group,
            buffer = bufnr,
            command = 'LspEslintFixAll',
          })
        end,
      })
    )

    vim.lsp.config('cssls', default_config)

    vim.lsp.config('css_variables', default_config)

    vim.lsp.config('emmet_ls', vim.tbl_deep_extend('force', default_config, {
      -- Keep Emmet out of plain JS/TS so it doesn't suggest tag snippets in server-side code.
      filetypes = { 'html', 'css', 'scss', 'javascriptreact', 'typescriptreact', 'vue', 'blade' },
    }))

    vim.lsp.config('tailwindcss', {
      capabilities = require('config.lsp.servers.tailwindcss').capabilities,
      handlers = handlers,
      filetypes = require('config.lsp.servers.tailwindcss').filetypes,
      on_attach = require('config.lsp.servers.tailwindcss').on_attach,
      settings = require('config.lsp.servers.tailwindcss').settings,
    })

    vim.lsp.config(
      'jsonls',
      vim.tbl_deep_extend('force', default_config, {
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
        },
      })
    )

    vim.lsp.config(
      'yamlls',
      vim.tbl_deep_extend('force', default_config, {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = '' },
            schemas = require('schemastore').yaml.schemas(),
          },
        },
      })
    )

    vim.lsp.config(
      'intelephense',
      vim.tbl_deep_extend('force', default_config, {
        filetypes = require('config.lsp.servers.intelephense').filetypes,
        get_language_id = require('config.lsp.servers.intelephense').get_language_id,
        handlers = vim.tbl_extend('force', handlers, {
          -- A Blade document is not valid PHP as a whole. Keep Intelephense's
          -- completion, hover and navigation, but let the Laravel LSP report
          -- framework-aware Blade diagnostics without duplicate false errors.
          ['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
            if result and result.uri then
              local bufnr = vim.uri_to_bufnr(result.uri)
              if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == 'blade' then
                return
              end
            end

            return vim.lsp.handlers['textDocument/publishDiagnostics'](err, result, ctx, config)
          end,
        }),
        settings = {
          intelephense = require('config.lsp.servers.intelephense').settings,
        },
      })
    )

    -- Laravel's official LSP handles framework conventions (Blade components,
    -- routes, views, config, translations, Inertia, Livewire and Eloquent).
    -- Intelephense remains attached for ordinary PHP symbols and types.
    local laravel_lsp_command = vim.fn.exepath 'laravel-lsp'
    if laravel_lsp_command == '' then
      local composer_candidates = {
        vim.fn.expand '~/.config/composer/vendor/bin/laravel-lsp',
        vim.fn.expand '~/.composer/vendor/bin/laravel-lsp',
      }
      if vim.env.COMPOSER_HOME then
        table.insert(composer_candidates, 1, vim.env.COMPOSER_HOME .. '/vendor/bin/laravel-lsp')
      end
      for _, candidate in ipairs(composer_candidates) do
        if candidate and vim.fn.executable(candidate) == 1 then
          laravel_lsp_command = candidate
          break
        end
      end
      if laravel_lsp_command == '' then
        laravel_lsp_command = 'laravel-lsp'
      end
    end

    vim.lsp.config(
      'laravel_lsp',
      vim.tbl_deep_extend('force', default_config, {
        cmd = { laravel_lsp_command },
        filetypes = { 'php', 'blade' },
        -- The server rejects non-Laravel roots. Every standard Laravel app has
        -- artisan, while composer.json/.git also occur in ordinary PHP repos.
        root_markers = { 'artisan' },
        workspace_required = true,
        init_options = {
          -- Auto-detect local PHP, Sail, Herd, Valet, Lando or DDEV.
          phpEnvironment = 'auto',
        },
      })
    )
    vim.lsp.enable 'laravel_lsp'

    vim.lsp.config('vtsls', {
      capabilities = capabilities,
      handlers = vim.tbl_extend('force', handlers, require('config.lsp.servers.vtsls').handlers or {}),
      on_attach = require('config.lsp.servers.vtsls').on_attach,
      filetypes = require('config.lsp.servers.vtsls').filetypes,
      settings = require('config.lsp.servers.vtsls').settings,
    })

    vim.lsp.config(
      'vue_ls',
      vim.tbl_deep_extend('force', default_config, {
        on_init = function(client)
          client.handlers['tsserver/request'] = function(_, result, context)
            local ts_clients = vim.lsp.get_clients { bufnr = context.bufnr, name = 'ts_ls' }
            local vtsls_clients = vim.lsp.get_clients { bufnr = context.bufnr, name = 'vtsls' }
            local clients = {}

            vim.list_extend(clients, ts_clients)
            vim.list_extend(clients, vtsls_clients)

            if #clients == 0 then
              vim.notify('Could not find `vtsls` or `ts_ls` lsp client, `vue_ls` would not work without it.', vim.log.levels.ERROR)
              return
            end
            local ts_client = clients[1]

            local param = unpack(result)
            local id, command, payload = unpack(param)
            ts_client:exec_cmd({
              title = 'vue_request_forward',
              command = 'typescript.tsserverRequest',
              arguments = {
                command,
                payload,
              },
            }, { bufnr = context.bufnr }, function(_, r)
              local response = r and r.body
              local response_data = { { id, response } }

              ---@diagnostic disable-next-line: param-type-mismatch
              client:notify('tsserver/response', response_data)
            end)
          end
        end,
      })
    )
  end,
}
