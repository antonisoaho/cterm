return {
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local accent = '#D97757'
      local bg     = '#232323'
      local fg     = '#e8e6e3'
      local muted  = '#8a8a87'

      local theme = {
        normal = {
          a = { fg = '#1a1a1a', bg = accent, gui = 'bold' },
          b = { fg = fg,        bg = bg },
          c = { fg = muted,     bg = bg },
        },
        insert   = { a = { fg = '#1a1a1a', bg = '#8fa876', gui = 'bold' } },
        visual   = { a = { fg = '#1a1a1a', bg = '#d4a574', gui = 'bold' } },
        replace  = { a = { fg = '#1a1a1a', bg = '#c4736e', gui = 'bold' } },
        command  = { a = { fg = '#1a1a1a', bg = '#b08aa8', gui = 'bold' } },
        inactive = {
          a = { fg = muted, bg = bg },
          b = { fg = muted, bg = bg },
          c = { fg = muted, bg = bg },
        },
      }

      require('lualine').setup({
        options = {
          theme = theme,
          section_separators = '',
          component_separators = '|',
          globalstatus = true,
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { { 'filename', path = 1 } },
          lualine_x = { 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
      })
    end,
  },
}
