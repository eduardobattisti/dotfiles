local lsp_utils = require 'config.lsp.utils'

local M = {}

local LSP_BORDER = 'rounded'

local TS_JS_CONFIG = {
  updateImportsOnFileMove = { enabled = 'always' },
  suggest = {
    completeFunctionCalls = true,
  },
  inlayHints = {
    enumMemberValues = { enabled = true },
    functionLikeReturnTypes = { enabled = true },
    parameterNames = { enabled = 'literals' },
    parameterTypes = { enabled = true },
    propertyDeclarationTypes = { enabled = true },
    variableTypes = { enabled = false },
  },
}

local mason_registry = require 'mason-registry'
local has_volar, volar = pcall(mason_registry.get_package, 'vue-language-server')
local vue_ts_plugin_path = volar:get_install_path() .. '/node_modules/@vue/language-server'
local vue_plugin = {}

if has_volar then
  vue_plugin = {
    name = '@vue/typescript-plugin',
    -- Maybe a function to get the location of the plugin is better?
    -- e.g. pnpm fallback to nvm fallback to default node path
    location = vue_ts_plugin_path,
    languages = { 'vue' },
    configNamespace = 'typescript',
    enableForWorkspaceTypeScriptVersions = true,
  }
end

local handlers = {
  ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
    silent = true,
    border = LSP_BORDER,
  }),
  ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = LSP_BORDER }),
  ['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = true }),
  ['textDocument/definition'] = function(err, result, method, ...)
    vim.lsp.handlers['textDocument/definition'](err, result, method, ...)
  end,
}

local settings = {
  complete_function_calls = true,
  vtsls = {
    enableMoveToFileCodeAction = true,
    autoUseWorkspaceTsdk = true,
    experimental = {
      completion = {
        enableServerSideFuzzyMatch = true,
      },
    },
    ts_ls = {
      globalPlugins = {
        vue_plugin,
      },
    },
    tsserver = {
      globalPlugins = {
        vue_plugin,
      },
    },
  },
  typescript = TS_JS_CONFIG,
  javascript = TS_JS_CONFIG,
}

local actions = {
  {
    key = 'gD',
    callback = function()
      local params = vim.lsp.util.make_position_params()
      lsp_utils.lsp_execute {
        command = 'typescript.goToSourceDefinition',
        arguments = { params.textDocument.uri, params.position },
        open = true,
      }
    end,
    desc = 'Goto Source Definition',
  },
  {
    key = 'gR',
    callback = function()
      lsp_utils.lsp_execute {
        command = 'typescript.findAllFileReferences',
        arguments = { vim.uri_from_bufnr(0) },
        open = true,
      }
    end,
    desc = 'File References',
  },
  {
    key = '<leader>co',
    callback = lsp_utils.lsp_action['source.organizeImports'],
    desc = 'Organize Imports',
  },
  {
    key = '<leader>cM',
    callback = lsp_utils.lsp_action['source.addMissingImports.ts'],
    desc = 'Add missing imports',
  },
  {
    key = '<leader>cu',
    callback = lsp_utils.lsp_action['source.removeUnused.ts'],
    desc = 'Remove unused imports',
  },
  {
    key = '<leader>cD',
    callback = lsp_utils.lsp_action['source.fixAll.ts'],
    desc = 'Fix all diagnostics',
  },
  {
    key = '<leader>cV',
    callback = function()
      lsp_utils.lsp_execute { command = 'typescript.selectTypeScriptVersion' }
    end,
    desc = 'Select TS workspace version',
  },
}

local on_attach = function(_, bufnr)
  vim.lsp.inlay_hint.enable(true, { bufnr })

  for _, action in ipairs(actions) do
    lsp_utils.keymap(action.key, action.callback, action.bufnr, action.desc)
  end

  -- TODO: is necessary?
  -- require('workspace-diagnostics').populate_workspace_diagnostics(client, bufnr)
end

local filetypes = {
  'javascript',
  'javascriptreact',
  'javascript.jsx',
  'typescript',
  'typescriptreact',
  'typescript.tsx',
  'vue',
}

M.handler = handlers
M.settings = settings
M.filetypes = filetypes
M.on_attach = on_attach

return M
