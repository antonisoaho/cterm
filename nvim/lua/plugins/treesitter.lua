return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'lua', 'vim', 'vimdoc', 'bash', 'python',
          'javascript', 'typescript', 'tsx',
          'json', 'yaml', 'toml',
          'markdown', 'markdown_inline',
          'gitcommit', 'diff', 'git_rebase',
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}
