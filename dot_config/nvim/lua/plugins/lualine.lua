return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    sections = {
      lualine_a = {
        function()
          local reg = vim.fn.reg_recording()
          -- If a macro is being recorded, show "Recording @<register>"
          if reg ~= '' then
            return 'Recording @' .. reg
          else
            -- Get the full mode name using nvim_get_mode()
            local mode = require('lualine.utils.mode').get_mode()

            return mode:upper()
          end
        end,
      },
    },
    options = {
      icons_enabled = true,
      disabled_filetypes = {
        statusline = { 'neo-tree', 'alpha', 'toggleterm' },
      },
    },
  },
}
