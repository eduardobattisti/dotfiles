return {
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for Neovim
    { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },

    -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    { 'folke/neodev.nvim', opts = {} },
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

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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
        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
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
      -- 'phpcs',
      'markdownlint',
      'php-debug-adapter',
      'stylua',
      'cssls',
      'css_variables',
      'html',
      'intelephense',
      'vue_ls',
      'vtsls',
    }

    -- Install tools with mason-tool-installer
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    -- LSP servers and clients are able to communicate to each other what features they support.
    --  By default, Neovim doesn't support everything that is in the LSP specification.
    --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
    --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    -- Define global handlers for all servers
    local handlers = {
      ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
        silent = true,
        border = 'rounded',
      }),
      ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' }),
    }

    -- Setup mason-lspconfig with automatic server enablement
    -- This will automatically call vim.lsp.enable() for installed servers
    require('mason-lspconfig').setup {
      -- Automatically install these servers
      ensure_installed = {
        'cssls',
        'css_variables',
        'html',
        'intelephense',
        'vue_ls',
        'vtsls',
      },
      -- Automatically enable installed servers
      automatic_enable = true,
    }

    -- Configure specific server options using vim.lsp.config (Neovim 0.11+)
    -- This allows us to configure servers without disabling automatic_enable

    -- Configure HTML server to stop for Vue files
    vim.lsp.config('html', {
      on_attach = function(client, bufnr)
        local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
        if filetype == 'vue' then
          client.stop()
        end
      end,
    })

    -- Configure tailwindcss server with custom settings
    vim.lsp.config('tailwindcss', {
      capabilities = require('config.lsp.servers.tailwindcss').capabilities,
      filetypes = require('config.lsp.servers.tailwindcss').filetypes,
      on_attach = require('config.lsp.servers.tailwindcss').on_attach,
      settings = require('config.lsp.servers.tailwindcss').settings,
    })

    -- Configure intelephense (PHP) server with custom settings
    vim.lsp.config('intelephense', {
      capabilities = capabilities,
      filetypes = require('config.lsp.servers.intelephense').filetypes,
      settings = {
        intelephense = require('config.lsp.servers.intelephense').settings,
      },
    })

    -- Configure vtsls (TypeScript) server with custom settings
    vim.lsp.config('vtsls', {
      capabilities = capabilities,
      handlers = require('config.lsp.servers.vtsls').handlers,
      on_attach = require('config.lsp.servers.vtsls').on_attach,
      settings = require('config.lsp.servers.vtsls').settings,
      filetypes = require('config.lsp.servers.vtsls').filetypes,
    })

    -- Configure vue_ls (Vue Language Server) with custom on_init handling
    vim.lsp.config('vue_ls', {
      on_init = function(client)
        client.handlers['tsserver/request'] = function(_, result, context)
          local clients = vim.lsp.get_clients { bufnr = context.bufnr, name = 'vtsls' }
          if #clients == 0 then
            -- vim.notify('Could not found `vtsls` lsp client, vue_lsp would not work without it.', vim.log.levels.ERROR)
            return
          end
          local ts_client = clients[1]

          local param = unpack(result)
          local id, command, payload = unpack(param)
          ts_client:exec_cmd({
            command = 'typescript.tsserverRequest',
            arguments = {
              command,
              payload,
            },
          }, { bufnr = context.bufnr }, function(_, r)
            local response_data = { { id, r.body } }
            ---@diagnostic disable-next-line: param-type-mismatch
            -- client:notify('tsserver/response', response_data)
          end)
        end
      end,
    })

    -- Skip ts_ls as it's explicitly not needed
    vim.lsp.config('ts_ls', { enabled = false })
  end,
}
