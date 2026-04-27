return {
  {
    'echasnovski/mini.nvim',
    version = false,
    priority = 1000,
    lazy = false,
    config = function()
      require('mini.base16').setup({
        palette = {
          base00 = '#1a1a1a',
          base01 = '#232323',
          base02 = '#2d2d2d',
          base03 = '#6c6c6c',
          base04 = '#8a8a87',
          base05 = '#e8e6e3',
          base06 = '#f2f0ed',
          base07 = '#ffffff',
          base08 = '#c4736e',
          base09 = '#D97757',  -- claude orange (accent)
          base0A = '#d4a574',
          base0B = '#8fa876',
          base0C = '#a3b8a3',
          base0D = '#7a9eb1',
          base0E = '#b08aa8',
          base0F = '#8a6a52',
        },
        use_cterm = false,
      })

      local set = vim.api.nvim_set_hl
      local accent = '#D97757'
      local green  = '#8fa876'
      local yellow = '#d4a574'
      local red    = '#c4736e'

      -- neo-tree
      set(0, 'NeoTreeRootName',      { fg = accent, bold = true })
      set(0, 'NeoTreeDirectoryIcon', { fg = accent })
      set(0, 'NeoTreeDirectoryName', { fg = '#e8e6e3' })

      -- telescope
      set(0, 'TelescopeBorder',       { fg = accent })
      set(0, 'TelescopeTitle',        { fg = accent, bold = true })
      set(0, 'TelescopePromptTitle',  { fg = accent, bold = true })
      set(0, 'TelescopePromptBorder', { fg = accent })

      -- gitsigns
      set(0, 'GitSignsAdd',          { fg = green })
      set(0, 'GitSignsChange',       { fg = yellow })
      set(0, 'GitSignsDelete',       { fg = red })

      -- diffview
      set(0, 'DiffviewFilePanelTitle',   { fg = accent, bold = true })
      set(0, 'DiffviewFilePanelCounter', { fg = accent })
    end,
  },
}
