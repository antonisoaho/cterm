return {
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find files' },
      { '<C-c>p',     '<cmd>Telescope find_files<cr>', desc = 'Find files' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>',  desc = 'Live grep' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>',    desc = 'Buffers' },
      { '<leader>fh', '<cmd>Telescope help_tags<cr>',  desc = 'Help tags' },
    },
    opts = {
      defaults = {
        layout_strategy = 'flex',
        sorting_strategy = 'ascending',
        layout_config = { prompt_position = 'top' },
        path_display = { 'truncate' },
      },
    },
  },
}
