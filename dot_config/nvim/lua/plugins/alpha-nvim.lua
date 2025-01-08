return {
  'goolord/alpha-nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'nvim-lua/plenary.nvim',
    { 'juansalvatore/git-dashboard-nvim', dependencies = { 'nvim-lua/plenary.nvim' } },
  },
  config = function()
    -- Import alpha and dashboard
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.startify'

    local function whitespace_only(str)
      return str:match '^%s*$' ~= nil
    end

    local function git_header()
      local git_dashboard_raw = require('git-dashboard-nvim').setup {}
      local git_dashboard = {}

      for _, line in ipairs(git_dashboard_raw) do
        if not whitespace_only(line) then
          table.insert(git_dashboard, line)
        end
      end

      local git_repo = git_dashboard[1]
      local git_branch = git_dashboard[#git_dashboard]

      if git_repo == nil and git_branch == nil then
        return ''
      end

      return ' ' .. git_repo .. ':' .. git_branch
    end

    dashboard.section.header.val = {
      [[                                                                       ]],
      [[                                                                     ]],
      [[       ████ ██████           █████      ██                     ]],
      [[      ███████████             █████                             ]],
      [[      █████████ ███████████████████ ███   ███████████   ]],
      [[     █████████  ███    █████████████ █████ ██████████████   ]],
      [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
      [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
      [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
      [[                                                                       ]],
      [[                                                                       ]],
      git_header(),
    }

    alpha.setup(dashboard.opts)
  end,
}
