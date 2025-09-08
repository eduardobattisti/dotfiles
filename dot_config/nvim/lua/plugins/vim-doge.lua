return {
  'kkoomen/vim-doge',
  event = 'BufRead',
  cmd = { 'DogeGenerate', 'DogeCreateDocStandard' },
  config = function()
    vim.g.doge_enable_mappings = 0
    vim.g.doge_doc_standard_python = 'sphinx'
    vim.g.doge_doc_standard_javascript = 'jsdoc'
    vim.g.doge_doc_standard_typescript = 'jsdoc'
    vim.g.doge_doc_standard_php = 'phpdoc'
    vim.g.doge_doc_standard_lua = 'ldoc'
    vim.g.doge_doc_standard_java = 'javadoc'
    vim.g.doge_doc_standard_c = 'kernel_doc'
    vim.g.doge_doc_standard_cpp = 'cpp_doxygen'
    vim.g.doge_doc_standard_sh = 'google'
    
    -- Custom mapping
    vim.keymap.set('n', '<leader>dg', '<Plug>(doge-generate)', { desc = 'Generate documentation' })
  end,
}