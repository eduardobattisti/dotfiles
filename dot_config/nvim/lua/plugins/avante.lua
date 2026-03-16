return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  version = false,
  build = 'make',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-tree/nvim-web-devicons',
    'zbirenbaum/copilot.lua',
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = { file_types = { 'markdown', 'Avante' } },
      ft = { 'markdown', 'Avante' },
    },
  },
  opts = {
    -- Default provider (switch with :AvanteSwitchProvider)
    provider = 'copilot',

    providers = {
      copilot = {
        endpoint = 'https://api.githubcopilot.com',
        model = 'claude-sonnet-4-5-20250929',
        timeout = 30000,
        extra_request_body = {
          max_tokens = 20480,
        },
      },

      -- Cursor ACP provider (switch with :AvanteSwitchProvider cursor)
      cursor = {
        __inherited_from = 'openai',
        api_key_name = 'CURSOR_API_KEY',
        endpoint = 'https://api2.cursor.sh/v1',
        model = 'cursor-fast',
        timeout = 30000,
        extra_request_body = {
          temperature = 0,
          max_tokens = 4096,
        },
      },
    },

    behaviour = {
      auto_suggestions = false,
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = false,
    },

    windows = {
      position = 'right',
      wrap = true,
      width = 45,
      sidebar_header = {
        align = 'center',
        rounded = true,
      },
    },

    highlights = {
      diff = {
        current = 'DiffText',
        incoming = 'DiffAdd',
      },
    },

    diff = {
      autojump = true,
      list_opener = 'copen',
    },
  },
  keys = {
    {
      '<leader>aa',
      function()
        require('avante.api').ask()
      end,
      desc = 'Avante: Ask',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ar',
      function()
        require('avante.api').refresh()
      end,
      desc = 'Avante: Refresh',
    },
    {
      '<leader>ae',
      function()
        require('avante.api').edit()
      end,
      desc = 'Avante: Edit',
      mode = 'v',
    },
    { '<leader>at', '<cmd>AvanteToggle<cr>', desc = 'Avante: Toggle' },
    { '<leader>am', '<cmd>AvanteModels<cr>', desc = 'Avante: Select Model' },
    { '<leader>ap', '<cmd>AvanteSwitchProvider<cr>', desc = 'Avante: Switch Provider' },
  },
}
