return {
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      delay = 200,
      icons = { mappings = false },
      spec = {
        { '<leader>f', group = 'Find' },
        { '<leader>r', group = 'Refactor' },
        { '<leader>c', group = 'Code' },
        { '<leader>b', group = 'Buffer' },
        { '<C-w>',     group = 'Window' },
        { 'g',         group = 'Goto' },
        { '[',         group = 'Prev' },
        { ']',         group = 'Next' },
      },
    },
  },
}
