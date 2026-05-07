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

-- add file context to left CLI pane
map('n', '<leader>fc', function()
  local abs = vim.api.nvim_buf_get_name(0)
  if abs == '' then return end

  local dir = vim.fn.fnamemodify(abs, ':h')
  local root = vim.fn.system({ 'git', '-C', dir, 'rev-parse', '--show-toplevel' })
  root = root:gsub('[\r\n]+$', '')
  if root == '' then root = vim.fn.getcwd() end

  abs  = abs:gsub('\\', '/')
  root = root:gsub('\\', '/'):gsub('/$', '')
  local rel = abs:sub(#root + 2)

  local pane_id = os.getenv('WEZTERM_PANE') or ''
  local get_args = { 'wezterm', 'cli', 'get-pane-direction' }
  if pane_id ~= '' then
    table.insert(get_args, '--pane-id')
    table.insert(get_args, pane_id)
  end
  table.insert(get_args, 'Left')

  local left = vim.fn.system(get_args):gsub('[\r\n]+$', '')
  if left == '' then
    vim.notify('afc: no left pane', vim.log.levels.WARN)
    return
  end

  vim.fn.system({ 'wezterm', 'cli', 'send-text', '--pane-id', left }, rel .. '\n')
end, { desc = 'Add file context to CLI' })

-- clear search highlight + pattern (so n/N don't jump after clear)
map('n', '<Esc>', function()
  vim.cmd('nohlsearch')
  vim.fn.setreg('/', '')
end, { desc = 'Clear search' })
