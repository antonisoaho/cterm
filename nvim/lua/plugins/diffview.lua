return {
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory', 'DiffviewToggleFiles' },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr>',             desc = 'Diff view' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>',    desc = 'File history' },
      { '<leader>gq', '<cmd>DiffviewClose<cr>',            desc = 'Close diff' },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = { layout = 'diff3_mixed' },
      },
    },
  },
}
