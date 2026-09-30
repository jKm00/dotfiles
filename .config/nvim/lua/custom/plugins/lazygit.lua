return {
  'kdheepak/lazygit.nvim',
  cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  },
  -- optional for floating window border decoration
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  -- setting the keybinding for LazyGit with 'keys' is recommended in
  -- order to load the plugin when the command is run for the first time
  keys = {
    { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'Open lazy git' },
  },
  init = function()
    -- Nearly full-screen, with a little margin (default 0.9 leaves more).
    vim.g.lazygit_floating_window_scaling_factor = 0.98
  end,
}
