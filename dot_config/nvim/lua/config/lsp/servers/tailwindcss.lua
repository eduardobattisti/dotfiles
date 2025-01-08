-- @see https://github.com/ecosse3/nvim/blob/master/lua/config/lsp/servers/tailwindcss.lua
local M = {}

local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.colorProvider = { dynamicRegistration = false }
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

-- Settings

local on_attach = function(client, bufnr) end

local filetypes = { 'html', 'mdx', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'vue', 'svelte' }

local settings = {
  tailwindCSS = {
    includeLanguages = {
      eelixir = 'html-eex',
      eruby = 'erb',
    },
    lint = {
      cssConflict = 'warning',
      invalidApply = 'error',
      invalidConfigPath = 'error',
      invalidScreen = 'error',
      invalidTailwindDirective = 'error',
      invalidVariant = 'error',
      recommendedVariantOrder = 'warning',
    },
    experimental = {
      classRegex = {
        ---@see https://github.com/RayGuo-ergou/tailwind-intellisense-regex-list?tab=readme-ov-file#plain-javascript-object
        ---All javascript object, only enable when needed e.g. long object
        -- ':\\s*?["\'`]([^"\'`]*).*?,',
        '\\/\\*\\s*tw\\s*\\*\\/\\s*[`\'"](.*)[`\'"];?',
        '@tw\\s\\*/\\s+["\'`]([^"\'`]*)',
        { '(?:twMerge|twJoin)\\(([^\\);]*)[\\);]', '[`\'"]([^\'"`,;]*)[`\'"]' },
        'twc\\`(.*)\\`;?',
        '(?:clsx|cva|cn)[`]([\\s\\S][^`]*)[`]',
        { '(?:clsx|cva|cn)\\(([^)]*)\\)', "(?:'|\"|`)([^']*)(?:'|\"|`)" },
        { 'ui:\\s*{([^)]*)\\s*}', '["\'`]([^"\'`]*).*?["\'`]' },
        { '/\\*\\s?ui\\s?\\*/\\s*{([^;]*)}', ':\\s*["\'`]([^"\'`]*).*?["\'`]' },
        'class\\s*:\\s*["\'`]([^"\'`]*)["\'`]',
        ---@see https://github.com/RayGuo-ergou/tailwind-intellisense-regex-list?tab=readme-ov-file#dom
        { 'classList.(?:add|remove)\\(([^)]*)\\)', '(?:\'|"|`)([^"\'`]*)(?:\'|"|`)' },
        ---@see https://github.com/RayGuo-ergou/tailwind-intellisense-regex-list?tab=readme-ov-file#typescript-or-javascript-variables-strings-or-arrays-with-keyword
        { 'Styles\\s*(?::\\s*[^=]+)?\\s*=\\s*([^;]*);', '[\'"`]([^\'"`]*)[\'"`]' },
        ---@see https://github.com/RayGuo-ergou/tailwind-intellisense-regex-list?tab=readme-ov-file#headlessui-transition-react
        '(?:enter|leave)(?:From|To)?=\\s*(?:"|\'|{`)([^(?:"|\'|`})]*)',
      },
    },
    validate = true,
  },
}

M.settings = settings
M.filetypes = filetypes
M.capabilities = capabilities
M.on_attach = on_attach

return M
