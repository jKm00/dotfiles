return {
  {
    'nickjvandyke/opencode.nvim',
    version = '*',
    config = function()
      vim.g.opencode_opts = {
        server = {
          start = false,
        },
      }

      vim.keymap.set({ 'n', 'x' }, '<leader>a', '', { desc = '+opencode' })

      vim.keymap.set({ 'n', 'x' }, '<leader>aa', function()
        require('opencode').ask('@this: ')
      end, { desc = 'OpenCode: Ask' })

      vim.keymap.set({ 'n', 'x' }, '<leader>as', function()
        require('opencode').select()
      end, { desc = 'OpenCode: Select' })

      vim.keymap.set({ 'n', 'x' }, '<leader>ap', function()
        require('opencode').prompt('@this ')
      end, { desc = 'OpenCode: Prompt with context' })

      vim.keymap.set('n', '<leader>an', function()
        require('opencode').command('session.new')
      end, { desc = 'OpenCode: New session' })

      vim.keymap.set('n', '<leader>au', function()
        require('opencode').command('session.half.page.up')
      end, { desc = 'OpenCode: Scroll up' })

      vim.keymap.set('n', '<leader>ad', function()
        require('opencode').command('session.half.page.down')
      end, { desc = 'OpenCode: Scroll down' })
    end,
  },
}
