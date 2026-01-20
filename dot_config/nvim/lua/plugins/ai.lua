-- ============================================================================
-- AI PLUGINS
-- Conditional loading based on environment (work vs personal)
-- Work: Cursor CLI via cursor-agent.nvim
-- Personal: GitHub Copilot + CopilotChat.nvim
-- ============================================================================

local env = require 'utils.env'

-- ============================================================================
-- CURSOR AGENT (WORK ENVIRONMENT)
-- ============================================================================
local cursor_agent_spec = {
  'aug6th/cursoragent.nvim',
  cond = env.is_work,
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  cmd = {
    'CursorAgent',
    'CursorAgentAgent',
    'CursorAgentAsk',
    'CursorAgentPlan',
    'CursorAgentResume',
    'CursorAgentBuffer',
    'CursorAgentSelection',
  },
  config = function()
    require('cursoragent').setup {
      terminal = {
        split_side = 'right',
        split_width_percentage = 0.4,
        provider = 'native',
        auto_close = true,
        git_repo_cwd = true,
      },
      auto_start = true,
      track_selection = true,
      focus_after_send = true,
      diff_opts = {
        layout = 'vertical',
        open_in_new_tab = false,
      },
    }
  end,
  keys = {
    { '<leader>aa', '<cmd>CursorAgent<cr>', desc = 'AI: Toggle Cursor Agent', mode = 'n' },
    { '<leader>aa', '<cmd>CursorAgentSelection<cr>', desc = 'AI: Send selection to Cursor', mode = 'v' },
    { '<leader>ab', '<cmd>CursorAgentBuffer<cr>', desc = 'AI: Send buffer to Cursor', mode = 'n' },
    { '<leader>ak', '<cmd>CursorAgentAsk<cr>', desc = 'AI: Cursor Ask Mode', mode = 'n' },
    { '<leader>ap', '<cmd>CursorAgentPlan<cr>', desc = 'AI: Cursor Plan Mode', mode = 'n' },
    { '<leader>ar', '<cmd>CursorAgentResume<cr>', desc = 'AI: Resume Cursor Conversation', mode = 'n' },
  },
}

-- ============================================================================
-- COPILOT (PERSONAL ENVIRONMENT)
-- Inline completions
-- ============================================================================
local copilot_spec = {
  'zbirenbaum/copilot.lua',
  cond = env.is_personal,
  cmd = 'Copilot',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup {
      panel = {
        enabled = true,
        auto_refresh = true,
        keymap = {
          jump_prev = '[[',
          jump_next = ']]',
          accept = '<CR>',
          refresh = 'gr',
          open = '<M-CR>',
        },
        layout = {
          position = 'bottom',
          ratio = 0.4,
        },
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = '<M-l>',
          accept_word = false,
          accept_line = false,
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-]>',
        },
      },
      filetypes = {
        yaml = false,
        markdown = false,
        help = false,
        gitcommit = false,
        gitrebase = false,
        hgcommit = false,
        svn = false,
        cvs = false,
        ['.'] = false,
      },
      copilot_node_command = 'node',
      server_opts_overrides = {},
    }
  end,
}

