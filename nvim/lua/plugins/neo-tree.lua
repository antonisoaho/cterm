return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    cmd = 'Neotree',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    keys = {
      { '<leader>e',  '<cmd>Neotree toggle filesystem<cr>',  desc = 'Toggle file tree' },
      { '<leader>ge', '<cmd>Neotree toggle git_status<cr>',  desc = 'Toggle git tree' },
    },
    opts = {
      close_if_last_window = true,
      enable_git_status = true,
      enable_diagnostics = false,
      sources = { 'filesystem', 'buffers', 'git_status' },
      default_component_configs = {
        indent = { padding = 0 },
        git_status = {
          symbols = {
            added     = '+',
            modified  = '~',
            deleted   = '-',
            renamed   = '→',
            untracked = '?',
            ignored   = '·',
            unstaged  = '!',
            staged    = '✓',
            conflict  = '×',
          },
        },
      },
      window = { width = 32 },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = { hide_dotfiles = false, hide_gitignored = false },
      },
    },
    config = function(_, opts)
      require('neo-tree').setup(opts)
      vim.defer_fn(function() vim.cmd('Neotree show') end, 0)
    end,
  },
}
