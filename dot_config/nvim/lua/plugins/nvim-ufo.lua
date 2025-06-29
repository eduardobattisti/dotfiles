return {
  'kevinhwang91/nvim-ufo',
  dependencies = {
    'kevinhwang91/promise-async',
    {
      'luukvbaal/statuscol.nvim',
      opts = function()
        local builtin = require 'statuscol.builtin'
        return {
          setopt = true,
          relculright = true,
          -- override the default list of segments with:
          -- number-less fold indicator, then signs, then line number & separator
          segments = {
            { text = { builtin.foldfunc, ' ' }, click = 'v:lua.ScFa' },
            {
              text = { builtin.lnumfunc, ' ' },
              condition = { true, builtin.not_empty },
              click = 'v:lua.ScLa',
            },
            { text = { '%s' }, click = 'v:lua.ScSa' },
          },
        }
      end,
    },
  },
  opts = {
    preview = {
      win_config = {
        border = { '', '─', '', '', '', '─', '', '' },
        -- winhighlight = "Normal:Folded",
        winblend = 0,
      },
    },
    provider_selector = function(_, filetype, buftype)
      local function handleFallbackException(bufnr, err, providerName)
        if type(err) == 'string' and err:match 'UfoFallbackException' then
          return require('ufo').getFolds(bufnr, providerName)
        else
          return require('promise').reject(err)
        end
      end

      return (filetype == '' or buftype == 'nofile') and 'indent' -- only use indent until a file is opened
        or function(bufnr)
          return require('ufo')
            .getFolds(bufnr, 'lsp')
            :catch(function(err)
              return handleFallbackException(bufnr, err, 'treesitter')
            end)
            :catch(function(err)
              return handleFallbackException(bufnr, err, 'indent')
            end)
        end
    end,
  },
  config = function(_, opts)
    local handler = function(virtText, lnum, endLnum, width, truncate)
      local newVirtText = {}
      local totalLines = vim.api.nvim_buf_line_count(0)
      local foldedLines = endLnum - lnum
      local suffix = (' 󰧚 %d %d%%'):format(foldedLines, foldedLines / totalLines * 100)
      local sufWidth = vim.fn.strdisplaywidth(suffix)
      local targetWidth = width - sufWidth
      local curWidth = 0
      for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
          table.insert(newVirtText, chunk)
        else
          chunkText = truncate(chunkText, targetWidth - curWidth)
          local hlGroup = chunk[2]
          table.insert(newVirtText, { chunkText, hlGroup })
          chunkWidth = vim.fn.strdisplaywidth(chunkText)
          -- str width returned from truncate() may less than 2nd argument, need padding
          if curWidth + chunkWidth < targetWidth then
            suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
          end
          break
        end
        curWidth = curWidth + chunkWidth
      end
      local rAlignAppndx = math.max(math.min(vim.opt.textwidth['_value'], width - 1) - curWidth - sufWidth, 0)
      suffix = (' '):rep(rAlignAppndx) .. suffix
      table.insert(newVirtText, { suffix, 'MoreMsg' })
      return newVirtText
    end
    opts['fold_virt_text_handler'] = handler
    require('ufo').setup(opts)
  end,
}
