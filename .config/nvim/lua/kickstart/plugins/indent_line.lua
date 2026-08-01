return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    config = function()
      local hooks = require 'ibl.hooks'

      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, 'IblIndent', { fg = '#362343' })
        vim.api.nvim_set_hl(0, 'IblScope', { fg = '#f7997d' })
      end)

      require('ibl').setup {
        indent = {
          char = '│',
          tab_char = '│',
          highlight = 'IblIndent',
        },
        scope = {
          enabled = true,
          char = '│',
          highlight = 'IblScope',
          show_start = false,
          show_end = false,
        },
      }
    end,
  },
}
