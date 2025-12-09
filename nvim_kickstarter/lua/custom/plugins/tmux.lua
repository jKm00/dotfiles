return {
  {
    'aserowy/tmux.nvim',
    config = function()
      return require('tmux').setup {
        resize = {
          enable_default_keybindings = true,
        },
      }
    end,
  },
  {
    'christoomey/vim-tmux-navigator',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
      'TmuxNavigateProcessList',
    },
    keys = {
      { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-k>', '<cmd><C-U>TmueNavigateUp<cr>' },
      { '<c-l>', '<cmd><C-U>TmueNavigateRight<cr>' },
      { '<c-\\>', '<cmd><C-U>TmueNavigatePrevious<cr>' },
    },
  },
}
