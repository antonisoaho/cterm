return {
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add          = { text = '+' },
        change       = { text = '~' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '≃' },
      },
      on_attach = function(buf)
        local gs = require('gitsigns')
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        map('n', ']c', function() gs.nav_hunk('next') end, 'Next hunk')
        map('n', '[c', function() gs.nav_hunk('prev') end, 'Prev hunk')
        map('n', '<leader>hp', gs.preview_hunk,            'Preview hunk')
        map('n', '<leader>hs', gs.stage_hunk,              'Stage hunk')
        map('n', '<leader>hr', gs.reset_hunk,              'Reset hunk')
        map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, 'Blame line')
      end,
    },
  },
}
