local map = vim.keymap.set

-- save / quit
map('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save' })
map('n', '<leader>q', '<cmd>quit<cr>',  { desc = 'Quit' })

-- window navigation (works in normal AND terminal mode)
map('n', '<C-h>', '<C-w>h', { desc = 'Window left'  })
map('n', '<C-j>', '<C-w>j', { desc = 'Window down'  })
map('n', '<C-k>', '<C-w>k', { desc = 'Window up'    })
map('n', '<C-l>', '<C-w>l', { desc = 'Window right' })

map('t', '<C-h>', [[<C-\><C-n><C-w>h]], { desc = 'Window left from term'  })
map('t', '<C-j>', [[<C-\><C-n><C-w>j]], { desc = 'Window down from term'  })
map('t', '<C-k>', [[<C-\><C-n><C-w>k]], { desc = 'Window up from term'    })
map('t', '<C-l>', [[<C-\><C-n><C-w>l]], { desc = 'Window right from term' })

-- escape from terminal mode
map('t', '<Esc>', [[<C-\><C-n>]], { desc = 'Term to normal' })

-- buffer navigation
map('n', '<S-h>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev buffer' })
map('n', '<S-l>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })
map('n', '<leader>bd', function()
  local buf = vim.api.nvim_get_current_buf()
  local listed = vim.fn.getbufinfo({ buflisted = 1 })
  if #listed > 1 then
    vim.cmd('bprevious')
  else
    vim.cmd('enew')
  end
  vim.api.nvim_buf_delete(buf, { force = false })
end, { desc = 'Close file (keep window)' })

-- clear search highlight + pattern (so n/N don't jump after clear)
map('n', '<Esc>', function()
  vim.cmd('nohlsearch')
  vim.fn.setreg('/', '')
end, { desc = 'Clear search' })