-- ============================================================================
-- COPILOT CHAT (PERSONAL ENVIRONMENT)
-- Chat interface with model selection
-- ============================================================================
local copilot_chat_spec = {
  'CopilotC-Nvim/CopilotChat.nvim',
  cond = env.is_personal,
  dependencies = {
    { 'zbirenbaum/copilot.lua' },
    { 'nvim-lua/plenary.nvim', branch = 'master' },
  },
  build = 'make tiktoken',
  cmd = {
    'CopilotChat',
    'CopilotChatOpen',
    'CopilotChatClose',
    'CopilotChatToggle',
    'CopilotChatStop',
    'CopilotChatReset',
    'CopilotChatSave',
    'CopilotChatLoad',
    'CopilotChatPrompts',
    'CopilotChatModels',
  },
  config = function()
    require('CopilotChat').setup {
      model = 'claude-4.5-sonnet', -- Default model, can be changed with /model
      temperature = 0.1,

      -- Window configuration
      window = {
        layout = 'vertical',
        width = 0.4,
        border = 'rounded',
        title = ' Copilot Chat',
      },

      -- Show diffs
      show_diff = true,

      -- Headers
      headers = {
        user = ' You',
        assistant = ' Copilot',
        tool = ' Tool',
      },

      separator = '─',
      auto_follow_cursor = true,
      auto_insert_mode = true,

      -- Custom prompts
      prompts = {
        Explain = {
          prompt = '/COPILOT_EXPLAIN Write an explanation for the selected code as paragraphs of text.',
        },
        Review = {
          prompt = '/COPILOT_REVIEW Review the selected code and provide suggestions for improvement.',
        },
        Fix = {
          prompt = '/COPILOT_FIX There is a problem in this code. Rewrite the code to show it with the bug fixed.',
        },
        Optimize = {
          prompt = '/COPILOT_OPTIMIZE Optimize the selected code to improve performance and readability.',
        },
        Docs = {
          prompt = '/COPILOT_DOCS Add documentation comments for the selected code.',
        },
        Tests = {
          prompt = '/COPILOT_TESTS Generate tests for the selected code.',
        },
        Commit = {
          prompt = '/COPILOT_COMMIT Write commit message for the change with commitizen convention.',
        },
      },
    }
  end,
  keys = {
    -- Toggle chat
    {
      '<leader>aa',
      function()
        require('CopilotChat').toggle()
      end,
      desc = 'AI: Toggle Chat',
      mode = 'n',
    },
    {
      '<leader>aa',
      function()
        require('CopilotChat').toggle()
      end,
      desc = 'AI: Toggle Chat',
      mode = 'v',
    },

    -- Quick chat with selection
    {
      '<leader>aq',
      function()
        local input = vim.fn.input 'Quick Chat: '
        if input ~= '' then
          require('CopilotChat').ask(input)
        end
      end,
      desc = 'AI: Quick Chat',
      mode = 'n',
    },
    {
      '<leader>aq',
      function()
        local input = vim.fn.input 'Quick Chat: '
        if input ~= '' then
          require('CopilotChat').ask(input, { selection = require('CopilotChat.select').visual })
        end
      end,
      desc = 'AI: Quick Chat with Selection',
      mode = 'v',
    },

    -- Buffer context
    {
      '<leader>ab',
      function()
        local input = vim.fn.input 'Chat about buffer: '
        if input ~= '' then
          require('CopilotChat').ask(input, { selection = require('CopilotChat.select').buffer })
        end
      end,
      desc = 'AI: Chat about Buffer',
      mode = 'n',
    },

    -- Explain
    {
      '<leader>ae',
      function()
        require('CopilotChat').ask('/Explain', { selection = require('CopilotChat.select').visual })
      end,
      desc = 'AI: Explain Code',
      mode = 'v',
    },
    {
      '<leader>ae',
      function()
        require('CopilotChat').ask('/Explain', { selection = require('CopilotChat.select').buffer })
      end,
      desc = 'AI: Explain Buffer',
      mode = 'n',
    },

    -- Review
    {
      '<leader>ar',
      function()
        require('CopilotChat').ask('/Review', { selection = require('CopilotChat.select').visual })
      end,
      desc = 'AI: Review Code',
      mode = 'v',
    },
    {
      '<leader>ar',
      function()
        require('CopilotChat').ask('/Review', { selection = require('CopilotChat.select').buffer })
      end,
      desc = 'AI: Review Buffer',
      mode = 'n',
    },

    -- Fix
    {
      '<leader>af',
      function()
        require('CopilotChat').ask('/Fix', { selection = require('CopilotChat.select').visual })
      end,
      desc = 'AI: Fix Code',
      mode = 'v',
    },
    {
      '<leader>af',
      function()
        require('CopilotChat').ask('/Fix', { selection = require('CopilotChat.select').buffer })
      end,
      desc = 'AI: Fix Buffer',
      mode = 'n',
    },

    -- Optimize
    {
      '<leader>ao',
      function()
        require('CopilotChat').ask('/Optimize', { selection = require('CopilotChat.select').visual })
      end,
      desc = 'AI: Optimize Code',
      mode = 'v',
    },
    {
      '<leader>ao',
      function()
        require('CopilotChat').ask('/Optimize', { selection = require('CopilotChat.select').buffer })
      end,
      desc = 'AI: Optimize Buffer',
      mode = 'n',
    },

    -- Tests
    {
      '<leader>at',
      function()
        require('CopilotChat').ask('/Tests', { selection = require('CopilotChat.select').visual })
      end,
      desc = 'AI: Generate Tests',
      mode = 'v',
    },
    {
      '<leader>at',
      function()
        require('CopilotChat').ask('/Tests', { selection = require('CopilotChat.select').buffer })
      end,
      desc = 'AI: Generate Tests for Buffer',
      mode = 'n',
    },

    -- Docs
    {
      '<leader>ad',
      function()
        require('CopilotChat').ask('/Docs', { selection = require('CopilotChat.select').visual })
      end,
      desc = 'AI: Generate Docs',
      mode = 'v',
    },
    {
      '<leader>ad',
      function()
        require('CopilotChat').ask('/Docs', { selection = require('CopilotChat.select').buffer })
      end,
      desc = 'AI: Generate Docs for Buffer',
      mode = 'n',
    },

    -- Commit message
    {
      '<leader>ac',
      function()
        require('CopilotChat').ask '/Commit'
      end,
      desc = 'AI: Generate Commit Message',
      mode = 'n',
    },

    -- Model selection
    {
      '<leader>am',
      '<cmd>CopilotChatModels<cr>',
      desc = 'AI: Select Model',
      mode = 'n',
    },

    -- Prompts selection
    {
      '<leader>ap',
      '<cmd>CopilotChatPrompts<cr>',
      desc = 'AI: Select Prompt',
      mode = 'n',
    },

    -- Reset chat
    {
      '<leader>ax',
      '<cmd>CopilotChatReset<cr>',
      desc = 'AI: Reset Chat',
      mode = 'n',
    },

    -- Save/Load chat
    {
      '<leader>as',
      function()
        local name = vim.fn.input 'Save chat as: '
        if name ~= '' then
          require('CopilotChat').save(name)
        end
      end,
      desc = 'AI: Save Chat',
      mode = 'n',
    },
    {
      '<leader>al',
      function()
        local name = vim.fn.input 'Load chat: '
        if name ~= '' then
          require('CopilotChat').load(name)
        end
      end,
      desc = 'AI: Load Chat',
      mode = 'n',
    },
  },
}

-- ============================================================================
-- RETURN ALL SPECS
-- ============================================================================
return {
  cursor_agent_spec,
  copilot_spec,
  copilot_chat_spec,
}

