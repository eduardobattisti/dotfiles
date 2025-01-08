return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    {
      '<Leader>e',
      function()
        local neotree = require 'neo-tree'
        local bufnr_list = vim.api.nvim_list_bufs()
        local neotree_open = false

        for _, bufnr in ipairs(bufnr_list) do
          if vim.api.nvim_get_option_value('filetype', { buf = bufnr }) == 'neo-tree' then
            neotree_open = true
            break
          end
        end
        if neotree_open then
          neotree.close_all()
          return
        end

        vim.api.nvim_command 'Neotree reveal'
      end,
      desc = 'which_key_ignore',
    },
    { '<Leader>gs', ':Neotree source=git_status<CR>', desc = 'Neotree Git Status' },
  },
  opts = {
    close_if_last_window = false,
    enable_git_status = true,
    enable_diagnostics = true,
    sources = { 'filesystem', 'buffers', 'git_status' },
    source_selector = {
      winbar = true,
      content_layout = 'center',
      sources = {
        { source = 'filesystem', display_name = '󰉋 File' },
        { source = 'buffers', display_name = '󰈔 Bufs' },
        { source = 'diagnostics', display_name = '󰒡 Diagnostic' },
        { source = 'git_status', display_name = '󰊤 Git' },
      },
    },
    window = {
      width = 40,
      mappings = {
        ['<Tab>'] = 'next_source',
        ['<S-Tab>'] = 'prev_source',
      },
    },
    filesystem = {
      window = {
        mappings = {
          ['<Leader>o'] = 'close_window',
        },
      },
    },
  },
}
